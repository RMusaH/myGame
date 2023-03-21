/*
This file is part of gamelib-x64.
Copyright (C) 2014 Tim Hegeman
gamelib-x64 is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.
gamelib-x64 is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.
You should have received a copy of the GNU General Public License
along with gamelib-x64. If not, see <http://www.gnu.org/licenses/>.
*/

.file "src/game/game.s"

.global gameInit
.global gameLoop

.section .game.data


isgameover:		.byte 0						#checks if it's game over
isWin:			.byte 0

toPrint:		.quad 0						#contains witch cchar to print

lastMove:		.quad 0						#keeps track of last move

score:			.quad 0
highScore:		.quad 0
score_xxx1:		.quad 0
score_xx1x:		.quad 0
score_x1xx:		.quad 0
highScore_xxx1:	.quad 0
highScore_xx1x:	.quad 0
highScore_x1xx:	.quad 0
fruitDebug:		.quad 0

snakePos:		.zero 6000					#array with every location of the snake

fruitPos:		.quad 0						#has the fruit position

timer:			.quad 0
timerCount:		.quad 0



.section .game.text
	.equ		vgaStart,	0xB8000               #start of screen
	.equ    	vgaEnd,		0xB8FA0                 #end 0f screen
	.equ		posStart,	0xB87D0
	.equ		arenaStart, 0xB83E0				#+992 (6 lines + 1/5)
	.equ		arenaEnd, 	0xB8B20				#+2848 (18 lines - 1/5)
	scoreMsg:		.asciz		"SCORE"
	highscoreMsg:	.asciz		"HIGHSCORE"
	victoryMsg:		.asciz		"VICTORY"
	snakeMsg:		.asciz		"SNAKE"
	gameoverMsg:	.asciz		"GAME OVER"
	continueMsg:	.asciz		"PRESS SPACE TO CONTINUE"
	victoryMsgCover:	.asciz	"       "
	continueMsgCover:	.asciz	"                         "

	asciiArt1:		.asciz		"                 _        "
	asciiArt2:		.asciz		"                | |       "
	asciiArt3:		.asciz		" ___ _ __   __ _| | _____ "
	asciiArt4:		.asciz		"/ __| '_ \\ / _` | |/ / _ \\"
	asciiArt5:		.asciz		"\\__ \\ | | | (_| |   <  __/"
	asciiArt6:		.asciz		"|___/_| |_|\\__,_|_|\\_\\___|"

	headArt1:		.asciz		"           /^\\/^\\"
	headArt2:		.asciz		"         _|__|  O|"
	headArt3:		.asciz		"\\/     /~     \\_/ \\"
	headArt4:		.asciz		" \\____|__________/  \\"
	headArt5:		.asciz		"        \\_______      \\"
	headArt6:		.asciz		"                `\\     \\"



gameInit:

	movq    $19886, %rdi 
    call    setTimer    

	movq    $vgaStart, %rdi         #start of graphics memory

clearScreen: 
    movw    $0x0, (%rdi)              #erase what was there before
    addq    $2, %rdi                #get next memory address
    cmpq    $vgaEnd, %rdi           #check if it is the end
    jl      clearScreen             #if its not the end continue

	movq	$0, %r12				#position to start
	movq	$2, %r13				#witch offset to move
	movq	$4, %r14				#size
	movq	$0, timer				#counter of loops to determine clock speed
	movq	$0, score
	movq	$0, score_xxx1
	movq	$0, score_xx1x
	movq	$0, score_x1xx

	movb	$'H', %al
	movb	$0x2, %ah
	movw	%ax, toPrint

	movb	$0, isgameover(%rip)
	movb	$0, isWin(%rip)

	call 	putFruit

	movq	$10, timerCount
	
	movq	$arenaStart, %rdi
	movq	$arenaStart, %rcx
	addq	$98, %rcx

drawArenaTop: 
    movw    $0xF000, (%rdi)
    addq    $2, %rdi                
    cmpq    %rcx, %rdi          
    jl      drawArenaTop   
       
	addq	$62, %rdi  

drawArenaWall: 
    movw    $0xF000, (%rdi)
	addq	$96, %rdi

	movw    $0xF000, (%rdi)       
    addq    $64, %rdi

    cmpq    $arenaEnd, %rdi
    jl      drawArenaWall 


	subq	$160, %rdi

drawArenaBottom:
	movw    $0xF000, (%rdi)
    addq    $2, %rdi                
    cmpq    $arenaEnd, %rdi
    jl      drawArenaBottom   

	call	printSnake
	
	leaq	scoreMsg(%rip), %rcx	#string to print
	movq	$1, %r8				#color of the string 1- black
	movq	$vgaStart, %rdi			#display "score"
	addq    $354, %rdi				#where to print

	call	printText

	leaq	highscoreMsg(%rip), %rcx
	movq	$3, %r8
	movq	$vgaStart, %rdi			#display "score"
	addq    $434, %rdi

	call	printText

	jmp		gameLoop

printSnake:
	movq    $vgaStart, %rdi			#display "snake"
	addq	$56, %rdi
	movq	$2, %r8
	leaq	asciiArt1(%rip), %rcx
	call	printText
	addq    $160, %rdi
	movq	$2, %r8
	leaq	asciiArt2(%rip), %rcx
	call	printText
	movq	$2, %r8
	leaq	asciiArt3(%rip), %rcx
	call	printText
	addq    $160, %rdi
	movq	$2, %r8
	leaq	asciiArt4(%rip), %rcx
	call	printText
	addq    $160, %rdi
	movq	$2, %r8
	leaq	asciiArt5(%rip), %rcx
	call	printText
	addq    $160, %rdi
	movq	$2, %r8
	leaq	asciiArt6(%rip), %rcx
	call	printText

	movq    $vgaEnd, %rdi			#display "snake"
	subq	$56, %rdi
	movq	$2, %r8
	leaq	headArt6(%rip), %rcx
	call	printText
	subq    $160, %rdi
	movq	$2, %r8
	leaq	headArt5(%rip), %rcx
	call	printText
	movq	$2, %r8
	leaq	headArt4(%rip), %rcx
	call	printText
	subq    $160, %rdi
	movq	$2, %r8
	leaq	headArt3(%rip), %rcx
	call	printText
	subq    $160, %rdi
	movq	$2, %r8
	leaq	headArt2(%rip), %rcx
	call	printText
	subq    $160, %rdi
	movq	$2, %r8
	leaq	headArt1(%rip), %rcx
	call	printText

	ret

#rdi - where to print(place)
#rcx - what to print(declared string)
#r8  - color
printText:
	cmpq	$1, %r8
	je		white

	cmpq	$2, %r8
	je		green

	cmpq	$3, %r8
	je		yellow

	cmpq	$4, %r8
	je		red

	white:
		movb	$0x0F, %ah
		movq	$0, %r8
		jmp		printMsgLoop

	yellow:
		movb	$0x0E, %ah
		movq	$0, %r8	
		jmp		printMsgLoop

	red:
		movb	$0x04, %ah
		movq	$0, %r8	
		jmp		printMsgLoop

	green:
		movq	$0, %r8
		movb	$0x0A, %ah

	printMsgLoop:		
		movb	(%rcx, %r8, 1), %al
		movw	%ax,(%rdi, %r8, 2)
		incq	%r8
		movb	(%rcx, %r8, 1), %al
		cmpb	$0, %al
		jne		printMsgLoop

	ret

gameLoop:
	call	scoreUpdate
	call	hscoreUpdate

	cmpb	$0, isgameover(%rip)			#checks if game over
	jne		gameOver
	cmpb	$0, isWin(%rip)			#checks if game over
	jne		win_case
	
	call	readKeyCode
	cmpq	$0, %rax
	je		move

	cmpq	$0x11, %rax			#compare W
	je		up
	cmpq	$0x48, %rax			#compare up-arr
	je		up


	cmpq	$0x1E, %rax			#compare A
	je		left
	cmpq	$0x4B, %rax			#compare left-arr
	je		left

	cmpq	$0x1F, %rax			#compare S
	je		down
	cmpq	$0x50, %rax			#compare down-arr
	je		down

	cmpq	$0x20, %rax			#compare D
	je		right
	cmpq	$0x4D, %rax			#compare right-arr
	je		right

	jmp		move

scoreUpdate:
	movq    $vgaStart, %rdi
	addq    $514, %rdi
	movb	$0x0F, %ah
	movb	$0x30, %al
	addb	score_xxx1, %al
	movw    %ax, 6(%rdi)
	movb	$0x0F, %ah
	movb	$0x30, %al
	addb	score_xx1x, %al
	movw    %ax, 4(%rdi)
	movb	$0x0F, %ah
	movb	$0x30, %al
	addb	score_x1xx, %al
	movw    %ax, 2(%rdi)

	ret

hscoreUpdate:
	addq    $84, %rdi
	movb	$0x0F, %ah
	movb	$0x30, %al
	addb	highScore_xxx1, %al
	movw    %ax, 6(%rdi)
	movb	$0x0F, %ah
	movb	$0x30, %al
	addb	highScore_xx1x, %al
	movw    %ax, 4(%rdi)
	movb	$0x0F, %ah
	movb	$0x30, %al
	addb	highScore_x1xx, %al
	movw    %ax, 2(%rdi)
	
	ret

up:
	movb	$'I', %al
	movb	$0x2, %ah
	movw	%ax, toPrint

	cmpq	$160, lastMove          #compare to make it impossible to walk back
	je		move

	movq	$-160, %r13
	jmp		move

left:
	movb	$'H', %al
	movb	$0x2, %ah
	movw	%ax, toPrint

	cmpq	$2, lastMove          #compare to make it impossible to walk back
	je		move

	movq	$-2, %r13
	jmp		move

down:
	movb	$'I', %al
	movb	$0x2, %ah
	movw	%ax, toPrint

	cmpq	$-160, lastMove          #compare to make it impossible to walk back
	je		move

	movq	$160, %r13
	jmp		move

right:
	movb	$'H', %al
	movb	$0x2, %ah
	movw	%ax, toPrint

	cmpq	$-2, lastMove          #compare to make it impossible to walk back
	je		move

	movq	$2, %r13
	jmp		move

move:

	cmpq	$14, timerCount
	je		skipMove

	incq	timer						#clock speed to determine when should it move
	movq	timerCount, %rax
	cmpq	%rax, timer
	jl		endLoop

	skipMove:
	movq	%r13, lastMove

	movq	%r12, %rdx			#getting last move

	movq	$0,	timer			#loop counter

passMoves:

	movq	snakePos(,%r15,8), %rsi	#shifting every move in the array
	movq	%rdx, snakePos(,%r15,8)
	movq	%rsi, %rdx

	incq	%r15

	cmpq	%r14, %r15
	jle		passMoves


	movq    $posStart, %rdi

	addq	%r13, %r12				#add value of next move to the snake

	addq	%r12, %rdi
	movw	toPrint, %ax
	movw	%ax, (%rdi)			#print next position


	movq	$0, %r15				#loop counter

checkIfDead:
	movq	$posStart, %rcx						#loop to check if snake is on itself
	addq	snakePos(,%r15,8), %rcx
	cmpq	%rdi, %rcx
	je		gameOver

	incq	%r15
	cmpq	%r14, %r15
	jle		checkIfDead

	movq	$arenaStart, %rcx			#check colision w top wall
	addq	$160, %rcx
	cmpq	%rcx, %rdi
	jle		gameOver

	movq	$arenaEnd, %rcx			#check colision w bottom wall
	subq	$160, %rcx
	cmpq	%rcx, %rdi
	jge		gameOver

	movq	$arenaStart, %rcx
	addq	$160, %rcx

checkDeadByWall:						#check if player is on the side walls
	addq	$96, %rcx

	cmpq	%rcx, %rdi
	jl		notDead

	addq	$64, %rcx

	cmpq	%rcx, %rdi
	jg		checkDeadByWall
	jmp		gameOver

notDead:
	cmpq	%rdi, fruitPos				#checks if got the fruit
	je		grow

	movq	$0, %r15

	movq	$posStart, %rdi
	addq	snakePos(,%r14,8), %rdi
	movw	$0, (%rdi,1)				#delete end of the tail
	jmp 	endLoop

grow:
	jmp	score_calc_xxx1
	grow_rest:

	incq	score

	movq	$0, %rdx
	movq	score, %rax
	cmpq	$0, %rax
	je		dontGetFaster
	movq	$2, %rcx
	divq	%rcx
	cmpq	$0, %rdx
	jne		dontGetFaster

	decq	timerCount

dontGetFaster:
		
		movq	score, %rcx
		cmpq	%rcx, highScore
		jge	noNewHighScore

		newHighScore:
		movq	score, %rbx
		movq	%rbx, highScore
		movq	score_x1xx, %rbx
		movq	%rbx, highScore_x1xx
		movq	score_xx1x, %rbx
		movq	%rbx, highScore_xx1x
		movq	score_xxx1, %rbx
		movq	%rbx, highScore_xxx1

		noNewHighScore:


		incq	%r14		#increase size

		cmpq	$10, score
		je		win_case				

		call	putFruit	
		jmp		endLoop

score_calc_xxx1:
	cmpq	$9, score_xxx1
	jge	reset_xxx1

	incq	score_xxx1
	jmp	grow_rest

	reset_xxx1:
		movq	$0, score_xxx1
		jmp	score_calc_xx1x

score_calc_xx1x:
	cmpq	$9, score_xx1x
	jge		reset_xx1x

	incq	score_xx1x
	jmp		grow_rest

	reset_xx1x:
		movq	$0, score_xx1x
		jmp	score_calc_x1xx

score_calc_x1xx:
	cmpq	$9, score_x1xx
	jge	win_case

	incq	score_x1xx
	jmp	grow_rest

win_case:

	movq    $vgaStart, %rdi
	addq    $3116, %rdi
	leaq	victoryMsg(%rip), %rcx
	movq	$3, %r8
	call	printText

	movb	$1, isWin

	movq	$posStart, %rdi
	addq	$1420, %rdi
	leaq	continueMsg(%rip), %rcx
	movq	$1, %r8
	call	printText

	call	readKeyCode
	cmpq	$0x39, %rax
	jne		dontContinue
	/je		gameInit
	leaq	victoryMsgCover(%rip), %rcx
	movq    $vgaStart, %rdi
	addq    $3116, %rdi
	call	printText

	leaq	continueMsgCover(%rip), %rcx
	movq	$posStart, %rdi
	addq	$1420, %rdi
	call	printText
	
	movb	$0, isWin
	call 	putFruit

dontContinue:
	jmp	endLoop


gameOver:

	movq    $posStart, %rdi
	subq    $8, %rdi
	leaq	gameoverMsg(%rip), %rcx
	movq	$4, %r8
	call	printText

	movb	$1, isgameover

	movq	$posStart, %rdi
	addq	$1420, %rdi
	leaq	continueMsg(%rip), %rcx
	movq	$1, %r8
	call	printText

	call	readKeyCode
	cmpq	$0x39, %rax
	je		gameInit

endLoop:

	ret


putFruit:
	rdtsc                       	#get random pos to put the fruit    
	movq    $0, %rdx
	movq    $469, %rcx         		#(1856-160x2-64x9-4)/2
	divq	%rcx

	movq	%rdx, %rax

	movq	$2, %rcx
	mulq	%rcx

	movq	$0, %rdx
	movq	$arenaStart, %r8
	movq	$arenaEnd, %r9
	
	movq	%rax, %rdi

	addq	$arenaStart, %rdi
	addq	$162, %rdi

	movq	$arenaStart, %rcx
	addq	$162, %rcx


checkFruitLoop:						#check if fruit is on the arena
	addq	$94, %rcx

	cmpq	%rcx, %rdi
	jl		endCheckFruitLoop

	addq	$66, %rdi

	addq	$66, %rcx

	cmpq	%rcx, %rdi
	jg		checkFruitLoop

endCheckFruitLoop:

	movq	$0, %rsi				#loop counter

checkForPlayer:
	movq	$posStart, %rcx						#loop to check if snake is on itself
	addq	snakePos(,%rsi,8), %rcx
	cmpq	%rdi, %rcx
	je		putFruit

	incq	%rsi
	cmpq	%r14, %rsi
	jle		checkForPlayer

	movq	%rdi, fruitPos				#saves the location of the fruit

	movb	$'0', %al
	#movb	$'., %al #--> print a dot for some reason, so to print a non-letter character dont add ending '
	movb	$0x0C, %ah
	movw	%ax, (%rdi)

	movq	$0, %r15

	ret
