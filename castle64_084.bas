!- =============================================================
!- Project    CASTLE DUNGEON 64
!- Target     Commodore 64
!- Comments   My implementation of Castle Dungeon for Commodore 64
!- Author     ABSayuti
!- =============================================================
!-
!- Version: 0.84 (Editing on PC & Mac's UTM)
!-      - Add ML routine for Maze printing
!-      - Remove REMS because of Out of memory error
!-      - Shorten "ending" routine
!-      - Optimize game loop -- check for 'space' first
!-      - Try use 2 sprites for the player
!-      - Make the door bump animation more interesting
!-
!- Important addresses:
!-
!-      Top of BASIC = $3000 (12288)        
!-      Custom charset = $3000 - $3FFF*
!-      Sprite imnges = $3C00 - $3FFF (*overlapped)
!-                      (15360 - 16383)
!-
!- Set top of basic to $3000 = 12288 = 48*256
10 POKE 52,48 :POKE 56,48 :CLR
!- Initialization
20 GOSUB 3000
!-  Main loop starts here
!-  Setup maze, print, reset game vars
100 GOSUB 2000 :GOSUB 2500: GOSUB 2700
!-  Game loop
!-  Place man in maze @x,y
110 GOSUB 400 
120   lv = lv-1: IF lv<0 THEN lv=0
!-    Change to red border about 1 minute before time
130   IF TI>14400 THEN POKE brder,8
!-    Time is up afer 5 minutes --> end game
140   IF TI>18000 THEN 720
150   GET k$: IF k$="" THEN 150
160   IF k$="{up}" THEN dy=-1: GOTO 210 
170   IF k$="{down}" THEN dy=1: GOTO 210
180   IF k$="{left}" THEN dx=-1: GOTO 210
190   IF k$="{right}" THEN dx=1: GOTO 210
!-    L = levitation spell
200   IF k$="l" THEN lv=2: GOSUB 1300 
!-    Check what is in next cell
210   n$ = MID$(maze$(y+dy),x+dx,1)
!-    Empty space, loop to move player
215   IF n$=em$ THEN 110
!-    Wall, do not move
220   IF n$=wl$ THEN dx=0: dy=0 
!-    Door, ?key
230   IF n$=dr$ AND ky=0 THEN y0=y: dy=.5*dy: GOSUB1200:GOSUB400: y=y0: GOTO110
240   IF n$=dr$ AND ky=1 THEN GOSUB400: GOSUB1100: GOSUB1500: GOTO 110
!-    Pit, ?lv spell
250   IF n$=pt$ AND lv=0 THEN GOSUB400: GOSUB 1600: GOTO 700 
!-    Beast, ?sword
260   IF n$=bs$ AND sw=0 THEN GOSUB400:GOSUB1700:GOTO 710 
270   IF n$=bs$ AND sw=1 THEN GOSUB400:GOSUB1700:GOSUB1100:GOSUB500
!-    Found sword?
280   IF n$=sw$ THEN sw=1: GOSUB400:GOSUB1400:GOSUB1100:GOSUB500 
!-    Found key?
290   IF n$=ky$ THEN ky=1: GOSUB400:GOSUB1400:GOSUB1100:GOSUB500
!-    Found bomb?
300   IF n$<>bo$ THEN 110
310     bo=bo+1: GOSUB400:GOSUB1400:GOSUB1100:GOSUB500
320     IF bo=3 THEN 730
340 GOTO 110
!-    
!---------------------------------------------------------------
!-   Move player/hero
400 x=x+dx: y=y+dy: dx=0: dy=0
410 POKE ys,y*8+42: POKE ys+2,y*8+44
420 IF x<17 THEN POKE xs,x*16-8: POKE xs+2,x*16-8: POKE xh,0: RETURN
430 POKE xh,3: POKE xs,(x-16)*16-8: POKE xs+2,(x-16)*16-8
490 RETURN
!-
!---------------------------------------------------------------
!-  Print status
500 PRINT LEFT$(yy$,25);"{light green}";
510 IF sw=1 THEN PRINT"{194}{195}";
520 IF ky=1 THEN PRINT"{203}{204}";
530 IF bo>0 THEN FOR i=1 TO bo: PRINT"{199}{200}";: NEXT
540 IF lv>0 THEN PRINT"l";
550 PRINT "  {black}";
560 RETURN
!-    
!---------------------------------------------------------------
!-  Game over message
700 a$ = " you fell into a pit ": GOTO 800
710 a$ = " you lost to a beast ": GOTO 800
720 a$ = " castle is destroyed ": GOTO 800
730 a$ = " you saved the castle! "
!---------------------------------------------------------------
!-  Game over, play again?
800 PRINT LEFT$(yy$,13);LEFT$(xx$,9);"{white}";a$
!-  Reveal maze, disable Spr0 
810 POKE bgro,11: POKE brd,11: POKE en,0
820 IF bo<3 THEN GOSUB1900
830 IF bo=3 THEN GOSUB1800
840 FOR j=1 TO 3000: NEXT
880 PRINT "{clear}": POKE bgro,0
890 PRINT LEFT$(yy$,13);LEFT$(xx$,11);"play again? (y/n)"
900 GOSUB 1000
910 IF a=1 THEN 100
!-  THE END!
930 PRINT "{clear}bye!": POKE brdr,0
940 END
!-
!---------------------------------------------------------------
!-   Get user response Y/N
1000 b=2
1010 POKE brdr,12+b
1020 GET k$
1030 IF k$<>"" THEN 1070
1040 FOR i=1 TO 1000: NEXT
1050 b=-b
1060 GOTO 1010
1070 IF k$="y" THEN a=1: RETURN
1080 IF k$="n" THEN a=0: RETURN
1090 GOTO 1010
!-
!---------------------------------------------------------------
!-   Remove an item next location
1100 maze$(y)=LEFT$(maze$(y),x-1)+" "+RIGHT$(maze$(y),20-x)
1110 PRINT LEFT$(yy$,y+1);LEFT$(xx$,2*(x-1));"  "
1130 RETURN
!-
!---------------------------------------------------------------
!-   Show door is locked and bump into it
1200 REM PRINT LEFT$(yy$,y+dy+1);LEFT$(xx$,2*(x+dx-1));"{205}{205}"
1210 POKE l1,100: POKE h1,2
1220 POKE vol,15: POKE ad,20: POKE sr,5: POKE wav,no
1230 FOR td=1 TO 2: NEXT: POKE wav,no-1
1240 REM PRINT LEFT$(yy$,y+dy+1);LEFT$(xx$,2*(x+dx-1));"{196}{196}"
1290 RETURN
!-
!---------------------------------------------------------------
!-   Levitate SOUND
1300 POKE ad,100: POKE sr,250: POKE vol,15
1310 FOR a=2 TO 4
1320   FOR b=0 TO 7
1340     POKE h1,a*b: POKE l1,0: POKE wav,tr
1350     FOR td=1 TO 2: NEXT: POKE wav,tr-1
1370   NEXT
1380 NEXT
1390 RETURN
!---------------------------------------------------------------
!-   Pling sound
1400 POKE ad,14: POKE sr,200: POKE vo,15
1410 POKE h1,60: POKE wav,sa
1420 FOR td=1 TO 2: NEXT
1430 POKE wav,sa-1
1440 FOR td=1 TO 60: NEXT
1450 POKE h1,120: POKE wav,sa
1460 FOR td=1 TO 3: NEXT
1470 POKE wav,sa-1
1490 RETURN
!---------------------------------------------------------------
!-   Door opening sound
1500 POKE ad,17: POKE sr,140: POKE vo,15
1510 POKE l1,0: POKE h1,2: POKE wav,sa
1520 FOR td=1 TO 2: NEXT
1530 POKE wav,sa-1
1590 RETURN
!---------------------------------------------------------------
!-   Falling sound
1600 POKE ad,10: POKE sr,10: POKE vo,15
1610 FOR a=200 to 100 STEP-2
1620   POKE h1,a: POKE l1,100: POKE wa,tr
1630   FOR td=1 TO 3: NEXT
1640   POKE wa,tr-1
1650   FOR td=1 TO 3: NEXT 
1660 NEXT
1670 RETURN
!---------------------------------------------------------------
!-   Beast sound
1700 POKE ad,100: POKE sr,100: POKE vo,15
1710 POKE h1,2: POKE l1,10: POKE wa,no
1720   FOR td=1 TO 1000: NEXT
1730   POKE wa,no-1
1740   FOR td=1 TO 100: NEXT 
1790 RETURN
!---------------------------------------------------------------
!-   Victory sound
1800 POKE ad,100: POKE sr,100: POKE vo,15
1810 FOR i=1 TO 4
1820   POKE h1,no(1,i): POKE l1,100: POKE wa,sa
1830   FOR td=1 TO du(1,i): NEXT
1840   POKE wa,sa-1
1850   FOR td=1 TO du(1,i): NEXT
1860 NEXT 
1890 RETURN
!---------------------------------------------------------------
!-   Lose sound
1900 POKE ad,100: POKE sr,120: POKE vo,15
1910 POKE l1,48: POKE h1,4: POKE wa,sa
1920 FOR td=1 TO 500: NEXT
1930 POKE wa,sa-1
1940 FOR td=1 TO 400: NEXT
1950 POKE l1,24: POKE h1,2: POKE wa,sa
1960 FOR td=1 TO 900: NEXT
1970 POKE wa,sa-1
1980 FOR td=1 TO 500: NEXT
1990 RETURN
!-
!---------------------------------------------------------------
!-   Setup the dungeon maze
2000 PRINT CHR$(142);"{clear}{white}":POKE bg,0: POKE br,0
2010 PRINT LEFT$(yy$,13);LEFT$(xx$,11);"please wait..."
2020 maze$(0)  = "####################"
2030 maze$(1)  = "#..#..#     #      #"
2040 maze$(2)  = "#..#..# ### # #### #"
2050 maze$(3)  = "#-###-# #   # #..# #"
2060 maze$(4)  = "# #   # # ###-#..# #"
2070 maze$(5)  = "# # # # #  #..#-## #"
2080 maze$(6)  = "#   # #-## #..#    #"
2090 maze$(7)  = "##### #..# #### ####"
2100 maze$(8)  = "#     #..#    # #..#"
2110 maze$(9)  = "# ### #### #  # #..#"
2120 maze$(10) = "# #      # #### ##-#"
2130 maze$(11) = "# #  #   #         #"
2140 maze$(12) = "# ######## #-##### #"
2150 maze$(13) = "#          #..#..# #"
2160 maze$(14) = "### # #-## #..#..# #"
2170 maze$(15) = "# # # #..# #####-# #"
2180 maze$(16) = "# # # #..#  #..# # #"
2190 maze$(17) = "#   ####### #..# # #"
2200 maze$(18) = "# # #       #-##   #"
2210 maze$(19) = "# # ####### #    # #"
2220 maze$(20) = "# ####    # # ######"
2230 maze$(21) = "#-#..#  # # # #....#"
2240 maze$(22) = "#....#  #   #    ..#"
2250 maze$(23) = "####################"
!-   Markers for items
2260 mn$="$": wl$="#": em$=" ": rm$=".": dr$="-"
2270 pt$="@": ky$="+": bs$="&": bo$="*": sw$="/"
!-   Place items in random rooms
2280 a$=bo$: c$=rm$: n=3
2290 GOSUB 2400
2300 a$=bs$: n=7
2310 GOSUB 2400
2320 c$=em$: n=2: GOSUB 2400
2330 a$=pt$: n=3
2340 GOSUB 2400
2350 a$=ky$: n=1
2360 GOSUB 2400
2370 a$=sw$
2380 GOSUB 2400
2390 RETURN
!-
!---------------------------------------------------------------
!-   Place item a$ at N random locations c$ in the maze$
2400 FOR i=1 TO n
2410   x = INT(RND(0)*20)+1
2420   y = INT(RND(0)*23)
2430   IF MID$(maze$(Y),X,1)<>c$ THEN 2410
2450   m$ = LEFT$(maze$(y),x-1)
2460   m$ = m$+a$
2470   m$ = m$+RIGHT$(maze$(y),20-x)
2480   maze$(y) = m$
2490 NEXT
2495 RETURN
!-
!---------------------------------------------------------------
!-   Print the maze
2500 POKE bg,0: PRINT"{black}{clear}"
2510 FOR r=0 TO 23
2520   SYS 49152,r,ma$(r)
2530 NEXT
2590 RETURN
!-
!---------------------------------------------------------------
!-   Reset/init game variables
2700 lv=0: ky=0: sw=0: bo=0: dx=0: dy=0 
2710 x = INT(RND(0)*20)+1
2720 y = INT(RND(0)*22)
2730 IF MID$(maze$(y),x,1)<>" " THEN 2710
!-   Enable Spr0 + Spr1
2740 POKE en,3
2750 ti$="000000"
2790 RETURN
!-
!---------------------------------------------------------------
!-   Declare key variables / constants
!-   sp = spr0 image pointer
3000 vic=53248: sp=2040 
3010 bg=vi+33: br=vi+32 
3020 xs=vic: xh=vi+16: ys=vi+1
!-   Spr0 enable, expand X, expand Y
3030 en=vi+21: ex=vi+23: ey=vi+29 
!-   Spr0 colour, priority vs char
3040 co=vi+39: pr=vi+27 
3050 sid=54272: wa=sid+4: vol=sid+24: ad=sid+5: sr=sid+6
3060 noise=129: tr=17: saw=33: l1=sid: h1=sid+1
3070 yy$="{home}{down*25}"
3080 xx$="{right*39}"
!-   Array contain the maze
3090 DIM maze$(23)
!-   Plant random seed 
3100 x=RND(-TI)
!-
!-   Setup game data/variables
!-   Black border & bground
3110 POKE br,0: POKE bg,0 
!-   Print title of game & instruction
3120 GOSUB 8000 
!-   Poke ML programs 
!-   (1) 49152 - print maze(i) 
!-   (2) 49155 - Copy character ROM to $3000 (12288)
3130 GOSUB 5000 
!-   Call 2nd ML program to copy char ROM
3135 SYS 49155 
!-   Charset -> $3000
3140 POKE 53272,(PEEK(53272)AND 240)OR 12 
!-   Switch to lowercase
3150 PRINT CHR$(14);
!-   Create custom characters
3160 GOSUB 6000 
!-   Define sprite image(s)
3170 GOSUB 7000 
3180 GOSUB 9000
3200 a$="Hit any key to begin": b$="{pink}"
3210 PRINT LEFT$(yy$,23);LEFT$(xx$,10);b$;a$
3220 FOR i=1 to 1000: NEXT
3230 GET k$
3240 IF k$<>"" THEN RETURN 
3250 IF b$="{pink}" THEN b$="{white}": GOTO 3210
3260 b$="{pink}": GOTO 3210
!-
!---------------------------------------------------------------
!-   ML Codes:  (1) Print a line of maze(i) - SYS 49152,i,maze$(i)
!-              (2) Copy char ROM to RAM@$3000 - SYS 49155
5000 a = 49152
5010 FOR i = 0 TO 276
5020 READ d% : POKE a+i,d%: NEXT
5025 RETURN
5030 DATA 76,6,192,76,179,192,32,253
5040 DATA 174,32,158,183,142,226,192,32
5050 DATA 253,174,32,158,173,32,163,182
5060 DATA 36,13,16,10,141,227,192,134
5070 DATA 251,132,252,76,43,192,162,22
5080 DATA 76,55,164,172,226,192,185,229
5090 DATA 192,133,253,185,253,192,133,254
5100 DATA 160,0,177,251,201,32,208,4
5110 DATA 72,76,161,192,201,35,208,6
5120 DATA 169,64,72,76,161,192,201,46
5130 DATA 208,6,169,32,72,76,161,192
5140 DATA 201,45,208,6,169,68,72,76
5150 DATA 161,192,201,38,208,8,169,74
5160 DATA 72,169,73,76,161,192,201,47
5170 DATA 208,8,169,67,72,169,66,76
5180 DATA 161,192,201,43,208,8,169,76
5190 DATA 72,169,75,76,161,192,201,42
5200 DATA 208,8,169,72,72,169,71,76
5210 DATA 161,192,201,64,208,8,169,70
5220 DATA 72,169,69,76,161,192,169,33
5230 DATA 72,145,253,230,253,208,2,230
5240 DATA 254,104,145,253,200,204,227,192
5250 DATA 208,136,96,120,165,1,41,251
5260 DATA 133,1,169,0,133,251,133,253
5270 DATA 169,208,133,252,169,48,133,254
5280 DATA 160,0,162,16,177,251,145,253
5290 DATA 200,208,249,230,252,230,254,202
5300 DATA 208,242,165,1,9,4,133,1
5310 DATA 88,96,0,0,0,0,40,80
5320 DATA 120,160,200,240,24,64,104,144
5330 DATA 184,224,8,48,88,128,168,208
5340 DATA 248,32,72,112,152,4,4,4
5350 DATA 4,4,4,4,5,5,5,5
5360 DATA 5,5,6,6,6,6,6,6
5370 DATA 6,7,7,7,7
!-
!---------------------------------------------------------------
!-   Create custom characters
6000 READ a
6010 IF a=0 THEN 6070
6020 FOR n=0 TO 7
6030   READ d
6040   POKE 12288+A*8+N,D
6050 NEXT
6060 GOTO 6000
6070 RETURN
!-   Index, Data,...,...,...x8
6100 DATA 64, 0,251,251,251,0,223,223,223
6105 DATA 291, 0,251,251,251,0,223,223,223 :REM '#' lowercase
6110 DATA 65, 0,0,0,0,0,0,0,1
6120 DATA 66, 0,0,0,0,3,126,28,100
6130 DATA 67, 0,12,56,224,128,0,0,0
6140 DATA 68, 0,0,0,255,255,0,0,0
6150 DATA 69, 0,3,15,63,63,31,7,0
6160 DATA 70, 0,224,248,252,252,240,192,0
6170 DATA 71, 6,1,3,7,7,7,3,0
6180 DATA 72, 0,128,192,224,224,224,192,0
6190 DATA 73, 24,32,64,127,127,127,48,96
6200 DATA 74, 0,56,254,248,254,240,96,56
6210 DATA 75, 0,24,36,39,36,24,0,0
6220 DATA 76, 0,0,0,252,20,20,0,0
6230 DATA 77, 0,0,0,170,85,0,0,0
6290 DATA 0
!-
!---------------------------------------------------------------
!-   Create sprite image
7000 FOR a=0 to 64*2-1
7010   READ d
7020   POKE 15360+a,d
7030 NEXT
!-   Spr0 image at $3C00 (15360)
!-   7050 POKE sp,240 
7040 POKE sp,240: POKE sp+1,241 
!-   Spr0+1 expand Y 
7060 POKE ex,0: POKE ey,3 
!-   Spr0 is red, Spr1 is yellow
7070 POKE co,2: POKE co+1,7
!-   Set Spr1 priority behind characters
7075 POKE pr,2
7090 RETURN
!-   Data for Spr0 = Man + lighted area
7200 DATA 0,0,0,0,0,0,0,0,0
7210 DATA 0,0,0,0,0,0,0,0,0
7220 DATA 0,0,0,0,0,0,0,16,0
7230 DATA 0,56,0,0,18,0,0,60,0
7240 DATA 0,80,0,0,16,0,0,40,0
7250 DATA 0,40,0,0,0,0,0,0,0
7260 DATA 0,0,0,0,0,0,0,0,0
7270 DATA 0
7300 DATA 0,255,0,3,255,192,15,255,240
7310 DATA 31,255,248,63,255,252,63,255,252
7320 DATA 127,255,254,127,255,254,255,255,255
7330 DATA 255,255,255,255,255,255,255,255,255
7340 DATA 255,255,255,255,255,255,255,255,255
7350 DATA 127,255,254,127,255,254,31,255,252
7360 DATA 31,255,248,7,255,224,1,255,128
7370 DATA 0
!-
!---------------------------------------------------------------
!-   Title screen 
!-         Clear     Black     Lowercase
8000 PRINT CHR$(14);"{clear}{red}"
8010 PRINT TAB(8)" ##  #   ## ### #    ##"
8020 PRINT TAB(8)"#   # # #    #  #   #"
8030 PRINT TAB(8)"#   # # ###  #  #   ##"
8040 PRINT TAB(8)"#   ###   #  #  #   #"
8050 PRINT TAB(8)"### # # ###  #  ### ###"
8055 PRINT
8060 PRINT TAB(6)"##  # # ##   ##  ##  ## ##"
8070 PRINT TAB(6)"# # # # # # #   #   # # # #"
8080 PRINT TAB(6)"# # # # # # # # ##  # # # #"
8090 PRINT TAB(6)"# # # # # # # # #   # # # #"
8100 PRINT TAB(6)"##  ##  # # ### ### ##  # #"
8110 PRINT "{white}"
8120 PRINT "Find and defuse the bombs hidden in the"
8130 PRINT " dungeon. Don't fall into a pit or get"
8140 PRINT "           eaten by a beast."
8145 PRINT
8150 PRINT "Press the {reverse on}{yellow}L{reverse off}{white} key for a levitation spell."
8155 PRINT
8160 PRINT "     You have {yellow}5 minutes{white} to complete"
8170 PRINT "              your quest."
8190 RETURN
!-
!---------------------------------------------------------------
!-   Define a set of short musical notes
9000 DIM no(2,7), nl(2,7), dur(2,7)
9010 FOR i=1 TO 4
9020   READ no(1,i), du(1,i)
9030 NEXT
9040 FOR i=1 to 7
9050   READ no(2,i), nl(2,i), dur(2,i)
9060 NEXT
9070 RETURN
!-
9080 DATA 8,100, 7,50, 7,50, 12,300
9090 DATA 14,2,24, 100,2,24, 100,2,24, 100,2,163
9100 DATA 100,2,24, 100,2,163, 100,3,35

