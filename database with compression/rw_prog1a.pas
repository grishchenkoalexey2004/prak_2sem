{nba players db
fields : height.inch(1..12), height.feet(integer), name(array [1..25] of char), years played in a career : set,
scores in the last ten matches,   }



{с помощью процедуры на языке ассемблера будем сжимать в слово следующие поля: team, ht.feet,ht.inch,is_healthy }

program rw_db;
const max_record_count = 10;
	match_count = 3;
const compressed_file_filename = 'db1_PA.rec';

type name_range = 1..25;
	match_range = 1..match_count;
	score_range = 0..70;
	answer_range =  1..3;

type name_arr=array[name_range] of char;
	stat_arr=array[match_range] of score_range;
	position_set=set of char;

type player_type = record
		player_name:name_arr;{имя}
		team:integer;{номер команды - 3 бит}
		ht:record {рост}
			feet:integer;{можно упаковать в 3 бита}
			inch:integer;{можно упаквоать в 4 бита}
		end;
		positions:position_set; {позиции на которых играет данный игрок  P - разыгрывающий, S -снайпер, F - форвард
    С - центровой}
		match_stats:stat_arr;   {статистика в последних трех матчах}
		is_healthy:integer;    {состояние здоровья - можно упаковать в 1 бит}
	end;

{тип записи, хранящей информацию об игроке в сжатом виде}
type compressed_player_type = record 
		player_name :name_arr;
		compressed_player_data:integer;{в integer будет храниться данные о росте, команде и состоянии здоровья}
		positions:position_set;
		match_stats:stat_arr;
	end;

type record_arr = array [1..max_record_count] of player_type;

type db_file = file of compressed_player_type;
var f:db_file;
	db_arr:record_arr;
	answer:answer_range;
	to_exit:boolean;
	write_ind:integer;


procedure clear_name_arr(var arr:name_arr);
var i:integer;
begin
	for i:=1 to 25 do
		arr[i]:='.';
end;

{выводит имя игрока}
procedure print_name(arr:name_arr);
var ind:name_range;
begin
	ind:=1;
  write('Имя :');
	while arr[ind]<>'.' do
		begin
			write(arr[ind]);
			ind:=ind+1;
		end;
	writeln;

end;

{выводит статистику по заброшенным очкам за последние три матча}
procedure print_match_stats(stats:stat_arr);
var i:integer;
begin
  write('Статистика за последние 3 матча: ');
	for i:=1 to match_count do
		write(stats[i],' ');
	writeln;

end;

{выводит позиции на которых играет игрок}
procedure print_positions(pos_set:position_set);
begin
  write('Позиции : ');
	if 'P' in pos_set then
		write('разыгрывающий ');
	if 'S' in pos_set then
		write('снайпер ');
	if 'F' in pos_set then
		write('форвард ');
	if 'C' in pos_set then
		write('центровой ');
	writeln;
end;

{выводит название команды, за которую выступает игрок}
procedure print_team(team_num:integer);
begin
	case team_num of
		1:writeln('MEM');
		2:writeln('LAL');
		3:writeln('GSW');
		4:writeln('ORL');
		5:writeln('OKC');
	end;
end;

{выводит состояние здоровья игрока}
procedure print_health_state(health:integer);
begin
	if health =1  then
		writeln('Здоров')
	else
		writeln('Травмирован');
end;

{вывод базы данных}
procedure print_db(var db_arr:record_arr;write_ind:integer);
var i:integer;
var player:player_type;
begin
	if write_ind<>1 then
		begin
			for i:=1 to write_ind-1 do
				begin
					writeln('/////////////////////////////////////////////////////////');
					player:=db_arr[i];
					with player do
						begin

							print_name(player_name);
							writeln('Рост : ',ht.feet,'.',ht.inch);
							print_positions(positions);
							print_match_stats(match_stats);
							print_team(team);
							print_health_state(is_healthy);
						end;
					writeln('/////////////////////////////////////////////////////////');
					writeln;
				end;
		end
	else
		writeln('В базе данных нет записей!');
end;

{узнает у пользователя, какую операцию тот хочет выполнить}
function ask_question:answer_range;
var ans:answer_range;
begin
	writeln('Что вы хотите сделать с базой данных? (1-вывести|2-добавить запись|3-выйти из программы');
	readln(ans);
	ask_question:=ans;
end;

{ссылки на процедуры описанные в модуле на ЯА}
function pack_data(ht_feet,ht_inch,team_num,health_state:integer):integer;
stdcall;
external name '_pack_data@0';
{$L pck_unpck_module.obj}

procedure unpack_data(compr_data:integer;var ht_feet,ht_inch,team_num,health_state:integer);
stdcall;
external name '_unpack_data@0';
{$L pck_unpck_module.obj}

{данная подпрограмма создает сжатую запись на основе несжатой}
procedure compress_player_info(var compressed_player:compressed_player_type;normal_player:player_type);
var ht_ft,ht_inch,team_number,health_num:integer;
var compressed_data:integer;
begin
	ht_ft:=normal_player.ht.feet;
	ht_inch:=normal_player.ht.inch;
	team_number:=normal_player.team;
	health_num:=normal_player.is_healthy;
	compressed_player.player_name:=normal_player.player_name;
	compressed_player.match_stats:=normal_player.match_stats;
	compressed_player.positions:=normal_player.positions;
	{вывов процедуры для упаковки данных на ассемблере}
	compressed_data:=pack_data(ht_ft,ht_inch,team_number,health_num);
	compressed_player.compressed_player_data:=compressed_data;
end;

{данная подпрограмма распаковывает сжатую запись и записывает информацию в тип записи без сжатия}
procedure unpack_player_info(var normal_player:player_type;compressed_player:compressed_player_type);
var ht_ft,ht_inch,team_number,health_num:integer;
var compressed_info:integer;
begin
	normal_player.player_name:=compressed_player.player_name;
	normal_player.match_stats:=compressed_player.match_stats;
	normal_player.positions:=compressed_player.positions;
	compressed_info:= compressed_player.compressed_player_data;
	{проиводим распаковку информации, хранящейся в переменной типа integer}
	unpack_data(compressed_info,ht_ft,ht_inch,team_number,health_num);
	{записываем распакованные данные в запись несжатого типа}
	normal_player.ht.feet:=ht_ft;
	normal_player.ht.inch:=ht_inch;
	normal_player.team:=team_number;
	normal_player.is_healthy:=health_num;
	{вызов процедуры на ассемблере}
end;

{загружает из фаила в массив записей информацию об игроках}
procedure download_records(var f:db_file;var db_arr:record_arr;var write_ind:integer);
var compressed_player:compressed_player_type;
var normal_player:player_type;
begin
	writeln('Записи загружаются!');
	reset(f);
	while not eof(f) do
		begin
			read(f,compressed_player);
			{перед тем как записывать информацию в массив записей происходит распаковка}
			unpack_player_info(normal_player,compressed_player);
			db_arr[write_ind]:=normal_player;
			write_ind:=write_ind+1;
		end;
end;

{записывает информацию из массива записей в фаил }
procedure upload_records(var f:db_file;var db_arr:record_arr;write_ind:integer);
var i:integer;
var compressed_player:compressed_player_type;
begin
	rewrite(f);
	writeln('Записи выгружаются!');
	for i:=1 to write_ind-1 do
		begin
			{перед выгрузкой  в фаил запись сжимается, и уже сжатая запись записывается в текстовый фаил }
			compress_player_info(compressed_player,db_arr[i]);
			write(f,compressed_player);
		end;
  close(f);
end;

{добавляет в конец массива с записями новую ячейку, с введенной пользователем информации об игроке} 
procedure add_record(var db_arr:record_arr;var write_ind:integer);
var new_player:player_type;
var i:integer;
var team_number:integer;
var is_healthy_char,input_position:char;

begin
	clear_name_arr(new_player.player_name);
	write('Введите имя игрока и нажмите enter: ');
	readln(new_player.player_name);
	write('Введите через пробел рост игрока в футах (от 5 до 7) и дюймах(от 0 до 11) через пробел: ');
	read(new_player.ht.feet);
	readln(new_player.ht.inch);
	write('Введите количество набранных очков в последних трех матчах (от 0 до 70): ');
	for i:=1 to match_count do
		begin
			read(new_player.match_stats[i]);
		end;
  readln;
  write('Введите позиции на которых играет данный игрок (S|P|F|C) без пробелов и в конце поставьте точку: ');
	new_player.positions:=[];
	repeat
		read(input_position);
		if input_position<>'.' then
			new_player.positions:=new_player.positions+[input_position];
	until input_position='.';
  readln;
  write('Введите номер команды за которую играет данный игрок (возможные варианты:MEM-1,LAL -2,GSW-3,ORL-4,OKC-5): ');
	readln(team_number);
	new_player.team:=team_number;
	writeln('Есть травмы? (y|n)');
	readln(is_healthy_char);
	if is_healthy_char = 'y' then
		new_player.is_healthy:=0
	else
		new_player.is_healthy:=1;
	db_arr[write_ind]:=new_player;

	if write_ind >= max_record_count then
		writeln('база данных полностью заполнена')
	else
		write_ind:=write_ind+1;

end;


begin
  assign(f,compressed_file_filename);
	to_exit:=false;
	write_ind:=1;
	download_records(f,db_arr,write_ind);
	while not(to_exit) do
	begin
		answer:=ask_question();
		case answer of
			1:print_db(db_arr,write_ind);
			2:add_record(db_arr,write_ind);
			3:begin
				upload_records(f,db_arr,write_ind);
        to_exit:=true;
			end;
		end;


	end;

end.
