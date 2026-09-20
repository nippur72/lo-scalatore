/* ============================================================================
 * Lo Scalatore (The Hardhat Climber)
 * di Chris Lesher
 * 
 * First appeared on Compute's Gazette Jan 84
 * Pubblicato in italia su SuperVIC n.1 giugno 1984 
 * trad. e adatt. E. Comini
 *
 * Digitato da saver71
 * Porting C per Z80 (compilatore Z88DK) per computer generico
 * ============================================================================
 */

#include <stdint.h>

/* ============================================================================
 * TIPI E DEFINIZIONI SCHERMO / HARDWARE GENERICO
 * ============================================================================
 */

#ifndef uint8_t
typedef unsigned char  uint8_t;
typedef unsigned short uint16_t;
typedef signed char    int8_t;
typedef signed short   int16_t;
#endif

/* Dimensioni schermo a matrice di caratteri */
#define SCREEN_COLS 22
#define SCREEN_ROWS 23
#define SCREEN_SIZE (SCREEN_COLS * SCREEN_ROWS)

/*
 * Caratteri ridefiniti (nessun magic number)
 * 8 trave     (56)
 * 9 scala     (57)
 * : omino     (58)
 * ; bomba     (59) (nel sorgente c'è il controllo omino su bomba, ma questo carattere non viene mai usato)
 * < barile    (60)
 * = borsa     (61)
 * > spazio    (62) (spazio calpestabile)
 * ? deviatore (63) (spazio invisibile trigger/deviatore, per deviare il barile a fine trave o scale interrotte)
 */
#define CHR_BEAM    56  /* Trave (8) */
#define CHR_LADDER  57  /* Scala (9) */
#define CHR_PLAYER  58  /* Omino (:) */
#define CHR_BOMB    59  /* Bomba (;) */
#define CHR_BARREL  60  /* Barile (<) */
#define CHR_BAG     61  /* Borsa (=) */
#define CHR_SPACE   62  /* Spazio calpestabile (>) */
#define CHR_TRIGGER 63  /* Deviatore invisibile (?) */

/* Colori VIC-20 standard (utilizzati nei parametri color per astrazione video) */
#define COLOR_BLACK   0
#define COLOR_WHITE   1
#define COLOR_RED     2
#define COLOR_CYAN    3
#define COLOR_PURPLE  4
#define COLOR_GREEN   5
#define COLOR_BLUE    6
#define COLOR_YELLOW  7

/* Codici di input per input_player() */
#define INPUT_NONE  0
#define INPUT_FIRE  1  /* Salto */
#define INPUT_DOWN  2  /* Sotto */
#define INPUT_LEFT  3  /* Sinistra */
#define INPUT_UP    4  /* Sopra */
#define INPUT_RIGHT 5  /* Destra */

/* Identificatori eventi interni */
#define EVENT_NONE         0
#define EVENT_DEATH        1
#define EVENT_NEWLEVEL     2
#define EVENT_NEWBARREL    3
#define EVENT_MANOUTSIDE   4
#define EVENT_RESTARTLEVEL 5
#define EVENT_GAMEOVER     6

/* Identificatori suoni per play_sound() */
#define SOUND_MUTE         0
#define SOUND_MOVE         1
#define SOUND_JUMP         2
#define SOUND_BAG          3
#define SOUND_BARREL_BONUS 4
#define SOUND_DEATH        5

/* ============================================================================
 * VARIABILI STATICHE GLOBALI
 * ============================================================================
 */

/* Matrice memoria video schermo */
static uint8_t screen[SCREEN_SIZE];

/*
 * Relativi all'omino:
 * s  = locazione video omino (player_pos)
 * t  = carattere sotto l'omino (player_under_char)
 * di = direzione corrente omino destra/sinistra (-1, +1) (player_dir)
 */
static uint16_t s;
static uint8_t  t;
static int8_t   di;

/*
 * Relativi al barile:
 * v      = posizione schermo del barile (barrel_pos)
 * w      = carattere sotto del barile (barrel_under_char)
 * b(11)  = offset schermo dei singoli barili nella pila (barrel_pyramid_offsets)
 * y      = 0..11 numero del barile che sta rotolando (barrel_idx)
 * do_dir = direzione corrente barile (-1, +1, +SCREEN_COLS) (barrel_dir)
 */
static uint16_t v;
static uint8_t  w;
static int8_t   do_dir;
static uint8_t  y;

/*
 * Posizioni dei 12 barili nella pila (vettore b) a partire dal barile più in alto a sinistra
 * BASIC riga 100: DATA ,1,21,22,23,24,42,43,44,45,46,47
 * La pila occupa le righe 1-3, colonne 10-15 (offset 0 = riga 0 colonna 0)
 * Riga 1: colonne 10-11 (32, 33)
 * Riga 2: colonne 9-12 (53, 54, 55, 56)
 * Riga 3: colonne 8-13 (74, 75, 76, 77, 78, 79)
 */
static const uint8_t b[12] = {
    1 * SCREEN_COLS + 10, 1 * SCREEN_COLS + 11,
    2 * SCREEN_COLS + 9,  2 * SCREEN_COLS + 10, 2 * SCREEN_COLS + 11, 2 * SCREEN_COLS + 12,
    3 * SCREEN_COLS + 8,  3 * SCREEN_COLS + 9,  3 * SCREEN_COLS + 10, 3 * SCREEN_COLS + 11,
    3 * SCREEN_COLS + 12, 3 * SCREEN_COLS + 13
};

/*
 * Relativi al punteggio e stato gioco:
 * h  = numero delle borse recuperate (max 16)
 * ss = score
 * sc = livello (screen)
 * ch = numero di vite (inizia da 2 per 3 vite)
 */
static uint8_t  h;
static uint16_t ss;
static uint8_t  sc;
static int8_t   ch;
static uint16_t next_bonus_score;

/*
 * Generazione del livello:
 * e1 = numero di buchi casuali sulle travi, max 8, si incrementa ad ogni livello
 * e2 = chance percentuale deviatori dei barili sulle scale (0..100%), aumenta del 5% ogni livello
 */
static uint8_t  e1;
static uint8_t  e2;

/* Seed generatore casuale */
static uint16_t rng_seed = 0x1234;

/* ============================================================================
 * PROTOTIPI DELLE FUNZIONI
 * ============================================================================
 */
static void     init_graph(void);
static void     play_sound(uint8_t sound_id);
static uint8_t  video_read(uint16_t address);
static void     video_write(uint16_t address, uint8_t ch_val, uint8_t color);
static uint8_t  input_player(void);
static uint8_t  get_char_color(uint8_t ch_val);
static uint16_t rnd(uint16_t max);
static uint8_t  rnd_percent(void);

static void     clear_screen(void);
static void     text_write(const char *message, uint8_t col, uint8_t row, uint8_t color);
static void     intro(void);
static void     game_over(void);
static void     draw_score_bar(void);
static void     draw_level(void);
static void     spawn_player(void);
static void     spawn_barrel(void);
static void     check_bonus_life(void);
static uint8_t  player_death(void);
static void     level_cleared(void);
static uint8_t  move_player(uint8_t input_cmd);
static uint8_t  move_barrel(void);
static void     game_loop(void);

/* ============================================================================
 * FUNZIONI HARDWARE ABSTRACTION LAYER (HAL) / VIDEO / SUONO / INPUT
 * ============================================================================
 */

/*
 * video_read(address)
 * Legge un carattere dalla memoria video (offset relativo 0..SCREEN_SIZE-1)
 */
static uint8_t video_read(uint16_t address) {
    if (address < SCREEN_SIZE) {
        return screen[address];
    }
    return CHR_SPACE;
}

/*
 * video_write(address, char, color)
 * Scrive un carattere nella memoria video e gestisce il colore associato.
 */
static void video_write(uint16_t address, uint8_t ch_val, uint8_t color) {
    (void)color; /* Parametro per estensioni hardware video specifiche */
    if (address < SCREEN_SIZE) {
        screen[address] = ch_val;
    }
}

/*
 * clear_screen()
 * Pulisce lo schermo cancellando tutti i caratteri (imposta spazi)
 */
static void clear_screen(void) {
    uint16_t i;
    for (i = 0; i < SCREEN_SIZE; i++) {
        video_write(i, ' ', COLOR_BLACK);
    }
}

/*
 * text_write(message, col, row, color)
 * Scrive una stringa di testo alla posizione (col, row) specificata.
 */
static void text_write(const char *message, uint8_t col, uint8_t row, uint8_t color) {
    uint16_t addr = (uint16_t)(row * SCREEN_COLS + col);
    while (*message && col < SCREEN_COLS && addr < SCREEN_SIZE) {
        video_write(addr, (uint8_t)(*message), color);
        message++;
        col++;
        addr++;
    }
}

/*
 * Restituisce il colore associato a ciascun carattere ridefinito (palette VIC-20)
 * d(0)=4 (trave), d(1)=2 (scala), d(4)=7 (barile), borsa=0, omino=0
 */
static uint8_t get_char_color(uint8_t ch_val) {
    switch (ch_val) {
        case CHR_BEAM:   return COLOR_PURPLE; /* d(0)=4 */
        case CHR_LADDER: return COLOR_RED;    /* d(1)=2 */
        case CHR_BARREL: return COLOR_YELLOW; /* d(4)=7 */
        case CHR_BAG:    return COLOR_BLACK;  /* Borsa */
        case CHR_PLAYER: return COLOR_BLACK;  /* Omino */
        default:         return COLOR_BLACK;
    }
}

/*
 * Inizializzazione grafica (Dummy HAL)
 *
 * Codice originale VIC-20:
 * 0 print "{clr}"          ' cancella schermo
 *   poke 51,192:poke 52,29 ' imposta la fine memoria a 7616 dove iniziano i caratteri definibili (56 ch)
 *   poke 55,192:poke 56,29 ' imposta la fine memoria a 7616 dove iniziano i caratteri definibili (56 ch)
 *   poke 36869,255         ' visualizza caratteri definibili a 7168
 *   poke 36878,15          ' volume del suono al massimo
 *   poke 36879,25          ' bordo e sfondo bianchi
 * 
 * Bitmap 8 caratteri ridefiniti (DATA riga 101-103):
 * 101 DATA 255,255,153,102,102,153,255,255 (56: Trave)
 *          195,255,255,195,195,255,255,195 (57: Scala)
 *          60,60,25,255,188,60,36,231       (58: Omino)
 * 102 DATA 3,4,24,24,60,126,126,60         (59: Bomba)
 *          60,66,165,153,153,165,66,60     (60: Barile)
 *          0,24,36,126,126,126,126,0       (61: Borsa)
 * 103 DATA 0,0,0,0,0,0,0,0                 (62: Spazio calpestabile)
 *          0,0,0,0,0,0,0,0                 (63: Deviatore invisibile)
 */
static void init_graph(void) {
    uint16_t i;
    for (i = 0; i < SCREEN_SIZE; i++) {
        screen[i] = CHR_SPACE;
    }
}

/*
 * Riproduzione suoni (Dummy HAL)
 *
 * Registri audio originali VIC-20:
 * poke 36878, 15          ' volume massimo
 * poke 36874, freq        ' voce 1 (bassi)
 * poke 36875, freq        ' voce 2 (medi)
 * poke 36876, freq        ' voce 3 (alti)
 * poke 36877, freq        ' voce 4 (rumore bianco)
 *
 * 35 poke 36876,240       ' salto
 * 40 poke 36876,200:poke 36876,0 ' beep spostamento
 * 66 poke 36877,250 / for m=240 to 250:poke 36876,m:next ' bonus barile
 * 56 poke 36874,so        ' suono caduta morte (da 250 a 150 a passi di -5)
 */
static void play_sound(uint8_t sound_id) {
    (void)sound_id;
    /* Da implementare per chip audio/beeper specifico Z80 */
}

/*
 * Lettura input giocatore (Dummy HAL)
 *
 * Routine originale VIC-20 (LM SYS 828):
 * 0 - Nessun tasto
 * 1 - Fire (Salto)
 * 2 - Sotto
 * 3 - Sinistra
 * 4 - Sopra
 * 5 - Destra
 */
static uint8_t input_player(void) {
    /* Da collegare ai registri di lettura tastiera / joystick I/O */
    return INPUT_NONE;
}

/* PRNG lineare a 16 bit intero veloce */
static uint16_t rnd(uint16_t max) {
    if (max == 0) return 0;
    rng_seed = (uint16_t)(rng_seed * 25173u + 13849u);
    return (uint16_t)(rng_seed % max);
}

/* Restituisce una percentuale casuale intera (0..99) */
static uint8_t rnd_percent(void) {
    return (uint8_t)rnd(100);
}

/* ============================================================================
 * FUNZIONI LOGICHE DI GIOCO
 * ============================================================================
 */

/*
 * Disegna la barra punteggio nella riga 0:
 * BASIC riga 73: print "{rvon}"tab(8-len(str$(ss)))ss;tab(14)ch;tab(17)sc
 * BASIC riga 73: poke 7697,163 (simbolo #)
 */
static void draw_score_bar(void) {
    uint16_t temp = ss;
    int8_t i;

    /* Pulisce le prime 8 colonne */
    for (i = 0; i < 8; i++) {
        video_write(i, CHR_SPACE, COLOR_PURPLE);
    }

    /* Scrive punteggio allineato a destra entro le prime 8 colonne */
    i = 7;
    if (temp == 0) {
        video_write(i, (uint8_t)'0', COLOR_PURPLE);
    } else {
        while (temp > 0 && i >= 0) {
            video_write(i, (uint8_t)('0' + (temp % 10)), COLOR_PURPLE);
            temp /= 10;
            i--;
        }
    }

    /* Vite alla colonna 14 */
    video_write(14, (uint8_t)('0' + (ch >= 0 ? ch : 0)), COLOR_PURPLE);

    /* Simbolo '#' alla colonna 16 */
    video_write(16, (uint8_t)'#', COLOR_PURPLE);

    /* Livello alla colonna 17-18 */
    if (sc >= 10) {
        video_write(17, (uint8_t)('0' + (sc / 10)), COLOR_PURPLE);
        video_write(18, (uint8_t)('0' + (sc % 10)), COLOR_PURPLE);
    } else {
        video_write(17, (uint8_t)('0' + sc), COLOR_PURPLE);
        video_write(18, CHR_SPACE, COLOR_PURPLE);
    }
}

/*
 * draw_level()
 * Disegna il livello in maniera completa (BASIC linee 70-90)
 */
static void draw_level(void) {
    uint16_t i, m, r, n;
    uint8_t  o, row_idx;

    /* 70 print "{clr}{pur}"; for n=1 to 21:print a$:next: print a$"{home}" */
    for (i = 0; i < SCREEN_SIZE; i++) {
        video_write(i, CHR_SPACE, COLOR_PURPLE);
    }

    /*
     * 71 print "{down}{down}"tab(6)"?>>>>>>>>?{red}"
     *    printtab(6)"9{pur}88888888{red}9"
     *    printtab(6)"9>>>>>>>>9"
     *    printtab(6)"9>>>>>>>>9{pur}"
     * Struttura supporto piramide barili (righe 2, 3, 4, 5, colonne 6..15)
     */
    /* Riga 2: deviatore, 8 spazi, deviatore */
    video_write(2 * SCREEN_COLS + 6, CHR_TRIGGER, COLOR_RED);
    for (i = 7; i <= 14; i++) {
        video_write(2 * SCREEN_COLS + i, CHR_SPACE, COLOR_RED);
    }
    video_write(2 * SCREEN_COLS + 15, CHR_TRIGGER, COLOR_RED);

    /* Riga 3: scala, 8 travi, scala */
    video_write(3 * SCREEN_COLS + 6, CHR_LADDER, COLOR_RED);
    for (i = 7; i <= 14; i++) {
        video_write(3 * SCREEN_COLS + i, CHR_BEAM, COLOR_PURPLE);
    }
    video_write(3 * SCREEN_COLS + 15, CHR_LADDER, COLOR_RED);

    /* Righe 4 e 5: scale ai lati e spazi al centro */
    for (row_idx = 4; row_idx <= 5; row_idx++) {
        video_write(row_idx * SCREEN_COLS + 6, CHR_LADDER, COLOR_RED);
        for (i = 7; i <= 14; i++) {
            video_write(row_idx * SCREEN_COLS + i, CHR_SPACE, COLOR_PURPLE);
        }
        video_write(row_idx * SCREEN_COLS + 15, CHR_LADDER, COLOR_RED);
    }

    /*
     * 72 for n=1 to 3: print b$"{down}{down}{down}{down}": next: printb$"{home}";
     * Stampa le 4 travi principali (righe 7, 12, 17, 22)
     * b$ = ">88888888888888888888" (spazio, 20 caratteri trave)
     */
    for (row_idx = 0; row_idx < 4; row_idx++) {
        uint16_t beam_start = (uint16_t)((7 + row_idx * 5) * SCREEN_COLS);
        video_write(beam_start, CHR_SPACE, COLOR_PURPLE);
        for (i = 1; i <= 20; i++) {
            video_write(beam_start + i, CHR_BEAM, COLOR_PURPLE);
        }
        if (beam_start + 21 < SCREEN_SIZE) {
            video_write(beam_start + 21, CHR_SPACE, COLOR_PURPLE);
        }
    }

    /* 72 poke 8185,62 ' spazio in angolo basso destra per evitare omino fuori */
    /* 8185 - 7680 = 505 (riga 22 colonna 21) */
    video_write(22 * SCREEN_COLS + 21, CHR_SPACE, COLOR_PURPLE);

    /* 73 Stampa punteggio, vite e livello */
    draw_score_bar();

    /*
     * 73-74 for n=0 to 11: poke 7712+b(n),60: poke 7712+b(n)+g,7: next
     * 7712 - 7680 = 32 (riga 1 colonna 10)
     */
    for (n = 0; n < 12; n++) {
        video_write(32 + b[n], CHR_BARREL, COLOR_YELLOW);
    }

    /*
     * 74 for n=7834 to 8164 step 110
     * Cicla sulle travi (offset 154, 264, 374; la quarta a 484 non genera scale verso il basso)
     * 7834 - 7680 = 154 (riga 7)
     * 8164 - 7680 = 484 (riga 22)
     */
    for (n = 154; n <= 374; n += (5 * SCREEN_COLS)) {
        /* Disegna 3 scale per trave */
        for (o = 1; o <= 3; o++) {
            /* 76 r=n+1+int(rnd(1)*20): if peek(r)<>56 then 76 */
            do {
                r = n + 1 + rnd(20);
            } while (video_read(r) != CHR_BEAM);

            /* 77 for m=r to r+88 step 22: poke m,57: poke m+g,2: next */
            for (m = r; m <= r + (4 * SCREEN_COLS); m += SCREEN_COLS) {
                video_write(m, CHR_LADDER, COLOR_RED);
            }

            /*
             * 77 if o>1 and rnd(1)<e2 then poker+(int(rnd(1)*2)+2)*22,63
             * Scala interrotta: deviatore ad altezza casuale
             */
            if (o > 1 && rnd_percent() < e2) {
                video_write(r + (rnd(2) + 2) * SCREEN_COLS, CHR_TRIGGER, COLOR_RED);
            }

            /*
             * 78 if rnd(1)<.5 and peek(r-22)=62 then poker-22,63
             * Deviatore in cima alla scala col 50% di probabilità
             */
            if (rnd_percent() < 50 && video_read(r - SCREEN_COLS) == CHR_SPACE) {
                video_write(r - SCREEN_COLS, CHR_TRIGGER, COLOR_RED);
            }
        }
    }

    /*
     * 80 Disegna buchi sulle travi
     * 80 for o=1 to e1
     */
    for (n = 154; n <= 484; n += (5 * SCREEN_COLS)) {
        for (o = 0; o < e1; o++) {
            /* 81 r=n+3+int(rnd(1)*16) */
            r = n + 3 + rnd(16);
            /* 81 if peek(r)<>56 or peek(r-22)<>62 or peek(r+1)=62 or peek(r-1)=62 then 85 */
            if (video_read(r) != CHR_BEAM ||
                video_read(r - SCREEN_COLS) != CHR_SPACE ||
                video_read(r + 1) == CHR_SPACE ||
                video_read(r - 1) == CHR_SPACE) {
                continue;
            }
            /* 84 poke r,62: poke r-22,63 */
            video_write(r, CHR_SPACE, COLOR_BLACK);
            video_write(r - SCREEN_COLS, CHR_TRIGGER, COLOR_BLACK);
        }

        /*
         * 86 Disegna 4 borse per trave
         * 86 for o=1 to 4: 87 r=n-21+int(rnd(1)*20)
         * n - 21 = (n - SCREEN_COLS) + 1 (riga sopra la trave, colonne 1..20)
         */
        for (o = 0; o < 4; o++) {
            do {
                r = n - SCREEN_COLS + 1 + rnd(20);
            } while (video_read(r) != CHR_SPACE || video_read(r + SCREEN_COLS) == CHR_SPACE);

            /* 88 poke r,61: poke r+g,0 */
            video_write(r, CHR_BAG, COLOR_BLACK);
        }
    }

    /*
     * 89 Deviatori ai lati della pila di barili
     * 7710 - 7680 = 30 (riga 1 colonna 8)
     * 7715 - 7680 = 35 (riga 1 colonna 13)
     * 7731 - 7680 = 51 (riga 2 colonna 7)
     * 7738 - 7680 = 58 (riga 2 colonna 14)
     */
    video_write(30, CHR_TRIGGER, COLOR_BLACK);
    video_write(35, CHR_TRIGGER, COLOR_BLACK);
    video_write(51, CHR_TRIGGER, COLOR_BLACK);
    video_write(58, CHR_TRIGGER, COLOR_BLACK);

    /*
     * 90 for n=7812 to 8142 step 110: poke n,63: next (fine trave sinistra)
     * 90 for n=7833 to 8163 step 110: poke n,63: next (fine trave destra)
     * 7812 - 7680 = 132 (riga 6 colonna 0)
     * 7833 - 7680 = 153 (riga 6 colonna 21)
     */
    for (n = 132; n <= 462; n += (5 * SCREEN_COLS)) {
        video_write(n, CHR_TRIGGER, COLOR_BLACK);
    }
    for (n = 153; n <= 483; n += (5 * SCREEN_COLS)) {
        video_write(n, CHR_TRIGGER, COLOR_BLACK);
    }
}

/*
 * spawn_player()
 * Posiziona l'omino sulla trave inferiore in una posizione valida (BASIC riga 16-17)
 * 16 s=8143+int(rnd(1)*20) -> 8143 - 7680 = 463 (riga 21 colonna 1)
 */
static void spawn_player(void) {
    do {
        s = 463 + rnd(20);
    } while (video_read(s + SCREEN_COLS) == CHR_SPACE || video_read(s) == CHR_BOMB);

    /* 17 t=peek(s): poke s,58: poke s+g,0 */
    t = video_read(s);
    video_write(s, CHR_PLAYER, COLOR_BLACK);

    /* 1 di=do(int(rnd(1)*2)) ' sceglie casualmente sx (-1) o dx (+1) */
    di = (rnd(2) == 0) ? -1 : 1;
}

/*
 * spawn_barrel()
 * Inizializza il rotolamento del prossimo barile (BASIC riga 19)
 * 19 v=7712+b(y): w=62: do=do(int(rnd(1)*2))
 * 7712 - 7680 = 32
 */
static void spawn_barrel(void) {
    v = 32 + b[y];
    w = CHR_SPACE;
    do_dir = (rnd(2) == 0) ? -1 : 1;
}

/*
 * check_bonus_life()
 * Controllo bonus vita (BASIC riga 98)
 * Nel BASIC originale 'if ss=q*e3 then' falliva spesso perché il punteggio saliva a scaglioni.
 * Correzione: if (ss >= next_bonus_score)
 */
static void check_bonus_life(void) {
    if (ss >= next_bonus_score) {
        ch++;
        next_bonus_score += 10000;
        draw_score_bar();
    }
}

/*
 * player_death()
 * Gestisce la sequenza di morte dell'omino (BASIC linee 55-62)
 */
static uint8_t player_death(void) {
    uint8_t n;

    play_sound(SOUND_DEATH);

    /* 55 if t=60 then t=w */
    if (t == CHR_BARREL) {
        t = w;
    }

    /*
     * 56 fa cadere l'omino fino ad incontrare una trave o la fine dello schermo
     * if peek(s+22)<>56 and s<8164 then (8164 - 7680 = 484)
     */
    while (video_read(s + SCREEN_COLS) != CHR_BEAM && s < 484) {
        video_write(s, t, get_char_color(t));
        s += SCREEN_COLS;
        t = video_read(s);
        video_write(s, CHR_PLAYER, COLOR_BLACK);
        /* Ritardo simulato per animazione caduta */
        for (n = 0; n < 17; n++) { }
    }

    /* 58 ch=ch-1: if ch=-1 then fine gioco */
    ch--;
    if (ch < 0) {
        return EVENT_GAMEOVER;
    }

    /* 59 Aggiorna conteggio vite a video */
    draw_score_bar();

    /* 59 Cancella barile che stava rotolando */
    video_write(v, w, get_char_color(w));
    y++;

    /* 59 if w=58 then pokev,t: pokev+g,d(t-j) */
    if (w == CHR_PLAYER) {
        video_write(v, t, get_char_color(t));
    }

    /* 60 if y>10 then 15 ' se caduti tutti i barili, ricomincia livello */
    if (y > 10) {
        return EVENT_RESTARTLEVEL;
    }

    /* 61 if s>8163 then (8163 - 7680 = 483) ' omino morto fuori schermo */
    if (s > 483) {
        video_write(s, t, get_char_color(t));
        return EVENT_MANOUTSIDE;
    }

    /* 62 poke s,58: poke s+g,0 */
    video_write(s, CHR_PLAYER, COLOR_BLACK);
    return EVENT_NEWBARREL;
}

/*
 * level_cleared()
 * Animazione di fine livello, conteggio barili residui e passaggio al livello successivo (BASIC linee 64-68)
 */
static void level_cleared(void) {
    uint8_t n;

    /* 65 for n=y+1 to 11: cancella barile dalla pila e assegna 100 punti */
    if (y < 11) {
        for (n = y + 1; n < 12; n++) {
            video_write(32 + b[n], CHR_SPACE, COLOR_BLACK);
            ss += 100;
            draw_score_bar();
            check_bonus_life();
            play_sound(SOUND_BARREL_BONUS);
        }
    }

    /*
     * 67 e2=e2+.05 (aumenta del 5% chance deviatori sulle scale)
     *    sc=sc+1   (aumenta livello)
     *    e1=e1+1   (aumenta buchi sulle travi, max 8)
     */
    e2 += 5;
    sc++;
    e1++;
    if (e1 > 8) {
        e1 = 8;
    }
}

/*
 * move_player(input_cmd)
 * Spostamento del giocatore in base all'input (BASIC linee 20-43)
 */
static uint8_t move_player(uint8_t input_cmd) {
    uint8_t n;

    switch (input_cmd) {
        case INPUT_FIRE:
            /*
             * 35 poke 36876,240 ' suono salto
             *    poke s,t: poke s+g,d(t-j)
             *    s=s-22+di
             */
            play_sound(SOUND_JUMP);
            video_write(s, t, get_char_color(t));
            s = (uint16_t)(s - SCREEN_COLS + di);
            t = video_read(s);
            video_write(s, CHR_PLAYER, COLOR_BLACK);

            /* 35 if t=60 then 55 ' collisione con barile */
            if (t == CHR_BARREL) {
                return EVENT_DEATH;
            }

            /* 36 if peek(s+22)=60 then ss=ss+1000 ' salto sopra un barile */
            if (video_read(s + SCREEN_COLS) == CHR_BARREL) {
                ss += 1000;
                draw_score_bar();
            }

            /* 37 ritardo per rendere visibile il salto */
            for (n = 0; n < 5; n++) { }

            /* 37 s=s+22+di (ricaduta) */
            video_write(s, t, get_char_color(t));
            s = (uint16_t)(s + SCREEN_COLS + di);
            t = video_read(s);
            video_write(s, CHR_PLAYER, COLOR_BLACK);

            /* 37 if peek(s+22)>61 then 55 (caduta nel vuoto) */
            if (video_read(s + SCREEN_COLS) > CHR_BAG) {
                return EVENT_DEATH;
            }

            play_sound(SOUND_MUTE);
            break;

        case INPUT_DOWN:
            /* 26 if peek(s+22)=z then s=s+22 */
            if (video_read(s + SCREEN_COLS) == CHR_LADDER) {
                video_write(s, t, get_char_color(t));
                s += SCREEN_COLS;
                play_sound(SOUND_MOVE);
                t = video_read(s);
                video_write(s, CHR_PLAYER, COLOR_BLACK);
            }
            break;

        case INPUT_LEFT:
            /* 28 di=-1: if peek(s+21)<62 then s=s-1 */
            di = -1;
            if (video_read(s + SCREEN_COLS - 1) < CHR_SPACE) {
                video_write(s, t, get_char_color(t));
                s -= 1;
                play_sound(SOUND_MOVE);
                t = video_read(s);
                video_write(s, CHR_PLAYER, COLOR_BLACK);
            } else if (t != CHR_LADDER) {
                /* 29 if t<>z then omino nel vuoto -> morte */
                video_write(s, t, get_char_color(t));
                s = (uint16_t)(s + di);
                t = video_read(s);
                return EVENT_DEATH;
            }
            break;

        case INPUT_UP:
            /* 31 if t=z then s=s-22 */
            if (t == CHR_LADDER) {
                video_write(s, t, get_char_color(t));
                s -= SCREEN_COLS;
                play_sound(SOUND_MOVE);
                t = video_read(s);
                video_write(s, CHR_PLAYER, COLOR_BLACK);
            }
            break;

        case INPUT_RIGHT:
            /* 33 di=1: if peek(s+23)<62 then s=s+1 */
            di = 1;
            if (video_read(s + SCREEN_COLS + 1) < CHR_SPACE) {
                video_write(s, t, get_char_color(t));
                s += 1;
                play_sound(SOUND_MOVE);
                t = video_read(s);
                video_write(s, CHR_PLAYER, COLOR_BLACK);
            } else if (t != CHR_LADDER) {
                /* 34 goto 29 -> omino nel vuoto */
                video_write(s, t, get_char_color(t));
                s = (uint16_t)(s + di);
                t = video_read(s);
                return EVENT_DEATH;
            }
            break;

        case INPUT_NONE:
        default:
            /* 21 for n=1 to 23:next ' ciclo di ritardo */
            for (n = 0; n < 23; n++) { }
            break;
    }

    /*
     * 41 if t=61 then trovato borsa
     * ss=ss+150: h=h+1: t=62: if h=16 then fine livello
     */
    if (t == CHR_BAG) {
        ss += 150;
        draw_score_bar();
        h++;
        t = CHR_SPACE;
        if (h == 16) {
            return EVENT_NEWLEVEL;
        }
    }

    /* 42 if t=60 then 55 (collisione barile) */
    if (t == CHR_BARREL) {
        return EVENT_DEATH;
    }

    /* 43 controlla se per caso è scattato il bonus vita */
    check_bonus_life();

    return EVENT_NONE;
}

/*
 * move_barrel()
 * Spostamento del barile (BASIC linee 45-51)
 */
static uint8_t move_barrel(void) {
    /* 45 poke v,w: poke v+g,d(w-j): v=v+do: w=peek(v): poke v,60: poke v+g,7 */
    video_write(v, w, get_char_color(w));
    v = (uint16_t)(v + do_dir);
    w = video_read(v);
    video_write(v, CHR_BARREL, COLOR_YELLOW);

    /*
     * 46 if do=22 and peek(v+22)=56 then do=do(int(rnd(1)*2))
     * Se il barile sta cadendo (do=SCREEN_COLS) e sotto c'è una trave, sceglie sx o dx
     */
    if (do_dir == SCREEN_COLS && video_read(v + SCREEN_COLS) == CHR_BEAM) {
        do_dir = (rnd(2) == 0) ? -1 : 1;
    } else if (w == CHR_TRIGGER) {
        /* 47 if w=63 then do=22 (incontra deviatore, inizia a scendere) */
        do_dir = SCREEN_COLS;
    }

    /* 48 if w=58 then 55 (crasha su omino) */
    if (w == CHR_PLAYER) {
        return EVENT_DEATH;
    }

    /* 49 if v<8164 then ritorna (8164 - 7680 = 484) */
    if (v < 484) {
        return EVENT_NONE;
    }

    /* 50 barile fuori schermo: y=y+1: if y=12 then morte */
    y++;
    if (y == 12) {
        return EVENT_DEATH;
    }

    /* 51 poke v,62 ' cancella barile uscito dallo schermo */
    video_write(v, CHR_SPACE, COLOR_BLACK);
    return EVENT_NEWBARREL;
}

/*
 * game_loop()
 * Ciclo principale di gioco
 */
static void game_loop(void) {
    uint8_t cmd, ev, death_ev;

    /*
     * 3 sc=1 (livello 1)
     *   ch=2 (3 vite)
     *   e1=0 (0 buchi al primo livello)
     *   next_bonus_score=10000
     */
    sc = 1;
    ch = 2;
    e1 = 0;
    e2 = 0;
    ss = 0;
    next_bonus_score = 10000;

    while (ch >= 0) {
        /* 15 gosub 70 (disegna livello): h=0: y=0 */
        draw_level();
        h = 0;
        y = 0;

        /* 16 Posiziona omino sulla piattaforma iniziale */
        spawn_player();

        /* Ciclo per ciascun barile */
        while (1) {
            /* 19 Inizializza rotolamento del barile */
            spawn_barrel();

            /* Loop frame: movimento omino e barile */
            while (1) {
                cmd = input_player();
                ev = move_player(cmd);

                if (ev == EVENT_DEATH) {
                    death_ev = player_death();
                    if (death_ev == EVENT_GAMEOVER) {
                        return;
                    }
                    if (death_ev == EVENT_RESTARTLEVEL) {
                        break; /* Ricomincia livello */
                    }
                    if (death_ev == EVENT_MANOUTSIDE) {
                        spawn_player();
                        spawn_barrel();
                        continue;
                    }
                    if (death_ev == EVENT_NEWBARREL) {
                        spawn_barrel();
                        continue;
                    }
                } else if (ev == EVENT_NEWLEVEL) {
                    level_cleared();
                    break; /* Passa al livello successivo */
                }

                ev = move_barrel();
                if (ev == EVENT_DEATH) {
                    death_ev = player_death();
                    if (death_ev == EVENT_GAMEOVER) {
                        return;
                    }
                    if (death_ev == EVENT_RESTARTLEVEL) {
                        break;
                    }
                    if (death_ev == EVENT_MANOUTSIDE) {
                        spawn_player();
                        spawn_barrel();
                        continue;
                    }
                    if (death_ev == EVENT_NEWBARREL) {
                        spawn_barrel();
                        continue;
                    }
                } else if (ev == EVENT_NEWBARREL) {
                    spawn_barrel();
                }
            }

            if (ev == EVENT_NEWLEVEL || death_ev == EVENT_RESTARTLEVEL) {
                break;
            }
        }
    }
}

/*
 * intro()
 * Schermata introduttiva (BASIC linee 200-270 di lo_scalatore.16k.bas)
 */
static void intro(void) {
    clear_screen();
    text_write("THE HARDHAT CLIMBER", 1, 2, COLOR_BLUE);
    text_write("written by", 6, 4, COLOR_BLUE);
    text_write("Chris Lesher", 5, 6, COLOR_BLACK);
    text_write("Compute!'s Gazette", 2, 8, COLOR_BLUE);
    text_write("Jan, 1984", 6, 9, COLOR_BLUE);
    text_write("2023 turbo edition", 2, 12, COLOR_BLUE);
    text_write("by Antonino Porcino", 1, 13, COLOR_BLUE);
    text_write("github.com/nippur72", 1, 15, COLOR_GREEN);
    text_write("/lo-scalatore", 4, 16, COLOR_BLUE);
    text_write("press any key", 4, 19, COLOR_BLUE);

    /* Attesa pressione tasto (dummy HAL) */
    /* while (input_player() == INPUT_NONE) { } */
}

/*
 * game_over()
 * Schermata di Game Over e visualizzazione punteggio finale (BASIC linee 300-340 di lo_scalatore.16k.bas)
 */
static void game_over(void) {
    char score_str[16];
    uint16_t temp = ss;
    int8_t i = 0, j, len;

    clear_screen();
    text_write("your score: ", 2, 2, COLOR_BLACK);

    /* Conversione punteggio in stringa */
    if (temp == 0) {
        score_str[i++] = '0';
    } else {
        char rev[8];
        len = 0;
        while (temp > 0) {
            rev[len++] = (char)('0' + (temp % 10));
            temp /= 10;
        }
        for (j = len - 1; j >= 0; j--) {
            score_str[i++] = rev[j];
        }
    }
    score_str[i] = '\0';
    text_write(score_str, 14, 2, COLOR_BLACK);

    text_write("press any key", 4, 7, COLOR_BLACK);

    /* Attesa pressione tasto (dummy HAL) */
    /* while (input_player() == INPUT_NONE) { } */
}

/*
 * Entry point del programma
 */
void main(void) {
    init_graph();
    while (1) {
        intro();
        game_loop();
        game_over();
    }
}
