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

position:	.quad 0x0				#counter of position

.section .game.text
.equ		vgaStart, 0xB8000               #start of screen
.equ    	vgaEnd, 0xB8FA0                 #end if screen

	#0x0F3D

gameInit:

	movq    $19886, %rdi 
    call    setTimer    

	movq    $vgaStart, %rdi         #start of graphics memory

initLoop: 
    movw    $0, (%rdi)              #erase what was there before
    addq    $2, %rdi                #get next memory address
    cmpq    $vgaEnd, %rdi           #check if it is the end
    jl      initLoop                #if its not the end continue

	movq	$0, %r12				#position to start
	movq	$2, %r13				#witch offset to move
	movq	$0, %r8					#counter of loops to determine clock speed
	movq	$1, %r9                 #snake size

	rdtsc                       	#get random pos to put the fruit    
	movq    $0, %rdx
	movq    $4000, %rcx         
	divq	%rcx

	addq	$vgaStart, %rdx
	movq	%rdx, %rdi
	movw	$0x0F3D, (%rdi)

gameLoop:
	
	incq	%r8						#clock speed to determine when should it move
	cmpq	$10, %r8
	jl		endloop
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

	addq	%r13, %r12				#add value of next move to the snake

	pushq	%r13
	
	movq    $vgaStart, %rdi

	addq	%r12, %rdi
	movw	$0x0323, (%rdi)			#print next position

	popq	%r13
	subq	%r13, %rdi
	movw	$0, (%rdi)				#delete old position

endloop:

	ret

putFruit:
	rdtsc                       #get random pos to put the fruit    
	movq    $0, %rdx
	movq    $4000, %rcx         
	divq	%rcx

	addq	$vgaStart, %rcx
	movq	%rcx, %rdi
	movw	$0x0F3D, (%rdi)



	ret
