program search_program;

const max_record_count = 10;
	match_count = 3;
const compressed_file_filename = 'db1_P.rec';
type name_range = 1..25;
	match_range = 1..match_count;
	score_range = 0..70;
	answer_range =  1..5;

type name_arr=array[name_range] of char;
	stat_arr=array[match_range] of score_range;
	position_set=set of char;

type player_type = record
		player_name:name_arr;
		team:integer;
		ht:record
			feet:integer;
			inch:integer
		end;
		positions:position_set;
		match_stats:stat_arr;
		is_healthy:integer;
	end;

type record_arr = array [1..max_record_count] of player_type;

type db_file = file of player_type;
var f:db_file;
	db_arr:record_arr;
	answer:answer_range;
	to_exit:boolean;
	write_ind:integer;

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

procedure print_match_stats(stats:stat_arr);
var i:integer;
begin
  write('Статистика за последние 3 матча: ');
	for i:=1 to match_count do
		write(stats[i],' ');
	writeln;

end;

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

procedure print_health_state(health:integer);
begin
	if health = 1 then
		writeln('Здоров')
	else
		writeln('Травмирован');
end;

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



procedure download_records(var f:db_file;var db_arr:record_arr;var write_ind:integer);
var read_player:player_type;
begin
	writeln('Записи загружаются!');
	reset(f);
	while not eof(f) do
		begin
			read(f,read_player);
			db_arr[write_ind]:=read_player;
			write_ind:=write_ind+1;
		end;
end;



function ask_question:answer_range;
var ans:answer_range;
begin
  writeln('Что вы хотите сделать? (1-задание 1|2-задание 2|3-задание 3|4-выход из программы|5-вывод базы данных)');
	readln(ans);
	ask_question:=ans;
end;

procedure task1(db_arr:record_arr;write_ind:integer);
var team_number:integer;
	max_height_ft:integer;
	max_height_inch:integer;
	i:integer;
	player_selected:boolean;
	player_name:name_arr;
	cur_player:player_type;
begin
	i:=1;
	max_height_ft:=5;
	max_height_inch:=0;
	player_selected:=false;
  write('Введите номер команды (возможные варианты:MEM-1,LAL -2,GSW-3,ORL-4,OKC-5): ');
	readln(team_number);
	for i:=1 to write_ind-1 do
		begin
			cur_player:=db_arr[i];
			if cur_player.team = team_number then
				begin

					if (cur_player.ht.feet>=max_height_ft) and (cur_player.ht.inch>=max_height_inch) then
						begin
							max_height_ft:=cur_player.ht.feet;
							max_height_inch:=cur_player.ht.inch;
							player_selected:=true;
							player_name:=cur_player.player_name;
						end;
				end;
		end;
	if player_selected then
		begin
			print_name(player_name);
			writeln('Рост: ',max_height_ft,'.',max_height_inch);
		end
	else
		writeln('В выбранной команде нет игроков');

end;

procedure task2(db_arr:record_arr;write_ind:integer);
var pos_char:char;
var player_selected:boolean;
var score_sum,max_score_sum,i,k:integer;
var max_av_score:real;
var player_name:name_arr;
var cur_player:player_type;
begin
	write('Введите позицию (P-разыгрывающий|C-центровой|S-снайпер|F-форвард): ');
	readln(pos_char);
	player_selected:=false;
	max_score_sum:=0;
	for i:=1 to write_ind-1 do
		begin
			cur_player:=db_arr[i];
			if pos_char in cur_player.positions then
				begin
					score_sum:=0;
					player_selected:=true;
					for k:=1 to match_count do
						score_sum:=score_sum+cur_player.match_stats[k];
					if score_sum>=max_score_sum then
						begin
							max_score_sum:=score_sum;
							player_name:=cur_player.player_name;
							max_av_score:=(score_sum/match_count);
						end;

				end;
		end;
	if player_selected then
		begin
			print_name(player_name);
			writeln('среднее количество очков за матч: ',max_av_score:0:1);
		end
	else
		writeln('Не найден игрок, играющий на данной позиции');


end;

function exceeds_lim(arr:stat_arr;score:integer):boolean;
var k:integer;
var to_break:boolean;
begin
	to_break:=false;
	k:=1;
	while (k<=match_count) and not(to_break) do
		begin
			if arr[k]>score then
				to_break:=true;
			k:=k+1;
    end;
	exceeds_lim:=to_break;
end;


procedure task3(db_arr:record_arr;write_ind:integer);
var counter,lim_score,i:integer;
var cur_player:player_type;
begin
	counter:=0;
	write('Введите количество очков: ');
	readln(lim_score);
	for i:=1 to write_ind-1 do
		begin
			cur_player:=db_arr[i];
			if (cur_player.is_healthy = 1) and (exceeds_lim(cur_player.match_stats,lim_score))  then
				begin
          print_name(cur_player.player_name);
          counter:=counter+1;
				end;
		end;
  if counter = 0 then
    writeln('Нет игроков удовлетворяющих условиям поиска')
  else
    writeln('Найдено ', counter,' игроков.');

end;




begin
  assign(f,compressed_file_filename);
	to_exit:=false;
	write_ind:=1;
	download_records(f,db_arr,write_ind);
	writeln('Задания:');
	writeln('1) Вывод имени и роста самого высокого игрока в выбранной команде ');
  writeln('2) Поиск самого результативного игрока на выбранной позиции');
  writeln('3) Вывод имен и количества здоровых игроков забивших больше введеного количества очков в одном из своих матчей');
  writeln('4) Выход из программы');
  writeln('5) Печать базы данных');
	while not(to_exit) do
		begin
			answer:=ask_question();
			case answer of
				1:task1(db_arr,write_ind);
				2:task2(db_arr,write_ind);
				3:task3(db_arr,write_ind);
				4:to_exit:=true;
				5:print_db(db_arr,write_ind);
			end;
		end;
end.
