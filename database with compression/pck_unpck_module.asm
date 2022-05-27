 .686
.model flat,stdcall
option casemap:none

.code 
	;параметры (в том порядке, в котором они должны идти в программе на паскале):
	;в качестве аргументов  передаются 4 переменных типа word (рост в футах, рост в дюймах,номер команды,состояние здоровья)
	; 
	; + адрес переменной в которую записывается сжатая информация)
	pack_data proc public
		push ebp 
		mov ebp,esp
		push ebx
		push ecx
		push edx
		push edi
		
		xor ax,ax
		mov dx,word ptr [ebp+8];рост в футах (занимает 3 бита)
		mov bx,word ptr [ebp+12];рост в дюймах (занимает 4 бита)
		mov cx,word ptr [ebp+16];номер команды (занимает 3 бита)
		mov di,word ptr [ebp+20];состояние здоровья (занимает 1 бит)
		
		;упаковка ax
		shl dx,8
		or ax,dx
			
		;упаковка bx
		shl bx,4
		or ax,bx
		
		;упаковка cx
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
	
	
	;параметры (в том порядке, в котором они должны идти в программе на паскале):
	;переменная со сжатыми данными (dw), адреса переменных в которые будем записывать рост в футах, рост в дюймах, номер команды
	;состояние здоровья
	unpack_data proc public
		push ebp
		mov ebp,esp
		push eax
		push ebx
		push ecx
		push edx
		
		mov ax,word ptr [ebp+8]
		
		xor dx,dx
		shl ax,5; предварительно сдвигаем блок с ценной информацией влево  на 16 - 11 = 5 позиций (ценная инфа содержится в правых 11 битах)	
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