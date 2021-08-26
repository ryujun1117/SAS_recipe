*---マクロ処理のログの表示設定 ;
options mprint;

/* ライブラリの指定*/
libname chika_2  "/home/u58418928/sasuser.v94/chika_2";

%macro  TEST(year=);
data chika_2.data&year.;
	attrib keido length=8 label="keido";
	attrib ido length=8 label="ido";
	attrib syozaiti_code length=8 label="syozaiticode";
	attrib youto length=8 label="youto";
	attrib renban length=$8 label="renban";
	attrib nenji length=$8 label="nenji";
	attrib zen_syozaiti length=$8 label="zen_syozaiti";
	attrib zen_youto length=$4 label="zen_youto";
	attrib zen_renban length=$4 label="zen_renban";
	attrib sikutyousonmei length=$16 label="sikutyosonmei";
	attrib jyukyo length=$60 label="jyukyo";
	attrib gyousei length=$8 label="gyousei";
	attrib tiseki length=8 label="tiseki";
	attrib riyou length=$8 label="riyou";
	attrib riyou_jyoukyou length=$16 label="riyou_jyoukyou";
	attrib tatemono length=$20 label="tatemono";
	attrib sisetu length=$8 label="sisetu";
	attrib keijyo length=$8 label="keijyo";
	attrib maguti length=8 label="maguti";
	attrib okuyuki length=8 label="okuyuki";
	attrib tijyou length=4 label="tijyou";
	attrib tika length=4 label="tika";
	attrib zenmen length=$8 label="zenmen";
	attrib houi length=$8 label="houi";
	attrib haba length=8 label="haba";
	attrib ekimae length=$8 label="ekimae";
	attrib hosou length=$8 label="hosou";
	attrib sokudou length=$8 label="sokudou";
	attrib sokudou_houi length=$8 label="sokudou_houi";
	attrib koutusisetu length=$20 label="koutusisetu";
	attrib syuuhen length=$20 label="syuuhen";
	attrib ekimei length=$8 label="ekimei";
	attrib ekikyori length=8 label="ekikyori";
	attrib youtokubun length=$8 label="youtokubun";
	attrib bouka length=$4 label="bouka";
	attrib tosikeikaku length=$8 label="tosikeikaku";
	attrib sinrin length=$8 label="sinrin";
	attrib kouen length=$8 label="kouen";
	attrib kenpei length=4 label="kenpei";
	attrib youseki length=4 label="youseki";
	attrib kyoutuu length=$8 label="kyoutuu";
	attrib sentei length=$8 label="sentei";
	
	%do I = 1983 %to &year. %by 1;
		attrib AD&I length=8 label="seireki";
	%end;
	infile "sasuser.v94/chika_2/chikakouji_2021.csv" dsd dlm="," firstobs=2 encoding="sjis";
	input keido -- AD&year.;
run;

/*  課題1*/
	data chika_2.add_tihou;
		format ID;
		ID+1;
		tmp = int(syozaiti_code / 1000);
		set chika_2.data&year.;
		/*住宅地に用途を限定*/
		where youto = 0;
		keep ID nenji syozaiti_code tmp youto jyukyo AD1983 -- AD&year.;
	run;

	data chika_2.todouhuken;
		attrib tihou_code length=8 label="tihou_code";
		attrib tihoumei length=$16 label="tihou";
		attrib todouhuken_code length=8 label="todouhuken_code";
		attrib todouhukenmei length=$16 label="todouhuken";
		infile "sasuser.v94/chika/todouhuken.csv" dsd dlm="," firstobs=2 encoding="sjis";
		input tihou_code--todouhukenmei;
	run;
	proc sql;
		create table chika_2.add_todouhuken as
		select *
		from chika_2.add_tihou as a left join chika_2.todouhuken as b 
		on a.tmp = b.todouhuken_code;
	quit;
	
	%macro hendou(year=);
		data chika_2.datamart;
			format ID nenji tihoumei todouhukenmei;
			array _AR{10} hendouritu col_1 col_2 col_3 col_4 col_5 col_6 col_7 col_8 col_9;
				%do I = 1 %to 10 %by 1;
						%let bunshi = %eval(&year.-&I);
						%let bunbo  = %eval(&year.-&I);
						_AR{&I.} = divide(AD%eval(&bunshi+1), AD&bunbo);
/* 						if AD&bunbo = 0 then delete; */
/* 						else _AR{&I.} = AD%eval(&bunshi+1)/AD&bunbo; */
				%end;
			set chika_2.add_todouhuken;
			ruiseki_heikin_3 = (col_2 * col_1 * hendouritu) **(1/3)*100;
			ruiseki_heikin_5 = (col_4 * col_3 *col_2 * col_1 * hendouritu) **(1/5)*100;
			ruiseki_heikin_10 = (col_9 * col_8 * col_7 * col_6 * col_5 * col_4 * col_3 *col_2 * col_1 * hendouritu) **(1/10)*100;
			hendouritu_mean = mean(hendouritu); 
			keep ID nenji tihoumei todouhukenmei hendouritu ruiseki_heikin_3 ruiseki_heikin_5 ruiseki_heikin_10 hendouritu_mean;
		run;
	%mend hendou;
	%hendou(year=&year.);
	
/* 課題1の出力 */
proc tabulate data = chika_2.datamart out=chika_2.kadai_1(drop=_type_ _page_ _table_);
	var hendouritu ruiseki_heikin_3 ruiseki_heikin_5 ruiseki_heikin_10;
	class tihoumei;
	table tihoumei, mean*hendouritu mean*ruiseki_heikin_3 mean*ruiseki_heikin_5 mean*ruiseki_heikin_10;
run;
/* 課題1をCSV形式で出力 */
PROC EXPORT DATA = chika_2.kadai_1
            OUTFILE= "kadai_1.xlsx"
            DBMS=XLSX REPLACE;
RUN;

/* 課題2 */
/* 全国平均の算出 */
data chika_2.datamart;
	set chika_2.datamart;
	flg_1 = 1;
run;

data chika_2.tmp;
	set chika_2.datamart;
	flg_2 = 1;
	keep ID hendouritu flg_2 ;
run;
proc sql;
	create table chika_2.zenkokuheikin as
	select flg_2, mean(hendouritu) as zenkokuheikin format=8.6
	from chika_2.tmp
	group by flg_2;
quit;
proc sql;
	create table chika_2.add_mean as
	select *
	from chika_2.datamart as a left join chika_2.zenkokuheikin as b 
	on a.flg_1 = b.flg_2;
quit;
proc sql;
	create table chika_2.kadai_2 as 
	select todouhukenmei, 
		mean(hendouritu) as hendouritu,
		mean(zenkokuheikin) as zenkokuheikin 
	from chika_2.add_mean
	group by todouhukenmei
	having hendouritu >= zenkokuheikin
	order by hendouritu;
quit;
proc sort data = chika_2.kadai_2 out = chika_2.kadai_2;
	by descending hendouritu;
run;
proc print data = chika_2.kadai_2;
run;

/* 課題2をCSV形式で出力 */
PROC EXPORT DATA = chika_2.kadai_2
            OUTFILE= "kadai_2.xlsx"
            DBMS=XLSX REPLACE;
RUN;
/* 全国平均の抽出 */
proc sql noprint;
	select zenkokuheikin into: _X1 from chika_2.zenkokuheikin;
quit;
%put &_X1;

/* 課題4 */
data chika_2.default;
	attrib ID length=$1 label="ID";
	attrib kasidasigaku length=8 label="貸出額(円)";
	attrib kasidasikikan length=4 label="貸出期間(年)";
	attrib kasidasikinri length=4 label="貸出金利";
	attrib tanpo_sum length=8 label="担保評価額_合計(円)";
	attrib tanpo_toti length=8 label="担保評価額_土地(円)";
	attrib tanpo_tatemono length=8 label="担保評価額_建物(円)";
	attrib default_month length=4 label="デフォルト時経過月数";
	infile "sasuser.v94/chika_2/defalt.csv" dsd dlm="," firstobs=2 encoding="sjis";
	input ID -- default_month;
run;
/* デフォルト損失額の計算 */
data chika_2.kadai_4;
	set chika_2.default;
	geturi = kasidasikinri/(12*100);
	hensai_term = kasidasikikan*12;
	ruisekihensai = finance("cumprinc", geturi,hensai_term,kasidasigaku,1,default_month);
	default_year = default_month / 12;
	default_tanpo_toti = (tanpo_toti * (&_X1)**default_year);
	default_tanpo_tatemono = (tanpo_tatemono * (1-(0.9)**default_year));	
	default_zandaka = kasidasigaku - ruisekihensai;
	default_loss = default_zandaka -(1-0.2)*(default_tanpo_toti + default_tanpo_tatemono);
	if tmp >= 0 then do; default_sonsitugaku = tmp; end;
	else do; default_sonsitugaku = 0; end;
	keep ID default_loss;
run;
proc print data = chika_2.kadai_4;
run;
/* 課題4をCSV形式で出力 */
proc export data = chika_2.kadai_4 outfile=classCSV DBMS=CSV replace;
run;
PROC EXPORT DATA = chika_2.kadai_4
            OUTFILE= "kadai_4.xlsx"
            DBMS=XLSX REPLACE;
RUN;

%mend TEST;


/* 2018年：2018, 2019年：2019, 2020年：2020 */
%TEST(year=2021);

