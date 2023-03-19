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
.equ		vgaStart, 0xB8000               #start of vga
.equ    	vgaEnd, 0xB8FA0                 #end if vga

gameInit:

	movq    $39772, %rdi            #reloadValue for 60 Hz since this game's logic is frame-dependent
    call    setTimer                #call setTimer to load it to 60 Hz

	movq    $vgaStart, %rdi         #start of graphics memory

	movq	$0, %r12
	movq	$0, %r13

initLoop: 
    movw    $0, (%rdi)              #erase what was there before
    addq    $2, %rdi                #get next memory address
    cmpq    $vgaEnd, %rdi           #check if it is the end
    jl      initLoop                #if its not the end continue

	ret

gameLoop:

	incq	%r12

	movq    $vgaStart, %rdi
	movw	$0x0F3D, (%rdi)

	# Check if a key has been pressed
	call	readKeyCode
	cmpq	$0, %rax
	je		noClick
	
	
	#movb	$'1', %dl
	#movq	$1, %rdi
	#movq	$0, %rsi
	#movb	$0x0f, %cl
	#call	putChar

noClick:

	#movb	$0, %dl
	#movq	%r12, %r8
	#decq	%r8
	#movq	%r8, %rdi
	#movq	$0, %rsi
	#movb	$0x0f, %cl
	#call	putChar

	#movb	$'0', %dl
	#movq	%r12, %rdi
	#movq	$0, %rsi
	#movb	$0x0f, %cl
	#call	putChar

endloop:

	ret
