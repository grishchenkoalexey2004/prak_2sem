program test_gen;
const test_count = 100;
const arr_len1 = 5;
const arr_len2 = 10; 


const output_filename = 'tests.txt';
var sign_ind,arr_elem:integer;
var output_file:text;


type short_arr = array[1..arr_len1] of integer;
type long_arr = array[1..arr_len2] of integer;

var arr1:short_arr;
var arr2:long_arr;
var i:integer;

function gen_rand_el():integer;
var elem:integer;
begin
	sign_ind:=random(2);
	elem:=random(80);
	if sign_ind =1 then 
		elem:=elem*(-1);

	gen_rand_el:=elem
end;

procedure fill_arrays(var arr1:short_arr;var arr2:long_arr);
var k,j:integer;
var val:integer; 
begin
	for k:=1 to arr_len1 do 
		begin
			val:=gen_rand_el();
			arr1[k]:=val;
		end; 

	for j:=1 to arr_len2 do 
	begin
		val:=gen_rand_el();
		arr2[j]:=val;
	end; 
end;

procedure write_arrays(var f_out:text;arr1:short_arr;arr2:long_arr);
var k,j:integer;
begin
	for k:=1 to arr_len1 do 
		begin
			write(f_out,arr1[k],' ');
		end; 
	writeln(f_out);
	for j:=1 to arr_len2 do 
		begin
			write(f_out,arr2[j],' ');
		end; 
	writeln(f_out);
	writeln(f_out);


end; 




begin
	assign(output_file,output_filename);
	rewrite(output_file);
	for i:=1 to test_count do 
		begin
			fill_arrays(arr1,arr2);
			write_arrays(output_file,arr1,arr2);
		end;
	close(output_file);

end.