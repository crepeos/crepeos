
	BITS 16
	%INCLUDE "cdev.inc"
	ORG 32768


start:
	call os_hide_cursor
    call os_clear_screen

	mov ax, os_init_msg		; Set up the welcome screen
	mov cx, 11110000b		; Colour: black and white 
	call os_draw_background

	mov bl, 01001111b		
	mov dl, 0		; X
	mov dh, 1		; Y	
	mov si, 80		; Width	
	mov di, 3		; End of Y	
	call os_draw_block

    mov si, title
    call os_print_string

	mov bl, 01001111b		
	mov dl, 0		; X
	mov dh, 3		; Y	
	mov si, 80		; Width	
	mov di, 4		; End of Y	
	call os_draw_block

    jc operations

    


operations:
    call os_print_newline
    call os_print_newline

    call os_print_horiz_line
    mov si, ops
    call os_print_string
    call os_print_newline
    call os_print_horiz_line

    call os_wait_for_key


add:
    ret


os_init_msg	db '| CrepeOS Calc |------------------------------------------| Version 0.3 Alpha |', 0
title db 'Choose an Operation', 0
ops db 'Add, Subtract, Divide and Multiply or quit'