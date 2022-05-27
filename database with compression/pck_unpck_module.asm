 .686
.model flat,stdcall
option casemap:none

.code 
	;��ࠬ���� (� ⮬ ���浪�, � ���஬ ��� ������ ��� � �ணࠬ�� �� ��᪠��):
	;� ����⢥ ��㬥�⮢  ��।����� 4 ��६����� ⨯� word (��� � ����, ��� � ���,����� �������,���ﭨ� ���஢��)
	; 
	; + ���� ��६����� � ������ �����뢠���� ᦠ�� ���ଠ��)
	pack_data proc public
		push ebp 
		mov ebp,esp
		push ebx
		push ecx
		push edx
		push edi
		
		xor ax,ax
		mov dx,word ptr [ebp+8];��� � ���� (�������� 3 ���)
		mov bx,word ptr [ebp+12];��� � ��� (�������� 4 ���)
		mov cx,word ptr [ebp+16];����� ������� (�������� 3 ���)
		mov di,word ptr [ebp+20];���ﭨ� ���஢�� (�������� 1 ���)
		
		;㯠����� ax
		shl dx,8
		or ax,dx
			
		;㯠����� bx
		shl bx,4
		or ax,bx
		
		;㯠����� cx
		shl cx,1
		or ax,cx
		
		or ax,di
			
		pop edi
		pop edx
		pop ecx
		pop ebx
		pop ebp
		ret 16
	pack_data endp
	
	
	;��ࠬ���� (� ⮬ ���浪�, � ���஬ ��� ������ ��� � �ணࠬ�� �� ��᪠��):
	;��६����� � ᦠ�묨 ����묨 (dw), ���� ��६����� � ����� �㤥� �����뢠�� ��� � ����, ��� � ���, ����� �������
	;���ﭨ� ���஢��
	unpack_data proc public
		push ebp
		mov ebp,esp
		push eax
		push ebx
		push ecx
		push edx
		
		mov ax,word ptr [ebp+8]
		
		xor dx,dx
		shl ax,5; �।���⥫쭮 ᤢ����� ���� � 業��� ���ଠ樥� �����  �� 16 - 11 = 5 ����権 (業��� ��� ᮤ�ন��� � �ࠢ�� 11 ����)	
		mov ecx,3
		ht_feet_unpack_loop:
			shl ax,1
			rcl dx,1
			loop ht_feet_unpack_loop
		mov ebx,dword ptr [ebp+12]
		mov word ptr [ebx],dx
		
		xor dx,dx
		mov ecx,4
		ht_inch_unpack_loop:
			shl ax,1
			rcl dx,1
			loop ht_inch_unpack_loop
		mov ebx,dword ptr [ebp+16]
		mov word ptr [ebx],dx
		
		xor dx,dx
		mov ecx,3
		team_num_unpack_loop:
			shl ax,1
			rcl dx,1
			loop team_num_unpack_loop
		mov ebx,dword ptr [ebp+20]
		mov word ptr [ebx],dx
		
		xor dx,dx
		shl ax,1
		rcl dx,1
		mov ebx,dword ptr [ebp+24]
		mov word ptr [ebx],dx
		
		pop edx
		pop ecx
		pop ebx
		pop eax
		pop ebp
		ret 20
	unpack_data endp
		
end