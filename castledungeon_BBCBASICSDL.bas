      REM **********************************************************************
      REM Castle Dungeon 0.08
      REM 1 January 2026
      REM Ported from VIC-20 version as appeared in Compute!'s Gazette June 1984
      REM https://archive.org/details/1984-06-computegazette/page/n55/mode/2up
      REM
      REM **********************************************************************


      REM -------------------------------oOo------------------------------------
      REM Main program starts here
      PROC_titlescreen
      PROC_defglobal
      PROC_customchar
      play = TRUE
      WHILE play
        PROC_makemaze
        CLS
        PROC_initgame
        REPEAT
          PROC_playgame
        UNTIL gameover
        play = FN_playagain
      ENDWHILE
      CLS
      PRINT "BYE!"
      END


      REM -------------------------------===------------------------------------
      REM Show title screen
      DEF PROC_titlescreen
      MODE 1 :REM 40x32 chars 4 colours
      CLS
      OFF
      LOCAL text$, pitch()
      DIM text$(10), pitch(4)
      text$(0) = "Find and defuse the bombs hidden in"
      text$(1) = "the dungeon."
      text$(2) = "Don't fall into a pit or get eaten"
      text$(3) = "by a beast."
      text$(4) = "Press the L key for a levitation"
      text$(5) = "spell."
      text$(6) = "You have 5 minutes to complete"
      text$(7) = "your quest."
      text$(8) = "Press any key to begin..."
      text$(9) = " "
      pitch(0) = 40   :REM A
      pitch(1) = 32   :REM G
      pitch(2) = 24   :REM F
      pitch(3) = 20   :REM E
      PROC_drawcastle
      COLOUR 7
      PROC_printtitle
      REM Display instruction and play a tune while waiting for key press
      REM Gong/organ sound
      ENVELOPE 1,4, 0,0,0, 0,0,0, 70,-1,0,-1, 126,100
      n = 0
      REPEAT
        PRINT TAB(0,25);"                                        "
        PRINT TAB(0,26);"                                        "
        k = (40-LEN(text$(n)))/2
        PRINT TAB(k,25);text$(n)
        k = (40-LEN(text$(n+1)))/2
        PRINT TAB(k,26);text$(n+1)
        n = n+2
        IF n>9 THEN n = 0
        FOR i=0 TO 3
          SOUND 1,1,pitch(i),1
          k$ = INKEY$(100)
          IF k$<>"" THEN ENDPROC
        NEXT
      UNTIL FALSE
      ENDPROC


      REM ----------------------------------------------------------------------
      REM Print game title
      DEF PROC_printtitle
      COLOUR 2
      VDU 23,ASC("#"), 254,254,254,0,239,239,239,0
      PRINT TAB(9,1);" ##  #   ## ### #    ##"
      PRINT TAB(9,2);"#   # # #    #  #   #"
      PRINT TAB(9,3);"#   # # ###  #  #   ##"
      PRINT TAB(9,4);"#   ###   #  #  #   #"
      PRINT TAB(9,5);"### # # ###  #  ### ###"
      PRINT TAB(7, 7);"##  # # ##   ##  ##  ## ##"
      PRINT TAB(7, 8);"# # # # # # #   #   # # # #"
      PRINT TAB(7, 9);"# # # # # # # # ##  # # # #"
      PRINT TAB(7,10);"# # # # # # # # #   # # # #"
      PRINT TAB(7,11);"##  ##  # # ### ### ##  # #"
      ENDPROC


      REM ----------------------------------------------------------------------
      REM Draw castle
      DEF PROC_drawcastle
      LOCAL r, c, w, h, x, y
      x = 150: y = 240 :REM Castle position/offset on screen
      w = 80: h = 30 :REM width and height of a brick
      REM Draw castle
      GCOL 0,7
      REM Draw BOTTOM half
      FOR r=1 TO 5 STEP 2
        FOR c=2 TO 10
          RECTANGLE FILL x+c*w, y+r*h, w-5, h-5
        NEXT
      NEXT
      FOR r=2 TO 6 STEP 2
        RECTANGLE FILL x+2*w, y+r*h, w/2-5, h-5
        RECTANGLE FILL x+(10.5)*w, y+r*h, w/2-5, h-5
        FOR c=2 TO 9
          RECTANGLE FILL x+(c+0.5)*w, y+r*h, w-5, h-5
        NEXT
      NEXT
      REM Draw TOP half
      FOR r=7 TO 9 STEP 2
        FOR c=1 TO 11
          RECTANGLE FILL x+c*w, y+r*h, w-5, h-5
        NEXT
      NEXT
      FOR r=8 TO 10 STEP 2
        RECTANGLE FILL x+w, y+r*h, w/2-5, h-5
        RECTANGLE FILL x+(11.5)*w, y+r*h, w/2-5, h-5
        FOR c=1 TO 10
          RECTANGLE FILL x+(c+0.5)*w, y+r*h, w-5, h-5
        NEXT
      NEXT
      REM Draw Battlements
      FOR c=1 TO 11 STEP 2
        RECTANGLE FILL x+c*w, y+11*h, w-5, h-5
      NEXT
      REM Draw door
      GCOL 0,8
      RECTANGLE FILL x+5.5*w-2, y+h, w*2, h*4
      CIRCLE FILL x+6.5*w-1,y+(h+0.5)*4,w
      ENDPROC


      REM ----------------------------------------------------------------------
      REM Draw flags on the castle
      DEF PROC_drawflags
      LOCAL r, c, w, h, x, y
      x = 150: y = 240 :REM Castle position/offset on screen
      w = 80: h = 30 :REM width and height of a brick
      GCOL 0,7
      RECTANGLE FILL x+1*w, y+11*h, 2,3*h
      RECTANGLE FILL x+6.5*w-4, y+11*h, 2,4*h
      RECTANGLE FILL x+12*w-4, y+11*h, 2,3*h
      GCOL 0,1
      RECTANGLE FILL x+1*w, y+14*h, w,h
      RECTANGLE FILL x+6.5*w-4, y+15*h, w,h
      RECTANGLE FILL x+12*w-4, y+14*h, w,h
      ENDPROC


      REM -------------------------------===------------------------------------
      REM Define and set global variables an CONSTANTs
      DEF PROC_defglobal
      REM Values for 16 colours
      BLACK% = 0
      RED% = 1
      GREEN% = 2
      YELLOW% = 3
      BLUE% = 4
      MAGENTA% = 5
      CYAN% = 6
      WHITE% = 7
      REM Pitches for a happy tune
      PITCHES% = 9
      DIM pitch(PITCHES%)
      FOR i=1 TO PITCHES%
        READ pitch(i)
      NEXT
      REM EEE CEG G(lower octave)
      DATA 164,164,164,0,148,164,176,0,128
      ENDPROC


      REM -------------------------------===------------------------------------
      REM Define custom characters
      REM 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47
      REM !  "  #  $  %  &  '  (  )  *  +  ,  -  .  /
      REM 58 59 60 61 62 63 64
      REM :  ;  <  =  >  ?  @
      DEF PROC_customchar
      MODE 2 :REM 20x32 chars 16 colours
      OFF
      man$ = "$"
      VDU 23,ASC(man$), 239,199,237,131,175,239,215,215
      wall$ = "#"
      VDU 23,ASC(wall$), 255,34,34,34,255,68,68,68
      empty$ = "_"
      VDU 23,ASC(empty$), 255,255,255,255,255,255,255,255
      room$ = "."
      VDU 23,ASC(room$), 255,255,255,255,255,255,255,255
      door$ = "-"
      VDU 23,ASC(door$), 255,255,255,129,129,255,255,255
      pit$ = "@"
      VDU 23,ASC(pit$), 255,231,195,129,129,131,199,255
      fell$ = "{"
      VDU 23,ASC(fell$), 215,239,211,145,129,131,199,255
      key$ = "\"
      VDU 23,ASC(key$), 255,191,95,64,90,186,255,255
      beast$ = "&"
      VDU 23,ASC(beast$), 191,121,112,1,0,135,55,115
      eat$ = "}"
      VDU 23,ASC(eat$), 119,181,231,11,208,231,173,238
      bomb$ = "*"
      VDU 23,ASC(bomb$), 255,239,247,231,195,195,231,255
      sword$ = "|"
      VDU 23,ASC(sword$), 255,253,251,247,143,207,175,255
      dragon$ = "%"
      VDU 23,ASC(dragon$), 191,121,112,1,0,135,55,115
      door2$ = ";"
      VDU 23,ASC(door2$), 255,255,231,0,0,231,255,255
      blok$ = "+"
      VDU 23,ASC(blok$), 0,170,170,170,170,170,170,0
      ENDPROC


      REM -------------------------------===------------------------------------
      REM Build/make the maze
      DEF PROC_makemaze
      DIM maze$(23)
      maze$(0)  = "####################"
      maze$(1)  = "#..#..#     #      #"
      maze$(2)  = "#..#..# ### # #### #"
      maze$(3)  = "#-###-# #   # #..# #"
      maze$(4)  = "# #   # # ###-#..# #"
      maze$(5)  = "# # # # #  #..#-## #"
      maze$(6)  = "#   # #-## #..#    #"
      maze$(7)  = "##### #..# #### ####"
      maze$(8)  = "#     #..#    # #..#"
      maze$(9)  = "# ### #### #  # #..#"
      maze$(10) = "# #      # #### ##-#"
      maze$(11) = "# #  #   #         #"
      maze$(12) = "# ######## #-##### #"
      maze$(13) = "#          #..#..# #"
      maze$(14) = "### # #-## #..#..# #"
      maze$(15) = "# # # #..# #####-# #"
      maze$(16) = "# # # #..#  #..# # #"
      maze$(17) = "#   ####### #..# # #"
      maze$(18) = "# # #       #-##   #"
      maze$(19) = "# ######### #    # #"
      maze$(20) = "#-#..#    # ## #####"
      maze$(21) = "#....#  #   #    ..#"
      maze$(22) = "####################"
      REM
      REM Replace (space) with (inverted space) in the maze
      FOR row=0 TO 22
        m$ = ""
        FOR i=1 TO 20
          n$ = MID$(maze$(row),i,1)
          IF n$<>" " THEN
            m$ = m$ + n$
          ELSE
            m$ = m$ + empty$
          ENDIF
        NEXT
        maze$(row) = m$
      NEXT
      REM
      REM Place stuff at random locations
      REM Place bombs
      FOR i=1 TO 3
        PROC_randomroom(bomb$)
      NEXT
      REM Place beasts
      FOR i=1 TO 2
        PROC_randomplace(beast$)
      NEXT
      FOR i=1 TO 7
        PROC_randomroom(beast$)
      NEXT
      REM Place key
      PROC_randomplace(key$)
      REM Place sword
      PROC_randomplace(sword$)
      REM Place pits
      FOR i=1 TO 3
        PROC_randomplace(pit$)
      NEXT
      ENDPROC


      REM -----------------------------------------------------------------------
      REM Put item x$ at a random place in the dungeon
      DEF PROC_randomplace(x$)
      PRINT empty$
      REPEAT
        x = RND(20)
        y = RND(22)
        n$ = MID$(maze$(y),x,1)
      UNTIL n$=empty$
      m$ = LEFT$(maze$(y),x-1)
      m$ = m$ + x$
      m$ = m$ + RIGHT$(maze$(y),20-x)
      maze$(y) = m$
      ENDPROC


      REM -----------------------------------------------------------------------
      REM Put item x$ in a random room in the dungeon
      DEF PROC_randomroom(x$)
      REPEAT
        x = RND(20)
        y = RND(22)
        n$ = MID$(maze$(y),x,1)
      UNTIL n$=room$
      m$ = LEFT$(maze$(y),x-1)
      m$ = m$ + x$
      m$ = m$ + RIGHT$(maze$(y),20-x)
      maze$(y) = m$
      ENDPROC


      REM -------------------------------===------------------------------------
      REM Initialize game parameters
      DEF PROC_initgame
      REM Place player (randomly)
      REPEAT
        x = RND(20)
        y = RND(22)
        n$ = MID$(maze$(y),x,1)
      UNTIL n$=empty$
      REM Reset game variables
      timelimit = 30000       :REM 5 minutes = 5*60*100 = 30000
      tstart = TIME           :REM Mark start of game
      bombs = 0
      spell = FALSE
      sword = FALSE
      key = FALSE
      gameover = FALSE
      PROC_printstatus
      COLOUR YELLOW%
      PROC_printpart(x,y)
      PROC_sound_pling
      ENDPROC


      REM ======================================================================
      REM Main game routine
      REM ----------------------------------------------------------------------
      DEF PROC_playgame
      REM Check if time limit reached
      tgame = TIME - tstart
      IF tgame > timelimit THEN
        PROC_printmaze
        PROC_explode
        PROC_lostcastle
        gameover = TRUE
      ENDIF

      PROC_printtimebar(tgame)
      PROC_printstatus

      REM Get user's move
      dx = 0
      dy = 0
      k = INKEY(100)
      REM Directions
      IF k=136 THEN dx=-1
      IF k=137 THEN dx=1
      IF k=139 THEN dy=-1
      IF k=138 THEN dy=1
      REM Levitation spell L
      IF k=108 OR k=76 THEN
        PROC_sound_levitate
        spell = TRUE
      ENDIF
      REM Show map?
      IF k=109 OR k=77 THEN
        PROC_printmaze
        WAIT 300 :REM 3 seconds should be enough
        CLS
      ENDIF

      REM What is in the cell we are moving to?
      ns$ = MID$(maze$(y+dy),x+dx,1)

      REM Hit a wall
      IF ns$=wall$ THEN
        dx=0
        dy=0
      ENDIF

      REM Walk into a pit
      IF ns$=pit$ THEN
        IF spell=FALSE THEN
          PROC_fellpit     :REM No levitation spell
          gameover = TRUE  :REM .. you're dead
        ENDIF
      ENDIF

      REM Found sword?
      IF ns$=sword$ THEN
        PROC_sound_foundit
        sword = TRUE
        PROC_removeitem(x+dx,y+dy)
      ENDIF

      REM Found key?
      IF ns$=key$ THEN
        PROC_sound_foundit
        key = TRUE
        PROC_removeitem(x+dx,y+dy)
        PROC_printstatus
      ENDIF

      REM Found bomb?
      IF ns$=bomb$ THEN
        PROC_sound_foundit
        PROC_removeitem(x+dx,y+dy)
        PROC_printstatus
        bombs = bombs+1
        IF bombs=3 THEN
          PROC_savedcastle
          gameover = TRUE
        ENDIF
        COLOUR YELLOW%
      ENDIF

      REM Walked into beast
      IF ns$=beast$ THEN
        IF sword= FALSE THEN
          PROC_beastlost
          gameover = TRUE
        ELSE
          COLOUR YELLOW%
          COLOUR RED%+128
          PRINT TAB(x+dx-1,y+dy);eat$
          PROC_sound_beast
          COLOUR YELLOW%
          COLOUR BLACK%+128
          PROC_removeitem(x+dx,y+dy)
        ENDIF
      ENDIF

      REM Walk into a door, no key
      COLOUR YELLOW%
      IF ns$=door$ THEN
        IF key=FALSE THEN
          PROC_sound_bumped
          PRINT TAB(x-1,y);empty$
          PRINT TAB(x+dx-1,y+dy);door2$
          WAIT 10
          PRINT TAB(x+dx-1,y+dy);door$
          PRINT TAB(x-1,y);man$
          dx = 0
          dy = 0
        ELSE
          PROC_removeitem(x+dx,y+dy)
        ENDIF
      ENDIF

      IF NOT gameover THEN
        IF dx<>0 OR dy<>0 THEN
          PROC_moveplayer
          spell = FALSE
        ENDIF
      ENDIF

      ENDPROC


      REM ----------------------------------------------------------------------
      REM Print time bar
      DEF PROC_printtimebar(tgame)
      tbar = INT((timelimit-tgame)/3000)  :REM Divide into 10 bars
      IF tbar>9 THEN tbar = 9
      PRINT TAB(0,23);"           "
      IF tbar=0 THEN
        COLOUR RED%
      ELSE
        COLOUR GREEN%
      ENDIF
      FOR i=0 TO tbar
        PRINT TAB(i,23);blok$
      NEXT
      ENDPROC


      REM ----------------------------------------------------------------------
      REM Print status bar
      DEF PROC_printstatus
      COLOUR BLACK%
      COLOUR GREEN%+128
      IF sword THEN PRINT TAB(14,23);sword$
      IF key THEN PRINT TAB(15,23);key$
      IF bombs>0 THEN
        FOR i=1 TO bombs
          PRINT TAB(15+i,23);bomb$
        NEXT
      ENDIF
      COLOUR GREEN%
      COLOUR BLACK%+128
      IF spell THEN
        PRINT TAB(19,23);"L";
      ELSE
        PRINT TAB(19,23);" ";
      ENDIF
      ENDPROC


      REM ----------------------------------------------------------------------
      REM Move player to new postion
      DEF PROC_moveplayer
      PROC_erasepart(x,y)
      x = x+dx
      y = y+dy
      PROC_printpart(x,y)
      PROC_sound_step
      ENDPROC


      REM ----------------------------------------------------------------------
      REM Print small part of the maze
      REM       x = 1..20    y = 0..22
      DEF PROC_printpart(x,y)
      FOR i=0 TO 2
        IF y+i>0 THEN
          m$ = MID$(maze$(y-1+i),x-1,3)
          PRINT TAB(x-2,y-1+i);m$
        ENDIF
      NEXT
      PRINT TAB(x-1,y);man$
      ENDPROC


      REM ----------------------------------------------------------------------
      REM Erase small part of the maze
      REM       x = 1..20    y = 1..22
      DEF PROC_erasepart(x,y)
      FOR i=0 TO 2
        IF y+i>0 THEN
          m$ = "   "
          PRINT TAB(x-2,y-1+i);m$
        ENDIF
      NEXT
      ENDPROC


      REM ----------------------------------------------------------------------
      REM Remove item from the maze
      REM       x = 1..20    y = 1..22
      DEF PROC_removeitem(x,y)
      m1$ = LEFT$(maze$(y),x-1)
      m2$ = RIGHT$(maze$(y),20-x)
      maze$(y) = m1$ + empty$ + m2$
      PRINT TAB(x-1,y);empty$
      ENDPROC


      REM ----------------------------------------------------------------------
      REM Print the maze
      DEF PROC_printmaze
      COLOUR BLUE%
      PRINT TAB(0,0);
      FOR row=0 TO 22
        PRINT maze$(row);
      NEXT
      ENDPROC


      REM ----------------------------------------------------------------------
      REM Lost castle because time is up
      DEF PROC_lostcastle
      COLOUR RED%
      PRINT TAB(0,11);"                    "
      PRINT TAB(0,12);"THE CASTLE DESTROYED"
      PRINT TAB(0,13);"                    "
      WAIT 200
      ENDPROC


      REM ----------------------------------------------------------------------
      REM 'Explode the castle by randomly removing parts
      DEF PROC_explode
      ENVELOPE 6,3, 0,0,0, 1,1,1, 127,-5,0,-3, 126,0
      ENVELOPE 7,3, 0,0,0, 0,0,0, 127,0,0,-3, 126,0
      SOUND 0,7,4,10
      COLOUR RED%
      FOR n=1 TO 90
        x = RND(7)*3
        y = RND(8)*3-2
        PROC_printpart(x,y)
        SOUND 1,6,x,1
        WAIT 1
        PROC_erasepart(x,y)
      NEXT
      CLS
      ENDPROC


      REM ----------------------------------------------------------------------
      REM Castle is saved
      DEF PROC_savedcastle
      CLS
      PROC_drawcastle
      PROC_drawflags
      COLOUR GREEN%+8
      PRINT TAB(0,25);"YOU SAVED THE CASTLE"
      PROC_happytune
      WAIT 300
      ENDPROC


      REM ----------------------------------------------------------------------
      REM Lost to a beast
      DEF PROC_beastlost
      COLOUR RED%+8
      PROC_moveplayer
      m$ = LEFT$(maze$(y),x-1)
      m$ = m$ + fell$
      m$ = m$ + RIGHT$(maze$(y),20-x)
      maze$(y) = m$
      COLOUR RED%+8
      PRINT TAB(x-1,y);eat$
      PROC_sound_beast
      COLOUR RED%
      PRINT TAB(0,11);"                    "
      PRINT TAB(0,12);"YOU LOST TO A BEAST!"
      PRINT TAB(0,13);"                    "
      WAIT 200
      ENDPROC


      REM ----------------------------------------------------------------------
      REM Fell into a pit
      DEF PROC_fellpit
      COLOUR RED%+8
      PROC_moveplayer
      m$ = LEFT$(maze$(y),x-1)
      m$ = m$ + fell$
      m$ = m$ + RIGHT$(maze$(y),20-x)
      maze$(y) = m$
      PRINT TAB(x-1,y);fell$
      PROC_sound_pitfall
      COLOUR RED%
      PRINT TAB(0,11);"                    "
      PRINT TAB(0,12);"YOU FELL INTO A PIT "
      PRINT TAB(0,13);"                    "
      WAIT 300
      ENDPROC


      REM -------------------------------===------------------------------------
      REM Ask if user wants to play again
      DEF FN_playagain
      SOUND 1,-15,240,3
      CLS
      COLOUR WHITE%
      PRINT TAB(0,11);"                    "
      PRINT TAB(0,12);" Play again? (Y/N)  "
      PRINT TAB(0,13);"                    "
      answer = FALSE
      REPEAT
        a$ = INKEY$(0)
      UNTIL a$="Y" OR a$="y" OR a$="N" OR a$="n"
      IF a$="Y" OR a$="y" THEN answer = TRUE
      =answer


      REM ----------------------------------------------------------------------
      REM Make pling sound
      DEF PROC_sound_pling
      ENVELOPE 1,4, 0,0,0, 0,0,0, 70,-1,0,-6, 126,100
      SOUND 1,1,196,1
      SOUND 2,1,220,1
      ENDPROC


      REM ----------------------------------------------------------------------
      REM Make ting-tong sound
      DEF PROC_sound_foundit
      ENVELOPE 1,4, 0,0,0, 0,0,0, 70,-1,0,-10, 126,100
      ENVELOPE 2,4, 0,0,0, 0,0,0, 70,-1,0,-6, 126,100
      SOUND 1,1,166,1
      WAIT 10
      SOUND 2,2,190,1
      ENDPROC


      REM ----------------------------------------------------------------------
      REM Make foot step sound
      DEF PROC_sound_step
      ENVELOPE 1,1, 0,0,0, 0,0,0, 70,-20,0,-20, 66,0
      SOUND 0,1,1,1
      ENDPROC


      REM ----------------------------------------------------------------------
      REM Make 'bumping into a wall' sound
      DEF PROC_sound_bumped
      ENVELOPE 1,4, 0,0,0, 0,0,0, 70,-1,0,-10, 126,100
      SOUND 1,1,1,1
      ENDPROC


      REM ----------------------------------------------------------------------
      REM Sound of falling into a pit
      DEF PROC_sound_pitfall
      LOCAL v, j
      v = 15
      FOR j=154 TO 80 STEP-1
        SOUND 2,-v,j,1
        SOUND 3,-v,j-48,1
        v = v-0.2
      NEXT
      ENDPROC


      REM ----------------------------------------------------------------------
      REM Make beast sound
      DEF PROC_sound_beast
      LOCAL v, f
      FOR f=0 TO 15
        SOUND 1,-15,f,1
        SOUND 2,-15,f*2,1
        SOUND 0,-f,3,1
      NEXT
      FOR f=15 TO 7 STEP -1
        SOUND 1,-15,f,2
        SOUND 2,-15,f*2,2
        SOUND 0,-f,3,1
      NEXT
      FOR v=15 TO 0 STEP -1
        SOUND 1,-v,f,2
      NEXT
      ENDPROC


      REM ----------------------------------------------------------------------
      REM Make a 'woot-woot-woot' sound
      DEF PROC_sound_levitate
      LOCAL v, n
      FOR n=0 TO 3
        FOR v=0 TO 15 STEP 2
          SOUND 1,-v,88+v*n,1
        NEXT
      NEXT
      ENDPROC


      REM ----------------------------------------------------------------------
      REM Play a happy tune
      DEF PROC_happytune
      REM Ting/piano sound
      ENVELOPE 6,3, 0,0,0, 1,1,1, 127,-5,0,-5, 126,0
      FOR i=0 TO PITCHES%
        SOUND 1,6,pitch(i),1
        WAIT 20
      NEXT
      ENDPROC

