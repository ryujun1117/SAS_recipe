data Data_202 ;
	input ID 1-2 GENDER 4 AGE 6-7 HEIGHT 9-11 WEIGHT 13-16 SMOKE $ 18;
cards ;
1  1 55 175 65.2 Y
2  1 47 168 62.4 Y
3  2 39 158 47.2 N
4  2 62 152 45.9 Y
5  1 32 181 78.5 N
6  1 45 170 66.7 N
7  2 66 145 50.2 N
8  2 33 160 48.2 Y
9  2 43 159 46.7 Y
10 1 52 173 70.2 N
;
run;


*--- setステートメントによるデータの読み込み;
data data2 ;
	set Data_202 ; *--- 読み込むデータセットを指定 ;
run;


*--- ライブラリの作成 ;
libname TESTDT "/home/u58461128/sasuser.v94/Learn_sas" ;


*--- ライブラリへのデータセットの出力 ;
data TESTDT.Data_203 ;
	input X Y Z ;
cards ;
	1 2 3
	4 5 6
	7 8 9
;
run;


*--- csvファイルの読み込み;
proc import out=TESTDT.RESERVE datafile="/home/u58461128/sasuser.v94/Learn_sas/reserve.csv" replace ;
run;


*--- データの整列（昇順・降順) ;
proc sort data = TESTDT.RESERVE out = TESTDT.tmp ;
	by checkin_date ;
run;
proc print data = TESTDT.tmp ;
run ;
*--- 降順で整列 ;
proc sort data = TESTDT.reserve out = TESTDT.tmp ;
	by descending checkin_date ;
run;


*--- 変数の作成 ;
data data_var1 ;
	a = 1		;
	b = "bbb"	;
run;
proc print  data = data_var1 ;
run;

*--- 四則演算 ;
data data_var2 ;
	X = 8 + 7 ;
	Y = 8 - 5 ;
	Z = 3 * 4 ;
	W = 9 / 3 ;
run;
proc print data = data_var2 ;
run;


*--- その他の演算 ;
data data_var3 ;
	X = 3 ** 4 ;
	Y = sqrt(2) ;
	Z = log(2) ;
	W = exp(2) ;
run;
proc print data = data_var3 ;
run;


*--- 変数の保持・削除 ;
data data_keep ;
	set data_202 ;
	keep ID BMI ;
run;

data data_drop ;
	set data_202 ;
	drop age gender ; *--- 削除する項目を指定 ;
run;


*--- データセット読み込み時のkeep・dropステートメントの使用 ;
data data_keep2 ;
	set data_202(keep = weight) ;
run;

data data_drop2 ;
	set data_202(drop = age) ;
run;

*---変数をまとめて保持・削除するときは
keep X1 -- X3 
drop X1 -- X3
のようにする ;















