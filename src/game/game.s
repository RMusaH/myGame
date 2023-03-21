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

snakePos:		.zero 6000					#array with every location of the snake

fruitPos:		.quad 0						#has the fruit position



.section .game.text
.equ		vgaStart, 0xB8000               #start of screen
.equ    	vgaEnd, 0xB8FA0                 #end 0f screen
.equ		posStart, 0xB87D0
.equ		arenaStart, 0xB83E0				#+992 (6 lines + 1/5)
.equ		arenaEnd, 0xB8B20				#+2848 (18 lines - 1/5)

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
	movq	$0, %r15				#counter of loops to determine clock speed
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

drawSnake:	
	movq    $vgaStart, %rdi			#display "snake"
	addq    $394, %rdi
	movb	$0x0A, %ah
	movb	$'S', %al
	movw    %ax, (%rdi) 
	movb	$0x0A, %ah		
	movb	$'N', %al
	movw    %ax, 2(%rdi)
	movb	$0x0A, %ah
	movb	$'A', %al
	movw    %ax, 4(%rdi)
	movb	$0x0A, %ah
	movb	$'K', %al
	movw    %ax, 6(%rdi)
	movb	$0x0A, %ah
	movb	$'E', %al
	movw    %ax, 8(%rdi)

drawScore:
	movq    $vgaStart, %rdi		#display "score"
	addq    $354, %rdi
	movb	$0x0F, %ah
	movb	$'S', %al
	movw    %ax, (%rdi) 
	movb	$0x0F, %ah		
	movb	$'C', %al
	movw    %ax, 2(%rdi)
	movb	$0x0F, %ah
	movb	$'O', %al
	movw    %ax, 4(%rdi)
	movb	$0x0F, %ah
	movb	$'R', %al
	movw    %ax, 6(%rdi)
	movb	$0x0F, %ah
	movb	$'E', %al
	movw    %ax, 8(%rdi)

drawHighscore:
	addq    $80, %rdi			#highscore display
	movb	$0x0E, %ah
	movb	$'H', %al
	movw    %ax, (%rdi) 
	movb	$0x0E, %ah		
	movb	$'I', %al
	movw    %ax, 2(%rdi)
	movb	$0x0E, %ah
	movb	$'G', %al
	movw    %ax, 4(%rdi)
	movb	$0x0E, %ah
	movb	$'H', %al
	movw    %ax, 6(%rdi)
	movb	$0x0E, %ah
	movb	$'S', %al
	movw    %ax, 8(%rdi)
	movb	$'C', %al
	movw    %ax, 10(%rdi)
	movb	$0x0E, %ah
	movb	$'O', %al
	movw    %ax, 12(%rdi)
	movb	$0x0E, %ah
	movb	$'R', %al
	movw    %ax, 14(%rdi)
	movb	$0x0E, %ah
	movb	$'E', %al
	movw    %ax, 16(%rdi)


gameLoop:
	call	updateScore
	call	updateHighscore

	cmpb	$0, isgameover(%rip)			#checks if game over
	jne		gameOver
	cmpb	$0, isWin(%rip)			#checks if game over
	jne		win_case
	
	call	readKeyCode
	cmpq	$0, %rax
	je		move
	cmpq	$0x11, %rax			#compare W
	je		up
	cmpq	$0x1E, %rax			#compare A
	je		left
	cmpq	$0x1F, %rax			#compare S
	je		down
	cmpq	$0x20, %rax			#compare D
	je		right

	jmp		move
	
updateScore:
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

updateHighSchool:
	movq    $vgaStart, %rdi
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
	
	incq	%r15						#clock speed to determine when should it move
	cmpq	$10, %r15
	jl		endLoop

	movq	%r13, lastMove

	movq	%r12, %rdx			#getting last move

	movq	$0, %r15			#loop counter

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

		cmpq	$1, score
		je		win_case
		
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


		incq	%r14					#increase size
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
	addq    $712, %rdi
	movb	$0x0E, %ah
	movb	$'V', %al
	movw    %ax, (%rdi) 
	movb	$0x0E, %ah		
	movb	$'I', %al
	movw    %ax, 2(%rdi)
	movb	$0x0E, %ah
	movb	$'C', %al
	movw    %ax, 4(%rdi)
	movb	$0x0E, %ah
	movb	$'T', %al
	movw    %ax, 6(%rdi)
	movb	$0x0E, %ah
	movb	$'O', %al
	movw    %ax, 8(%rdi)
	movb	$0x0E, %ah
	movb	$'R', %al
	movw    %ax, 10(%rdi)
	movb	$0x0E, %ah
	movb	$'Y', %al
	movw    %ax, 12(%rdi)
	movb	$1, isWin

	call	readKeyCode
	cmpq	$0x39, %rax
	jne		dontContinue

	movb	$0, isWin

dontContinue:
	jmp	endLoop


gameOver:

	movq    $posStart, %rdi
	subq    $8, %rdi
	movw    $0x0F47, (%rdi)  		#game over shows
	movw    $0x0F41, 2(%rdi)
	movw    $0x0F4D, 4(%rdi)
	movw    $0x0F45, 6(%rdi)
	movw    $0x0F4F, 10(%rdi)
	movw    $0x0F56, 12(%rdi)
	movw    $0x0F45, 14(%rdi)
	movw    $0x0F52, 16(%rdi)
	movb	$1, isgameover

	call	readKeyCode
	cmpq	$0x39, %rax
	je		gameInit

endLoop:

	ret


putFruit:
	rdtsc                       	#get random pos to put the fruit    
	movq    $0, %rdx
	movq    $478, %rcx         		#(1856-160x2-64x9-4)/2
	divq	%rcx

	movq	%rdx, %rax

	movq	$2, %rcx
	mulq	%rcx
	
	movq	%rax, %rdi

	addq	$arenaStart, %rdi
	addq	$162, %rdi

	movq	$arenaStart, %rcx
	addq	$160, %rcx


checkFruitLoop:						#check if fruit is on the arena
	addq	$96, %rcx

	cmpq	%rcx, %rdi
	jl		endCheckFruitLoop

	addq	$64, %rdi

	addq	$64, %rcx

	cmpq	%rcx, %rdi
	jg		checkFruitLoop

endCheckFruitLoop:


	movq	%rdi, fruitPos				#saves the location of the fruit

	movb	$'0', %al
	movb	$0x4, %ah
	movw	%ax, (%rdi)

	ret
