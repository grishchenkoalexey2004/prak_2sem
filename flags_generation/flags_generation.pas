program flag_calculator;
const num_count = 3;{количество чисел в одной строке входного фаила}
var f_in,f_out:text;
var f_in_name,f_out_name:string;
type string_arr = array[1..3] of longint;{массив для хранения чисел записанных в строке входного фаила}
type flag_arr = array [1..4] of 0..1;
type bin_arr = array [1..16] of integer; {массив в котором будет храниться двоичное представление чисел}
type ans_record = record 
		byte_count:integer;{количество байт отведенное для хранения числа	}
		dec_num1:longint;
		dec_num2:longint;
		bin_num1:bin_arr;
		bin_num2:bin_arr;

		pos_dec_sum:longint;
		sign_dec_sum:longint;
		bin_sum_res:bin_arr;
		pos_dec_subtr:longint;
		sign_dec_subtr:longint;
		bin_subtr_res:bin_arr;

		flags_sum:flag_arr;
		flags_subtr:flag_arr;
		error:boolean;
	end;
var test_bin_arr:bin_arr;

{функция вычисляет сколько чисел можно закодировать с помощью заданного количества бит}
function calc_encoded_nums_number(byte_count:integer):longint;
var i:integer;
var ans:longint;
begin
	ans:=1;
	for i:=1 to byte_count do 
		ans:=ans*2;
	calc_encoded_nums_number:=ans;
end;

function calc_max_pos_num(enc_nums_number:longint):longint;
begin
	calc_max_pos_num:=enc_nums_number-1;
end;

function calc_min_sign_num(byte_count:integer):longint;
var i:integer;
var ans:longint;
begin
	ans:=1;
	for i:=1 to (byte_count-1) do 
		ans:=ans*2;
	ans:=ans*(-1);
	calc_min_sign_num:=ans;
end;

function calc_max_sign_num(min_sign_num:longint):longint;
begin
	calc_max_sign_num:=(min_sign_num+1)*(-1);
end;

{перевод числа в знаковое представление}
function sign_repr(num,max_sign_num,nums_encoded:longint):longint;
begin
	if num>max_sign_num then 
		num:=num-nums_encoded;
	sign_repr:=num;
end;

{перевод числа в беззнаковое представление}
function positive_repr(num,nums_encoded:longint):longint;
begin
	if num<0 then {если число меньше нуля, то
	для перевода в положительное представление добавляем к нему 2^N где N - количество байт, которым кодируется это число}
		num:=num+nums_encoded;	
	positive_repr:=num;
end;

procedure convert_to_bin(var bin_num:bin_arr;num,max_pos_num:longint;byte_count:integer);
var i,ind,num_len:integer;
begin
	num_len:=byte_count;{результат не должен занимать больше byte_count бит}
	for i:=1 to 16 do 
		bin_num[i]:=0;
	ind:=16;
	if num<0 then 
		num:=num+max_pos_num+1;
	while (num>0) and (num_len>0) do 
		begin
			bin_num[ind]:=num mod 2;
			num:=num div 2;
			num_len:=num_len-1;
			ind:=ind-1;
		end;
end;

{высчитывает флаг нуля на основании двоичной записи}
function calc_zf(bin_num:bin_arr):integer;
var i:integer;
var zf:integer;
begin
	zf:=1;
	for i:=1 to 16 do 
		if bin_num[i]=1 then
			zf:=0;
	calc_zf:=zf;
end;

function calc_sf(bin_num:bin_arr;byte_count:integer):integer;
var sf,sign_bit_ind:integer;
begin
	sign_bit_ind:=16-byte_count+1;
	sf:=0;
	if bin_num[sign_bit_ind]=1 then 
		sf:=1;
	calc_sf:=sf;
end;

function calc_cf(pos_num,max_pos_num:longint):integer;
var cf:integer;
begin
	cf:=0;
	{pos_sum<0 может сработать при вычитании}
	if ((pos_num)>max_pos_num) or (pos_num<0) then cf:=1;
	calc_cf:=cf;
end;

function calc_of(sign_num,min_num,max_sign_num:longint):integer;
var ovf:integer;
begin
	ovf:=0;
	if (sign_num>max_sign_num) or (sign_num<min_num) then OVF:=1;
	calc_of:=ovf;
end;

function adjust_pos_res(bin_num:bin_arr;byte_count:integer):longint;{вычисляет беззнаковое число по двоичной записи}
var res:longint;
var multiplier:longint;
var i:integer;
begin
	multiplier:=1;
	res:=0;
	for i:=1 to byte_count do 
		begin
			res:=res+bin_num[17-i]*multiplier;
			multiplier:=multiplier*2;
		end;
	adjust_pos_res:=res;
end;

function adjust_sign_res(bin_num:bin_arr;byte_count:integer):longint;
var res:longint;
var sign_bit_ind:integer;
var i:integer;
begin
	sign_bit_ind:=16-byte_count+1;
	if bin_num[sign_bit_ind]=0 then 
		begin
			res:=adjust_pos_res(bin_num,byte_count);
		end
	else
		begin
			{инвертируется число}
			for i:=1 to byte_count do
				begin
					if bin_num[17-i]=1 then 
						bin_num[17-i]:=0
					else
						bin_num[17-i]:=1;
				end;
			
			res:=adjust_pos_res(bin_num,byte_count);
			res:=res+1;
			res:=res*(-1);
		end;
	adjust_sign_res:=res
end;

procedure err_message(input_num,min_num,max_num:longint);
begin
	writeln('Ошибка! Число ',input_num,' не лежит в диапазоне ',min_num,'..',max_num);
end;

procedure print_res_status(flag_val:integer);

begin
	if flag_val=1 then
		write(' (неверно) ')
	else
		write(' (верно) ');
end;

procedure print_results(pos_num1,pos_num2,sign_num1,sign_num2,pos_sum_res,sign_sum_res,pos_subtr_res,
				sign_subtr_res:longint;flags_sum,flags_subtr:flag_arr;byte_count:integer);
begin
	write(byte_count,' бит: ');
	write('(',pos_num1,')',' + ','(',pos_num2,')','=',pos_sum_res);
	print_res_status(flags_sum[3]);
	write('(',sign_num1,')',' + ','(',sign_num2,')','=',sign_sum_res);
	print_res_status(flags_sum[4]);
	write('(',pos_num1,')',' - ','(',pos_num2,')','=',pos_subtr_res);
	print_res_status(flags_subtr[3]);
	write('(',sign_num1,')',' - ','(',sign_num2,')','=',sign_subtr_res);
	print_res_status(flags_subtr[4]);
	writeln;
end;

{обрабатывает одну строчку из входного фаила и записывает результаты в запись}
procedure process_string(var answer:ans_record;num_arr:string_arr); 
const base = 2;
var byte_count:integer;
var num1,num2:longint;{исходные числа}
var nums_encoded,min_num,max_pos_num,max_sign_num:longint;
var err1,err2,err:boolean;
var sign_sum_res,pos_sum_res,sign_subtr_res,pos_subtr_res:longint;
var bin_num1,bin_num2,bin_sum_res,bin_subtr_res:bin_arr;
var sign_num1,sign_num2:longint;{знаковое представление}
var pos_num1,pos_num2:longint;{беззнаковое представление}
var flags_sum,flags_subtr:flag_arr;
begin
	byte_count:=num_arr[1];
	num1:=num_arr[2];
	num2:=num_arr[3];
	nums_encoded:=calc_encoded_nums_number(byte_count);
	max_pos_num:=calc_max_pos_num(nums_encoded);
	min_num:=calc_min_sign_num(byte_count);
	max_sign_num:=calc_max_sign_num(min_num);
	err1:=(num1<min_num) or (num1>max_pos_num);{err1 = true если первое число не лежит в заданном диапазоне}
	err2:=(num2<min_num) or (num2>max_pos_num);
	err:=err1 or err2;
	if not(err) then 
		begin
			sign_num1:=sign_repr(num1,max_sign_num,nums_encoded);
			sign_num2:=sign_repr(num2,max_sign_num,nums_encoded);

			pos_num1:=positive_repr(num1,nums_encoded);
			pos_num2:=positive_repr(num2,nums_encoded);

			convert_to_bin(bin_num1,num1,max_pos_num,byte_count);
			convert_to_bin(bin_num2,num2,max_pos_num,byte_count);

			pos_sum_res:=pos_num1+pos_num2;
			sign_sum_res:=sign_num1+sign_num2;
			
			pos_subtr_res:=pos_num1-pos_num2;
			sign_subtr_res:=sign_num1-sign_num2; 

			convert_to_bin(bin_sum_res,pos_sum_res,max_pos_num,byte_count);
			convert_to_bin(bin_subtr_res,pos_subtr_res,max_pos_num,byte_count);

			{выработка флагов для сложаня}
			flags_sum[1]:=calc_zf(bin_sum_res);
			flags_sum[2]:=calc_sf(bin_sum_res,byte_count);
			flags_sum[3]:=calc_cf(pos_sum_res,max_pos_num);
			if flags_sum[3]=1 then 
				pos_sum_res:=adjust_pos_res(bin_sum_res,byte_count);
			{может получиться так, результат вылезет за диапазон
			беззнаковых чисел (Сf = 1), тогда результат будем считать по его двоичной записи в заданном количестве бит}
			flags_sum[4]:=calc_of(sign_sum_res,min_num,max_sign_num);{аналогичная проблема со знаковыми}
			if flags_sum[4]=1 then 
				sign_sum_res:=adjust_sign_res(bin_sum_res,byte_count);

			{выработка флагов для вычитания}
			flags_subtr[1]:=calc_zf(bin_subtr_res);
			flags_subtr[2]:=calc_sf(bin_subtr_res,byte_count);
			flags_subtr[3]:=calc_cf(pos_subtr_res,max_pos_num);
			if flags_subtr[3]=1 then 
				pos_subtr_res:=adjust_pos_res(bin_subtr_res,byte_count);
			flags_subtr[4]:=calc_of(sign_subtr_res,min_num,max_sign_num);
			if flags_subtr[4]=1 then 
				sign_subtr_res:=adjust_sign_res(bin_subtr_res,byte_count);
			{запись ответа в record}
			answer.byte_count:=byte_count;
			answer.dec_num1:=num1;
			answer.dec_num2:=num2;
			answer.bin_num1:=bin_num1;
			answer.bin_num2:=bin_num2;

			answer.pos_dec_sum:=pos_sum_res;
			answer.sign_dec_sum:=sign_sum_res;
			answer.bin_sum_res:=bin_sum_res;
			answer.pos_dec_subtr:=pos_subtr_res;
			answer.sign_dec_subtr:=sign_subtr_res;
			answer.bin_subtr_res:=bin_subtr_res;

			answer.flags_sum:=flags_sum;
			answer.flags_subtr:=flags_subtr;
			answer.error:=false;
			{печать результатов на экран в следующем порядке: 1)беззнак слож,2)знак слож,3)беззнак вычит 4)знак вычит }
			
			print_results(pos_num1,pos_num2,sign_num1,sign_num2,pos_sum_res,sign_sum_res,pos_subtr_res,
				sign_subtr_res,flags_sum,flags_subtr,byte_count);
			
		end
	else 
		begin
			if err1 then 
				err_message(num1,min_num,max_pos_num)
			else
				err_message(num2,min_num,max_pos_num);
			answer.error:=true;
		end;
end; 

{процедура для записи числа в фаил двоичном представлении}
procedure write_binary(bin_num:bin_arr;num_len:integer;var output_file:text);
var start_ind,i:integer;
begin
	start_ind:=16-num_len+1;
	for i:=start_ind to 16 do 
		begin
			write(output_file,bin_num[i])
		end;
end;

procedure write_flags(flags:flag_arr;var output_file:text);
var i:integer;
begin
	for i:=1 to 4 do 
		write(output_file,flags[i]);
		writeln(output_file,'');{перевод на новую строку}
end;

function calc_space_count(num:longint;byte_count:integer):integer;{процедура подсчитывает количество пробелов
которое надо поставить перед десятично числом в фаиле вывода}
var ans:integer;
begin
	ans:=byte_count;
	if num<0 then
		begin 
			num:=abs(num);
			ans:=ans-1;
		end;
	repeat
		num:=num div 10;
		ans:=ans-1;

	until num=0;
	calc_space_count:=ans;
end;

procedure write_whitespace(num:integer;var f:text);{печатает num пробелов в фаил f}
var i:integer;
begin
	for i:=1 to num do 
		write(f,' ');

end;

{запись результатов сложения и вычитания для одной тройки чисел}
procedure write_record(rec:ans_record;var output_file:text);
var wsp_count1,wsp_count2,wsp_count3,wsp_count4:integer;
begin
	if not(rec.error) then
		begin
			{cложение}
			writeln(output_file,rec.byte_count,' ',rec.dec_num1,' ',rec.dec_num2);
			write(output_file,'+ ');
			write_binary(rec.bin_num1,rec.byte_count,output_file);
			write(output_file,'  ');
			write_binary(rec.bin_num2,rec.byte_count,output_file);
			write(output_file,'  ');
			write_binary(rec.bin_sum_res,rec.byte_count,output_file);
			wsp_count1:=calc_space_count(rec.pos_dec_sum,rec.byte_count);
			wsp_count2:=calc_space_count(rec.sign_dec_sum,rec.byte_count);
			write_whitespace(wsp_count1,output_file);
			write(output_file,rec.pos_dec_sum);
			write_whitespace(wsp_count2,output_file);
			write(output_file,rec.sign_dec_sum);
			write(output_file,'  ');
			write_flags(rec.flags_sum,output_file);

			{вычитание}
			write(output_file,'- ');
			write_binary(rec.bin_num1,rec.byte_count,output_file);
			write(output_file,'  ');
			write_binary(rec.bin_num2,rec.byte_count,output_file);
			write(output_file,'  ');
			write_binary(rec.bin_subtr_res,rec.byte_count,output_file);
			wsp_count3:=calc_space_count(rec.pos_dec_subtr,rec.byte_count);
			wsp_count4:=calc_space_count(rec.sign_dec_subtr,rec.byte_count);
			write_whitespace(wsp_count3,output_file);
			write(output_file,rec.pos_dec_subtr);
			write_whitespace(wsp_count4,output_file);
			write(output_file,rec.sign_dec_subtr);
			write(output_file,'  ');
			write_flags(rec.flags_subtr,output_file);
			writeln(output_file,'');
		end;
end;

{основная процедура, считывает имена фаилов ввода и вывода, обрабатывает построчно фаил ввода
 и записывает результаты в фаил вывода}
procedure main();
var string_data:string_arr;
var i:integer;
var results:ans_record;
begin
	writeln('Введите имя входного фаила: ');
	readln(f_in_name);
	assign(f_in,f_in_name);
	reset(f_in);
	writeln('Введите имя выходного фаила: ');
	readln(f_out_name);
	assign(f_out,f_out_name);{присваиваем имена входным и выходным фаилам}
	rewrite(f_out);
	while not(eof(f_in)) do 
		begin
			for i:=1 to num_count do 
				read(f_in,string_data[i]);
			process_string(results,string_data);
			write_record(results,f_out);
		end;
	close(f_in);
	close(f_out);
end;


begin
	main();
end.