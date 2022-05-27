include console.inc

.const 

	max_string_len equ 100
	a_code equ 'a'
	zero_code equ '0'
	one_code equ '1'
	nine_code equ '9'
	K equ 6

.data
	string_1 db max_string_len+1 dup (?);१�ࢨ�㥬 ��� ��ப� 101 ����, �.�. 
	;�᫨ ��� ��ப� �㤥� ������ �� 100 ᨬ�����, � ���ॡ���� 101� ���� ��� �࠭���� 0 
	string_2 db max_string_len+1 dup (?)
	shift_val db ?;�㤥� �����, �� ���祭�� ᤢ��� ����頥��� � ���� 

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
	mov edi,[ebp+8];�����뢠�� � edi ���� �祩�� � ���ன �࠭���� ����� ��ப�
	mov edx, [ebp+12];�����뢠�� � edx ���� ��ࢮ�� ����� ��ப� 
	xor ecx,ecx 
	input_cycle:
		inchar bl 
		cmp bl,'.'
		je input_end 
		cmp ecx,max_string_len;	�᫨ �� 101 ������ ��ப� ���짮��⥫� ��⠥��� ������� �㪢�, � 
		;⮣�� � eax �����뢠�� ���祭�� ᢨ��⥫�����饥 �� �訡��
		je write_error_val
		mov byte ptr [edx][ecx],bl
		inc ecx
		jmp input_cycle
		
	write_error_val:
		xor eax,eax  
	
	input_end:
		flush
		mov byte ptr [edi],cl 
		mov byte ptr [edx][ecx],0; �����뢠�� � ����� ��ப� ����� 
		
		pop edi 
		pop edx 
		pop ecx 
		pop ebx
		pop ebp 
	ret 2*4

input_string endp 

; � ����⢥ ��ࠬ��� ��।����� ���� ��ࢮ�� ����� ��ப� � ����� ��ப� 
;procedure first_transf_rule (var string:array;var string_len:integer)
first_transf_rule proc
	push ebp
	mov ebp,esp
	
	push ecx 
	push ebx 
	mov ebx,[ebp+12];ebx = ���� ��ࢮ�� ����� ��ப�
	mov ecx, [ebp+8]	;ecx = string_len 
	dec ecx ;���⠥� ������� ⠪ ��� �祩�� [ebx][string_len] �� �ਭ������� ��ப�;	
	transf1_cycle:
		cmp byte ptr [ebx][ecx],one_code
		jb transf1_cycle_end
		cmp byte ptr [ebx][ecx],nine_code
		ja transf1_cycle_end;�᫨ ᨬ��� ��  ��ன
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
	
;��楤�� ᤢ������ �� ᨬ���� ��ப� �� shift_val ����権 
;� ����⢥ ��ࠬ��஢ ��।����� ���� ��ࢮ�� ����� ���ᨢ�, ����� ��ப�, ���祭�� ᤢ���
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
	
	
	mov esi,[ebp+16];ebx = ���� ��ࢮ�� ����� ��ப�
	mov ecx, [ebp+12]	;ecx = string_len 
	xor ebx,ebx 
	mov ebx,[ebp+8]; bl = shift_val 
	;����ன�� ���祭�� ॣ���஢ ��। ��ॢ��⮬ ��᫥���� K ����⮢ ��ப� 
	cmp cl,bl
	ja normal_case; ��ଠ��� ��砩 - ����� ��ப� ����� ���祭�� ᤢ���
	je proc_end; �᫨ ����� ��ப� ࠢ����� ���祭�� ᤢ���, � ��ப� �������� �� �㦭� 
	outstrln 'here'
	xor eax,eax 
	mov al,bl 
	mov dl,cl;dl = string_len 
	div dl ;� �h �㤥� �࠭����� ���⮪ � ⠪�� ����� ���祭�� ᤢ���
	mov bl,ah 
	
	normal_case:
	mov edx,ecx 
	sub dl,bl
	mov edi,ecx
	dec edi 
	
	rev_last_syms:
		cmp edx ,edi
		jae rev_first_syms

		;����� ���祭�ﬨ ����� �祩����
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

		;����� ���祭�ﬨ ����� �祩����
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

		;����� ���祭�ﬨ ����� �祩����
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
	outstrln "�����: �������� ������� 109��"
	outstrln "�������������� 1 - �������� ��� ����� � ������ �� ��������������� ����� �������� 1-a 2-b ... "

	outstrln "�������������� 2 - �������� ��� ������� ������ �� K(���������) ������� ������ ��� ������������� ���. ������ "
	outstrln "������� ��� ������ (����� ENTER)"
	newline
	
	mov shift_val,K; ���祭�� ����⠭�� �����뢠� � ��६�����, ⠪ ��� ���祭�� ᤢ��� ������ ���� ��������, �᫨ 
	;����� ��ப� < ���祭�� ᤢ���
	program_loop:
		
		outstrln '������� ������ ������'
		push offset string_1
		push offset string_len1
		call input_string
		cmp al,0FFh
		jne input_error
		
		outstrln '������� ������ ������'
		push offset string_2
		push offset string_len2
		call input_string
		cmp al,0FFh
		jne input_error
		
		outstrln '�������� ������'
		outstrln offset string_1
		outstrln offset string_2
		
		outstrln '/////////////////////////////'	
		
		mov al,string_len1
		cmp al,string_len2
		
		jb first_shorter
		
			;�ਬ��塞 ��ࢮ� �ࠢ��� �࠭��ଠ樨 � ��ࢮ� ��ப�
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
			print_registers;�᫨ �� �믮������� ��୮, � �ணࠬ�� ������ �������� ��ப� �� �����祪
			
			outstrln '1st string after 1st transf. rule'
			outstrln offset string_1
			outstrln '2nd string after 2nd transf. rule'
			outstrln offset string_2
			jmp program_loop_end
		
		first_shorter:
			;�ਬ��塞 ��ࢮ� �ࠢ��� �࠭��ଠ樨 �� ��ன ��ப� 
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
			outstrln '������ �����'
		
		program_loop_end:
			outstrln '1-��������� ���������� ���������, 0-����������'
			inint al 
			cmp al,1
			jne program_loop
			jmp program_end
		
	program_end:
		exit 


end Start 
