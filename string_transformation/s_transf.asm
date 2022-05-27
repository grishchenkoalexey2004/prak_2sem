include console.inc

.const 

	max_string_len equ 100
	a_code equ 'a'
	zero_code equ '0'
	one_code equ '1'
	nine_code equ '9'
	K equ 6

.data
	string_1 db max_string_len+1 dup (?);резервируем под строку 101 байт, т.к. 
	;если наша строка будет состоять из 100 символов, то потребуется 101ый байт для хранения 0 
	string_2 db max_string_len+1 dup (?)
	shift_val db ?;будем считать, что значение сдвига помещается в байт 

	string_len1 db ?
	string_len2 db ?
.code 

input_string proc ; function (var arr:string,var string_len:integer):integer->al
	push ebp 
	mov ebp,esp
	
	push ebx
	push ecx 
	push edx
	push edi 
	
	mov eax,0FFh
	mov edi,[ebp+8];записываем в edi адрес ячейки в которой хранится длина строки
	mov edx, [ebp+12];записываем в edx адрес первого элемента строки 
	xor ecx,ecx 
	input_cycle:
		inchar bl 
		cmp bl,'.'
		je input_end 
		cmp ecx,max_string_len;	если на 101 позицию строки пользователь пытается записать букву, то 
		;тогда в eax записываем значение свидетельствующее об ошибке
		je write_error_val
		mov byte ptr [edx][ecx],bl
		inc ecx
		jmp input_cycle
		
	write_error_val:
		xor eax,eax  
	
	input_end:
		flush
		mov byte ptr [edi],cl 
		mov byte ptr [edx][ecx],0; записываем в конец строки нолик 
		
		pop edi 
		pop edx 
		pop ecx 
		pop ebx
		pop ebp 
	ret 2*4

input_string endp 

; в качестве параметра передается адрес первого элемента строки и длина строки 
;procedure first_transf_rule (var string:array;var string_len:integer)
first_transf_rule proc
	push ebp
	mov ebp,esp
	
	push ecx 
	push ebx 
	mov ebx,[ebp+12];ebx = адрес первого элемента строки
	mov ecx, [ebp+8]	;ecx = string_len 
	dec ecx ;вычитаем единичку так как ячейка [ebx][string_len] не принадлежит строке;	
	transf1_cycle:
		cmp byte ptr [ebx][ecx],one_code
		jb transf1_cycle_end
		cmp byte ptr [ebx][ecx],nine_code
		ja transf1_cycle_end;если символ не явл цифрой
		sub byte ptr [ebx][ecx],zero_code+1
		add byte ptr[ebx][ecx], a_code
		transf1_cycle_end:
			dec ecx 
			cmp ecx,-1
			jne transf1_cycle
		
	pop ebx
	pop ecx 
	pop ebp
	ret 2*4
	
first_transf_rule endp 
	
;процедура сдвигающая все символы строки на shift_val позиций 
;в качестве параметров передаются адрес первого элемента массива, длина строки, значение сдвига
;procedure sec_transf_rule (var string:array,var string_len:integer,var shift_val:integer)
sec_transf_rule proc
	push ebp
	mov ebp,esp
	
	push eax 
	push ebx 
	push ecx 
	push edx 
	push edi 
	push esi 
	
	
	mov esi,[ebp+16];ebx = адрес первого элемента строки
	mov ecx, [ebp+12]	;ecx = string_len 
	xor ebx,ebx 
	mov ebx,[ebp+8]; bl = shift_val 
	;настройка значений регистров перед переворотом последних K элементов строки 
	cmp cl,bl
	ja normal_case; нормальный случай - длина строки больше значения сдвига
	je proc_end; если длина строки равняется значению сдвига, то строку изменять не нужно 
	outstrln 'here'
	xor eax,eax 
	mov al,bl 
	mov dl,cl;dl = string_len 
	div dl ;в аh будет храниться остаток а также новое значение сдвига
	mov bl,ah 
	
	normal_case:
	mov edx,ecx 
	sub dl,bl
	mov edi,ecx
	dec edi 
	
	rev_last_syms:
		cmp edx ,edi
		jae rev_first_syms

		;обмен значениями между ячейками
		mov al,byte ptr [esi][edx]
		xchg al,byte ptr [esi][edi]
		mov byte ptr [esi][edx],al
		inc edx
		dec edi 
		jmp rev_last_syms
	
	

	rev_first_syms:
	
	mov edi,ecx 
	xor edx,edx
	mov dl,bl 
	sub edi,edx
	dec edi 
	xor edx,edx
	rev_first_syms_cycle:
		cmp edx ,edi
		jae rev_whole_str

		;обмен значениями между ячейками
		mov al,byte ptr [esi][edx]
		xchg al,byte ptr [esi][edi]
		mov byte ptr [esi][edx],al
		inc edx
		dec edi 
		jmp rev_first_syms_cycle
		
		
	rev_whole_str:
	xor edx,edx
	mov edi,ecx
	dec edi 
	
	rev_whole_str_cycle:
		cmp edx,edi
		jae proc_end

		;обмен значениями между ячейками
		mov al,byte ptr [esi][edx]
		xchg al,byte ptr [esi][edi]
		mov byte ptr [esi][edx],al
		inc edx
		dec edi 
		jmp rev_whole_str_cycle
	
	
	proc_end:
	pop esi 
	pop edi 
	pop edx
	pop ecx
	pop ebx
	pop eax 
	pop ebp
	ret 3*4
sec_transf_rule endp

Start:
	outstrln "АВТОР: ГРИЩЕНКО АЛЕКСЕЙ 109ГР"
	outstrln "ПРЕОБРАЗОВАНИЕ 1 - ЗАМЕНИТЬ ВСЕ ЦИФРЫ В СТРОКЕ НА СООТВЕТСТВУЮЩУЮ БУКВУ АЛФАВИТА 1-a 2-b ... "

	outstrln "ПРЕОБРАЗОВАНИЕ 2 - СДВИНУТЬ ВСЕ СИМВОЛЫ СТРОКИ НА K(КОНСТАНТА) ПОЗИЦИЙ ВПРАВО БЕЗ ИСПОЛЬЗОВАНИЯ ДОП. ПАМЯТИ "
	outstrln "ВВЕДИТЕ ДВЕ СТРОКИ (ЧЕРЕЗ ENTER)"
	newline
	
	mov shift_val,K; значение константы записываю в переменную, так как значение сдвига должно быть изменено, если 
	;длина строки < значение сдвига
	program_loop:
		
		outstrln 'ВВЕДИТЕ ПЕРВУЮ СТРОКУ'
		push offset string_1
		push offset string_len1
		call input_string
		cmp al,0FFh
		jne input_error
		
		outstrln 'ВВЕДИТЕ ВТОРУЮ СТРОКУ'
		push offset string_2
		push offset string_len2
		call input_string
		cmp al,0FFh
		jne input_error
		
		outstrln 'ИСХОДНЫЕ СТРОКИ'
		outstrln offset string_1
		outstrln offset string_2
		
		outstrln '/////////////////////////////'	
		
		mov al,string_len1
		cmp al,string_len2
		
		jb first_shorter
		
			;применяем первое правило трансформации к первой строке
			push offset string_1
			xor eax,eax 
			mov al,string_len1
			push eax
			mov eax,1
			call first_transf_rule
			print_registers
			
			push offset string_2
			xor eax,eax 
			mov al,string_len2
			push eax 
			mov al,shift_val
			push eax 
			mov eax,1
			call sec_transf_rule
			print_registers;если все выполнилось верно, то программа должна напечатать строку из единичек
			
			outstrln '1st string after 1st transf. rule'
			outstrln offset string_1
			outstrln '2nd string after 2nd transf. rule'
			outstrln offset string_2
			jmp program_loop_end
		
		first_shorter:
			;применяем первое правило трансформации ко второй строке 
			push offset string_2
			xor eax,eax 
			mov al,string_len2
			push eax
			mov eax,1
			call first_transf_rule
			print_registers
			
			push offset string_1
			xor eax,eax 
			mov al,string_len1
			push eax 
			mov al,shift_val
			push eax 
			mov eax,1
			call sec_transf_rule
			print_registers
			
			outstrln '1st string after 2nd transf. rule'
			outstrln offset string_1
			outstrln '2nd string after 1st transf. rule'
			outstrln offset string_2
			jmp program_loop_end
		
		input_error:
			outstrln 'ОШИБКА ВВОДА'
		
		program_loop_end:
			outstrln '1-ЗАВЕРШИТЬ ВЫПОЛНЕНИЕ ПРОГРАММЫ, 0-ПРОДОЛЖИТЬ'
			inint al 
			cmp al,1
			jne program_loop
			jmp program_end
		
	program_end:
		exit 


end Start 
