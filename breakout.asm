################ CSC258H1F Fall 2022 Assembly Final Project ##################
# This file contains our implementation of Breakout.
#
# Student 1: Shaswata Chowdhury, 1007656163
######################## Bitmap Display Configuration ########################
# - Unit width in pixels:       8
# - Unit height in pixels:      8
# - Display width in pixels:    256
# - Display height in pixels:   512
# - Base Address for Display:   0x10008000 ($gp)
##############################################################################

    .data
##############################################################################
# Immutable Data
##############################################################################
# The address of the bitmap display. Don't forget to connect it!
ADDR_DSPL:
    .word 0x10008000
# The address of the keyboard. Don't forget to connect it!
ADDR_KBRD:
    .word 0xffff0000
#Colours
PDDL_COL:
	.word 0x00ffff #cyan
BALL_COL:
	.word 0xffff00 #yellow

RED:
	.word 0xff0000
GREEN:
	.word 0x00ff00
BLUE:
	.word 0x0000ff
YELLOW:
	.word 0xffff00
GRAY:
	.word 0x808080
BLACK:
	.word 0x000000
WHITE:
	.word 0xffffff
CYAN:
	.word 0x00ffff #cyan
#SCREEN_END: #Comment in once you figure out what the end of the bitmap screen is.
	#.word

#Sound Design
    pitchC: .byte 60
    pitchD: .byte 62
    pitchE: .byte 64
    pitchF: .byte 65
    pitchG: .byte 67
    pitchA: .byte 69
    pitchB: .byte 71
    instrument: .byte 14
    synth: .byte 87
    piano: .byte 1
    drums: .byte 112
    volume: .byte 127
    duration: .byte 500

##############################################################################
# Mutable Data
##############################################################################

#X and Y position of the center of the paddle. will be used to update paddle position.
paddleX: .word 64 #Range: 8 - 120. init: 16*4
paddleY: .word 7680 #Fixed position: initialized during stage setup. 60 *128
paddleXInit: .word 64
paddleYInit: .word 7680
xVel: .word 4
yVel: .word -128 #starts out moving right and up. (128 = 1 * 4 * -32) (moves up 1 row)
xPos: .word 64 #initially 16 pixels from the left.
yPos: .word 4096 #initially 32 rows down.
xPosInitial: .word 64
yPosInitial: .word 4096
#all velocities and positions expressed in terms of the bitmap addresses for ease.
score: .word 0
VictoryScore: .word 90 #reduce to test victory conditions without playing a full game
Lvl1VS: .word 85 #the score needed to win the first level. Reduce to test victory conditions without playing a full game.
Lvl2VS: .word 100 #the score needed to win the second level. Reduce to test victory conditions without playing a full playthrough.
Lives: 3 #Starts with three lives: every time the ball hits the bottom of the screen, lose a life. If lives hits 0, the game is over.

testgraphic: .space 4096
BreakoutLogo: .space 2176 #17 rows * 32 * 4
OptionsMenu: .space 2176 #17 rows * 32 * 4
Level2: .space 8192
WinScreen: .space 2176
OverScreen: .space 2176
##############################################################################
# Code
##############################################################################
	.text
	.globl main

    TestGraphic:
     la $t1, testgraphic
     li $t2, 0xffffff
     sw $t2, 140($t1)
     
     WinScreenDraw:
     la $t1, WinScreen
     lw $t2, GREEN
     #Draw the second line of Breakout!
     sw $t2, 140($t1)
     sw $t2, 156($t1)
     sw $t2, 164($t1)
     sw $t2, 172($t1)
     sw $t2, 176($t1)
     sw $t2, 180($t1)
    
    
    #3 Line
    sw $t2, 268($t1)
    sw $t2, 284($t1)
    sw $t2, 292($t1)
    sw $t2, 300($t1)
    sw $t2, 312($t1)
    
    #4 Line
    sw $t2, 396($t1)
    sw $t2, 404($t1)
    sw $t2, 412($t1)
    sw $t2, 420($t1)
    sw $t2, 428($t1)
    sw $t2, 440($t1)
    
    #5 Line
    sw $t2, 528($t1)
    sw $t2, 536($t1)
    sw $t2, 548($t1)
    sw $t2, 556($t1)
    sw $t2, 568($t1)
    
    OverScreenDraw: #Draws the word OVER.
    la $t1, OverScreen
    lw $t2, RED
    #2 Line
    sw $t2, 140($t1)
    sw $t2, 144($t1)
    sw $t2, 156($t1)
    sw $t2, 164($t1)
    sw $t2, 172($t1)
    sw $t2, 176($t1)
    sw $t2, 180($t1)
    sw $t2, 188($t1)
    sw $t2, 192($t1)
    sw $t2, 196($t1)
    
    #3 Line
    sw $t2, 264($t1)
    sw $t2, 276($t1)
    sw $t2, 284($t1)
    sw $t2, 292($t1)
    sw $t2, 300($t1)
    sw $t2, 316($t1)
    sw $t2, 324($t1)
    
    #4 Line
    sw $t2, 392($t1)
    sw $t2, 404($t1)
    sw $t2, 412($t1)
    sw $t2, 420($t1)
    sw $t2, 428($t1)
    sw $t2, 432($t1)
    sw $t2, 436($t1)
    sw $t2, 444($t1)
    sw $t2, 448($t1)
    
    #5 Line
    sw $t2, 520($t1)
    sw $t2, 532($t1)
    sw $t2, 540($t1)
    sw $t2, 548($t1)
    sw $t2, 556($t1)
    sw $t2, 572($t1)
    sw $t2, 580($t1)
    
    #6 Line
    sw $t2, 652($t1)
    sw $t2, 656($t1)
    sw $t2, 672($t1)
    sw $t2, 684($t1)
    sw $t2, 688($t1)
    sw $t2, 692($t1)
    sw $t2, 700($t1)
    sw $t2, 708($t1)
    
     
    BreakOutLogoDraw:
    la $t1, BreakoutLogo
    lw $t2, WHITE
    #Draw the second line of Breakout!
    sw $t2, 268($t1)
    sw $t2, 272($t1)
    sw $t2, 276($t1)
    
    
    #3 Line
    sw $t2, 396($t1)
    sw $t2, 408($t1)
    sw $t2, 476($t1)
    
    #4 Line
    sw $t2, 524($t1)
    sw $t2, 536($t1)
    sw $t2, 524($t1)
    sw $t2, 544($t1)
    sw $t2, 548($t1)
    sw $t2, 552($t1)
    sw $t2, 564($t1)
    sw $t2, 568($t1)
    sw $t2, 604($t1)
    sw $t2, 612($t1)
    
    #5 Line
    sw $t2, 652($t1)
    sw $t2, 656($t1)
    sw $t2, 660($t1)
    sw $t2, 672($t1)
    sw $t2, 688($t1)
    sw $t2, 700($t1)
    sw $t2, 712($t1)
    sw $t2, 716($t1)
    sw $t2, 732($t1)
    sw $t2, 740($t1)
    
    #6 Line
    sw $t2, 780($t1)
    sw $t2, 792($t1)
    sw $t2, 800($t1)
    sw $t2, 816($t1)
    sw $t2, 820($t1)
    sw $t2, 824($t1)
    sw $t2, 836($t1)
    sw $t2, 848($t1)
    sw $t2, 860($t1)
    sw $t2, 864($t1)
    
    #7 Line
    sw $t2, 908($t1)
    sw $t2, 920($t1)
    sw $t2, 928($t1)
    sw $t2, 944($t1)
    sw $t2, 964($t1)
    sw $t2, 976($t1)
    sw $t2, 988($t1)
    sw $t2, 996($t1)
    
    #8 Line
    sw $t2, 1036($t1)
    sw $t2, 1040($t1)
    sw $t2, 1044($t1)
    sw $t2, 1056($t1)
    sw $t2, 1076($t1)
    sw $t2, 1080($t1)
    sw $t2, 1084($t1)
    sw $t2, 1096($t1)
    sw $t2, 1100($t1)
    sw $t2, 1108($t1)
    sw $t2, 1116($t1)
    sw $t2, 1124($t1)
    
    #9 Line
    
    #10 Line
    
    lw $t2, YELLOW
    
    #11 Line
    sw $t2, 1500($t1)
    sw $t2, 1516($t1)
    
    #12 Line
    sw $t2, 1628($t1)
    sw $t2, 1644($t1)
    
    #13 Line
    sw $t2, 1716($t1)
    sw $t2, 1720($t1)
    sw $t2, 1732($t1)
    sw $t2, 1744($t1)
    sw $t2, 1752($t1)
    sw $t2, 1756($t1)
    sw $t2, 1760($t1)
    sw $t2, 1772($t1)
    
    #14 Line
    sw $t2, 1840($t1)
    sw $t2, 1852($t1)
    sw $t2, 1860($t1)
    sw $t2, 1872($t1)
    sw $t2, 1884($t1)
    sw $t2, 1900($t1)
    
    #15 Line
    sw $t2, 1968($t1)
    sw $t2, 1980($t1)
    sw $t2, 1988($t1)
    sw $t2, 2000($t1)
    sw $t2, 2012($t1)
    sw $t2, 2020($t1)
    
    #16 Line
    sw $t2, 2100($t1)
    sw $t2, 2104($t1)
    sw $t2, 2120($t1)
    sw $t2, 2124($t1)
    sw $t2, 2140($t1)
    sw $t2, 2144($t1)
    sw $t2, 2156($t1)
    
    
    OptionsMenuDraw:
    la $t1, OptionsMenu
    lw $t2, WHITE
    lw $t4, CYAN
    #Draw the second line of Breakout!
    sw $t2, 144($t1)
    sw $t2, 160($t1)
    sw $t2, 168($t1)
    
    
    sw $t4, 184($t1)
    sw $t4, 188($t1)
    
    
    #3 Line
    sw $t2, 272($t1)
    sw $t2, 288($t1)
    sw $t2, 296($t1)
    
    sw $t4, 316($t1)
    
    #4 Line
    sw $t2, 400($t1)
    sw $t2, 416($t1)
    sw $t2, 424($t1)
    
    sw $t4, 444($t1)
    
    #5 Line
    sw $t2, 528($t1)
    sw $t2, 532($t1)
    sw $t2, 536($t1)
    sw $t2, 548($t1)
    sw $t2, 560($t1)
    
    sw $t4, 572($t1)
    
    #6 Line
    
    #7 Line
    sw $t2, 784($t1)
    sw $t2, 800($t1)
    sw $t2, 808($t1)
    
    
    sw $t4, 824($t1)
    sw $t4, 828($t1)
    
    
    #8 Line
    sw $t2, 912($t1)
    sw $t2, 928($t1)
    sw $t2, 936($t1)
    
    sw $t4, 956($t1)
    
    #9 Line
    sw $t2, 1040($t1)
    sw $t2, 1056($t1)
    sw $t2, 1064($t1)
    
    sw $t4, 1080($t1)
    
    #10 Line
    sw $t2, 1168($t1)
    sw $t2, 1172($t1)
    sw $t2, 1176($t1)
    sw $t2, 1188($t1)
    sw $t2, 1200($t1)
    
    sw $t4, 1208($t1)
    sw $t4, 1212($t1)
    
    
    #11 Line
    
    #Draw Esc.
    #12 Line
    sw $t4, 1428($t1)
    sw $t4, 1432($t1)
    sw $t4, 1444($t1)
    sw $t4, 1448($t1)
    sw $t4, 1464($t1)
    sw $t4, 1468($t1)
    
    
    #13 Line
    sw $t4, 1552($t1)
    sw $t4, 1568($t1)
    sw $t4, 1588($t1)
    
    #14 Line
    sw $t4, 1684($t1)
    sw $t4, 1688($t1)
    sw $t4, 1700($t1)
    sw $t4, 1704($t1)
    sw $t4, 1716($t1)
    
    #15 Line
    sw $t4, 1808($t1)
    sw $t4, 1836($t1)
    sw $t4, 1844($t1)
    
    #16 Line
    sw $t4, 1940($t1)
    sw $t4, 1944($t1)
    sw $t4, 1956($t1)
    sw $t4, 1960($t1)
    sw $t4, 1976($t1)
    sw $t4, 1980($t1)
    
    j StartMenu


    Blackout: #Totally blacks out the screen, in order to soft reset the screen
    lw $t0, ADDR_DSPL
    lw $t1, BLACK
    addi $t3, $t0, 0
    addi $t4, $t0, 8188
    
    BlackoutLoop:
    sw $t1, 0($t3)
    addi $t3, $t3, 4
    ble $t3, $t4, BlackoutLoop
    BlackoutLoopEnd:
    
    BlackoutEnd:
    jr $ra
    
    ResetGame: #Resets the game back to the starting conditions.
    #Reset screen by calling Blackout
    #Reset xPos and yPos to the middle of the screen
    #Reset xVel and yVel to the values shown in Mutable Data above.
    #Resets the score counter to zero.
    jal Blackout
    lw $t1, xPosInitial
    lw $t2, yPosInitial
    sw $t1, xPos
    sw $t2, yPos
    lw $t1, paddleXInit
    lw $t2, paddleYInit
    sw $t1, paddleX
    sw $t2, paddleY
    li $t3, 3
    sw $t3, Lives
    li $t3, 0
    sw $t3, score
    j StartMenu

    StartMenu:
    lw $t0, ADDR_DSPL
    addi $t0, $t0, 0
    addi $t2, $zero, 2176
    la $t1, BreakoutLogo
    jal PixelCopy
    
    lw $t0, ADDR_DSPL
    addi $t0, $t0, 2432
    addi $t2, $zero, 2176
    la $t1, OptionsMenu
    jal PixelCopy
    
    j ToggleStart
    
    PixelCopy:
    ble $t2, $zero, PixelCopyEnd
    add $t4, $t1, $t2
    add $t5, $t0, $t2
    lw $t3, 0($t4)
    sw $t3, 0($t5)
    addi $t2, $t2, -4
    j PixelCopy
    
    PixelCopyEnd:
    jr $ra
    

#========START========START========START========START========START========START========START========START========START========START========START========START========
    ToggleStart: #Toggles start pause mode. Screen will simply be still while in this loop. Only accessible from system shift by pressing "p".
    
    lw $t8, ADDR_KBRD
    lw $t9, 0($t8)
    beq $t9, 1, ToggleStartKeyCheck
    j ToggleStartKeyCheckEnd
    
    ToggleStartKeyCheck:
    
    lw $t7, 0xffff0004 #store keypress input in $t7.
    #set system to sleep for some time to create buffer to process instructions
    addi $v0, $zero, 32 #code for syscall sleep
    addi $a0, $zero, 83 #roughly 12 frames per second
    syscall
    
    beq $t7, 49, SetupAndMain # 80 is ASCII for p. Starts the game if reached.
    beq $t7, 50, SetupAndLvl2 
    beq $t7, 27, exit #Shuts down the program if Esc is pressed by the user.
    
    ToggleStartKeyCheckEnd:
    
    j ToggleStart #Keeps looping pause mode. Exit is performed within the loop if p is pressed and recorded by the system.
    
#========START========START========START========START========START========START========START========START========START========START========START========START========

    SetupAndMain:
    jal Blackout
    j main
    
    SetupAndLvl2:
    jal Blackout
    j Level2SceneDraw

	# Run the Brick Breaker game.
main:
    Lvl1:
    # Initialize the game
    li $t1, 0x808080	#$t1 stores colour gray
    li $t2, 0xff0000	#t2 stores colour red
    li $t3, 0x00ff00	#t3 stores colour green
    li $t4, 0x0000ff	#t4 stores colour blue
    li $t6, 0x00ffff	#t6 stores colour cyan.
    
    # Initializing Walls
    
    # Top Wall
    
    addi $t5, $zero, 32		#Width of bitmap is 32 pixels long.
    lw $t0, ADDR_DSPL # loads $t0 = base address for display
    
    topborder: #iteratively draws top border, pixel by pixel
    beq $t5, $zero, topborderend
    sw $t1, 0($t0) #colours pixel gray.
    addi $t0, $t0, 4 #moves to next pixel (4 since it's an address/full word.)
    subi $t5, $t5, 1
    j topborder
    
    topborderend:
    
    lw $t0, ADDR_DSPL #resets t0 to the starting pixel for the display.
    
    # Left Wall
    
    addi $t5, $zero, 64 # Height of display is 64 pixels
    
    leftborder:
    beq $t5, $zero, leftborderend
    sw $t1, 0($t0) #colours pixel gray.
    addi $t0, $t0, 128 #moves to next pixel down (moves right by 32 pixels (each is 4 bytes long address).
    subi $t5, $t5, 1
    j leftborder
    
    leftborderend:
    
    lw $t0, ADDR_DSPL #resets t0 to the starting pixel for the display.
    
    # Right Wall
    
    addi $t5, $zero, 64 # Height of display is 64 pixels
    
    rightborder:
    beq $t5, $zero, rightborderend
    sw $t1, 124($t0) #colours pixel gray on right side gray.
    addi $t0, $t0, 128 #moves to next pixel down (moves right by 32 pixels (each is 4 bytes long address).
    subi $t5, $t5, 1
    j rightborder
    
    rightborderend:
    
    #Initializing the bricks
    
    # 9 rows of space left for scoring and lives counter.
    lw $t0, ADDR_DSPL #resets t0 to the starting pixel for the display.
    addi $t0, $t0, 1156 #moved the address pointer down 9 rows and 1 pixel left to clear the wall.
    addi $t5, $zero, 30 # bricks on entire row not including the walls.
    
    brickrow1:
    beq $t5, $zero, brickrow1end
    sw $t2, 0($t0) #colours pixel red.
    addi $t0, $t0, 4 #moves to next pixel (4 since it's an address/full word.)
    subi $t5, $t5, 1
    j brickrow1
    
    brickrow1end:
    
    lw $t0, ADDR_DSPL
    addi $t0, $t0, 1540 #address pointer on 12th row + 1 pixel
    addi $t5, $zero, 30
    
    brickrow2:
    beq $t5, $zero, brickrow2end
    sw $t3, 0($t0) #colours pixel green.
    addi $t0, $t0, 4 #moves to next pixel (4 since it's an address/full word.)
    subi $t5, $t5, 1
    j brickrow2
    
    brickrow2end:
    
    lw $t0, ADDR_DSPL
    addi $t0, $t0, 1924 #address pointer on 15th row + 1 pixel
    addi $t5, $zero, 30
    
    brickrow3:
    beq $t5, $zero, brickrow3end
    sw $t4, 0($t0) #colours pixel blue.
    addi $t0, $t0, 4 #moves to next pixel (4 since it's an address/full word.)
    subi $t5, $t5, 1
    j brickrow3
    
    brickrow3end:
    
    # Paddle
    # Initial Location: in the middle of the screen, 4 rows from the bottom.
    
    lw $t0, ADDR_DSPL
    addi $t0, $t0, 7680 #address pointer 4 rows from the bottom.
    
    paddle_init: #initializes the paddle in the middle of the 60th row of pixels
    sw $t6, 60($t0)
    sw $t6, 64($t0)
    sw $t6, 68($t0) 
    
    #Initialize Ball in the middle of the screen
    
    lw $t0, ADDR_DSPL
    addi $t0, $t0, 4096 #ball on the 32th row of pixels on the screen.
    
    ball_init: #initializes the paddle in the middle of the 60th row of pixels.
    li $t7, 0xFFFF00
    sw $t7, 64($t0)
    
    
    
    UpdateVictoryScoreLvl1: #Updates the victory score to that of level 1.
    
    lw $t4, Lvl1VS
    sw $t4, VictoryScore
    
    #j exit #Comment in for Milestone 1 testing.

    #Pause until keypress of w,a,s,d (for ball launch direction)
    
# li, $s7, 0

    j LaunchLoopStack
    
Level2SceneDraw: #Draws the second level within an array.
    
    # Initialize the game
    li $t1, 0x808080	#$t1 stores colour gray
    li $t2, 0xff0000	#t2 stores colour red
    li $t3, 0x00ff00	#t3 stores colour green
    li $t4, 0x0000ff	#t4 stores colour blue
    li $t6, 0x00ffff	#t6 stores colour cyan.
    
    # Initializing Walls
    
    # Top Wall
    
    addi $a1, $zero, 32		#Width of bitmap is 32 pixels long.
    addi $t5, $zero, 32
    la $t0, Level2 # loads $t0 = the first address in the array Level2.
    la $a0, Level2
    lw $a2, GRAY
    
    j topborderlvl2
    
    DrawHorizontalLine: #Macro that draws a horizontal line at the address in $a0, of length $a1, in colour $a2
    
    HorLineLoop:
    beq $a1, $zero, HorLineLoopEnd
    sw $a2, 0($a0) #colours pixel in the colour in $a2.
    addi $a0, $a0, 4 #moves to next pixel (4 since it's an address/full word.)
    subi $a1, $a1, 1
    j HorLineLoop
    
    HorLineLoopEnd:
    jr $ra
    
    DrawHorizontalLineEnd:
    
    DrawVerticalLine: #Macro that draws a vertical line at the address in $a0, of length $a1, in colour $a2
    
    VertLineLoop:
    beq $a1, $zero, VertLineLoopEnd
    sw $a2, 0($a0) #colours pixel in the colour in $a2.
    addi $a0, $a0, 128 #moves to next pixel (4 since it's an address/full word.)
    subi $a1, $a1, 1
    j VertLineLoop
    
    VertLineLoopEnd:
    
    jr $ra
    DrawVerticalLineEnd:
    
    topborderlvl2: #iteratively draws top border, pixel by pixel
    addi $a1, $zero, 32		#Width of bitmap is 32 pixels long.
    la $a0, Level2 #loads the address of the array in $a0.
    lw $a2, GRAY
    sw $a2, 0($a0)
    jal DrawHorizontalLine
    
    topborderlvl2end:
    
    la $a0, Level2 #resets a0 to the starting pixel for the display.
    
    # Left Wall
    
    addi $a1, $zero, 64 # Height of display is 64 pixels
    
    leftborderlvl2:
    la $a0, Level2
    addi $a1, $zero, 64
    jal DrawVerticalLine
    
    
    leftborderlvl2end:
    
    la $a0, Level2 #resets t0 to the starting pixel for the display.
    
    # Right Wall
    
    
    rightborderlvl2:
    la $a0, Level2 #resets t0 to the starting pixel for the display.
    addi $a0, $a0, 124 #moves the pointer in $a0 to the rightmost side of the screen
    addi $a1, $zero, 64
    jal DrawVerticalLine #Draws the right border
    
    rightborderlvl2end:
    
    #Initializing the bricks
    
    # 9 rows of space left for scoring and lives counter.
    la $t0, Level2 #resets t0 to the starting pixel for the display.
    addi $t0, $t0, 1156 #moved the address pointer down 9 rows and 1 pixel left to clear the wall.
    addi $t5, $zero, 30 # bricks on entire row not including the walls.
    lw $t2, RED
    
    lvl2brickrow1:
    beq $t5, $zero, lvl2brickrow1end
    sw $t2, 0($t0) #colours pixel red.
    addi $t0, $t0, 4 #moves to next pixel (4 since it's an address/full word.)
    subi $t5, $t5, 1
    j lvl2brickrow1
    
    lvl2brickrow1end:
    
    la $t0, Level2
    addi $t0, $t0, 1540 #address pointer on 12th row + 1 pixel
    addi $t5, $zero, 30
    lw $t3, GREEN
    
    lvl2brickrow2:
    beq $t5, $zero, lvl2brickrow2end
    sw $t3, 0($t0) #colours pixel green.
    addi $t0, $t0, 4 #moves to next pixel (4 since it's an address/full word.)
    subi $t5, $t5, 1
    j lvl2brickrow2
    
    lvl2brickrow2end:
    
    la $t0, Level2
    addi $t0, $t0, 1924 #address pointer on 15th row + 1 pixel
    addi $t5, $zero, 30
    lw $t4, BLUE
    
    lvl2brickrow3:
    beq $t5, $zero, lvl2brickrow3end
    sw $t4, 0($t0) #colours pixel blue.
    addi $t0, $t0, 4 #moves to next pixel (4 since it's an address/full word.)
    subi $t5, $t5, 1
    j lvl2brickrow3
    
    lvl2brickrow3end:
    
    la $t0, Level2
    addi $t0, $t0, 2308 #address pointer on 18th row + 1 pixel
    addi $t5, $zero, 30
    lw $t4, GREEN
    
    lvl2brickrow4:
    beq $t5, $zero, lvl2brickrow4end
    sw $t4, 0($t0) #colours pixel blue.
    addi $t0, $t0, 4 #moves to next pixel (4 since it's an address/full word.)
    subi $t5, $t5, 1
    j lvl2brickrow4
    
    lvl2brickrow4end:
    
    
    la $t0, Level2
    addi $t0, $t0, 2692 #address pointer on 18th row + 1 pixel
    addi $t5, $zero, 30
    lw $t4, RED
    
    lvl2brickrow5:
    beq $t5, $zero, lvl2brickrow5end
    sw $t4, 0($t0) #colours pixel blue.
    addi $t0, $t0, 4 #moves to next pixel (4 since it's an address/full word.)
    subi $t5, $t5, 1
    j lvl2brickrow5
    
    lvl2brickrow5end:
    
    #Unbreakable wall obstacles for lvl 2.
    
    UnbreakableObstacles: #Draws a set of unbreakable walls to turn this simple game into the dark souls of arcade games.
    la $a0, Level2
    addi $a0, $a0, 64
    li $a1, 24
    lw $a2, GRAY
    jal DrawVerticalLine
    
    # Paddle
    # Initial Location: in the middle of the screen, 4 rows from the bottom.
    
    la $t0, Level2
    addi $t0, $t0, 7680 #address pointer 4 rows from the bottom.
    
    lvl2paddle_init: #initializes the paddle in the middle of the 60th row of pixels
    sw $t6, 60($t0)
    sw $t6, 64($t0)
    sw $t6, 68($t0) 
    
    #Initialize Ball in the middle of the screen
    
    la $t0, Level2
    addi $t0, $t0, 4096 #ball on the 32th row of pixels on the screen.
    
    lvl2ball_init: #initializes the paddle in the middle of the 60th row of pixels.
    li $t7, 0xFFFF00
    sw $t7, 64($t0)
    
    UpdateVictoryScoreLvl2: #Updates the victory score to that of level 1.
    
    lw $t4, Lvl2VS
    sw $t4, VictoryScore
    
    #Need to load lvl2 array into bitmap array
    
    LoadLevel2: #loads level 2 from it's array to the bitmap.
    lw $t0, ADDR_DSPL
    addi $t2, $zero, 8196
    la $t1, Level2
    jal PixelCopy
    
    j LaunchLoopStack
    
    
    #========LAUNCH========LAUNCH========LAUNCH========LAUNCH=======LAUNCH========LAUNCH========LAUNCH========LAUNCH========LAUNCH========LAUNCH========
    LaunchLoopStack:
    #store current t values in stack.
    addi $sp, $sp, -4
    sw $t1, 0($sp)
    addi $sp, $sp, -4
    sw $t2, 0($sp)
    addi $sp, $sp, -4
    sw $t3, 0($sp)
    addi $sp, $sp, -4
    sw $t4, 0($sp)
    addi $sp, $sp, -4
    sw $t5, 0($sp)
    addi $sp, $sp, -4
    sw $t6, 0($sp)
    addi $sp, $sp, -4
    sw $t7, 0($sp)
    
    LaunchLoop: #Toggles start pause mode. Screen will simply be still while in this loop. Only accessible from system shift by pressing "p".
    
    lw $t8, ADDR_KBRD
    lw $t9, 0($t8)
    beq $t9, 1, LaunchKeyCheck
    j LaunchKeyCheckEnd
    
    LaunchKeyCheck:
    
    lw $t7, 0xffff0004 #store keypress input in $t7.
    #set system to sleep for some time to create buffer to process instructions
    addi $v0, $zero, 32 #code for syscall sleep
    addi $a0, $zero, 83 #roughly 12 frames per second
    syscall
    
    beq $t7, 119, LaunchUp # 119 is ASCII for w. Sets ball velocity to point up.
    beq $t7, 97, LaunchLeft # 119 is ASCII for a. Sets ball velocity to point up and left.
    beq $t7, 100, LaunchRight # 100 is ASCII for d. Sets ball velocity to point up and right.
    beq $t7, 115, LaunchDown # 119 is ASCII for s. Sets ball velocity to point down.
    j LaunchKeyCheckEnd
    
    	LaunchUp:
    	li $t2, 0 #sets x velocity to 0
    	li $t3, -128 #sets y velocity upwards
    	
    	sw $t2, xVel
    	sw $t3, yVel
    	j LaunchLoopEnd
    	
    	LaunchDown:
    	li $t2, 0 #sets x velocity to 0
    	li $t3, 128 #sets y velocity upwards
    	
    	sw $t2, xVel
    	sw $t3, yVel
    	j LaunchLoopEnd
    	
    	LaunchLeft:
    	li $t2, -4 #sets x velocity leftwards
    	li $t3, -128 #sets y velocity upwards
    	
    	sw $t2, xVel
    	sw $t3, yVel
    	j LaunchLoopEnd
    	
    	LaunchRight:
    	li $t2, 4 #sets x velocity rightwards.
    	li $t3, -128 #sets y velocity upwards
    	
    	sw $t2, xVel
    	sw $t3, yVel
    	j LaunchLoopEnd
    	
    
    LaunchKeyCheckEnd:
    
    j LaunchLoop #Keeps looping the launch mode. Exit is performed within the loop if an accepted launch key input is registered by the system
    
    LaunchLoopEnd:
    #restore t values from the stack. 
    lw $t7, 0($sp)
    addi $sp, $sp, 4
    lw $t6, 0($sp)
    addi $sp, $sp, 4
    lw $t5, 0($sp)
    addi $sp, $sp, 4
    lw $t4, 0($sp)
    addi $sp, $sp, 4
    lw $t3, 0($sp)
    addi $sp, $sp, 4
    lw $t2, 0($sp)
    addi $sp, $sp, 4
    lw $t1, 0($sp)
    addi $sp, $sp, 4
    
    LaunchLoopStackEnd:
    
    j game_loop
    #========LAUNCH========LAUNCH========LAUNCH========LAUNCH=======LAUNCH========LAUNCH========LAUNCH========LAUNCH========LAUNCH========LAUNCH========
    
    

game_loop:
	# 1a. Check if key has been pressed
    # 1b. Check which key has been pressed
    # 2a. Check for collisions
	# 2b. Update locations (paddle, ball)
	# 3. Draw the screen
	# 4. Sleep
    
    #Ball Update Test Vector
   # bge $s7, 4, exit
#addi $s7, $s7, 4
    
    #Stuff Needed to Add for Section 2: Ball Movement
    #Stuff Needed to Add for Section 3: Collisions
    
    lw $t8, ADDR_KBRD
    lw $t9, 0($t8)
    beq $t9, 1, SystemShift # If keypress made, jump to system shift
    j SystemShiftEnd #jump to the end of this section if no keypress was made.
    
    ExitGame: #Should only be reachable if the Esc key is pressed. Termninates the game gracefully.
    li $v0, 10
    syscall
    
    
#========PAUSE========PAUSE========PAUSE========PAUSE========PAUSE========PAUSE========PAUSE========PAUSE========PAUSE========PAUSE========PAUSE========PAUSE=============
    TogglePause: #Toggles pause mode. Screen will simply be still while in this loop. Only accessible from system shift by pressing "p".
    
    lw $t8, ADDR_KBRD
    lw $t9, 0($t8)
    beq $t9, 1, TogglePauseKeyCheck
    j TogglePauseKeyCheckEnd
    
    TogglePauseKeyCheck:
    
    lw $t7, 0xffff0004 #store keypress input in $t7.
    #set system to sleep for some time to create buffer to process instructions
    addi $v0, $zero, 32 #code for syscall sleep
    addi $a0, $zero, 83 #roughly 12 frames per second
    syscall
    
    beq $t7, 112, game_loop # 80 is ASCII for p.
    
    TogglePauseKeyCheckEnd:
    
    j TogglePause #Keeps looping pause mode. Exit is performed within the loop if p is pressed and recorded by the system.
    
#========PAUSE========PAUSE========PAUSE========PAUSE========PAUSE========PAUSE========PAUSE========PAUSE========PAUSE========PAUSE========PAUSE========PAUSE=============
    
    SystemShift:
    
    lw $t7, 0xffff0004 #store keypress input in t7.
    
    #set system to sleep for some time to create buffer to process instructions
    addi $v0, $zero, 32 #code for syscall sleep
    addi $a0, $zero, 83 #roughly 12 frames per second
    syscall
    
    #redirect to appropiate submodule based on value of keypress in $t7
    beq $t7, 97, MoveLeft #97 is keypress code for a
    beq $t7, 100, MoveRight #100 is keypress code for d
    beq $t7, 27, ExitGame #27 is ASCII code for Esc.
    beq $t7, 112, TogglePause # 80 is ASCII for lowercase p.
    j  SystemShiftEnd
    
    # Code for Move Left + Erase Paddle and Draw Paddle
    
    MoveLeft: #updates the stored address of the centre of the paddle, and redraws the paddle.
    lw $t0, ADDR_DSPL #resets the pointer position of the screen element to the top left corner.
    lw $s0, paddleX #stores the x-position of the paddle in s0 for use in this submodule.
    lw $s1, paddleY #similar as above.
    add $s2, $s0, $s1
    add $t0, $t0, $s2 #moves the position pointer to the centre of the paddle
    jal ErasePaddle #erases the currently displayed paddle to allow for position update and drawing the paddle at the new position.
    
    jal PaddleLeft #If possible, shifts the position of the paddle centre left.
    
    #Update the display registers storing the position of paddle
    lw $t0, ADDR_DSPL
    lw $s0, paddleX
    lw $s1, paddleY
    add $s2, $s0, $s1 #sums number of bits needed to shift in bitmap display (paddleX and paddleY are already in num. bits)
    add $t0, $t0, $s2 #offsets the paddle pointer to the new center of the paddle position.
    
    jal DrawPaddle #draws a paddle at the current pointer location.
    
    j MoveUpdateEnd
    
    ErasePaddle: #erases the currently displayed paddle.
    #store current t values in stack.
    addi $sp, $sp, -4
    sw $t1, 0($sp) #stores grey in the stack
    
    #use _____ registers to 
    li $t1, 0x000000 #store black in t1.
    sw $t1, -4($t0)
    sw $t1, 0($t0)
    sw $t1, 4($t0)
    
    #restore original value in t1.
    lw $t1, 0($sp)
    addi $sp, $sp, 4
    jr $ra
    
    PaddleLeft: #shifts the value of paddleX one step left
    lw $s0, paddleX #stores recorded X position
    PaddleLeftIf: #updates X position only if possible.
    ble $s0, 8, PaddleLeftIfEnd
    addi $s0, $s0, -4
    PaddleLeftIfEnd:
    sw $s0, paddleX #records new X-position back into the keyword register.
    jr $ra
    
    DrawPaddle: #Draws a paddle at the current position
    #stores the current value of t6 in the stack.
    addi $sp, $sp, -4
    sw $t6, 0($sp)
    
    #draws the paddle in paddle colour.
    #Note: this requires the pointer position to already have been moved to the intended position.
    lw $t6, PDDL_COL
    sw $t6, -4($t0)
    sw $t6, 0($t0)
    sw $t6, 4($t0)
    
    #returns the value of t6 to whatever it weas before and unincrements the stack.
    lw $t6, 0($sp)
    addi $sp, $sp, 4
    
    #returns to the line after where DrawPaddle was called from.
    jr $ra
    
    #Code for Move Right (makes references to Erase Paddle and Draw Paddle from Move Left code chunk.
    
    MoveRight: #Code to remove the current paddle and place a paddle one pixel right.
    
    lw $t0, ADDR_DSPL #resets the pointer position of the screen element to the top left corner.
    lw $s0, paddleX #stores the x-position of the paddle in s0 for use in this submodule.
    lw $s1, paddleY #similar as above.
    add $s2, $s0, $s1
    add $t0, $t0, $s2 #moves the position pointer to the centre of the paddle
    jal ErasePaddle #erases the currently displayed paddle to allow for position update and drawing the paddle at the new position.
    
    jal PaddleRight # shifts the paddle 1 pixel (4 bytes) right if possible
    
    #Update the display registers storing the position of paddle
    lw $t0, ADDR_DSPL
    lw $s0, paddleX
    lw $s1, paddleY
    add $s2, $s0, $s1 #sums number of bits needed to shift in bitmap display (paddleX and paddleY are already in num. bits)
    add $t0, $t0, $s2 #offsets the paddle pointer to the new center of the paddle position.
    
    jal DrawPaddle
    
    j MoveUpdateEnd # jumps to end of paddle update code segment
    
    PaddleRight: #Shifts centre of paddle right 1 pixel if possible.
    
    lw $s0, paddleX #stores recorded X position
    PaddleRightIf: #updates X position right only if possible.
    bge $s0, 116, PaddleRightIfEnd
    addi $s0, $s0, 4
    PaddleRightIfEnd:
    sw $s0, paddleX #records new X-position back into the keyword register.
    jr $ra
    
    
    MoveUpdateEnd: # end of the update paddle section. Jumping to here moves on from the paddle update and to the next section.
    
    SystemShiftEnd: # jump to here if no keypress. Otherwise, reach naturally.
    
    # j SkipCollision # comment in to skip collision section
    
    CollisionUpdate: #Check for collisions and take appropriate actions.
    
    #Set the pointer to the current ball position.
    #Set t variables to stack.
    
    #store current t values in stack.
    addi $sp, $sp, -4
    sw $t1, 0($sp)
    addi $sp, $sp, -4
    sw $t2, 0($sp)
    addi $sp, $sp, -4
    sw $t3, 0($sp)
    addi $sp, $sp, -4
    sw $t4, 0($sp)
    addi $sp, $sp, -4
    sw $t5, 0($sp)
    addi $sp, $sp, -4
    sw $t6, 0($sp)
    addi $sp, $sp, -4
    sw $t7, 0($sp)
    addi $sp, $sp, -4
    sw $t8, 0($sp)
    addi $sp, $sp, -4
    sw $s1, 0($sp)
    addi $sp, $sp, -4
    sw $s2, 0($sp)
    
    lw $s1, yPos #stores the y position for use
    lw $s2, xPos #stores the x position for use
    lw $t0, ADDR_DSPL
    add $t0, $t0, $s1 #adds the yPos to the pointer position.
    add $t0, $t0, $s2 #adds the xPos to the pointer position.
    
    #for this section, do not change $t0 to store anything other than the current ball position.
    
    #Check side collision
    
    	#If object on both sides
    		#Set xVel to 0.
    	#If object on left and xVel < 0
    		# Negate xVel(xVel = 0 - xVel)
    	#If object on right and xVel > 0
    		#Negate xVel(xVel = 0 - xVel)
    	
    SideCollision:
    
    lw $t1, BLACK
    lw $t5, -4($t0)
    lw $t6, 4($t0)
    bne $t5, $t1, LeftCol #if any object immediately on the left, go to left collision case
    bne $t6, $t1, RightCol #if there are any objects immediately on the right, go to right collision case.
    j SideCollisionEnd
    
    #Remember to add skip rest condition.
    
    	LeftCol: #collision case where there is an objection on the left side of the ball.
    	
    	lw $t1, BLACK
    	bne $t6, $t1, TunnelCol # if additionally there is an object on the right wall, go to Tunnel Collision case.
    	lw $t3, xVel
    	sub $t4, $zero, $t3 #negates the xVel and stores it in $t4
    	sw $t4, xVel
    	li $v0, 31
    	lb $a1, duration
    	lb $a2, drums
    	lb $a3, volume
    	lb $a0, pitchA
    	syscall
    	j SideCollisionEnd #go to end of side collision section, since side collision calculations are complete.
    	
    	
    		TunnelCol: #collision case where there are objects on both sides of the ball (how'd you do that?)
    		li $t3, 0
    		sw $t3, xVel
    		li $v0, 31
    		lb $a1, duration
    		lb $a2, drums
    		lb $a3, volume
    		lb $a0, pitchC
    		syscall
    		j SideCollisionEnd #go to end of side collision section.
    		
    	RightCol: #collision case where is an object on the right side of the screen.
    	lw $t1, BLACK
    	lw $t3, xVel
    	sub $t4, $zero, $t3 #negates the xVel and stores it in $t4
    	sw $t4, xVel
    	li $v0, 31
        lb $a1, duration
   	lb $a2, drums
    	lb $a3, volume
    	lb $a0, pitchD
    	syscall
    	j SideCollisionEnd #go to end of side collision section, since side collision calculations are complete.
    
    
    SideCollisionEnd:
    
    #Check top collision
    	#If object on top pixel is gray
    		#Negate yVel(yVel = -128)
    	#Elif object on top pixel isn't black
    		#Negate yVel
    		#Call EraseBlock(erases up to 3 pixels if they aren't grey)
    		
    TopCollision:
    
    lw $t1, BLACK
    lw $t5, -128($t0)
    beq $t5, $t1, TopCollisionEnd #If pixel right above the ball is black, then no top collision, so jump to the end of this section of top collision.
    #add condition for brick above is grey.
    li, $t1, 128
    sw $t1, yVel #sets the yVel downwards if there is anything immediately above the ball.
    lw $t1, GRAY
    bne $t5, $t1, BrickBreak #if pixel above isn't grey, go to brick break mechanism.
    li $v0, 31
    lb $a1, duration
    lb $a2, drums
    lb $a3, volume
    lb $a0, pitchB
    syscall
    j TopCollisionEnd #if pixel above is grey, go to the end of the top collision section.
    
    
    BrickBreak:
    
    addi $t2, $t0, -132 #brick position counter start for the three bricks above. Remember $t0 points to current ball position.
    addi $t3, $t0, -120 #marker for when the system should stop breaking bricks.
    #change these to change the number of bricks broken.
    
    #loop over three bricks on top
    BrickBreakLooper:
    #store $s5 in stack: $s5 will be used to load and update the current score.
    addi $sp, $sp, -4
    sw $s5, 0($sp)
    
    lw $t1, BLACK
    lw $t4, RED
    lw $t5, BLUE
    lw $t6, GREEN
    lw $t9, GRAY
    lw $t7, 0($t2) #brings the colour stored at position $t2 to the effective memory register $t7.
    beq $t7, $t4, TopColRed #if colour at $t2 ($t7) is red, go to red case.
    beq $t7, $t5, TopColBlue #if colour at $t2 ($t7) is blue, go to blue case.
    beq $t7, $t6, TopColGreen #if colour at $t2 ($t7) is green, go to green case.
    j BrickBreakLooperEnd
    
    
    TopColRed: #brick is red
    sw $t5, 0($t2)
    j BrickBreakLooperEnd
    
    TopColBlue: #brick is blue
    sw $t6, 0($t2)
    j BrickBreakLooperEnd
    
    TopColGreen: #brick is green
    sw $t1, 0($t2)
    lw $s5, score
    addi $s5, $s5, 1 #increments the score by 1 to reflect the breaking of a brick.
    sw $s5, score
    j BrickBreakLooperEnd
    
    BrickBreakLooperEnd: #Use to loop until desired number of bricks broken.
    #return $s5 from the stack.
    lw $s5, 0($sp)
    addi $sp, $sp, 4
    
    addi $t2, $t2, 4 #Increments the position above the pixel being checked by the loop.
    bge $t2, $t3, BrickBreakEnd #if the position $t2 is greater than the position in $t3, stop
    j BrickBreakLooper
    
    BrickBreakEnd:
    li $v0, 31
    lb $a1, duration
    lb $a2, instrument
    lb $a3, volume
    lb $a0, pitchG
    syscall
    j TopCollisionEnd
    
    TopCollisionEnd:
    
    #Check bottom collision
    
    	# Set another variable: $t1 to the bit 128 forward from the pointer (thus a row below the pointer).
    	# if -4($t1), 0($t1), 4($t1) = cyan
    		#Set yVel = 128
    		#Set xVel = 0
    	# if 0($t1), 4($t1) = cyan, -4($t1) = black
    		#Set yVel = 128
    		#Set xVel = -4
    	# if -4($t1), 0($t1) = cyan, 4($t1) = black
    		#Set yVel = 128
    		#Set xVel = 4
    
    BottomCollision: #needs to check conditions similar to in top condition, plus cyan for the paddle.
    lw $t1, BLACK
    lw $t5, 128($t0)
    beq $t5, $t1, BottomCollisionEnd #If pixel right below the ball is black, then no bottom collision, so jump to the end of this section of top collision.
    #add condition for brick above is grey.
    li, $t1, -128
    sw $t1, yVel #sets the yVel upwards if there is anything immediately above the ball.
    lw $t1, PDDL_COL
    beq $t5, $t1, PaddleCollision #if the bottom pixel is the paddle colour, go to paddle collision section.
    lw $t1, GRAY
    bne $t5, $t1, BrickBreakBottom #if pixel below isn't grey or cyan, go to brick break bottom mechanism.
    j BottomCollisionEnd #if pixel above is grey, go to the end of the top collision section.
    
    
    PaddleCollision: #determines new x-velocity after a collision with the paddle. y-velocity should already have been calculated before getting here.
    lw $t3, 124($t0) #loads the color of the pixel to the bottom and left of the ball.
    lw $t1, BLACK
    beq $t3, $t1, BallLeftPaddle #If the pixel bottom and left of the ball is black, then the ball is on the left side of the paddle.
    lw $t3, 132($t0) #loads the color of the pixel to the bottom and right of the ball.
    beq $t3, $t1, BallRightPaddle
    j BallMiddlePaddle #Otherwise, the ball is in the middle of the paddle.
    
    BallLeftPaddle: #The case where the ball collided with the paddle, and is on the left side of it.
    li $t6, -4
    sw $t6, xVel
    li $v0, 31
    lb $a1, duration
    lb $a2, synth
    lb $a3, volume
    lb $a0, pitchF
    syscall
    j BottomCollisionEnd
    
    BallRightPaddle: #The case where the ball collided with the paddle, and is on the right side of it.
    li $t6, 4
    sw $t6, xVel
    li $v0, 31
    lb $a1, duration
    lb $a2, synth
    lb $a3, volume
    lb $a0, pitchG
    syscall
    j BottomCollisionEnd
    
    BallMiddlePaddle: #The case where the ball collided with the paddle, and is right above it's center.
    li $t6, 0
    sw $t6, xVel
    li $v0, 31
    lb $a1, duration
    lb $a2, synth
    lb $a3, volume
    lb $a0, pitchA
    syscall
    j BottomCollisionEnd
    
    BrickBreakBottom:
    
    addi $t2, $t0, 120 #brick position counter start for the three bricks below. Remember $t0 points to current ball position.
    addi $t3, $t0, 132 #marker for when the system should stop breaking bricks.
    #change these to change the number of bricks broken.
    
    #loop over three bricks on the bottom
    BrickBreakLooperBottom:
    lw $t1, BLACK
    lw $t4, RED
    lw $t5, BLUE
    lw $t6, GREEN
    lw $t7, 0($t2) #brings the colour stored at position $t2 to the effective memory register $t7.
    beq $t7, $t4, BottomColRed #if colour at $t2 ($t7) is red, go to red case.
    beq $t7, $t5, BottomColBlue #if colour at $t2 ($t7) is blue, go to blue case.
    beq $t7, $t6, BottomColGreen #if colour at $t2 ($t7) is green, go to green case.
    j BrickBreakLooperBottomEnd
    
    BottomColRed: #brick is red
    sw $t5, 0($t2)
    j BrickBreakLooperBottomEnd
    
    BottomColBlue: #brick is blue
    sw $t6, 0($t2)
    j BrickBreakLooperBottomEnd
    
    BottomColGreen: #brick is green
    sw $t1, 0($t2)
    j BrickBreakLooperBottomEnd
    
    BrickBreakLooperBottomEnd: #Use to loop until desired number of bricks broken.
    addi $t2, $t2, 4 #Increments the position above the pixel being checked by the loop.
    bge $t2, $t3, BrickBreakBottomEnd #if the position $t2 is greater than the position in $t3, stop
    j BrickBreakLooperBottom
    
    BrickBreakBottomEnd:
    
    
    BottomCollisionEnd:
    
    #Check top-sides collision(iff no Top collision or bottom collision)
    	#Calculate next object position
    		#If next object position is cyan
    			#yVel = 128
    		#If next object position is white
    			#Move pointer to next position and erase brick.
    			#Reverse yVel and xVel
    
    MoreCollision: #Checks for additional Collision Conditions
    
    lw $s1, xVel
    lw $s2, yVel
    
    #Calculate the currently angled next position of the ball under current velocity conditions.
    add $t2, $t0, $s1 #$t2 used to store the position in order to retain the ball position in $t0.
    add $t2, $t2, $s2
    
    
    #If there is an object at that location in $t2, and no choices were made in top or bottom sections, flip the y velocity.
    
    #if a choice was made in top or bottom, flip the x velocity.
    
    #Too hard, and very rare instance.
    
    #Just reverse both x and y velocity if this happens.
    
    lw $t1, BLACK
    lw $t3, 0($t2)
    bne $t3, $t1, EdgeCaseFlipVelocity #In most cases where this happens, you can just send the particle back the way it came from. As though the ball bounced off the corner of the block.
    #The rare cases where there's a block immediately after the bounce is very very rare. We'll just have to live with it for now.
    
    j SkipMoreCollision #If the extra collision metric is not matched, do not perform the flip of the velocity.
    
    	EdgeCaseFlipVelocity: #Flips the direction of the velocity
    	lw $s1, xVel
    	lw $s2, yVel
    	
    	sub $t4, $zero, $s1 #Flips the called velocities.
    	sub $t5, $zero, $s2 #By subtracting from zero.
    	
    	sw $t4, xVel #Stores the flipped velocities back into their keywords.
    	sw $t5, yVel
    	
    	li $v0, 31
    	lb $a1, duration
    	lb $a2, drums
    	lb $a3, volume
    	lb $a0, pitchD
    	syscall
    	
    	lw $t7, RED
    	beq $t3, $t7, DestroyCornerBrick
    	lw $t7, BLUE
    	beq $t3, $t7, DestroyCornerBrick
    	lw $t7, GREEN
    	beq $t3, $t7, DestroyCornerBrick
    	j SkipMoreCollision
    	
    	DestroyCornerBrick: #Destroys a corner brick, only if it's a brick.
    	lw $t1, BLACK
    	sw $t1, 0($t2)
    	
    	
    	j SkipMoreCollision
    		
    
    
    SkipMoreCollision: #in the event of a regular top or bottom collision, skip to here to skip the more collision section.
    
    
    #Return $t variables from the stack.
    lw $s2, 0($sp)
    addi $sp, $sp, 4
    lw $s1, 0($sp)
    addi $sp, $sp, 4
    lw $t7, 0($sp)
    addi $sp, $sp, 4
    lw $t6, 0($sp)
    addi $sp, $sp, 4
    lw $t5, 0($sp)
    addi $sp, $sp, 4
    lw $t4, 0($sp)
    addi $sp, $sp, 4
    lw $t3, 0($sp)
    addi $sp, $sp, 4
    lw $t2, 0($sp)
    addi $sp, $sp, 4
    lw $t1, 0($sp)
    addi $sp, $sp, 4
    
    CollisionUpdateEnd: #jump to here once collision checks are done.
    
    SkipCollision:
    
    #j SkipBallUpdate: #Comment in to skip updating the ball position.
    
    BallUpdate: #updates the position of the ball in data and on the bitmap display.
    
    #set system to sleep for some time to create buffer to process instructions
    addi $v0, $zero, 32 #code for syscall sleep
    addi $a0, $zero, 166 #roughly 12 frames per second
    syscall
    
    jal EraseBall
    
    jal BallPosUpdate
    
    jal DrawBall
    
    j BallUpdateEnd #once ball is updated, moves to the end of the ball update section
    
    
    EraseBall: #Erases the currently displayed ball in preparation for an update to a new position.
    
    #store current t values in stack.
    addi $sp, $sp, -4
    sw $t1, 0($sp) #stores grey in the stack
    addi $sp, $sp, -4
    sw $t2, 0($sp)
    addi $sp, $sp, -4
    sw $t3, 0($sp)
    
    lw $t2, yPos
    lw $t3, xPos
    lw $t0, ADDR_DSPL
    add $t0, $t0, $t2 #adds the yPos to the pointer position.
    add $t0, $t0, $t3 #adds the xPos to the pointer position.
    
    #use _____ registers to 
    li $t1, 0x000000 #store black in t1.
    sw $t1, 0($t0) #store black in the address currently pointed to by the address pointer $t0.
    
    #restore original values in t from the stack.
    lw $t3, 0($sp)
    addi $sp, $sp, 4
    lw $t2, 0($sp)
    addi $sp, $sp, 4
    lw $t1, 0($sp)
    addi $sp, $sp, 4
    
    jr $ra #returns to call position.
    
    BallPosUpdate: #Updates the position of the ball by adding the velocity per cycle to it.
    
    #store current t values in stack.
    addi $sp, $sp, -4
    sw $t1, 0($sp)
    addi $sp, $sp, -4
    sw $t2, 0($sp)
    addi $sp, $sp, -4
    sw $t3, 0($sp)
    addi $sp, $sp, -4
    sw $t4, 0($sp)
    
    #Update Ball x and y Positions.
    #Update Ball y position.
    lw $t1, yPos
    lw $t2, yVel
    add $t1, $t1, $t2
    sw $t1, yPos #stores new y position in $t1 back into yPos.
    
    #Update Ball x position.
    lw $t3, xPos
    lw $t4, xVel
    add $t3, $t3, $t4
    sw $t3, xPos #stores new x position in $t3 back into xPos.
    
    #return t values from stack.
    lw $t4, 0($sp)
    addi $sp, $sp, 4
    lw $t3, 0($sp)
    addi $sp, $sp, 4
    lw $t2, 0($sp)
    addi $sp, $sp, 4
    lw $t1, 0($sp)
    addi $sp, $sp, 4
    
    jr $ra
    
    
    DrawBall: #draws a ball at the current ball position.
    
    #store current t values in stack.
    addi $sp, $sp, -4
    sw $t1, 0($sp) #stores grey in the stack
    addi $sp, $sp, -4
    sw $t2, 0($sp)
    addi $sp, $sp, -4
    sw $t3, 0($sp)
    addi $sp, $sp, -4
    sw $t4, 0($sp)
    
    lw $t2, yPos
    lw $t3, xPos
    lw $t0, ADDR_DSPL
    add $t0, $t0, $t2 #adds the yPos to the pointer position.
    add $t0, $t0, $t3 #adds the xPos to the pointer position.
    
    # draw the ball by storing the ball colour at the pointer position
    lw $t1, BALL_COL #store the ball colour in t1.
    sw $t1, 0($t0) #store a ball in the address currently pointed to by the address pointer $t0.
    
    #restore original values in t from the stack.
    lw $t4, 0($sp)
    addi $sp, $sp, 4
    lw $t3, 0($sp)
    addi $sp, $sp, 4
    lw $t2, 0($sp)
    addi $sp, $sp, 4
    lw $t1, 0($sp)
    addi $sp, $sp, 4
    
    jr $ra
    
    BallUpdateEnd:
    
    #Check Victory Conditions
    VictoryCheck: #Checks whether score is >= victory score. If so, sends to the game won section
    #store current values in stack.
    addi $sp, $sp, -4
    sw $s1, 0($sp)
    addi $sp, $sp, -4
    sw $s2, 0($sp)
    addi $sp, $sp, -4
    sw $t3, 0($sp)
    addi $sp, $sp, -4
    sw $t4, 0($sp)
    
    #Checks score vs victory score. If score is greater, send the system to the victory loop.
    
    lw $s1, score
    lw $s2, VictoryScore
    bge $s1, $s2, Victory
    
    #return values from stack.
    lw $t4, 0($sp)
    addi $sp, $sp, 4
    lw $t3, 0($sp)
    addi $sp, $sp, 4
    lw $s2, 0($sp)
    addi $sp, $sp, 4
    lw $s1, 0($sp)
    addi $sp, $sp, 4
    
    #Check Game Over Conditions
    GameOverCheck:
    
    #store current values in stack.
    addi $sp, $sp, -4
    sw $t0, 0($sp)
    addi $sp, $sp, -4
    sw $t2, 0($sp)
    addi $sp, $sp, -4
    sw $t3, 0($sp)
    addi $sp, $sp, -4
    sw $s1, 0($sp)
    addi $sp, $sp, -4
    sw $s2, 0($sp)
    addi $sp, $sp, -4
    sw $s3, 0($sp)
    addi $sp, $sp, -4
    sw $s4, 0($sp)
    
    lw $s1, yPos #stores the y position for use
    lw $s2, xPos #stores the x position for use
    lw $t0, ADDR_DSPL
    add $t3, $t0, $s1 #adds the yPos to the pointer position.
    add $t3, $t3, $s2 #adds the xPos to the pointer position.
    
    #Load the current velocities
    lw $s3, xVel
    lw $s4, yVel
    
    #Calculate the currently angled next position of the ball under current velocity conditions.
    add $t2, $t3, $s3 #$t2 used to store the position in order to retain the ball position in $t0.
    add $t2, $t2, $s4
    addi $t3, $t0, 8192
    bge $t2, $t3, OutOfBounds
    j OutOfBoundsSkip
    
    	OutOfBounds:
    	lw, $t4, Lives
    	addi $t4, $t4, -1
    	sw $t4, Lives
    	ble $t4, $zero, GameOver
    	li $v0, 31
    	lb $a1, duration
    	lb $a2, instrument
    	lb $a3, volume
    	lb $a0, pitchG
    	syscall
    	j BallReset
    
    	OutOfBoundsSkip:
    #return values from stack.
    lw $s4, 0($sp)
    addi $sp, $sp, 4
    lw $s3, 0($sp)
    addi $sp, $sp, 4
    lw $s2, 0($sp)
    addi $sp, $sp, 4
    lw $s1, 0($sp)
    addi $sp, $sp, 4
    lw $t3, 0($sp)
    addi $sp, $sp, 4
    lw $t2, 0($sp)
    addi $sp, $sp, 4
    lw $t0, 0($sp)
    addi $sp, $sp, 4
    
    j game_loop
    
    BallReset: #Resets the ball to the initial location
    
    jal EraseBall #Erases the currently existing ball.
    
    lw $s5, xPosInitial
    lw $s6, yPosInitial
    sw $s5, xPos
    sw $s6, yPos
    
    jal DrawBall
    
    j LaunchLoopStack
    
    
        #5. Go back to 1
    b game_loop #comment out for module 1 testing purposes
   #====================================================================================================================================== 
    Victory: #The game is won. Congratulations.
    
    lw $t0, ADDR_DSPL
    addi $t0, $t0, 2432
    addi $t2, $zero, 2176
    la $t1, WinScreen
    li $v0, 31
    lb $a0, pitchA
    lb $a1, duration
    lb $a2, piano
    lb $a3, volume
    syscall
    lb $a0, pitchF
    syscall
    lb $a0, pitchD
    syscall
    jal PixelCopy
    
    j PostGame
    
    GameOver:
    lw $t0, ADDR_DSPL
    addi $t0, $t0, 2688
    addi $t2, $zero, 2176
    la $t1, OverScreen
    li $v0, 31
    lb $a1, duration
    lb $a2, piano
    lb $a3, volume
    lb $a0, pitchA
    syscall
    lb $a0, pitchB
    syscall
    lb $a0, pitchC
    syscall
    lb $a0, pitchB
    syscall
    lb $a0, pitchA
    syscall
    jal PixelCopy
    
    j PostGame
    #play a sound
    #Loop, with r to reset to the beginning of the game. (Prior to the generation of the map.
    #Will need to implement a blackout screen and ResetGame as well at the start of the game to allow a soft reset. (ResetGame resets the initial conditions).
    
    PostGame: #Give the player the options to either go back to the start menu and restart the game, or quit the game.
    #========POST========POST========POST========POST========POST========POST========POST========POST========POST========POST========POST========POST========
    PostGameLoop: #Toggles start pause mode. Screen will simply be still while in this loop. Only accessible from system shift by pressing "p".
    
    lw $t8, ADDR_KBRD
    lw $t9, 0($t8)
    beq $t9, 1, PostGameKeyCheck
    j PostGameKeyCheckEnd
    
    PostGameKeyCheck:
    
    lw $t7, 0xffff0004 #store keypress input in $t7.
    #set system to sleep for some time to create buffer to process instructions
    addi $v0, $zero, 32 #code for syscall sleep
    addi $a0, $zero, 83 #roughly 12 frames per second
    syscall
    
    beq $t7, 114, ResetGame # 114 is ASCII for r. Resets the game if reached.
    beq $t7, 113, exit # 113 is ASCII for q. Quits the game if this condition is met.
    
    PostGameKeyCheckEnd:
    
    j PostGameLoop #Keeps looping pause mode. Exit is performed within the loop if p is pressed and recorded by the system.
    
    #========POST========POST========POST========POST========POST========POST========POST========POST========POST========POST========POST========POST========
    
exit:
    li $v0, 10              # terminate the program gracefully
    syscall
