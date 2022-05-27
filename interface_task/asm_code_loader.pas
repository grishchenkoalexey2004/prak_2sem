{����� ����� �⢥砥� �� ����㧪�  �ࠣ���⮢ �ணࠬ�� �� �몥 ��ᥬ���� �� txt 䠨��,a 
⠪�� �� ������� ⥪��, ����}

unit asm_code_loader;
interface 

	const max_strings_in_file = 100;{���� ������⢮ ��ப � 䠨��}
	const max_syms_in_string = 40;{���� ������⢮ ᨬ����� � ��ப�}
	const output_string_count = 5;
	const asm_file_name = 'asm_strings.txt';

	type asm_file =text;
	type asm_string  = string[max_syms_in_string];
	type asm_string_arr  = array[1..max_strings_in_file] of asm_string;
	type strings_to_display = array[1..output_string_count] of asm_string;
	type string_lengths_array = array[1..output_string_count] of integer;
	{�����뢠�� ��ப� �� 䠨�� � ���ᨢ}
	procedure load_strings(var input_file:asm_file;var file_strings:asm_string_arr;var string_count:integer);


	{��१��� �� 䠨�� ����� �� 5  ��ப, ��᫥����⥫쭮 �࠭����� � 䠨��} 
	procedure cut_string_sequence(var file_strings:asm_string_arr;var string_seq:strings_to_display;strings_in_file:integer);




implementation
	procedure load_strings(var input_file:asm_file;var file_strings:asm_string_arr;var string_count:integer);
	var new_string:asm_string;
	begin	
		string_count:=0;
		assign(input_file,asm_file_name);
		reset(input_file);
		while not(eof(input_file)) do 
			begin
				readln(input_file,new_string);
				string_count:=string_count+1;
				file_strings[string_count]:=new_string;

			end;

		close(input_file);
	end;

	

	procedure cut_string_sequence(var file_strings:asm_string_arr;var string_seq:strings_to_display;strings_in_file:integer);
	var first_string_index,last_string_index:integer;
	var i,k:integer;

	begin
		k:=1;
		first_string_index:=1+random(strings_in_file-output_string_count);
		last_string_index:=first_string_index+output_string_count-1;

		for i:=first_string_index to last_string_index do 
			begin

				string_seq[k]:=file_strings[i];
				k:=k+1;
			end;
	end;


begin
	randomize;


end.

