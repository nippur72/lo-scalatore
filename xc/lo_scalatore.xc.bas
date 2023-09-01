declare sub update_score() static
declare function get_random_direction as int () static
declare sub check_bonus_vita() static
declare function random as word (limit as word, mask as word) static
declare sub draw_level() static
declare sub init_mem() static
declare function playermove as byte () static
declare function barrel_move as byte () static
declare sub newlevel() static

' geometria dello schermo del VIC-20 
const NCOLS = 22
const NROWS = 23
const VRAM = 7680
const CRAM = 38400
const g = 30720   ' CRAM - VRAM

const CHAR_TRAVE = 56
const CHAR_SCALA = 57
const CHAR_MAN = 58
const CHAR_BOMB = 59
const CHAR_BARREL = 60
const CHAR_BAG = 61
const CHAR_SPACE = 62
const CHAR_DIVERT = 63

const COLOR_YELLOW = 7
const COLOR_BLACK = 0

const N_BARRELS = 12

const EVENT_NONE         = 0
const EVENT_NEWLEVEL     = 1
const EVENT_DEATH        = 2
const EVENT_NEWBARREL    = 3
const EVENT_GAMEOVER     = 4
const EVENT_RESTARTLEVEL = 5
const EVENT_MANOUTSIDE   = 6

dim pos_man as word
dim dir_man as word

dim bstack(N_BARRELS) as byte @bvector
dim pos_barrel as word
dim dir_barrel as int    
dim cbarrel as byte

dim score as word
dim nbags as byte
dim level as byte
dim lives as int
dim n_bonus as int
dim holes as byte
dim bonus_multiplier as word
dim divert_chance as float

dim d(5) as byte
dim n as word
dim w as byte
dim m as byte
dim o as byte
dim t as byte
dim freq as byte

dim e as byte

  print "{clr}"
  poke 36869,255
  poke 36878,15
  poke 36879,25

  dir_man=get_random_direction()
  a$=">>>>>>>>>>>>>>>>>>>>>{left}{inst}>"

  level=1
  lives=2
  holes=0
  d(0)=4:d(1)=2:d(4)=COLOR_YELLOW  
  n_bonus=1
  bonus_multiplier=10000
  call init_mem()  

15 call draw_level()
   nbags=0
   cbarrel=0

16
   do
      pos_man=8143 + random(20,31)
   loop while peek(pos_man+NCOLS)=CHAR_SPACE or peek(pos_man)=CHAR_BOMB

   t=peek(pos_man)
   poke pos_man,CHAR_MAN
   poke pos_man+g,COLOR_BLACK

newbarrel:
   pos_barrel=7712+bstack(cbarrel)
   w=CHAR_SPACE
   dir_barrel=get_random_direction()

   ' game loop
   do
      e = playermove()
      if e=EVENT_DEATH then 
         e=morte()
         if e=EVENT_GAMEOVER then exit do
         if e=EVENT_MANOUTSIDE then goto 16
         if e=EVENT_NEWBARREL then goto newbarrel
         if e=EVENT_RESTARTLEVEL then goto 15
      else
         if e=EVENT_NEWLEVEL then call newlevel():goto 15
      end if

      e = barrel_move()
      if e=EVENT_DEATH then 
         e=morte()
         if e=EVENT_GAMEOVER then exit do
         if e=EVENT_MANOUTSIDE then goto 16
         if e=EVENT_NEWBARREL then goto newbarrel
         if e=EVENT_RESTARTLEVEL then goto 15
      else 
         if e=EVENT_NEWBARREL then goto newbarrel
      end if
   loop

function morte as byte () static
   poke 36876,0
   freq=250
   if t=CHAR_BARREL then t=w

   do
      poke 36874,freq
      if peek(pos_man+NCOLS)<>CHAR_TRAVE and pos_man<8164 then 
         poke pos_man,t:poke pos_man+g,d(t-CHAR_TRAVE)
         pos_man=pos_man+NCOLS
         t=peek(pos_man)
         poke pos_man,CHAR_MAN
         poke pos_man+g,COLOR_BLACK
      end if
      for n=1 to 17:next
      freq=freq-5
   loop while freq>150 

   poke 36874,0
   lives=lives-1
   if lives=-1 then 
      return EVENT_GAMEOVER
      'poke d,255
      'poke 36869,240
      'print "{clr}{blk}";score
      'end
   end if

   call update_score()
   poke pos_barrel,w
   poke pos_barrel+g,d(w-CHAR_TRAVE)
   cbarrel=cbarrel+1
   if w=CHAR_MAN then 
      poke pos_barrel,t
      poke pos_barrel+g,d(t-CHAR_TRAVE)
   end if
   if cbarrel>10 then return EVENT_RESTARTLEVEL
   if pos_man>8163 then 
      poke pos_man,t
      return EVENT_MANOUTSIDE
   end if
   poke pos_man,CHAR_MAN
   poke pos_man+g,COLOR_BLACK
   RETURN EVENT_NEWBARREL
end sub

sub newlevel() static
   if cbarrel<N_BARRELS-1 then
      for n=cbarrel+1 to N_BARRELS-1
         poke 7712+bstack(n),CHAR_SPACE
         score=score+100
         call update_score()
         call check_bonus_vita()   
         poke 36877,250
         for m=240 to 250
            poke 36876,m
         next
         poke 36876,0
         poke 36877,0
      next
   end if

   divert_chance=divert_chance+0.05
   level=level+1
   holes=holes+1:if holes>8 then holes=8
end sub   

'
' movimento giocatore
'
function playermove as byte () static

   sys 828 fast
   on peek(1) goto nomove, fire, down, left, up, right

   ' nessuna mossa
nomove: 
   for n=1 to 23:next
   goto 41

down: 
   if peek(pos_man+NCOLS)=CHAR_SCALA then 
      poke pos_man,t
      poke pos_man+g,d(t-CHAR_TRAVE)
      pos_man=pos_man+NCOLS
      goto 40
   end if
   goto 41

left: 
   dir_man=-1
   if peek(pos_man+21)<CHAR_SPACE then 
      poke pos_man,t
      poke pos_man+g,d(t-CHAR_TRAVE)
      pos_man=pos_man-1
      goto 40
   end if
29 if t<>CHAR_SCALA then 
      poke pos_man,t:poke pos_man+g,d(t-CHAR_TRAVE)
      pos_man=pos_man+dir_man
      t=peek(pos_man)
      return EVENT_DEATH
   end if
   goto 41

up: 
   if t=CHAR_SCALA then 
      poke pos_man,t
      poke pos_man+g,d(t-CHAR_TRAVE)
      pos_man=pos_man-NCOLS
      goto 40
   end if
   goto 41

right: 
   dir_man=1
   if peek(pos_man+23)<CHAR_SPACE then 
      poke pos_man,t:poke pos_man+g,d(t-CHAR_TRAVE)
      pos_man=pos_man+1
      goto 40
   end if
   goto 29

fire:
   poke 36876,240
   poke pos_man,t:poke pos_man+g,d(t-CHAR_TRAVE)
   pos_man=pos_man-NCOLS+dir_man:t=peek(pos_man)
   poke pos_man,CHAR_MAN
   if t=CHAR_BARREL then return EVENT_DEATH
   if peek(pos_man+NCOLS)=CHAR_BARREL then 
      score=score+1000
      call update_score()
   end if
   for n=1 to 5:next
   poke pos_man,t:poke pos_man+g,d(t-CHAR_TRAVE)
   pos_man=pos_man+NCOLS+dir_man
   t=peek(pos_man)
   poke pos_man,CHAR_MAN
   if peek(pos_man+NCOLS)>CHAR_BAG then return EVENT_DEATH

   poke pos_man+g,COLOR_BLACK
   poke 36876,0
   goto 41

40 poke 36876,200
   poke 36876,0
   t=peek(pos_man)
   poke pos_man,CHAR_MAN
   poke pos_man+g,COLOR_BLACK

41 if t=CHAR_BAG then 
      score=score+150
      call update_score()
      nbags=nbags+1
      t=CHAR_SPACE
      if nbags=16 then return EVENT_NEWLEVEL
   end if      
42 if t=CHAR_BARREL then return EVENT_DEATH
43 call check_bonus_vita()
   return EVENT_NONE
end function

'
' movimento del barile
'
function barrel_move as byte () static
   poke pos_barrel,w
   poke pos_barrel+g,d(w-CHAR_TRAVE)
   pos_barrel=pos_barrel+dir_barrel
   w=peek(pos_barrel)
   poke pos_barrel,CHAR_BARREL
   poke pos_barrel+g,COLOR_YELLOW
   if dir_barrel=NCOLS and peek(pos_barrel+NCOLS)=CHAR_TRAVE then 
      dir_barrel = get_random_direction()
   else
      if w=CHAR_DIVERT then dir_barrel=NCOLS
   end if
   if w=CHAR_MAN then return EVENT_DEATH
   if pos_barrel<8164 then return EVENT_NONE
   cbarrel=cbarrel+1
   if cbarrel=N_BARRELS then return EVENT_DEATH
   poke pos_barrel,CHAR_SPACE
   return EVENT_NEWBARREL
end function

sub draw_level() static
   dim r as word

   print "{clr}{pur}";
   for n=1 to 21
      print a$
   next
   print a$;"{home}"
   b$=">88888888888888888888"
   rem print "{down}{down}";tab(6);"?>>>>>>>>?{red}"
   rem print tab(6);"9{pur}88888888{red}9"
   rem print tab(6);"9>>>>>>>>9"
   rem print tab(6);"9>>>>>>>>9{pur}"

   for n=1 to 3
      print b$;"{down}{down}{down}{down}"
   next
   print b$;"{home}";
   poke 8185,CHAR_SPACE

   call update_score()
   poke 7697,163
   for n=0 to 11
      poke 7712+bstack(n),CHAR_BARREL
      poke 7712+bstack(n)+g,COLOR_YELLOW
   next
   
   for n=7834 to 8164 step 110
   
      for o=1 to 3
         do
            r=n+1+random(20,31)
         loop while peek(r)<>CHAR_TRAVE 

         for m=r to r+88 step NCOLS
            poke m,57
            poke m+g,2
         next
         if o>1 and rnd()<divert_chance then 
            poke r+(random(2,2)+2)*NCOLS,CHAR_DIVERT
         end if

         if rnd()<0.5 and peek(r-NCOLS)=CHAR_SPACE then 
            poke r-NCOLS,CHAR_DIVERT
         end if
      next

      for o=1 to holes
         do
            r=n+3+random(16,15)
         loop while peek(r)<>CHAR_TRAVE or peek(r-NCOLS)<>CHAR_SPACE or peek(r+1)=CHAR_SPACE or peek(r-1)=CHAR_SPACE

         poke r,CHAR_SPACE
         poke r-NCOLS,CHAR_DIVERT
      next

      for o=1 to 4
         do
            r=n-21+random(20,31)
         loop while peek(r)<>CHAR_SPACE or peek(r+NCOLS)=CHAR_SPACE
         poke r,CHAR_BAG
         poke r+g,COLOR_BLACK
      next
   next

   poke 7710,CHAR_DIVERT
   poke 7715,CHAR_DIVERT
   poke 7731,CHAR_DIVERT
   poke 7738,CHAR_DIVERT
   for n=7812 to 8142 step 110
      poke n,CHAR_DIVERT
   next
   for n=7833 to 8163 step 110
      poke n,CHAR_DIVERT
   next
end sub

'
' check bonus vite
'
sub check_bonus_vita() static
   if score=bonus_multiplier*n_bonus then 
      lives=lives+1
      n_bonus=n_bonus+1
      call update_score()
   end if
end sub
   
sub init_mem() static
   memcpy @chardata, 7616, 7679-7616+1
   memcpy @lmdata, 828, 899-828+1
end sub

sub update_score() static
   print "{home}{rvon}";
   locate 8-len(str$(score)), 0
   print score
   locate 14, 0
   print lives
   locate 17, 0
   print level
end sub

function get_random_direction as int () static
   if rndb() and 1 then return 1 else return -1
end function

function random as word (limit as word, mask as word) static
   dim r as word
   do
      r = rndw() and mask
   loop until r < limit
   return r      
end function

bvector: data as byte 0,1,21,22,23,24,42,43,44,45,46,47

chardata:
   data as byte 255,255,153,102,102,153,255,255,195,255,255,195,195,255,255,195,60,60,25,255,188
   data as byte 60,36,231,3,4,24,24,60,126,126,60,60,66,165,153,153,165,66,60,0,24,36,126,126,126
   data as byte 126,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

lmdata:
   data as byte 169,0,133,1,169,255,141,34,145,169,32,44,31,145,208,5,169,1,133,1,96,169,8,44
   data as byte 31,145,208,5,169,2,133,1,96,169,16,44,31,145,208,5,169,3,133,1,96,169,4,44,31
   data as byte 145,208,3,133,1,96,169,127,141,34,145,169,128,44,32,145,208,4,169,5,133,1,96

