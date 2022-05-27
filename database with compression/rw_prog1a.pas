{nba players db
fields : height.inch(1..12), height.feet(integer), name(array [1..25] of char), years played in a career : set,
scores in the last ten matches,   }



{� ������� ��楤��� �� �몥 ��ᥬ���� �㤥� ᦨ���� � ᫮�� ᫥���騥 ����: team, ht.feet,ht.inch,is_healthy }

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
		player_name:name_arr;{���}
		team:integer;{����� ������� - 3 ���}
		ht:record {���}
			feet:integer;{����� 㯠������ � 3 ���}
			inch:integer;{����� 㯠������ � 4 ���}
		end;
		positions:position_set; {����樨 �� ������ ��ࠥ� ����� ��ப  P - ࠧ��뢠�騩, S -᭠����, F - �ࢠ�
    � - 業�஢��}
		match_stats:stat_arr;   {����⨪� � ��᫥���� ��� �����}
		is_healthy:integer;    {���ﭨ� ���஢�� - ����� 㯠������ � 1 ���}
	end;

{⨯ �����, �࠭�饩 ���ଠ�� �� ��ப� � ᦠ⮬ ����}
type compressed_player_type = record 
		player_name :name_arr;
		compressed_player_data:integer;{� integer �㤥� �࠭����� ����� � ���, ������� � ���ﭨ� ���஢��}
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

{�뢮��� ��� ��ப�}
procedure print_name(arr:name_arr);
var ind:name_range;
begin
	ind:=1;
  write('��� :');
	while arr[ind]<>'.' do
		begin
			write(arr[ind]);
			ind:=ind+1;
		end;
	writeln;

end;

{�뢮��� ����⨪� �� ����襭�� �窠� �� ��᫥���� �� ����}
procedure print_match_stats(stats:stat_arr);
var i:integer;
begin
  write('����⨪� �� ��᫥���� 3 ����: ');
	for i:=1 to match_count do
		write(stats[i],' ');
	writeln;

end;

{�뢮��� ����樨 �� ������ ��ࠥ� ��ப}
procedure print_positions(pos_set:position_set);
begin
  write('����樨 : ');
	if 'P' in pos_set then
		write('ࠧ��뢠�騩 ');
	if 'S' in pos_set then
		write('᭠���� ');
	if 'F' in pos_set then
		write('�ࢠ� ');
	if 'C' in pos_set then
		write('業�஢�� ');
	writeln;
end;

{�뢮��� �������� �������, �� ������ ����㯠�� ��ப}
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

{�뢮��� ���ﭨ� ���஢�� ��ப�}
procedure print_health_state(health:integer);
begin
	if health =1  then
		writeln('���஢')
	else
		writeln('�ࠢ��஢��');
end;

{�뢮� ���� ������}
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
							writeln('���� : ',ht.feet,'.',ht.inch);
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
		writeln('� ���� ������ ��� ����ᥩ!');
end;

{㧭��� � ���짮��⥫�, ����� ������ �� ��� �믮�����}
function ask_question:answer_range;
var ans:answer_range;
begin
	writeln('�� �� ��� ᤥ���� � ����� ������? (1-�뢥��|2-�������� ������|3-��� �� �ணࠬ��');
	readln(ans);
	ask_question:=ans;
end;

{��뫪� �� ��楤��� ���ᠭ�� � ���㫥 �� ��}
function pack_data(ht_feet,ht_inch,team_num,health_state:integer):integer;
stdcall;
external name '_pack_data@0';
{$L pck_unpck_module.obj}

procedure unpack_data(compr_data:integer;var ht_feet,ht_inch,team_num,health_state:integer);
stdcall;
external name '_unpack_data@0';
{$L pck_unpck_module.obj}

{������ ����ணࠬ�� ᮧ���� ᦠ��� ������ �� �᭮�� ��ᦠ⮩}
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
	{�뢮� ��楤��� ��� 㯠����� ������ �� ��ᥬ����}
	compressed_data:=pack_data(ht_ft,ht_inch,team_number,health_num);
	compressed_player.compressed_player_data:=compressed_data;
end;

{������ ����ணࠬ�� �ᯠ���뢠�� ᦠ��� ������ � �����뢠�� ���ଠ�� � ⨯ ����� ��� ᦠ��}
procedure unpack_player_info(var normal_player:player_type;compressed_player:compressed_player_type);
var ht_ft,ht_inch,team_number,health_num:integer;
var compressed_info:integer;
begin
	normal_player.player_name:=compressed_player.player_name;
	normal_player.match_stats:=compressed_player.match_stats;
	normal_player.positions:=compressed_player.positions;
	compressed_info:= compressed_player.compressed_player_data;
	{�ந����� �ᯠ����� ���ଠ樨, �࠭�饩�� � ��६����� ⨯� integer}
	unpack_data(compressed_info,ht_ft,ht_inch,team_number,health_num);
	{�����뢠�� �ᯠ������� ����� � ������ ��ᦠ⮣� ⨯�}
	normal_player.ht.feet:=ht_ft;
	normal_player.ht.inch:=ht_inch;
	normal_player.team:=team_number;
	normal_player.is_healthy:=health_num;
	{�맮� ��楤��� �� ��ᥬ����}
end;

{����㦠�� �� 䠨�� � ���ᨢ ����ᥩ ���ଠ�� �� ��ப��}
procedure download_records(var f:db_file;var db_arr:record_arr;var write_ind:integer);
var compressed_player:compressed_player_type;
var normal_player:player_type;
begin
	writeln('����� ����㦠����!');
	reset(f);
	while not eof(f) do
		begin
			read(f,compressed_player);
			{��। ⥬ ��� �����뢠�� ���ଠ�� � ���ᨢ ����ᥩ �ந�室�� �ᯠ�����}
			unpack_player_info(normal_player,compressed_player);
			db_arr[write_ind]:=normal_player;
			write_ind:=write_ind+1;
		end;
end;

{�����뢠�� ���ଠ�� �� ���ᨢ� ����ᥩ � 䠨� }
procedure upload_records(var f:db_file;var db_arr:record_arr;write_ind:integer);
var i:integer;
var compressed_player:compressed_player_type;
begin
	rewrite(f);
	writeln('����� ���㦠����!');
	for i:=1 to write_ind-1 do
		begin
			{��। ���㧪��  � 䠨� ������ ᦨ������, � 㦥 ᦠ�� ������ �����뢠���� � ⥪�⮢� 䠨� }
			compress_player_info(compressed_player,db_arr[i]);
			write(f,compressed_player);
		end;
  close(f);
end;

{�������� � ����� ���ᨢ� � �����ﬨ ����� �祩��, � ��������� ���짮��⥫�� ���ଠ樨 �� ��ப�} 
procedure add_record(var db_arr:record_arr;var write_ind:integer);
var new_player:player_type;
var i:integer;
var team_number:integer;
var is_healthy_char,input_position:char;

begin
	clear_name_arr(new_player.player_name);
	write('������ ��� ��ப� � ������ enter: ');
	readln(new_player.player_name);
	write('������ �१ �஡�� ��� ��ப� � ���� (�� 5 �� 7) � ���(�� 0 �� 11) �१ �஡��: ');
	read(new_player.ht.feet);
	readln(new_player.ht.inch);
	write('������ ������⢮ ���࠭��� �窮� � ��᫥���� ��� ����� (�� 0 �� 70): ');
	for i:=1 to match_count do
		begin
			read(new_player.match_stats[i]);
		end;
  readln;
  write('������ ����樨 �� ������ ��ࠥ� ����� ��ப (S|P|F|C) ��� �஡���� � � ���� ���⠢�� ���: ');
	new_player.positions:=[];
	repeat
		read(input_position);
		if input_position<>'.' then
			new_player.positions:=new_player.positions+[input_position];
	until input_position='.';
  readln;
  write('������ ����� ������� �� ������ ��ࠥ� ����� ��ப (�������� ��ਠ���:MEM-1,LAL -2,GSW-3,ORL-4,OKC-5): ');
	readln(team_number);
	new_player.team:=team_number;
	writeln('���� �ࠢ��? (y|n)');
	readln(is_healthy_char);
	if is_healthy_char = 'y' then
		new_player.is_healthy:=0
	else
		new_player.is_healthy:=1;
	db_arr[write_ind]:=new_player;

	if write_ind >= max_record_count then
		writeln('���� ������ ��������� ���������')
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
