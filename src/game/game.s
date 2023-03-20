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

snakePos:		.zero 4000					#array with every location of the snake

size:			.byte 64

fruitPos:		.byte 64					#for debugging

.section .game.text
.equ		vgaStart, 0xB8000               #start of screen
.equ    	vgaEnd, 0xB8FA0                 #end if screen
.equ		posStart, 0xB87D0

	#0x0F3D

gameInit:

	movq    $19886, %rdi 
    call    setTimer    

	movq    $vgaStart, %rdi         #start of graphics memory

	movq	$posStart, fruitPos

clearScreen: 
    movw    $0, (%rdi)              #erase what was there before
    addq    $2, %rdi                #get next memory address
    cmpq    $vgaEnd, %rdi           #check if it is the end
    jl      clearScreen             #if its not the end continue

	movq	$0, %r12				#position to start
	movq	$2, %r13				#witch offset to move
	movq	$0, %r14				#size
	movq	$0, %r8					#counter of loops to determine clock speed

	call 	putFruit

gameLoop:
	
	incq	%r8						#clock speed to determine when should it move
	cmpq	$10, %r8
	jl		endLoop
	movq	$0, %r8


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

up:
	movq	$-160, %r13
	jmp		move

left:
	movq	$-2, %r13
	jmp		move

down:
	movq	$160, %r13
	jmp		move

right:
	movq	$2, %r13
	jmp		move

move:

	movq	$posStart, %rdx
	addq	%r12, %rdx			#getting last move

	movq	$0, %r15			#loop counter

passMoves:

	movq	snakePos(%r15,8), %rsi	#shifting every move in the array
	movq	%rdx, snakePos(,%r15,8)
	movq	%rsi, %rdx

	incq	%r15

	cmpq	%r14, %r15
	jle		passMoves


	movq    $posStart, %rdi

	addq	%r13, %r12				#add value of next move to the snake

	addq	%r12, %rdi
	movw	$0x0323, (%rdi)			#print next position

	cmpq	%rdi, %r9				#checks if got the fruit
	je		grow

	movq	snakePos(,%r14,8), %rdi
	movw	$0, (%rdi,1)				#delete end of the tail
	jmp 	endLoop

grow:
	incq	%r14					#increase size
	call	putFruit

endLoop:

	ret

putFruit:

	addq	$30, fruitPos
	movq	fruitPos, %rdx
	movq	%rdx, %r9				#saves the location of the fruit
	movq	%rdx, %rdi
	movw	$0x0F3D, (%rdi)

	ret
