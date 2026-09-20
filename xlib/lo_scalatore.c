/* ============================================================================
 * Lo Scalatore (The Hardhat Climber)
 * di Chris Lesher
 *
 * First appeared on Compute's Gazette Jan 84
 * Pubblicato in italia su SuperVIC n.1 giugno 1984
 * trad. e adatt. E. Comini
 *
 * Digitato da saver71
 * Primo porting C (Z88DK) e successivo porting CROSS-LIB
 *
 * ============================================================================
 * CROSS-LIB PORT
 * ============================================================================
 *
 * This file is a hardware-agnostic CROSS-LIB port of the original VIC-20
 * BASIC game. It builds for any CROSS-LIB target; the geometry matches the
 * authentic VIC-20 playfield (22 columns x 23 rows).
 *
 * HOW TO BUILD FOR THE VIC-20:
 *   1. Clone https://github.com/Fabrizio-Caruso/CROSS-LIB
 *   2. Create a game directory, e.g. src/games/lo_scalatore/, containing:
 *        - this file as main.c
 *        - tiles/ and shapes/ assets (bitmaps are in the comment block below)
 *        - config/, Makefile.lo_scalatore (copy the pattern from games/trex/)
 *   3. From the src/ directory run:  xl lo_scalatore vic20
 *
 * The original game reads back its own screen memory (PEEK) for logic; this
 * port keeps an explicit tile grid and renders it through _XL_DRAW instead.
 *
 * ----------------------------------------------------------------------------
 * ORIGINAL VIC-20 CHARACTER BITMAPS (BASIC lines 101-103), for tiles/8x8/:
 *   beam    (56): 255,255,153,102,102,153,255,255
 *   ladder  (57): 195,255,255,195,195,255,255,195
 *   player  (58): 60,60,25,255,188,60,36,231
 *   bomb    (59): 3,4,24,24,60,126,126,60   (unused by the original)
 *   barrel  (60): 60,66,165,153,153,165,66,60
 *   bag     (61): 0,24,36,126,126,126,126,0
 *   space   (62): 0,0,0,0,0,0,0,0           (walkable empty)
 *   trigger (63): 0,0,0,0,0,0,0,0           (invisible deviation trigger)
 * ----------------------------------------------------------------------------
 */

#include "cross_lib.h"

/* ============================================================================
 * SCREEN GEOMETRY
 * ============================================================================
 *
 * The level layout is hard-wired to the original VIC-20 grid (22x23).
 * Targets with at least that many tiles get the full game; smaller ones
 * print a message instead of drawing a broken playfield.
 */

#define GAME_COLS 22
#define GAME_ROWS 23

#if XSize >= GAME_COLS && YSize >= GAME_ROWS

#define OX ((XSize - GAME_COLS) / 2)  /* horizontal centering offset */
#define OY ((YSize - GAME_ROWS) / 2)  /* vertical centering offset   */

/* ============================================================================
 * TILES
 * ============================================================================
 * _TILE_n maps onto the game's assets. For VIC-20 builds the tile bitmaps
 * come from the DATA block quoted in the header comment.
 */

#define TILE_BEAM    _TILE_0
#define TILE_LADDER  _TILE_1
#define TILE_PLAYER  _TILE_2
#define TILE_BARREL  _TILE_3
#define TILE_BAG     _TILE_4
#define TILE_EMPTY   _TILE_5
/* trigger: never drawn (invisible in the original) */

/* ============================================================================
 * GRID CELL VALUES (logical state, not screen codes)
 * ============================================================================
 */

#define CELL_BEAM    0
#define CELL_LADDER  1
#define CELL_PLAYER  2
#define CELL_BARREL  3
#define CELL_BAG     4
#define CELL_SPACE   5  /* walkable empty */
#define CELL_TRIGGER 6  /* invisible deviation trigger */

/* ============================================================================
 * COLORS (VIC-20 palette approximated with the CROSS-LIB palette)
 * ============================================================================
 * d(0)=4 beam purple, d(1)=2 ladder red, d(4)=7 barrel yellow.
 * CROSS-LIB has no purple: beams use _XL_BLUE as the closest match.
 */

#define COLOR_BEAM    _XL_BLUE
#define COLOR_LADDER  _XL_RED
#define COLOR_BARREL  _XL_YELLOW
#define COLOR_BAG     _XL_WHITE
#define COLOR_PLAYER  _XL_WHITE
#define COLOR_TEXT    _XL_WHITE

/* ============================================================================
 * INPUT CODES (mapped from _XL_INPUT() onto the original BASIC codes)
 * ============================================================================
 * BASIC line 20: on peek(1) goto 35,26,28,31,33  (fire,down,left,up,right)
 */

#define INPUT_NONE  0
#define INPUT_FIRE  1  /* jump  */
#define INPUT_DOWN  2  /* down  */
#define INPUT_LEFT  3  /* left  */
#define INPUT_UP    4  /* up    */
#define INPUT_RIGHT 5  /* right */

/* ============================================================================
 * EVENT CODES
 * ============================================================================
 */

#define EVENT_NONE         0
#define EVENT_DEATH        1
#define EVENT_NEWLEVEL     2
#define EVENT_NEWBARREL    3
#define EVENT_MANOUTSIDE   4
#define EVENT_RESTARTLEVEL 5
#define EVENT_GAMEOVER     6

/* ============================================================================
 * SOUND MAPPINGS
 * ============================================================================
 * BASIC: 35 poke 36876,240 (jump), 40 poke 36876,200 (move beep),
 *        66 (barrel bonus), 56 poke 36874,so (death fall)
 */

#define SOUND_MOVE         0
#define SOUND_JUMP         1
#define SOUND_BAG          2
#define SOUND_BARREL_BONUS 3
#define SOUND_DEATH        4

/* ============================================================================
 * GAME STATE
 * ============================================================================
 */

/* Explicit grid: the original PEEKs screen RAM, we keep our own copy. */
static uint8_t grid[GAME_ROWS][GAME_COLS];

/*
 * Player:
 * s  = grid position (row-major index)
 * t  = cell content under the player
 * di = current walking direction (-1 left, +1 right)
 */
static uint16_t s;
static uint8_t  t;
static signed char di;   /* CROSS-LIB guarantees uint8_t/uint16_t only */

/*
 * Barrel:
 * v      = grid position
 * w      = cell content under the barrel
 * b(11)  = grid offsets of the 12 barrels in the pyramid
 * y      = 0..11 index of the rolling barrel
 * do_dir = current barrel direction (-1, +1, +GAME_COLS)
 */
static uint16_t v;
static uint8_t  w;
static signed char do_dir; /* -1, +1, or +GAME_COLS while falling */
static uint8_t  y;

/*
 * BASIC line 100: DATA ,1,21,22,23,24,42,43,44,45,46,47
 * The pyramid occupies rows 1-3, columns 8-15 (row-major from row 1 col 10).
 */
static const uint8_t b[12] = {
    1 * GAME_COLS + 10, 1 * GAME_COLS + 11,
    2 * GAME_COLS + 9,  2 * GAME_COLS + 10, 2 * GAME_COLS + 11, 2 * GAME_COLS + 12,
    3 * GAME_COLS + 8,  3 * GAME_COLS + 9,  3 * GAME_COLS + 10, 3 * GAME_COLS + 11,
    3 * GAME_COLS + 12, 3 * GAME_COLS + 13
};

/*
 * Score and game state:
 * h  = bags collected (max 16)
 * ss = score
 * sc = level
 * ch = lives (starts at 2 => 3 lives)
 */
static uint8_t  h;
static uint16_t ss;
static uint8_t  sc;
static signed char ch;   /* lives, starts at 2 => 3 lives */
static uint16_t next_bonus_score;

/*
 * Level generation:
 * e1 = random holes per beam (max 8, +1 per level)
 * e2 = % chance of broken ladders (triggers), +5% per level
 */
static uint8_t  e1;
static uint8_t  e2;

/* ============================================================================
 * GRID ACCESS
 * ============================================================================
 * The original addresses screen RAM linearly (0..505); we keep the same
 * addressing on top of the 2D grid so the BASIC line references hold.
 */

#define GRID_SIZE (GAME_ROWS * GAME_COLS)

static uint8_t grid_read(uint16_t addr)
{
    if(addr < GRID_SIZE)
    {
        return grid[addr / GAME_COLS][addr % GAME_COLS];
    }
    return CELL_SPACE;
}

static void grid_write(uint16_t addr, uint8_t cell)
{
    if(addr < GRID_SIZE)
    {
        grid[addr / GAME_COLS][addr % GAME_COLS] = cell;
    }
}

/* ============================================================================
 * DRAW HELPERS
 * ============================================================================
 */

static uint8_t cell_to_tile(uint8_t cell)
{
    switch(cell)
    {
        case CELL_BEAM:   return TILE_BEAM;
        case CELL_LADDER: return TILE_LADDER;
        case CELL_PLAYER: return TILE_PLAYER;
        case CELL_BARREL: return TILE_BARREL;
        case CELL_BAG:    return TILE_BAG;
        default:          return TILE_EMPTY;
    }
}

static uint8_t cell_to_color(uint8_t cell)
{
    switch(cell)
    {
        case CELL_BEAM:   return COLOR_BEAM;
        case CELL_LADDER: return COLOR_LADDER;
        case CELL_BARREL: return COLOR_BARREL;
        case CELL_BAG:    return COLOR_BAG;
        case CELL_PLAYER: return COLOR_PLAYER;
        default:          return COLOR_TEXT;
    }
}

/* Draw one grid cell on screen (trigger cells stay invisible). */
static void draw_cell(uint16_t addr)
{
    uint8_t cell = grid_read(addr);

    if(cell == CELL_TRIGGER)
    {
        _XL_DRAW(OX + (uint8_t)(addr % GAME_COLS),
                 OY + (uint8_t)(addr / GAME_COLS),
                 TILE_EMPTY, COLOR_TEXT);
        return;
    }
    _XL_DRAW(OX + (uint8_t)(addr % GAME_COLS),
             OY + (uint8_t)(addr / GAME_COLS),
             cell_to_tile(cell), cell_to_color(cell));
}

/* ============================================================================
 * HUD
 * ============================================================================
 * BASIC line 73: print "{rvon}"tab(8-len(str$(ss)))ss;tab(14)ch;tab(17)sc
 * plus poke 7697,163 (reverse-video '#' marker).
 * CROSS-Lib strings are letters/digits/space only: score, lives and level
 * are printed with _XL_PRINTD, the '#' marker becomes a "LV" label.
 */

#define HUD_ROW      0
#define SCORE_X      0
#define LIVES_X      13
#define LEVEL_LBL_X  15
#define LEVEL_X      18

static void draw_score_bar(void)
{
    _XL_SET_TEXT_COLOR(COLOR_TEXT);
    _XL_PRINTD(SCORE_X, HUD_ROW, 5, ss);
    _XL_PRINTD(LIVES_X, HUD_ROW, 1, (uint16_t) (ch < 0 ? 0 : ch));
    _XL_PRINT(LEVEL_LBL_X, HUD_ROW, "LV");
    _XL_PRINTD(LEVEL_X, HUD_ROW, 2, (uint16_t) sc);
}

/* ============================================================================
 * RANDOM (CROSS-LIB)
 * ============================================================================
 */

static uint16_t rnd(uint16_t max)
{
    if(max == 0)
    {
        return 0;
    }
    return (uint16_t) (_XL_RAND() % max);
}

/* Random percentage 0..99 */
static uint8_t rnd_percent(void)
{
    return (uint8_t) rnd(100);
}

/* ============================================================================
 * SOUND
 * ============================================================================
 */

static void play_sound(uint8_t sound_id)
{
    switch(sound_id)
    {
        case SOUND_MOVE:
            _XL_TICK_SOUND();
            break;
        case SOUND_JUMP:
            _XL_PING_SOUND();
            break;
        case SOUND_BAG:
            _XL_TOCK_SOUND();
            break;
        case SOUND_BARREL_BONUS:
            _XL_SHOOT_SOUND();
            break;
        case SOUND_DEATH:
            _XL_EXPLOSION_SOUND();
            break;
        default:
            break;
    }
}

/* ============================================================================
 * INPUT
 * ============================================================================
 * BASIC lines 20-35 read the joystick via the SYS 828 machine routine:
 * 0 none, 1 fire, 2 down, 3 left, 4 up, 5 right.
 */

static uint8_t input_player(void)
{
    uint16_t j = _XL_INPUT();

    if(_XL_FIRE(j))
    {
        return INPUT_FIRE;
    }
    if(_XL_DOWN(j))
    {
        return INPUT_DOWN;
    }
    if(_XL_LEFT(j))
    {
        return INPUT_LEFT;
    }
    if(_XL_UP(j))
    {
        return INPUT_UP;
    }
    if(_XL_RIGHT(j))
    {
        return INPUT_RIGHT;
    }
    return INPUT_NONE;
}

/* ============================================================================
 * LEVEL GENERATION
 * ============================================================================
 * BASIC lines 70-90. Beam rows are 7, 12, 17, 22; the bottom beam (row 22)
 * hosts the player, the other three get ladders, holes and bags.
 */

static void draw_level(void)
{
    uint16_t i, m, r, n;
    uint8_t  o, row_idx;

    /* 70 print "{clr}{pur}"; for n=1 to 21:print a$:next: print a$"{home}" */
    for(i = 0; i < GRID_SIZE; ++i)
    {
        grid_write(i, CELL_SPACE);
    }

    /*
     * 71 Pyramid support (rows 2-5, columns 6-15):
     * row 2: trigger, 8 spaces, trigger
     * row 3: ladder, 8 beams, ladder
     * rows 4-5: ladders at the sides, spaces in the middle
     */
    grid_write(2 * GAME_COLS + 6, CELL_TRIGGER);
    for(i = 7; i <= 14; ++i)
    {
        grid_write(2 * GAME_COLS + i, CELL_SPACE);
    }
    grid_write(2 * GAME_COLS + 15, CELL_TRIGGER);

    grid_write(3 * GAME_COLS + 6, CELL_LADDER);
    for(i = 7; i <= 14; ++i)
    {
        grid_write(3 * GAME_COLS + i, CELL_BEAM);
    }
    grid_write(3 * GAME_COLS + 15, CELL_LADDER);

    for(row_idx = 4; row_idx <= 5; ++row_idx)
    {
        grid_write(row_idx * GAME_COLS + 6, CELL_LADDER);
        for(i = 7; i <= 14; ++i)
        {
            grid_write(row_idx * GAME_COLS + i, CELL_SPACE);
        }
        grid_write(row_idx * GAME_COLS + 15, CELL_LADDER);
    }

    /*
     * 72 for n=1 to 3: print b$"{down}{down}{down}{down}": next: printb$"{home}";
     * Four beams at rows 7, 12, 17, 22: one space, 20 beams, one space.
     */
    for(row_idx = 0; row_idx < 4; ++row_idx)
    {
        uint16_t beam_start = (uint16_t) ((7 + row_idx * 5) * GAME_COLS);
        grid_write(beam_start, CELL_SPACE);
        for(i = 1; i <= 20; ++i)
        {
            grid_write(beam_start + i, CELL_BEAM);
        }
        if(beam_start + 21 < GRID_SIZE)
        {
            grid_write(beam_start + 21, CELL_SPACE);
        }
    }

    /* 72 poke 8185,62: bottom-right corner space (keeps the man inside) */
    grid_write(22 * GAME_COLS + 21, CELL_SPACE);

    /* 73 score bar */
    draw_score_bar();

    /*
     * 73-74 for n=0 to 11: poke 7712+b(n),60: poke 7712+b(n)+g,7: next
     * 7712 - 7680 = 32 (row 1, column 10)
     */
    for(n = 0; n < 12; ++n)
    {
        grid_write(32 + b[n], CELL_BARREL);
    }

    /*
     * 74 for n=7834 to 8164 step 110: beams at offsets 154, 264, 374
     * (the fourth beam, at 484, gets no descending ladders)
     */
    for(n = 154; n <= 374; n += 5 * GAME_COLS)
    {
        /* 75-79: three ladders per beam */
        for(o = 1; o <= 3; ++o)
        {
            /* 76 r=n+1+int(rnd(1)*20): if peek(r)<>56 then 76 */
            do
            {
                r = n + 1 + rnd(20);
            }
            while(grid_read(r) != CELL_BEAM);

            /* 77 for m=r to r+88 step 22: poke m,57: poke m+g,2: next */
            for(m = r; m <= r + 4 * GAME_COLS; m += GAME_COLS)
            {
                grid_write(m, CELL_LADDER);
            }

            /*
             * 77 if o>1 and rnd(1)<e2 then poke r+(int(rnd(1)*2)+2)*22,63
             * Broken ladder: trigger at a random height.
             */
            if(o > 1 && rnd_percent() < e2)
            {
                grid_write(r + (rnd(2) + 2) * GAME_COLS, CELL_TRIGGER);
            }

            /*
             * 78 if rnd(1)<.5 and peek(r-22)=62 then poke r-22,63
             * 50% chance of a trigger on top of the ladder.
             */
            if(rnd_percent() < 50 && grid_read(r - GAME_COLS) == CELL_SPACE)
            {
                grid_write(r - GAME_COLS, CELL_TRIGGER);
            }
        }
    }

    /*
     * 80-85: holes in the beams (e1 of them per beam)
     * 80 for o=1 to e1 / 81 r=n+3+int(rnd(1)*16)
     */
    for(n = 154; n <= 484; n += 5 * GAME_COLS)
    {
        for(o = 0; o < e1; ++o)
        {
            r = n + 3 + rnd(16);
            /*
             * 81 if peek(r)<>56 or peek(r-22)<>62
             *      or peek(r+1)=62 or peek(r-1)=62 then 85
             */
            if(grid_read(r) != CELL_BEAM ||
               grid_read(r - GAME_COLS) != CELL_SPACE ||
               grid_read(r + 1) == CELL_SPACE ||
               grid_read(r - 1) == CELL_SPACE)
            {
                continue;
            }
            /* 84 poke r,62: poke r-22,63 */
            grid_write(r, CELL_SPACE);
            grid_write(r - GAME_COLS, CELL_TRIGGER);
        }

        /*
         * 86-88: four bags per beam
         * 87 r=n-21+int(rnd(1)*20): if peek(r)<>62 or peek(r+22)=62 then 87
         */
        for(o = 0; o < 4; ++o)
        {
            do
            {
                r = n - GAME_COLS + 1 + rnd(20);
            }
            while(grid_read(r) != CELL_SPACE || grid_read(r + GAME_COLS) == CELL_SPACE);

            /* 88 poke r,61: poke r+g,0 */
            grid_write(r, CELL_BAG);
        }
    }

    /*
     * 89: triggers beside the barrel pyramid
     * 7710-7680=30 (row 1 col 8), 7715-7680=35 (row 1 col 13),
     * 7731-7680=51 (row 2 col 7), 7738-7680=58 (row 2 col 14)
     */
    grid_write(30, CELL_TRIGGER);
    grid_write(35, CELL_TRIGGER);
    grid_write(51, CELL_TRIGGER);
    grid_write(58, CELL_TRIGGER);

    /*
     * 90: triggers at the beam ends
     * for n=7812 to 8142 step 110 (left ends, offset 132)
     * for n=7833 to 8163 step 110 (right ends, offset 153)
     */
    for(n = 132; n <= 462; n += 5 * GAME_COLS)
    {
        grid_write(n, CELL_TRIGGER);
    }
    for(n = 153; n <= 483; n += 5 * GAME_COLS)
    {
        grid_write(n, CELL_TRIGGER);
    }

    /* Full repaint */
    for(i = 0; i < GRID_SIZE; ++i)
    {
        draw_cell(i);
    }
    _XL_REFRESH();
}

/* ============================================================================
 * SPAWNING
 * ============================================================================
 */

/*
 * spawn_player(): BASIC lines 16-17.
 * 16 s=8143+int(rnd(1)*20): if peek(s+22)=62 or peek(s)=59 then 16
 * 8143 - 7680 = 463 (row 21, column 1)
 */
static void spawn_player(void)
{
    /*
     * The original also retried while peek(s)=59 (the unused bomb character);
     * bombs never spawn, so that check has no cell to test here.
     */
    do
    {
        s = 463 + rnd(20);
    }
    while(grid_read(s + GAME_COLS) == CELL_SPACE);

    /* 17 t=peek(s): poke s,58: poke s+g,0 */
    t = grid_read(s);
    grid_write(s, CELL_PLAYER);
    draw_cell(s);

    /* 1 di=do(int(rnd(1)*2)): random initial direction */
    di = (rnd(2) == 0) ? (signed char) -1 : (signed char) 1;
}

/*
 * spawn_barrel(): BASIC line 19.
 * 19 v=7712+b(y): w=62: do=do(int(rnd(1)*2))
 */
static void spawn_barrel(void)
{
    v = 32 + b[y];
    w = CELL_SPACE;
    do_dir = (rnd(2) == 0) ? (signed char) -1 : (signed char) 1;
}

/* ============================================================================
 * SCORE / LIVES
 * ============================================================================
 */

/*
 * check_bonus_life(): BASIC line 98.
 * The original 'if ss=q*e3' often skipped the exact multiple; the port uses
 * '>=' so the bonus actually fires (documented fix).
 */
static void check_bonus_life(void)
{
    if(ss >= next_bonus_score)
    {
        ++ch;
        next_bonus_score += 10000;
        draw_score_bar();
    }
}

/* ============================================================================
 * DEATH
 * ============================================================================
 */

/*
 * player_death(): BASIC lines 55-62. Falls the player down to the next beam
 * (or off screen), deducts a life and decides what happens next.
 */
static uint8_t player_death(void)
{
    play_sound(SOUND_DEATH);

    /* 55 if t=60 then t=w */
    if(t == CELL_BARREL)
    {
        t = w;
    }

    /*
     * 56-57: fall until a beam is under the player or the screen ends.
     * if peek(s+22)<>56 and s<8164 then ... (8164-7680 = 484)
     */
    while(grid_read(s + GAME_COLS) != CELL_BEAM && s < 484)
    {
        grid_write(s, t);
        draw_cell(s);
        s += GAME_COLS;
        t = grid_read(s);
        grid_write(s, CELL_PLAYER);
        draw_cell(s);
        _XL_SLOW_DOWN(17 * _XL_SLOW_DOWN_FACTOR);
    }

    /* 58 ch=ch-1: if ch=-1 then game over */
    --ch;
    if(ch < 0)
    {
        return EVENT_GAMEOVER;
    }

    /* 59 print "{home}{rvon}"tab(14)ch */
    draw_score_bar();

    /* 59 poke v,w: poke v+g,d(w-j): remove the rolling barrel */
    grid_write(v, w);
    draw_cell(v);
    ++y;

    /* 59 if w=58 then pokev,t: pokev+g,d(t-j) */
    if(w == CELL_PLAYER)
    {
        grid_write(v, t);
        draw_cell(v);
    }

    /* 60 if y>10 then 15: all barrels gone, restart the level */
    if(y > 10)
    {
        return EVENT_RESTARTLEVEL;
    }

    /* 61 if s>8163 then (8163-7680 = 483): player fell off screen */
    if(s > 483)
    {
        grid_write(s, t);
        draw_cell(s);
        return EVENT_MANOUTSIDE;
    }

    /* 62 poke s,58: poke s+g,0 */
    grid_write(s, CELL_PLAYER);
    draw_cell(s);
    return EVENT_NEWBARREL;
}

/* ============================================================================
 * LEVEL CLEARED
 * ============================================================================
 */

/*
 * level_cleared(): BASIC lines 64-68. Counts remaining barrels for points,
 * then raises the difficulty for the next level.
 */
static void level_cleared(void)
{
    uint8_t n;

    /* 65 for n=y+1 to 11: clear the barrel, award 100 points */
    if(y < 11)
    {
        for(n = (uint8_t) (y + 1); n < 12; ++n)
        {
            grid_write(32 + b[n], CELL_SPACE);
            draw_cell(32 + b[n]);
            ss += 100;
            draw_score_bar();
            check_bonus_life();
            play_sound(SOUND_BARREL_BONUS);
            _XL_SLOW_DOWN(5 * _XL_SLOW_DOWN_FACTOR);
        }
    }

    /*
     * 67 e2=e2+.05 (5% more broken ladders)
     *    sc=sc+1   (next level)
     *    e1=e1+1   (one more hole, max 8)
     */
    e2 += 5;
    ++sc;
    ++e1;
    if(e1 > 8)
    {
        e1 = 8;
    }
}

/* ============================================================================
 * PLAYER MOVEMENT
 * ============================================================================
 */

/*
 * move_player(): BASIC lines 20-43.
 * Returns EVENT_NONE, EVENT_DEATH or EVENT_NEWLEVEL.
 */
static uint8_t move_player(uint8_t input_cmd)
{
    switch(input_cmd)
    {
        case INPUT_FIRE:
            /*
             * 35 poke 36876,240 / poke s,t / s=s-22+di
             */
            play_sound(SOUND_JUMP);
            grid_write(s, t);
            draw_cell(s);
            s = (uint16_t) (s - GAME_COLS + di);
            t = grid_read(s);
            grid_write(s, CELL_PLAYER);
            draw_cell(s);

            /* 35 if t=60 then 55: jumped into a barrel */
            if(t == CELL_BARREL)
            {
                return EVENT_DEATH;
            }

            /* 36 if peek(s+22)=60 then ss=ss+1000: jumped over a barrel */
            if(grid_read(s + GAME_COLS) == CELL_BARREL)
            {
                ss += 1000;
                draw_score_bar();
            }

            /* 37 for n=1 to 5:next: keep the jump visible */
            _XL_SLOW_DOWN(5 * _XL_SLOW_DOWN_FACTOR);

            /* 37 s=s+22+di: fall back down */
            grid_write(s, t);
            draw_cell(s);
            s = (uint16_t) (s + GAME_COLS + di);
            t = grid_read(s);
            grid_write(s, CELL_PLAYER);
            draw_cell(s);

            /* 37 if peek(s+22)>61 then 55: jumped into the void */
            if(grid_read(s + GAME_COLS) > CELL_BAG)
            {
                return EVENT_DEATH;
            }
            break;

        case INPUT_DOWN:
            /* 26 if peek(s+22)=z then s=s+22 */
            if(grid_read(s + GAME_COLS) == CELL_LADDER)
            {
                grid_write(s, t);
                draw_cell(s);
                s += GAME_COLS;
                play_sound(SOUND_MOVE);
                t = grid_read(s);
                grid_write(s, CELL_PLAYER);
                draw_cell(s);
            }
            break;

        case INPUT_LEFT:
            /* 28 di=-1: if peek(s+21)<62 then s=s-1 */
            di = -1;
            if(grid_read(s + GAME_COLS - 1) < CELL_SPACE)
            {
                grid_write(s, t);
                draw_cell(s);
                --s;
                play_sound(SOUND_MOVE);
                t = grid_read(s);
                grid_write(s, CELL_PLAYER);
                draw_cell(s);
            }
            else if(t != CELL_LADDER)
            {
                /* 29: walking into the void */
                grid_write(s, t);
                draw_cell(s);
                s = (uint16_t) (s + di);
                t = grid_read(s);
                return EVENT_DEATH;
            }
            break;

        case INPUT_UP:
            /* 31 if t=z then s=s-22 */
            if(t == CELL_LADDER)
            {
                grid_write(s, t);
                draw_cell(s);
                s -= GAME_COLS;
                play_sound(SOUND_MOVE);
                t = grid_read(s);
                grid_write(s, CELL_PLAYER);
                draw_cell(s);
            }
            break;

        case INPUT_RIGHT:
            /* 33 di=1: if peek(s+23)<62 then s=s+1 */
            di = 1;
            if(grid_read(s + GAME_COLS + 1) < CELL_SPACE)
            {
                grid_write(s, t);
                draw_cell(s);
                ++s;
                play_sound(SOUND_MOVE);
                t = grid_read(s);
                grid_write(s, CELL_PLAYER);
                draw_cell(s);
            }
            else if(t != CELL_LADDER)
            {
                /* 34 goto 29: walking into the void */
                grid_write(s, t);
                draw_cell(s);
                s = (uint16_t) (s + di);
                t = grid_read(s);
                return EVENT_DEATH;
            }
            break;

        case INPUT_NONE:
        default:
            /* 21 for n=1 to 23:next: idle delay */
            _XL_SLOW_DOWN(23 * _XL_SLOW_DOWN_FACTOR);
            break;
    }

    /*
     * 41 if t=61: bag collected
     * ss=ss+150: h=h+1: t=62: if h=16 then 64 (level cleared)
     */
    if(t == CELL_BAG)
    {
        ss += 150;
        draw_score_bar();
        ++h;
        t = CELL_SPACE;
        play_sound(SOUND_BAG);
        if(h == 16)
        {
            return EVENT_NEWLEVEL;
        }
    }

    /* 42 if t=60 then 55: walked into a barrel */
    if(t == CELL_BARREL)
    {
        return EVENT_DEATH;
    }

    /* 43 gosub 98: bonus life check */
    check_bonus_life();

    return EVENT_NONE;
}

/* ============================================================================
 * BARREL MOVEMENT
 * ============================================================================
 */

/*
 * move_barrel(): BASIC lines 45-51.
 * Returns EVENT_NONE, EVENT_DEATH or EVENT_NEWBARREL.
 */
static uint8_t move_barrel(void)
{
    /* 45 poke v,w: v=v+do: w=peek(v): poke v,60 */
    grid_write(v, w);
    draw_cell(v);
    v = (uint16_t) (v + do_dir);
    w = grid_read(v);
    grid_write(v, CELL_BARREL);
    draw_cell(v);

    /*
     * 46 if do=22 and peek(v+22)=56 then do=do(int(rnd(1)*2))
     * Falling barrel landing on a beam: pick a random side.
     */
    if(do_dir == GAME_COLS && grid_read(v + GAME_COLS) == CELL_BEAM)
    {
        do_dir = (rnd(2) == 0) ? (signed char) -1 : (signed char) 1;
    }
    else if(w == CELL_TRIGGER)
    {
        /* 47 if w=63 then do=22: trigger hit, start falling */
        do_dir = GAME_COLS;
    }

    /* 48 if w=58 then 55: barrel hit the player */
    if(w == CELL_PLAYER)
    {
        return EVENT_DEATH;
    }

    /* 49 if v<8164 then 20: still on screen */
    if(v < 484)
    {
        return EVENT_NONE;
    }

    /* 50 y=y+1: if y=12 then 55: all 12 barrels gone */
    ++y;
    if(y == 12)
    {
        return EVENT_DEATH;
    }

    /* 51 poke v,62: clear the off-screen barrel, roll the next one */
    grid_write(v, CELL_SPACE);
    draw_cell(v);
    return EVENT_NEWBARREL;
}

/* ============================================================================
 * INTRO / GAME OVER
 * ============================================================================
 */

/* Centered-print helper: CROSS-LIB docs list _XL_PRINT_CENTERED_ON_ROW but
 * current library versions do not ship it — compute the x offset ourselves. */
static void print_centered(uint8_t row, const char *msg)
{
    uint8_t len = 0;
    const char *p;
    for(p = msg; *p; ++p)
    {
        ++len;
    }
    _XL_PRINT((uint8_t) ((XSize > len) ? (XSize - len) / 2 : 0), row, msg);
}

static void intro(void)
{
    _XL_CLEAR_SCREEN();
    _XL_SET_TEXT_COLOR(COLOR_TEXT);
    print_centered(2, "THE HARDHAT CLIMBER");
    print_centered(4, "BY CHRIS LESHER");
    print_centered(6, "COMPUTE GAZETTE JAN 1984");
    print_centered(9, "CROSS-LIB PORT");
    print_centered(12, "PRESS FIRE OR ANY KEY");
    _XL_REFRESH();
    _XL_WAIT_FOR_INPUT();
}

static void game_over(void)
{
    _XL_CLEAR_SCREEN();
    _XL_SET_TEXT_COLOR(COLOR_TEXT);
    print_centered(4, "GAME OVER");
    print_centered(7, "SCORE");
    _XL_PRINTD(XSize / 2 - 2, 9, 5, ss);
    _XL_REFRESH();
    _XL_WAIT_FOR_INPUT();
}

/* ============================================================================
 * MAIN GAME LOOP
 * ============================================================================
 * BASIC lines 3, 15-68.
 */

static void game_loop(void)
{
    uint8_t cmd, ev;
    uint8_t death_ev = EVENT_NONE;

    /* 3 sc=1, ch=2, e1=0, e2=0, q=10000, e3=1 */
    sc = 1;
    ch = 2;
    e1 = 0;
    e2 = 0;
    ss = 0;
    next_bonus_score = 10000;

    while(ch >= 0)
    {
        /* 15 gosub 70: draw the level, h=0, y=0 */
        draw_level();
        h = 0;
        y = 0;

        /* 16: place the player on the bottom beam */
        spawn_player();

        /* Loop over the 12 barrels */
        while(1)
        {
            /* 19: start rolling the next barrel */
            spawn_barrel();

            /* Frame loop: player move, then barrel move */
            while(1)
            {
                cmd = input_player();
                ev = move_player(cmd);

                if(ev == EVENT_DEATH)
                {
                    death_ev = player_death();
                    if(death_ev == EVENT_GAMEOVER)
                    {
                        return;
                    }
                    if(death_ev == EVENT_RESTARTLEVEL)
                    {
                        break;
                    }
                    if(death_ev == EVENT_MANOUTSIDE)
                    {
                        spawn_player();
                        spawn_barrel();
                        continue;
                    }
                    if(death_ev == EVENT_NEWBARREL)
                    {
                        spawn_barrel();
                        continue;
                    }
                }
                else if(ev == EVENT_NEWLEVEL)
                {
                    level_cleared();
                    break;
                }

                ev = move_barrel();
                if(ev == EVENT_DEATH)
                {
                    death_ev = player_death();
                    if(death_ev == EVENT_GAMEOVER)
                    {
                        return;
                    }
                    if(death_ev == EVENT_RESTARTLEVEL)
                    {
                        break;
                    }
                    if(death_ev == EVENT_MANOUTSIDE)
                    {
                        spawn_player();
                        spawn_barrel();
                        continue;
                    }
                    if(death_ev == EVENT_NEWBARREL)
                    {
                        spawn_barrel();
                        continue;
                    }
                }
                else if(ev == EVENT_NEWBARREL)
                {
                    spawn_barrel();
                }

                _XL_WAIT_VSYNC();
                _XL_REFRESH();
            }

            if(ev == EVENT_NEWLEVEL || death_ev == EVENT_RESTARTLEVEL)
            {
                break;
            }
        }
    }
}

/* ============================================================================
 * ENTRY POINT
 * ============================================================================
 */

int main(void)
{
    _XL_INIT_GRAPHICS();
    _XL_INIT_SOUND();
    _XL_INIT_INPUT();

    while(1)
    {
        intro();
        game_loop();
        game_over();
    }
    return 0; /* never reached, keeps some compilers happy */
}

#else /* screen too small for the 22x23 playfield */

int main(void)
{
    _XL_INIT_GRAPHICS();
    _XL_INIT_INPUT();
    _XL_CLEAR_SCREEN();
    _XL_SET_TEXT_COLOR(_XL_WHITE);
    _XL_PRINT(0, 0, "SCREEN TOO SMALL");
    _XL_REFRESH();
    for(;;)
    {
    }
    return 0;
}

#endif /* XSize/YSize check */
