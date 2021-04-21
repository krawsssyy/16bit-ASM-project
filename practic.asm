assume cs:code, ds:data

data segment
	a db 2, 1, -3, 3, -4, 2, 6
	l_a equ $-a
	b db 4, 5, 7, -6, 2, 1
	l_b equ $-b
	d1 db l_a + l_b dup(?)
	d2 db l_a + l_b dup(?)
	newLine db 10, 13, '$'
data ends

code segment
	start:
		mov ax, data
		mov ds, ax
		mov es, ax

		cld

		mov si, offset a
		mov di, offset d1

		mov cx, l_a
		add cx, l_b

		construct_d1:
			lodsb
			mov dl, al
			cmp al, 0
			jge checkParity
			jmp end_construct_d1

			checkParity:
				cbw
				mov bl, 2
				idiv bl
				cmp ah, 0
				je addToD1
				jmp end_construct_d1

				addToD1:
					mov al, dl
					stosb

			end_construct_d1:
		loop construct_d1

		mov al, '$'
		stosb
		mov cx, l_a
		add cx, l_b
		mov di, 0

		prepare_to_print_d1:
			cmp d1[di], '$'
			je out_of_loop
			add d1[di], '0'
			inc di
		loop prepare_to_print_d1

		out_of_loop:
		mov ah, 09h
		mov dx, offset d1
		int 21h

		mov dx, offset newLine
		int 21h

		xor ax, ax

		mov si, offset a
		mov di, offset d2

		mov cx, l_a
		add cx, l_b

		construct_d2:
			lodsb
			mov dl, al
			cmp al, 0
			jle checkDivisibility
			jmp end_construct_d2

			checkDivisibility:
				cbw
				mov bl, 3
				idiv bl
				cmp ah, 0
				je addToD2
				jmp end_construct_d2

				addToD2:
					mov al, dl
					stosb

			end_construct_d2:
		loop construct_d2

		mov al, '$'
		stosb
		mov cx, l_a
		add cx, l_b
		mov di, 0

		print_d2:
			mov al, d2[di]
			cmp al, '$'
			je end_program
			neg al
			add al, '0'
			mov ah, 02h
			mov dl, '-'
			int 21h
			mov dl, al
			int 21h
			inc di
		loop print_d2

		end_program:
		mov ax, 4C00h
		int 21h
code ends
	end start