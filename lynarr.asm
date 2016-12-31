%include "asm_io.inc"

SECTION .data

	err1: db "incorrect number of command line arguments, must be two incl. program name",10,0
	err2: db "incompatible string length, string must be of length 1-20 (inclusive)",10,0
	err3: db "incompatible string, must be lower case letters only",10,0
	TEST: dd 10000,50,0,2,3
SECTION .bss
	X: resd 20					;input array
	Y: resd 80					;output array

	N: resd 4					;length
	i: resd 4					;counter for maxLyn
	k: resd 4
	end: resd 4
	p: resd 4
	Z: resd 1
SECTION .text
	global  asm_main

display:						;;;;WORKS;;;
	enter 0,0
	pusha	
	
	mov ebx, dword [ebp+8]		;array to be displayed's address
	mov ecx, dword [ebp+12]		;length
	mov edx, dword [ebp+16]		;flag, 0 for string, 1 for integer
	
	cmp edx, 0					;check flag, goto proper printer
	je STRING_DISPLAY			

	INTEGER_DISPLAY:			
				
	mov eax, dword [ebx]		;load int
	call print_int				;print the int	
	mov eax, ' '
	call print_char	

	add ebx, dword 4			;advance pointer
	sub ecx, dword 1			;decrement counter

	cmp ecx, dword 0			;check for EOL
	jbe display_end				;loop
	

	jmp INTEGER_DISPLAY
	
	STRING_DISPLAY:
	
	mov al, byte[ebx]			;al holds next char
	call print_char				;print it
	add ebx, dword 1			;advance pointer

	cmp ecx, dword 0			; check for end
	jbe display_end
	
	sub ecx, dword 1			; decrement counter

	jmp STRING_DISPLAY			;loop

	display_end:				;print nl, wait for enter, return
	call read_char
	popa
	leave
	ret

maxLyn:							;returns into p
	
	enter 0,0
	pusha

	mov ebx, dword [ebp+8]		;&Z
	mov ecx, dword [ebp+12]		;end
	mov edx, dword [ebp+16]		;k
	mov [Z], ebx
	mov [end], ecx
	mov [k], edx
	mov [p], dword 1
	inc edx
	mov [i], edx				;i = k+1

	cmp edx, [end]				; if k+1 = n // if k = n-1 
	je maxLyn_end
	
	LOOP_LYN:

	mov ebx, [end]				; for i from k+1 to n-1

	cmp [i], ebx				; 
	jge maxLyn_end				; if we get out of for loop, go to end
			
	
	mov ebx, [Z]				;ebx = &Z[i]
	add ebx, dword[i]

	mov ecx, ebx				;ecx = &Z[i-p]
	sub ecx, dword[p]	

	mov bl, byte [ebx]
	mov cl, byte [ecx]
	
	cmp cl, bl				;if z[i-p] = Z[i], loop again
	je LOOP_LYN_AGAIN
	cmp cl, bl				; if z[i-p] > z[i] return p
	jg maxLyn_end

	mov ebx, dword 1					; z[i-p] < z[i] is the only option, so p =i+1-k			
	add ebx, [i]
	sub ebx, [k]	
	mov [p], ebx

	LOOP_LYN_AGAIN:
	inc dword[i]	
	jmp LOOP_LYN
	maxLyn_end:			

	popa
	leave
	ret

asm_main:
	enter 0,0					; setup routine
	pusha                		; save all registers

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; two args

	mov eax, dword [ebp+8]   	; argc
	cmp eax, dword 2         	; argc should be 2
	jne ERR1

;;;;;;;;;;;;;;;;;;;;;;;;;;;; correct size

	mov ebx, dword [ebp+12]
    mov ecx, dword [ebx+4]		;;loading up input string
    mov ebx, dword 0			;setting incrementer
    WHILE_SIZE:
         
    mov al, [ecx]				;load next character into al
    inc ecx					;move pointer to string to next character
     
    cmp al, 0					;check for null, end of string
    jz EXIT_SIZE

    cmp al, 'a'				;check if proper char
	jl ERR3
	cmp al, 'z'
	jg ERR3
    inc ebx     				;i++
     
    jmp WHILE_SIZE				;looping
    EXIT_SIZE:
	cmp ebx, dword 20			;checks if string is too long
	jg ERR2
	
	mov [N], ebx				;set N to size of the string
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;; filling up X

	mov ebx, dword [ebp+12]
    mov ecx, dword [ebx+4]		;loading up input string
    mov ebx, dword X			;setting incrementer
    WHILE_FILL:
         
    mov al, [ecx]				;load next character into al
    inc ecx						;move pointer to string to next character
     
    cmp al, 0					;check for null, end of string
    jz EXIT_FILL
	
	mov [ebx], al				;load character into X array	

    inc ebx     				;i++
     
    jmp WHILE_FILL				;looping
    EXIT_FILL:
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;; display input string

	push dword 0				;send third arg (string)
	push dword [N]				;send second argument to display
	push X						;send first argument to display	
	call display
	add esp, 12					;move pointer

	
;;;;;;;;;;;;;;;;;;;;;;;;;;; loop for lyndon
	
	mov ebx, Y					;ebx holds pointer to Y[k]	
	mov ecx, dword 0					;ecx = k, k=0

	LOOP_LYNDON:
	cmp ecx, [N]				;while k < N
	jge LOOP_LYNDON_END	
	

	push dword ecx				;ebp+16 = k
	push dword [N]				;ebp+12 = N
	push X						;ebp+8 = &X
	call maxLyn					
	add esp, 12
	

	mov eax, [p]				;eax holds result of calling maxLyn	

	mov [ebx], eax				;store result in Y[k]
	add ebx, dword 4					;inc. &Y
	add ecx, dword 1					;inc. k	
	jmp LOOP_LYNDON	
	LOOP_LYNDON_END:

;;;;;;;;;;;;;;;;;;;;;;;;;;;; print result
	
	push dword 1
	push dword [N]
	push Y
	call display
	add esp, 12

;;;;;;;;;;;;;;;;;;;;;;;;;;;; errors and end
	jmp asm_main_end
 ERR1:
	mov eax, err1
	call print_string
	call print_nl
	jmp asm_main_end

 ERR2:
	mov eax, err2
	call print_string
	call print_nl
	jmp asm_main_end

 ERR3:
	mov eax, err3
	call print_string
	call print_nl
	jmp asm_main_end

 asm_main_end:
	popa                  ; restore all registers
	leave                     
	ret
