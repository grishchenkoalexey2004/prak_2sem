include console.inc
;���� - ��饭�� ����ᥩ
;���஢�� ������� ᫮� � ������ �� �����⠭�� ���襭�� ��⮤�� ����쪠 

.data
	arr_len1 equ 7
	arr_len2 equ 1
	
	arr1 dd arr_len1 dup (?)
	arr2 dd arr_len2 dup (?) 
.code 

input_arr proc;��। �맮��� ��楤��� � �⥪ ����室��� �������� ���� ��ࢮ�� ����� � ����� ��ᨢ�  
	push ebp
	mov ebp,esp 
	
	push eax
	push ebx 
	push ecx 
	
	xor eax,eax 
	mov ebx,[ebp+12]; �����뢠�� ���� ��ࢮ�� ����� ���ᨢ� 
	mov ecx,[ebp+8];�����뢠�� ����� ���ᨢ�
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

print_array proc; ��। �맮��� ��楤��� � �⥪ ����室��� �������� ���� ��ࢮ�� ����� ���ᨢ� � ����� ���ᨢ�
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

sort_arr proc; ��। �맮��� ��楤��� � �⥪ �������� ���� ��ࢮ�� �����  � ����� ���ᨢ� 
	
	push ebp
	mov ebp,esp 
	
	;����� �� ॣ����� ����� ���ॡ����� ��� ॠ����樨 ���஢�� 
	push eax 
	push ebx 
	push ecx 
	push edx 
	push esi 
	push edi 
	
	mov ebx,[ebp +12]; ebx = ���� ��ࢮ�� ����� ���ᨢ�
	mov ecx,[ebp +8]
	dec ecx ;ecx = arr_len -1 
	
	mov ebp,ecx; ebp = arr_len -1 
	;� ebp �㤥� �࠭��� ���祭�� ��� ���稪� ����७���� 横��;
	;��஥ ���祭�� ebp ����� �����, �.�. �� 㦥 �ਭ﫨 �� ����室��� ��ࠬ���� � ����ᠫ� �� � ᮮ⢥�����騥 ॣ����� 
	cmp ebp,0;�� ��砩 �᫨ ���ᨢ ����� 1 
	je end_sort 
	sort_cycle:;��� �⮩ ��⪮� ����ᠭ� �᭮���� ���� �����⬠ ���஢�� 
	;� ���祭�� � edi �㤥� ��������� 1, ����� ࠧ �� ᮢ��襭�� ����⠭���� (�᫨ edi =0 ��᫥ ��।���� ��ᬮ�� ���ᨢ�, ⮣�� �४�頥� ���஢��)
		xor edi,edi 
		xor eax,eax
		mov edx,ebp ; ���稪 ��� ���������� 横�� 
		parse_arr:; � 横�� ��ᬠ�ਢ��� ���ᨢ �� �� ��砫� �� ���� 
			mov esi,[ebx][eax*4]
			cmp esi,[ebx][eax*4]+4
			jg swap 
			end_swap:
			inc eax 
			dec edx 
			cmp edx,0 
			jne parse_arr;
		
		cmp edi,0
		je end_sort;����筮� �४�饭�� ���஢�� (�᫨ ����稫��� ⠪, �� �� ��室 ���ᨢ� � 横�� �� �� ᮢ��訫� �� ����� ����⠭����)
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
	outstr '������� ������� ����� ' 
	outword arr_len1 
	outstr ' � '
	outword arr_len2 
	outstrln ' (�������� ������ ������� �������� ����� ������, ����� ������ 2-��� ������� ENTER)'
	;���� ��ࢮ�� ���ᨢ� 
	push offset arr1
	push arr_len1
	call input_arr
	flush 
	;���� ��ண� ���ᨢ� 
	push offset arr2
	push arr_len2
	call input_arr
	
	;����� ���ᨢ��
	flush 
	push offset arr1
	push arr_len1
	call print_array
	
	
	push offset arr2
	push arr_len2
	call print_array
	
	;���஢�� ���ᨢ�� 
	push offset arr1
	push arr_len1
	call sort_arr
	
	
	push offset arr2
	push arr_len2
	call sort_arr
	
	;�뢮� ���ᨢ��
	outstrln '////////////////////////'
	push offset arr1
	push arr_len1
	call print_array
	
	
	
	push offset arr2
	push arr_len2
	call print_array
	
	exit 
	
		
end Start 	