   10 REM Castle Dungeon 0.9 BeebEm (BBC Model B+) version
   20 REM PART 1+2
   30
   40 MODE 7
   50 PROC_titlescreen
   60 MODE 5
   70 PROC_initialization
   80 PROC_customchar
   90 VDU 23,1,0;0;0;0;
  100
  110 play = TRUE
  120 REPEAT
  130   PROC_makemaze
  140   CLS
  150   PROC_initgame
  160   REPEAT
  170     PROC_playgame
  180   UNTIL gameover
  190   play = FN_playagain
  200 UNTIL play = FALSE
  210 CLS
  220 PRINT "BYE!"
  230 END
  240
  250 DEF PROC_makemaze
  260 CLS
  270 PRINT TAB(5,12);"Please wait"
  280 maze$(0)  = "####################"
  290 maze$(1)  = "#..#..#     #      #"
  300 maze$(2)  = "#..#..# ### # #### #"
  310 maze$(3)  = "#-###-# #   # #..# #"
  320 maze$(4)  = "# #   # # ###-#..# #"
  330 maze$(5)  = "# # # # #  #..#-## #"
  340 maze$(6)  = "#   # #-## #..#    #"
  350 maze$(7)  = "##### #..# #### ####"
  360 maze$(8)  = "#     #..#    # #..#"
  370 maze$(9)  = "# ### #### #  # #..#"
  380 maze$(10) = "# #      # #### ##-#"
  390 maze$(11) = "# #  #   #         #"
  400 maze$(12) = "# ######## #-##### #"
  410 maze$(13) = "#          #..#..# #"
  420 maze$(14) = "### # #-## #..#..# #"
  430 maze$(15) = "# # # #..# #####-# #"
  440 maze$(16) = "# # # #..#  #..# # #"
  450 maze$(17) = "#   ####### #..# # #"
  460 maze$(18) = "# # #       #-##   #"
  470 maze$(19) = "# ######### #    # #"
  480 maze$(20) = "#-#..#    # ## #####"
  490 maze$(21) = "#....#  #   #    ..#"
  500 maze$(22) = "####################"
  510 REM Replace wall, door & empty space with custom chars
  520 FOR row=0 TO 22
  530   m$ = ""
  540   FOR i=1 TO 20
  550     n$ = MID$(maze$(row),i,1)
  560     IF n$="#" THEN m$ = m$ + CHR$(wall%) :GOTO 610
  570     IF n$="-" THEN m$ = m$ + CHR$(door%) :GOTO 610
  580     IF n$="." THEN m$ = m$ + CHR$(room%) :GOTO 610
  590     IF n$=" " THEN m$ = m$ + CHR$(empty%) :GOTO 610
  600     m$ = m$ + n$
  610   NEXT
  620   maze$(row) = m$
  630 NEXT
  640 REM Place stuff at random locations
  650 FOR i=1 TO 3
  660   PROC_randomroom(bomb%)
  670 NEXT
  680 FOR i=1 TO 2
  690   PROC_randomplace(beast%)
  700 NEXT
  710 FOR i=1 TO 7
  720   PROC_randomroom(beast%)
  730 NEXT
  740 PROC_randomplace(key%)
  750 PROC_randomplace(sword%)
  760 FOR i=1 TO 3
  770   PROC_randomplace(pit%)
  780 NEXT
  790 ENDPROC
  800
  810 DEF PROC_randomplace(ch)
  820 REPEAT
  830   x = RND(20)
  840   y = RND(22)
  850   n$ = MID$(maze$(y),x,1)
  860 UNTIL ASC(n$)=empty%
  870 m$ = LEFT$(maze$(y),x-1)
  880 m$ = m$ + CHR$(ch)
  890 m$ = m$ + RIGHT$(maze$(y),20-x)
  900 maze$(y) = m$
  910 ENDPROC
  920
  930 DEF PROC_randomroom(ch)
  940 REPEAT
  950   x = RND(20)
  960   y = RND(22)
  970   n$ = MID$(maze$(y),x,1)
  980 UNTIL ASC(n$)=room%
  990 m$ = LEFT$(maze$(y),x-1)
 1000 m$ = m$ + CHR$(ch)
 1010 m$ = m$ + RIGHT$(maze$(y),20-x)
 1020 maze$(y) = m$
 1030 ENDPROC
 1040
 1050 DEF PROC_initgame
 1060 REPEAT
 1070   x = RND(20)
 1080   y = RND(22)
 1090   n$ = MID$(maze$(y),x,1)
 1100 UNTIL n$=CHR$(empty%)
 1110 dx = 0 :dy = 0
 1120 timelimit = 30000
 1130 tstart = TIME
 1140 gameover = FALSE
 1150 spell = 0
 1160 usword = FALSE
 1170 ukey = FALSE
 1180 ubombs = 0
 1190 PROC_sound_pling
 1200 ENDPROC
 1210
 1220 REM **************** THE GAME LOOP **********************
 1230 DEF PROC_playgame
 1240 COLOUR YELLOW%
 1250 PROC_moveplayer
 1260 IF spell=2 THEN spell=0
 1270 IF spell=1 THEN spell=2
 1280 tgame = TIME - tstart
 1290 IF tgame > timelimit THEN PROC_lostcastle :gameover=TRUE
 1300 PROC_printtimebar(tgame)
 1310 PROC_printstatus
 1320 k = INKEY(1000)
 1330 IF k=74 THEN dx=-1
 1340 IF k=76 THEN dx=1
 1350 IF k=73 THEN dy=-1
 1360 IF k=75 THEN dy=1
 1370 IF k=32 THEN PROC_sound_levitate :spell = 1
 1380 ns$ = MID$(maze$(y+dy),x+dx,1)
 1390 IF ns$=CHR$(wall%) THEN dx=0 :dy=0
 1400 IF ns$=CHR$(sword%) THEN PROC_removeitem(x+dx,y+dy) :usword=TRUE
 1410 IF ns$=CHR$(key%) THEN PROC_removeitem(x+dx,y+dy) :ukey = TRUE
 1420 IF ns$=CHR$(bomb%) THEN PROC_removeitem(x+dx,y+dy) :ubombs = ubombs+1
 1430 IF ubombs=3 THEN PROC_savedcastle :gameover = TRUE
 1440 IF ns$=CHR$(pit%) AND spell=0 THEN PROC_fellpit :gameover=TRUE
 1450 IF ns$=CHR$(beast%) AND usword THEN PROC_killbeast
 1460 IF ns$=CHR$(beast%) AND usword=FALSE THEN PROC_beastlost :gameover = TRUE
 1470 IF ns$=CHR$(door%) AND ukey THEN PROC_removeitem(x+dx,y+dy)
 1480 IF ns$=CHR$(door%) AND ukey=FALSE THEN PROC_doorbumped
 1490 ENDPROC
 1500 REM **********************************************
 1510
 1520 DEF PROC_printtimebar(tgame)
 1530 tbar = INT((timelimit-tgame)/3000)
 1540 IF tbar>9 THEN tbar = 9
 1550 IF tbar=0 THEN COLOUR RED% ELSE COLOUR WHITE%
 1560 REM
 1570 FOR i=0 TO tbar
 1580   PRINT TAB(i,23);CHR$(bar2%);
 1590 NEXT
 1600 PRINT " "
 1610 ENDPROC
 1620
 1630 DEF PROC_printstatus
 1640 COLOUR BLACK%
 1650 COLOUR WHITE%+128
 1660 IF usword THEN PRINT TAB(14,23);CHR$(sword%)
 1670 IF ukey THEN PRINT TAB(15,23);CHR$(key%)
 1680 IF ubombs>0 THEN PRINT TAB(16,23);CHR$(bomb%)
 1690 IF ubombs>1 THEN PRINT TAB(17,23);CHR$(bomb%)
 1700 IF ubombs>2 THEN PRINT TAB(18,23);CHR$(bomb%)
 1710 COLOUR WHITE%
 1720 COLOUR BLACK%+128
 1730 IF spell THEN PRINT TAB(19,23);"L"; ELSE PRINT TAB(19,23);" ";
 1740 COLOUR YELLOW%
 1750 ENDPROC
 1760
 1770 DEF PROC_moveplayer
 1780 COLOUR YELLOW%
 1790 PROC_erasepart(x,y)
 1800 x = x+dx
 1810 y = y+dy
 1820 PROC_printpart(x,y)
 1830 dx = 0
 1840 dy = 0
 1850 REM PROC_sound_step
 1860 ENDPROC
 1870
 1880 DEF PROC_printpart(x,y)
 1890 FOR i=0 TO 2
 1900   IF y+i>0 THEN m$ = MID$(maze$(y-1+i),x-1,3) :PRINT TAB(x-2,y-1+i);m$
 1910 NEXT
 1920 PRINT TAB(x-1,y);CHR$(man%)
 1930 ENDPROC
 1940
 1950 DEF PROC_erasepart(x,y)
 1960 FOR i=0 TO 2
 1970   IF y+i>0 THEN m$ = "   " :PRINT TAB(x-2,y-1+i);m$
 1980 NEXT
 1990 ENDPROC
 2000
 2010 DEF PROC_removeitem(x,y)
 2020 SOUND 1,-15,166,1
 2030 m1$ = LEFT$(maze$(y),x-1)
 2040 m2$ = RIGHT$(maze$(y),20-x)
 2050 maze$(y) = m1$ + CHR$(empty%) + m2$
 2060 PRINT TAB(x-1,y);CHR$(empty%)
 2070 k = INKEY(7)
 2080 SOUND 2,-15,190,1
 2090 ENDPROC
 2100
 2110 DEF PROC_printmaze
 2120 COLOUR WHITE%
 2130 PRINT TAB(0,0);
 2140 FOR row=0 TO 22
 2150   PRINT maze$(row);
 2160 NEXT
 2170 ENDPROC
 2180
 2190 DEF PROC_lostcastle
 2200 PROC_printmaze
 2210 PROC_explode
 2220 COLOUR RED%
 2230 PRINT TAB(0,13);"THE CASTLE DESTROYED"
 2240 k = INKEY(200)
 2250 ENDPROC
 2260
 2270 DEF PROC_explode
 2280 ENVELOPE 6,3, 0,0,0, 1,1,1, 127,-5,0,-3, 126,0
 2290 ENVELOPE 7,3, 0,0,0, 0,0,0, 127,0,0,-3, 126,0
 2300 SOUND 0,7,4,10
 2310 COLOUR RED%
 2320 FOR row=0 TO 22
 2330   PRINT TAB(0,row);maze$(row);
 2340   SOUND 1,6,x,2
 2350   k = INKEY(4)
 2360   FOR n=0 TO 19
 2370     PRINT TAB(19-n,row);" ";
 2380   NEXT
 2390 NEXT
 2400 CLS
 2410 ENDPROC
 2420
 2430 DEF PROC_savedcastle
 2440 CLS
 2450 RESTORE
 2460 PROC_drawcastle
 2470 COLOUR WHITE%
 2480 PRINT TAB(0,5);"YOU SAVED THE CASTLE"
 2490 PROC_happytune
 2500 k = INKEY(300)
 2510 ENDPROC
 2520
 2530 DEF PROC_beastlost
 2540 PROC_moveplayer
 2550 COLOUR RED%
 2560 PRINT TAB(x-1,y);CHR$(eaten%)
 2570 PROC_sound_beast
 2580 PRINT TAB(0,13);"YOU LOST TO A BEAST!"
 2590 k = INKEY(300)
 2600 ENDPROC
 2610
 2620 DEF PROC_killbeast
 2630 REM PROC_moveplayer
 2640 COLOUR RED%
 2650 PRINT TAB(x+dx-1,y+dy);CHR$(eaten%)
 2660 PROC_sound_beast
 2670 PROC_removeitem(x+dx,y+dy)
 2680 PROC_moveplayer
 2690 k = INKEY(300)
 2700 ENDPROC
 2710
 2720 DEF PROC_fellpit
 2730 PROC_moveplayer
 2740 COLOUR RED%
 2750 PRINT TAB(x-1,y);CHR$(fell%)
 2760 PROC_sound_pitfall
 2770 PRINT TAB(0,13);"YOU FELL INTO A PIT "
 2780 k = INKEY(300)
 2790 ENDPROC
 2800
 2810 DEF PROC_doorbumped
 2820 SOUND 1,-15,1,2
 2830 PRINT TAB(x-1,y);CHR$(empty%)
 2840 PRINT TAB(x+dx-1,y+dy);CHR$(door2%)
 2850 k = INKEY(10)
 2860 SOUND 1,0,0,0
 2870 PRINT TAB(x-1,y);CHR$(man%)
 2880 dx=0 :dy=0
 2890 ENDPROC
 2900
 2910 DEF FN_playagain
 2920 SOUND 1,-15,240,1
 2930 CLS
 2940 COLOUR WHITE%
 2950 PRINT TAB(0,14);" Play again? [Y/N] "
 2960 answer = FALSE
 2970 REPEAT
 2980   a$ = INKEY$(0)
 2990 UNTIL a$="Y" OR a$="y" OR a$="N" OR a$="n"
 3000 IF a$="Y" OR a$="y" THEN answer = TRUE
 3010 =answer
 3020
 3030 DEF PROC_sound_pling
 3040 SOUND 1,-15,196,1
 3050 SOUND 2,-15,220,1
 3060 ENDPROC
 3070
 3080 DEF PROC_sound_foundit
 3090 SOUND 1,-15,166,1
 3100 k = INKEY(10)
 3110 SOUND 2,-15,190,1
 3120 ENDPROC
 3130
 3140 DEF PROC_sound_step
 3150 SOUND 0,-15,1,1
 3160 ENDPROC
 3170
 3180 DEF PROC_sound_pitfall
 3190 LOCAL v, j
 3200 v = 15
 3210 FOR j=154 TO 80 STEP-1
 3220   SOUND 2,-v,j,1
 3230   SOUND 3,-v,j-48,1
 3240   v = v-0.2
 3250 NEXT
 3260 ENDPROC
 3270
 3280 DEF PROC_sound_beast
 3290 LOCAL v, f
 3300 FOR f=0 TO 15
 3310   SOUND 1,-15,f,1
 3320   SOUND 2,-15,f*2,1
 3330   SOUND 0,-f,3,1
 3340 NEXT
 3350 FOR f=15 TO 7 STEP -1
 3360   SOUND 1,-15,f,2
 3370   SOUND 2,-15,f*2,2
 3380   SOUND 0,-f,3,1
 3390 NEXT
 3400 FOR v=15 TO 0 STEP -1
 3410   SOUND 1,-v,f,2
 3420 NEXT
 3430 ENDPROC
 3440
 3450 DEF PROC_sound_levitate
 3460 LOCAL v, n
 3470 FOR n=0 TO 3
 3480   FOR v=0 TO 15 STEP 2
 3490     SOUND 1,-v,88+v*n,1
 3500   NEXT
 3510 NEXT
 3520 ENDPROC
 3530
 3540 DEF PROC_titlescreen
 3550 DIM pitch%(4)
 3560 pitch%(0) = 40   :REM A
 3570 pitch%(1) = 32   :REM G
 3580 pitch%(2) = 24   :REM F
 3590 pitch%(3) = 20   :REM E
 3600 REM
 3610 COLOUR 128
 3620 CLS
 3630 PROC_printtitle
 3640 n = 15
 3650 PRINT TAB(0,n);"Find and defuse the bombs hidden in the"
 3660 PRINT TAB(0,n+1);" dungeon. Don't fall into a pit or get"
 3670 PRINT TAB(0,n+2);" eaten by a beast. Press the SPACE bar"
 3680 PRINT TAB(0,n+3);"   for a levitation spell. You have"
 3690 PRINT TAB(0,n+4);"   5 minutes to complete your quest."
 3700 COLOUR 1
 3710 PRINT TAB(0,n+6);"      Press any key to begin..."
 3720 REPEAT
 3730   FOR i=0 TO 3
 3740     SOUND 1,-15,pitch%(i),20
 3750     k$ = INKEY$(100)
 3760     IF k$<>"" THEN ENDPROC
 3770   NEXT
 3780 UNTIL FALSE
 3790 ENDPROC
 3800
 3810 DEF PROC_printtitle
 3820 PRINT TAB(9,2);" ##  #   ## ### #    ##"
 3830 PRINT TAB(9,3);"#   # # #    #  #   #"
 3840 PRINT TAB(9,4);"#   # # ###  #  #   ##"
 3850 PRINT TAB(9,5);"#   ###   #  #  #   #"
 3860 PRINT TAB(9,6);"### # # ###  #  ### ###"
 3870 PRINT TAB(7, 8);"##  # # ##   ##  ##  ## ##"
 3880 PRINT TAB(7, 9);"# # # # # # #   #   # # # #"
 3890 PRINT TAB(7,10);"# # # # # # # # ##  # # # #"
 3900 PRINT TAB(7,11);"# # # # # # # # #   # # # #"
 3910 PRINT TAB(7,12);"##  ##  # # ### ### ##  # #"
 3920 ENDPROC
 3930
 3940 DEF PROC_initialization
 3950 DIM maze$(23)
   10 DIM happy%(9)
 3960 n = 225
 3970 man% = n
 3980 wall% = n+1
 3990 empty% = n+2
 4000 room% = n+3
 4010 door% = n+4
 4020 door2% = n+5
 4030 key% =  n+6
 4040 sword% = n+7
 4050 bomb% = n+8
 4060 pit% = n+9
 4070 fell% = n+10
 4080 beast% = n+11
 4090 eaten% = n+12
 4100 bar2% = n+13
 4110 REM Colours in BASIC 2 MODE 4
 4120 BLACK% = 0
 4130 RED% = 1
 4140 YELLOW% = 2
 4150 WHITE% = 3
 4160 ENDPROC
 4170
 4180 DEF PROC_customchar
 4190 VDU 23,man%, 239 ,199,237,131,175,239,215,215
 4200 VDU 23,wall%, 255,34,34,34,255,68,68,68
 4210 VDU 23,empty%, 255,255,255,255,255,255,255,255
 4220 VDU 23,room%, 255,255,255,255,255,255,255,255
 4230 VDU 23,door%, 255,255,255,129,129,255,255,255
 4240 VDU 23,door2%, 255,255,231,0,0,231,255,255
 4250 VDU 23,key%, 255,191,95,64,90,186,255,255
 4260 VDU 23,sword%, 255,253,251,247,143,207,175,255
 4270 VDU 23,bomb%, 255,239,247,231,195,195,231,255
 4280 VDU 23,pit%, 255,231,195,129,129,131,199,255
 4290 VDU 23,fell%, 215,239,211,145,129,131,199,255
 4300 VDU 23,beast%, 191,121,112,1,0,135,55,115
 4310 VDU 23,eaten%, 119,181,231,11,208,231,173,238
 4320 VDU 23,bar2%, 0,102,102,102,102,102,102,0
 4330 ENDPROC
 4340
 4350 DEF PROC_drawcastle
 4360 GCOL 0,1
 4370 REPEAT
 4380   READ N
 4390   IF N<>0 THEN PROC_drawlines
 4400 UNTIL N=0
 4410 ENDPROC
 4420 DEF PROC_drawlines
 4430 READ X,Y
 4440 MOVE X,Y
 4450 FOR I=2 TO N
 4460   READ X,Y
 4470   DRAW X,Y
 4480 NEXT
 4490 ENDPROC
 4500 REM Left tower
 4510 DATA 5, 200,200, 200,600, 400,600, 400,200, 200,200
 4520 REM Left battlements
 4530 DATA 12, 200,600, 200,650, 240,650, 240,600, 280,600, 280,650
 4540 DATA 320,650, 320,600, 360,600, 360,650, 400,650, 400,600
 4550 REM Main wall
 4560 DATA 4, 400,200, 800,200, 800,500, 400,500
 4570 REM Right tower
 4580 DATA 5, 800,200, 1000,200, 1000,600, 800,600, 800,200
 4590 REM Right battlements
 4600 DATA 12, 800,600, 800,650, 840,650, 840,600, 880,600, 880,650
 4610 DATA 920,650, 920,600, 960,600, 960,650, 1000,650, 1000,600
 4620 REM Door
 4630 DATA 4, 550,200, 550,350, 650,350, 650,200
 4640 DATA 0
 4650
 4690 DEF PROC_happytune
 4700 FOR i=0 TO 8
 4710   READ happy%(i)
 4720 NEXT
 4730 ENVELOPE 1, 1, 0, 0, 0, 0, 0, 0, 126, -2, -1, -1, 120, 0
 4740 FOR j=1 TO 2
 4750   FOR i=0 TO 8
 4760     SOUND 1, 1, happy%(i), 7
 4770   NEXT
 4780   k = INKEY(170)
 4790 NEXT
 4800 ENDPROC
 4810 DATA 164,164,164,0,148,164,176,0,128
 4820
