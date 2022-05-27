include console.inc
;автор - Грищенко Алексей
;сортировка двойных слов со знаком по возрастанию улучшенным методом пузырька 

.data
	arr_len1 equ 7
	arr_len2 equ 1
	
	arr1 dd arr_len1 dup (?)
	arr2 dd arr_len2 dup (?) 
.code 

input_arr proc;перед вызовом процедуры в стек необходимо положить адрес первого элемента и длину масива  
	push ebp
	mov ebp,esp 
	
	push eax
	push ebx 
	push ecx 
	
	xor eax,eax 
	mov ebx,[ebp+12]; записываем адрес первого элемента массива 
	mov ecx,[ebp+8];записываем длину массива
	input_cycle:
		inint dword ptr [ebx][eax*4]
		outchar ' '
		inc eax 
		cmp eax,ecx
		jne input_cycle 
	
	newline
	pop ecx
	pop ebx
	pop eax 
	pop ebp
	ret 2*4	
input_arr endp 

print_array proc; перед вызовом процедуры в стек необходимо положить адрес первого элемента массива и длину массива
	push ebp
	mov ebp,esp 
	push eax
	push ebx 
	push ecx 
	
	xor eax,eax 
	mov ebx,[ebp+12]
	mov ecx,[ebp+8]
	print_cycle:
		outint dword ptr [ebx][eax*4]
		outchar ' '
		inc eax 
		cmp eax,ecx
		jne print_cycle 
		
	newline
	pop ecx
	pop ebx
	pop eax 
	pop ebp 
	ret 2*4

print_array endp 

sort_arr proc; перед вызовом процедуры в стек кладется адрес первого элемента  и длина массива 
	
	push ebp
	mov ebp,esp 
	
	;бэкапим все регистры которые потребуются для реализации сортировки 
	push eax 
	push ebx 
	push ecx 
	push edx 
	push esi 
	push edi 
	
	mov ebx,[ebp +12]; ebx = адрес первого элемента массива
	mov ecx,[ebp +8]
	dec ecx ;ecx = arr_len -1 
	
	mov ebp,ecx; ebp = arr_len -1 
	;в ebp будем хранить значения для счетчика внутреннего цикла;
	;старое значение ebp можем стереть, т.к. мы уже приняли все необходимые параметры и записали их в соответствующие регистры 
	cmp ebp,0;на случай если массив длины 1 
	je end_sort 
	sort_cycle:;под этой меткой написана основная часть алгоритма сортировки 
	;к значению в edi будем добавлять 1, каждый раз при совершении перестановки (если edi =0 после очередного просмотра массива, тогда прекращаем сортировку)
		xor edi,edi 
		xor eax,eax
		mov edx,ebp ; счетчик для вложенного цикла 
		parse_arr:; в цикле просматриваем массив до от начала до конца 
			mov esi,[ebx][eax*4]
			cmp esi,[ebx][eax*4]+4
			jg swap 
			end_swap:
			inc eax 
			dec edx 
			cmp edx,0 
			jne parse_arr;
		
		cmp edi,0
		je end_sort;досрочное прекращение сортировки (если получилось так, что за проход массива в цикле мы не совершили ни одной перестановки)
		dec ecx 
		cmp ecx,0
		jne sort_cycle 
		je end_sort 
	swap:
		inc edi 
		mov esi,[ebx][eax*4]
		xchg esi,[ebx][eax*4]+4
		mov [ebx][eax*4],esi

		jmp end_swap 
	
	end_sort:
		pop edi 
		pop esi 
		pop edx 
		pop ecx 
		pop ebx 
		pop eax 
		pop ebp 
		ret 2*4
		
sort_arr endp 




Start:
	outstr 'ВВЕДИТЕ МАССИВЫ ДЛИНЫ ' 
	outword arr_len1 
	outstr ' И '
	outword arr_len2 
	outstrln ' (ЭЛЕМЕНТЫ ОДНОГО МАССИВА ВВОДЯТСЯ ЧЕРЕЗ ПРОБЕЛ, ПЕРЕД ВВОДОМ 2-ОГО МАССИВА ENTER)'
	;ввод первого массива 
	push offset arr1
	push arr_len1
	call input_arr
	flush 
	;ввод второго массива 
	push offset arr2
	push arr_len2
	call input_arr
	
	;печать массивов
	flush 
	push offset arr1
	push arr_len1
	call print_array
	
	
	push offset arr2
	push arr_len2
	call print_array
	
	;сортировки массивов 
	push offset arr1
	push arr_len1
	call sort_arr
	
	
	push offset arr2
	push arr_len2
	call sort_arr
	
	;вывод массивов
	outstrln '////////////////////////'
	push offset arr1
	push arr_len1
	call print_array
	
	
	
	push offset arr2
	push arr_len2
	call print_array
	
	exit 
	
		
end Start 	