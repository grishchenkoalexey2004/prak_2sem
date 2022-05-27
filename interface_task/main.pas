
program interface_procedures;
uses crt,asm_code_loader;


const main_window_width = 80;
const main_window_height = 25;
const text_window_height = 8;
const text_window_width = 60;
const input_window_width = 60 ;
const input_window_height = 8;
const text_window_X = 10;
const text_window_Y = 5;
const input_window_X = 10;
const input_window_Y = 15;

const main_menu_color = lightgray;
const text_menu_color = lightcyan;
const input_menu_color = green;
const mistake_window_color = yellow;
const mistake_text_color = red;

const error_color = red;
const main_text_color = black;

const enter_code = 13;
const esc_code = 27;
const ctrl_r_code = 18;
const delete_code = 8;
const cursor_margin_pos = 62;
type string_len_arr = array[1..output_string_count] of integer;

{глобальные переменные использующие типы из модуля asm_code_loader}
var input_file:asm_file;
var file_string_arr:asm_string_arr;
var string_count:integer; {количество  строк в фаиле}
var displayed_strings:strings_to_display;{массив строк, который отображается в верхнем текстовом окне}
var esc_pressed:boolean;
var string_lengths:string_len_arr; {в массиве будут храниться длины строк, которые пользователь ввел
в input_menu}
const allowed_chars = 'abcdefghigklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 .[],';


procedure print_info();
begin
	textcolor(main_text_color);
	gotoxy(1,1);
	writeln('Author: Grishchenko Alexey 109 group');
	writeln('Trenazher programmista na yazike Assemblera');
	writeln('ZADACHA:perepechatat tekst v zelyonom okne bez oshibok');
	writeln('ESC-vichod, ENTER-pomenyat stroky, CTRL+R-nachat zanovo, BACKSPACE-ydalyt symbol');
end;

{процедура выводит текст из фаила в окошко для текста}

procedure fill_text_window();
var i:integer;

begin
	gotoxy(1,1);
	for i:=1 to output_string_count do 
		begin
			writeln(displayed_strings[i]);
		end;
end; 



procedure generate_text_window();
begin
	Window(text_window_X,text_window_Y,text_window_X+text_window_width,
			text_window_Y+text_window_height);
		textbackground(text_menu_color);
		clrscr;

	fill_text_window()
end; 


procedure generate_input_window();

begin
	Window(input_window_X,input_window_Y,
			input_window_X+input_window_width,input_window_Y+input_window_height);
	textbackground(input_menu_color);
	clrscr;
end; 

procedure delete_sym(var cursorX,cursorY:integer);
var prev_string_len:integer;
var i:integer;
begin
	if cursorX<>1 then 
		begin
			string_lengths[cursorY]:=string_lengths[cursorY]-1;
			cursorX:=cursorX-1;
			gotoxy(cursorX,cursorY);
			textbackground(input_menu_color);
			write(' ');
			gotoxy(cursorX,cursorY);

		end
	else 
		begin
			if cursorY<>1 then 
				begin
					cursorY:=cursorY-1;
					prev_string_len:=string_lengths[cursorY];
					cursorX:=prev_string_len+1;
					gotoxy(cursorX,cursorY);
					textbackground(input_menu_color);
					for i:=cursorX to input_window_width do 
						write(' ');
					gotoxy(cursorX,cursorY);
				end;	

		end;
	
end;

procedure enter_pressed(var cursorX,cursorY,mistake_count:integer);
var string_len:integer;
var i:integer;
begin
	gotoxy(cursorX,cursorY);
	string_len:=ord(displayed_strings[cursorY][0]);
	textbackground(error_color);
	for i:=1 to string_len-cursorX+1 do 
		begin
			write(' ');
			mistake_count:=mistake_count+1;
		end;
	{высчитываем новую позицию курсора}
	textbackground(input_menu_color);
	cursorY:=cursorY+1;
	cursorX:=1;
	gotoxy(cursorX,cursorY);
end;

procedure wait_for_ctrl_r();
var ctrl_r_pressed:boolean;

var exit_key:char;
begin
	ctrl_r_pressed:=false;
	textcolor(input_menu_color);
	repeat 
		exit_key:=readkey;
		if ord(exit_key) = ctrl_r_code then
			ctrl_r_pressed:=true;
		if ord(exit_key) = esc_code then 
			esc_pressed:=true;	
	until ctrl_r_pressed or esc_pressed;
	textcolor(main_text_color);
end;

procedure reset_windows();
var i:integer;	
begin
	cut_string_sequence(file_string_arr,displayed_strings,string_count);
	generate_text_window();
	generate_input_window();
	for i:=1 to output_string_count do 
		string_lengths[i]:=0
end;


procedure process_key(input_char:char;var cursorX,cursorY,mistake_count:integer);
begin
	if cursorX = cursor_margin_pos then 
		begin
			mistake_count:=mistake_count+1;
			gotoxy(cursorX,cursorY);
		end
	else
		begin
			string_lengths[cursorY]:=string_lengths[cursorY]+1;
			if input_char<>displayed_strings[cursorY][cursorX] then 
				begin
					mistake_count:=mistake_count+1;
					gotoxy(cursorX,cursorY);
					textbackground(error_color);
					write(input_char);
					textbackground(input_menu_color);
				end
			else
				write(input_char);	

			cursorX:=cursorX+1;
			gotoxy(cursorX,cursorY);
		end;

	
	
end;

procedure take_input();

var input_char:char;
var mistake_count:integer;
var cursorX,cursorY:integer;
var exit_cycle:boolean;
begin
	cursorX:=1;
	cursorY:=1;
	exit_cycle:=false;
	mistake_count:=0;
	repeat 
		input_char:=readkey;
		case ord(input_char) of 
				esc_code:esc_pressed:=true;
				enter_code:enter_pressed(cursorX,cursorY,mistake_count);
				ctrl_r_code:exit_cycle:=true;
				delete_code:delete_sym(cursorX,cursorY);

				else

					process_key(input_char,cursorX,cursorY,mistake_count);
			end;

		if cursorY = (output_string_count+1) then 
			begin
				writeln('CTRL+R - nachat zanovo/ ESC - vichod');
				textcolor(mistake_text_color);
				write('Kolichestvo oshibok: ',mistake_count);
				textcolor(main_text_color);
				wait_for_ctrl_r();
				exit_cycle:=true
				{будем игнорировать все клавиши кроме комбинации ctrl+r}
			end;

	until  esc_pressed or exit_cycle; 
end; 





procedure setup_start();
begin
	esc_pressed:=false;
	load_strings(input_file,file_string_arr,string_count);
	clrscr;		
	Window(1,1,main_window_width,main_window_height);
	textbackground(main_menu_color);
	clrscr;
	print_info();
	while not(esc_pressed) do 
		begin
			reset_windows();
			take_input();
		end;

end;

begin
	randomize();
	load_strings(input_file,file_string_arr,string_count);{загружаем строки из txt фаила}
	setup_start();
end.