``` SAS
*20170912;
*建資料檔;
data bodyfat;
input gender $ fatpct @@;
datalines;
m 13.3 f 22 m 19 f 26 m 20 f 16 m 8 f 12 m 18 f 21.7 m 22 f 23.2 
m 20 f 21 m 31 f 28 m 21 f 30 m 12 f 23 m 16 m 12 m 24
;
run;
 
*算平均值;
PROC MEANS data=bodyfat;
var fatpct;
run;

*算平均值分男生女生;
PROC MEANS data=bodyfat;
class gender;
var fatpct;
run;

*20170919;
*將輸入tickets原始資料檔;
*資料部分請用PPT的檔案直接複製貼上;

*建資料檔;
DATA tickets;
	INPUT state $ amout @@;
	DATALINES;
AL 100 HI 200 DE 20 IL 1000 AK 300 CT 50 AR 100 IA 60 FL 250 
KS 90 AZ 250 IN 500 CA 100 LA 175 GA 150 MT 70 ID 100 KY 55 
CO 100 ME 50 NE 200 MA 85 MD 500 NV 1000 MO 500 MI 40 NM 100 
NJ 200 MN 300 NY 300 NC 1000 MS 100 ND 55 OH 100 NH 1000 OR 600
OK 75 SC 75 RI 210 PA 46 . 50 TN 50 SD 200 TX 200 VT 1000 UT 750 
WV 100 VA 200 WY 200 WA 77 WI 300 DC .
;
RUN;

*請列印資料;
*PROC PRINT;
PROC PRINT DATA=tickets;
RUN;

*請列印其中一個變項;
PROC PRINT DATA=tickets;
VAR state;
RUN;

*請不用列印obs;
PROC PRINT DATA=tickets NOOBS;
VAR state;
RUN;
*中間空一行;
PROC PRINT DATA=tickets DOUBLE;
VAR state;
RUN;

*不要列印obs且中間還要空一行;
PROC PRINT DATA=tickets DOUBLE NOOBS;
VAR state;
RUN;

*只顯示前幾個(obs);
PROC PRINT DATA=tickets (obs=10);
VAR state;
RUN;

*排序;
*PROC SORT;
*請根據amout排序;
PROC SORT DATA=tickets;
	BY amout;
RUN; 

*請檢查一下你的檔案是否改變;
*排序amout 但請由大至小-descending;
PROC SORT DATA=tickets;
	BY descending amout;
RUN; 

PROC SORT DATA=tickets;
	BY descending state amout;
RUN; 

*20170927;

*第一部分為如何將檔案名稱加以說明;
*先將上週使用的資料剪貼下來;
DATA tickets;
	LABEL state='state where ticket recevied' 
	             amount='超速罰金';
	INPUT state $ amount @@;
	DATALINES;
AL 100 HI 200 DE 20 IL 1000 AK 300 CT 50 AR 100 IA 60 FL 250 
KS 90 AZ 250 IN 500 CA 100 LA 175 GA 150 MT 70 ID 100 KY 55 
CO 100 ME 50 NE 200 MA 85 MD 500 NV 1000 MO 500 MI 40 NM 100 
NJ 200 MN 300 NY 300 NC 1000 MS 100 ND 55 OH 100 NH 1000 OR 600
OK 75 SC 75 RI 210 PA 46.50 TN 50 SD 200 TX 200 VT 1000 UT 750 
WV 100 VA 200 WY 200 WA 77 WI 300 DC .
;
RUN;
*Labeling variables;
*state='State Where Ticket Received'
*amount='Cost of Ticket';


*列印有labeling之後變項;
*加title及footnotes;
TITLE '超速不同州罰款';
TITLE2 'MONEY';
FOOTNOTE 'SAS課程';
PROC PRINT DATA=tickets LABEL;
RUN;

*取消原有的title and footnote;
TITLE ' ';
TITLE2 ' ';
FOOTNOTE ' ';
PROC MEANS DATA=tickets;
VAR amount;
RUN;


*第二部分為FORMAT 格式化(FORMAT)資料的呈現方式;
*FORMAT
*1. 利用SAS預設的格式;
*可以在DATA step;
DATA tickets;
	LABEL state='state where ticket recevied' 
	             amount='超速罰金';
	FORMAT amount DOLLAR8.1;
	INPUT state $ amount @@;
	DATALINES;
AL 100 HI 200 DE 20 IL 1000 AK 300 CT 50 AR 100 IA 60 FL 250 
KS 90 AZ 250 IN 500 CA 100 LA 175 GA 150 MT 70 ID 100 KY 55 
CO 100 ME 50 NE 200 MA 85 MD 500 NV 1000 MO 500 MI 40 NM 100 
NJ 200 MN 300 NY 300 NC 1000 MS 100 ND 55 OH 100 NH 1000 OR 600
OK 75 SC 75 RI 210 PA 46.50 TN 50 SD 200 TX 200 VT 1000 UT 750 
WV 100 VA 200 WY 200 WA 77 WI 300 DC .
;
RUN;

*可以在PROC Steps;
PROC PRINT DATA=tickets;
FORMAT amount DOLLAR8.1;
RUN;



*FORMAT;
*Using an Existing SAS Format: 此用SAS現有的;
*請將amount轉換成$

*2. Using a SAS Function;
*將state由縮寫轉換成全名;
*使用SAS function: stnamel;
DATA tickets;
	LABEL state='state where ticket recevied' 
	             amount='超速罰金';
	FORMAT amount DOLLAR8.1;
	INPUT state $ amount @@;
	statetext=STNAMEL(state);*新變數;
DATALINES;
AL 100 HI 200 DE 20 IL 1000 AK 300 CT 50 AR 100 IA 60 FL 250 
KS 90 AZ 250 IN 500 CA 100 LA 175 GA 150 MT 70 ID 100 KY 55 
CO 100 ME 50 NE 200 MA 85 MD 500 NV 1000 MO 500 MI 40 NM 100 
NJ 200 MN 300 NY 300 NC 1000 MS 100 ND 55 OH 100 NH 1000 OR 600
OK 75 SC 75 RI 210 PA 46.50 TN 50 SD 200 TX 200 VT 1000 UT 750 
WV 100 VA 200 WY 200 WA 77 WI 300 DC .
;
RUN;

*Creating Your Own Formats;
*將上星期的檔案'm'='male' 'f'='female';

PROC FORMAT;
VALUE $sex 'm'='男生' 'f'='女生';
RUN;

DATA bodyfat;
INPUT gender $ fatpct @@;
FORMAT gender $sex.;
DATALINES;
m 13.3 f 22 m 19 f 26 m 20 f 16 m 8 f 12 m 18 f 21.7 m 22 f 23.2 
m 20 f 21 m 31 f 28 m 21 f 30 m 12 f 23 m 16 m 12 m 24
;
RUN;
PROC PRINT DATA=bodyfat;
FORMAT gender $sex.;
RUN;


*第三部分為建立SAS永久檔及匯入不同格式檔案;

*Part 1: 請利用LIBNAME statement建立一個SAS資料匣;
*路徑為您存放SAS資料檔的地方;

LIBNAME mydata 'D:\統計實習課';

DATA mydata.tickets3;
SET tickets;
RUN;

DATA mydata.bodyfat;
SET bodyfat;
RUN;

*也可以用別種方式建立SAS資料匣;
*讀取資料時要記得需要提供SAS資料匣名稱-libref...;



*Part 2: 讀取外部資料;
*請使用INFILE statement讀取外部建置好的資料;
*有很多不同檔案型式;
*常見有.txt, .csv,....;



*PROC IMPORT 也可以匯入excel檔;
*將匯入資料存成永久檔;
PROC IMPORT OUT= WORK.ticketssss 
            DATAFILE= "C:\Users\user\Downloads\Tickets.XLS" 
            DBMS=EXCEL REPLACE;
     RANGE="Tickets09"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

*Part 3: 請用匯入精靈 import wizard;
*請跟著SAS介面進行匯入工作;


*20171003;

*chapter 4
*第一部分: Continuous variable
*請利用tickets
*請練習將tickets利用匯入功能匯入;
*最後請存在big3永久資料匣;

LIBNAME big3 'D:\big3'; 

*PROC UNIVARIATE, var amount;
PROC UNIVARIATE DATA=big3.tickets;
	VAR amount;
	ID state;
RUN;

*PROC MEANS 一樣可以提供較簡易的訊息;
PROC MEANS DATA=big3.tickets;
	VAR amount;
RUN;

*PROC MEANS with a variety of options, such as n nmiss mean median stddev range grange min max;
PROC MEANS DATA=big3.tickets MEDIAN QRANGE P1 P99 SKEW KURTOSIS;
	VAR amount;
RUN;


*圖: PROC UNIVARIATE plot;
PROC UNIVARIATE DATA=big3.tickets PLOT;
	VAR amount;
	ID state;
RUN;
*圖: histogram;
PROC UNIVARIATE DATA=big3.tickets ;
	VAR amount;
	HISTOGRAM amount;
RUN;
*圖: histogram with noprint options;
PROC UNIVARIATE DATA=big3.tickets NOPRINT;
	VAR amount;
	HISTOGRAM amount;
RUN;


*圖: histogram with a change of midpoints;

*圖: histogram with a change of endpoints;

*第二部分: Nonimal/ordinal or Discrete variable;

*請使用dogwalk資料;
data dogwalk;
input walks @@;
label walks='Number of Daily Walks';
datalines;
3 1 2 0 1 2 3 1 1 2 1 2 2 2 1 3 2 4 2 1
;
run;

*PROC FREQ;
PROC FREQ DATA=dogwalk;
 TABLES walks;
RUN;


*PROC FREQ with missing values;
data dogwalk2;
input walks @@;
label walks='Number of Daily Walks';
datalines;
3 1 2 . 0 1 2 3 1 . 1 2 1 2 . 2 2 1 3 2 4 2 1
;
run;

*PROC FREQ with the missing options;
PROC FREQ DATA=dogwalk2;
 TABLES walks/MISSING;
RUN;

*圖PROC GCHART -bar chart, vbar and hbar;
PROC GCHART DATA=dogwalk;
VBAR walks;
RUN;
PROC GCHART DATA=dogwalk;
HBAR walks;
RUN;
*圖PROC GCHART with nonstat option;
PROC GCHART DATA=dogwalk ;
HBAR walks/NOSTAT;
RUN;
*Creating Ordered Bar Charts;
proc gchart data=tickets;
hbar state / nostat descending sumvar=amount;
run;

**錯誤的表達方式;
PROC FREQ DATA=tickets;
TABLES amount;
RUN;
PROC MEANS DATA=dogwalk;
VAR walks;
RUN;


*20171018;

*Chapter 5;
*data source;
data falcons;
input aerieht @@;
label aerieht='Aerie Height in Meters';
datalines;
15.00 3.50 3.50 7.00 1.00 7.00 5.75 27.00 15.00 8.00
4.75 7.50 4.25 6.25 5.75 5.00 8.50 9.00 6.25 5.50
4.00 7.50 8.75 6.50 4.00 5.25 3.00 12.00 3.75 4.75
6.25 3.25 2.50
;
run;

*testing for normality;
*方法一: 請使用proc univariate with plot看圖形;
PROC UNIVARIATE DATA=falcons PLOT;
	VAR aerieht;
RUN;
*方法二: 請看proc univariate skewness and kurtosis結果;

*方法三: 請用proc univariate, histogram/normal;
PROC UNIVARIATE DATA=falcons PLOT normal;
	VAR aerieht;
RUN;

PROC UNIVARIATE DATA=falcons PLOT;
	VAR aerieht;
	HISTOGRAM aerieht/NORMAL;
RUN;

*方法四: 請用proc univariate, probplot;
PROC UNIVARIATE DATA=falcons;
	VAR aerieht;
	PROBPLOT aerieht/normal(mu=est sigma=est);
RUN;

***********subset your data;

*Where Statement: 將aerieht>=15予以排出或是不分析;
*方法一-where在proc univariate statement;
PROC UNIVARIATE DATA=falcons PLOT normal;
    WHERE aerieht<15;
	VAR aerieht;
RUN;

*方法二-where 在data statement;
DATA falcons;
	SET falcons;
    WHERE aerieht<15;
PROC UNIVARIATE DATA=falcons PLOT normal;
	VAR aerieht;
RUN;



*20171025;

****建立及重新修訂變項;
*匯入資料;
*建立五個新的變項 請參考講義;
*使用資料為Garden 需要使用INFILE將資料匯入;
*INPUT Name $ 1-7 Tomato Zucchini Peas Grapes;

DATA homegarden;
INFILE 'C:\Users\user\Downloads\Garden.dat';
INPUT Name $ 1-7 Tomato Zucchini Peas Grapes;
Zone = 14;
Type = 'home';
Zucchini = Zucchini * 10;
Total = Tomato + Zucchini + Peas + Grapes;
PerTom = (Tomato / Total) * 100;
RUN;

DATA homegarden;
INFILE 'C:\Users\user\Downloads\Garden.dat';
INPUT Name $ 1-7 Tomato Zucchini Peas Grapes;
Zone = 14;
Type = 'home';
Zucchini = Zucchini * 10;
*Total = Tomato + Zucchini + Peas + Grapes;*有遺漏值不會有總計;
Total=sum(Tomato, Zucchini, Peas, Grapes);*有遺漏值但會計算其他的總和;
PerTom = (Tomato / Total) * 100;
RUN;

****條件式;

DATA oldcars;
   INFILE 'C:\Users\user\Downloads\Auction.dat';
   INPUT Make $ 1-13 Model $ 15-29 YearMade Seats MillionsPaid;
Run;

**********************************************************************;
* Example: Using IF-THEN Statements;
**********************************************************************;

* 1950年前的車位經典款;
DATA oldcars;
   INFILE 'C:\Users\user\Downloads\Auction.dat';
   INPUT Make $ 1-13 Model $ 15-29 YearMade Seats MillionsPaid;
	IF yearmade>=1950 THEN mode='non-classic';
	IF yearmade<1950 THEN mode='classic';
RUN;

DATA oldcars;
   INFILE 'C:\Users\user\Downloads\Auction.dat';
   INPUT Make $ 1-13 Model $ 15-29 YearMade Seats MillionsPaid;
   LENGTH mode $12.;
	IF yearmade<1950 THEN mode='classic';
	IF yearmade>=1950 THEN mode='non-classic';
RUN;


**********************************************************************;
* Example for grouping Observations with IF-THEN/ELSE Statements
**********************************************************************;

*分為二類; 
DATA oldcars;
   INFILE 'C:\Users\user\Downloads\Auction.dat';
   INPUT Make $ 1-13 Model $ 15-29 YearMade Seats MillionsPaid;
   LENGTH mode $12.;
   IF yearmade<1950 THEN mode='classic';
   ELSE mode='non-classic';
RUN;

*分為三類;
DATA oldcars;
   INFILE 'C:\Users\user\Downloads\Auction.dat';
   INPUT Make $ 1-13 Model $ 15-29 YearMade Seats MillionsPaid;
   LENGTH mode $12.;
   IF yearmade<1900 THEN mode='classic';
   ELSE IF yearmand<1950 mode='non-classic';
   ELSE mode='modern';
RUN;

DATA oldcars;
   INFILE 'C:\Users\user\Downloads\Auction.dat';
   INPUT Make $ 1-13 Model $ 15-29 YearMade Seats MillionsPaid;
   LENGTH mode $12.;
   IF yearmade<1900 THEN mode='classic';
   IF 1900<=yearmade<1950 mode='non-classic';
   IF yearmade>=1950 mode='modern';
RUN;

*如果資料有遺漏值以下寫法比較安全;
DATA oldcars;
   INFILE 'C:\Users\user\Downloads\Auction.dat';
   INPUT Make $ 1-13 Model $ 15-29 YearMade Seats MillionsPaid;
   IF seats=. THEN mode='不知';
   ELSE IF seats=2 THEN mode='不孝';
   ELSE mode='孝順';
RUN;


***兩個actions;
DATA oldcars;
SET oldcars;
IF Model='F-88' THEN DO;
seats=2;
make='LINIEN';
END;
RUN;

***********subset your data;
*留位置有四人座;
DATA oldcars;
   INFILE 'C:\Users\user\Downloads\Auction.dat';
   INPUT Make $ 1-13 Model $ 15-29 YearMade Seats MillionsPaid;
	IF seats=4;
RUN;

** IF delete;
DATA oldcars;
   INFILE 'C:\Users\user\Downloads\Auction.dat';
   INPUT Make $ 1-13 Model $ 15-29 YearMade Seats MillionsPaid;
   IF seats^=4 THEN DELETE;
RUN;

**WHERE;
DATA oldcars;
   INFILE 'C:\Users\user\Downloads\Auction.dat';
   INPUT Make $ 1-13 Model $ 15-29 YearMade Seats MillionsPaid;
   WHERE seats=4;
RUN;


*******20171114**************;

*****PROC MEANS with CLM , aphal=;
*****compute 95% CI ;
PROC MEANS DATA=bodyfat MEAN STDDEV CLM;
RUN;

*****change aphal level;
*****maxdec 小數位;
PROC MEANS DATA=bodyfat MEAN STDDEV CLM MAXDEC=2 ALPHA=0.1;
RUN;

***********CREATE a SAS dataset;
proc format;
value $gentext 'm' = 'Male'
'f' = 'Female';
run;
data bodyfat;
input gender $ fatpct @@;
format gender $gentext.;
label fatpct='Body Fat Percentage';
datalines;
m 13.3 f 22 m 19 f 26 m 20 f 16 m 8 f 12 m 18 f 21.7
m 22 f 23.2 m 20 f 21 m 31 f 28 m 21 f 30 m 12 f 23
m 16 m 12 m 24
;
run;

*Summarizing data with PROC MEANS;

*Summarizing data with PROC UNIVARIATAE;
PROC UNIVARIATE DATA=bodyfat normal;
CLASS gender;
VAR fatpct;
RUN;


*Using PROC BOXPLOT for Side-by-Side Box Plots;
*使用proc boxplot前需要先根據你要比較的兩組排序;
PROC SORT DATA=bodyfat;
BY gender;
PROC BOXPLOT DATA=bodyfat;
PLOT fatpct*gender;
RUN;

*Performing the Two-Sample t-test;
PROC TTEST DATA=bodyfat;
CLASS gender;
VAR fatpct;
RUN;


*Changing the Alpha Level for Confidence Intervals;
PROC TTEST DATA=bodyfat alpha=0.1;
CLASS gender;
VAR fatpct;
RUN;

*Performing the Wilcoxon Rank Sum Test;
*Create a SAS dataset;
data gastric;
input group $ lysolevl @@;
datalines;
U 0.2 U 10.4 U 0.3 U 10.9 U 0.4 U 11.3 U 1.1 U 12.4 U 2.0
U 16.2 U 2.1 U 17.6 U 3.3 U 18.9 U 3.8 U 20.7 U 4.5
U 24.0 U 4.8 U 25.4 U 4.9 U 40.0 U 5.0 U 42.2 U 5.3
U 50.0 U 7.5 U 60.0 U 9.8
N 0.2 N 5.4 N 0.3 N 5.7 N 0.4 N 5.8 N 0.7 N 7.5 N 1.2 N 8.7
N 1.5 N 8.8 N 1.5 N 9.1 N 1.9 N 10.3 N 2.0 N 15.6 N 2.4
N 16.1 N 2.5 N 16.5 N 2.8 N 16.7 N 3.6 N 20.0
N 4.8 N 20.7 N 4.8 N 33.0
;
run;
*常態性檢定;
PROC UNIVARIATE DATA=gastric normal;
CLASS group;
VAR lysolevl;
RUN;

*Using PROC NPAR1WAY for the Wilcoxon Rank Sum Test;
PROC NPAR1WAY DATA=gastric WILCOXON;
CLASS group;
VAR lysolevl;
RUN;

*****************Comparing the 'MEAN' difference of paired groups of data*************;
**** create the data set for STA6207;
data STA6207; 
   input student exam1 exam2 @@; 
   scorediff = exam2 - exam1 ; *create a new variable;
   label scorediff='Differences in Exam Scores'; 
   datalines; 
1 93 98 2 88 74 3 89 67 4 88 92 5 67 83 6 89 90 
7 83 74 8 94 97 9 89 96 10 55 81 11 88 83 12 91 94 13 85 89 14 70 78 15 90 96 16 90 93 17 94 81 
18 67 81 19 87 93 20 83 91 
; 
run; 
**** Summarizing Differences with PROC UNIVARIATE ;
PROC UNIVARIATE DATA=sta6207 normal;
VAR scorediff;
RUN;
***********Using PROC UNIVARIATE to Test Paired Differences;
PROC UNIVARIATE DATA=sta6207;
VAR scorediff;
RUN;

****有沒有進步2分以上;
PROC UNIVARIATE DATA=sta6207 mu0=2; *預設為0分;
VAR scorediff;
RUN;

***********Using PROC TTEST to Test Paired Differences;
PROC TTEST DATA=sta6207;
PAIRED exam1*exam2;
RUN;




***20171121;
*Please provide the summary statistics for the salary data;
*Read your data first...libname;
LIBNAME big3 'C:\Users\user\Downloads';
*You can use:
*PROC MEANS;
PROC MEANS DATA=big3.salary;
CLASS subjarea;
VAR annsal;
RUN;
*PROC UNIVARIATE;
PROC UNIVARIATE DATA=big3.salary;
CLASS subjarea;
VAR annsal;
HISTOGRAM annsal;
RUN;
*Creating Comparative Histograms for Multiple Groups with nrow=6;
PROC UNIVARIATE DATA=big3.salary;
CLASS subjarea;
VAR annsal;
HISTOGRAM annsal/nrow=6;
RUN;

*PROC BOXPLOT;
*Creating Side-by-Side Box Plots for Multiple Groups ;
*Don't forget to sort your data first;
*Please consider boxwidthscale=1 and bwslegend;
PROC SORT DATA=big3.salary;
	BY subjarea;
PROC BOXPLOT DATA=big3.salary;
	PLOT annsal*subjarea / boxwidthscale=1  bwslegend;
RUN;

*Performing the Analysis of Variance;
*before performing ANOVA;
*balanced or unbalanced;
*independent;
*normality; *ANOVA works well for non normal data;
*equal variance;

*now you can perform ANOVA;
*suitable for balanced data;
PROC ANOVA data=big3.salary;
CLASS subjarea;
MODEL annsal=subjarea;
RUN;

*unbalanced data;
PROC GLM data=big3.salary;
CLASS subjarea;
MODEL annsal=subjarea;
RUN;
QUIT;

*Testing for Equal Variances with means subjarea/hovtest;
PROC ANOVA data=big3.salary;
CLASS subjarea;
MODEL annsal=subjarea;
means subjarea/hovtest;*檢定variance是否相同;
RUN;

*Performing the Welch ANOVA;
PROC ANOVA data=big3.salary;
CLASS subjarea;
MODEL annsal=subjarea;
means subjarea/welch;*如果你有unequal variance 可以改用這個方法
ANOVA output會提供unequal variance所應有的結果;
RUN;

*Performing a Kruskal-Wallis Test and using PROC NPAR1WAY;
*樣本不成常態not a normal distribution;
PROC npar1way data=big3.salary wilcoxon;
class subjarea;
var annsal;
run;

*Multiple comparison after an ANOVA test is significant;

*Performing Pairwise Comparisons with Multiple t-Tests;
PROC ANOVA DATA=big3.salary;
CLASS subjarea;
MODEL annsal=subjarea;
MEANS subjarea/t;
RUN;

*Using the Bonferroni Approach ;
PROC ANOVA DATA=big3.salary;
CLASS subjarea;
MODEL annsal=subjarea;
MEANS subjarea/bon;
RUN;

*Performing the Tukey-Kramer Test;
PROC ANOVA DATA=big3.salary;
CLASS subjarea;
MODEL annsal=subjarea;
MEANS subjarea/tukey;
RUN;

*Changing the alpha level;

*Using Dunnett’s Test When Appropriate;
PROC ANOVA DATA=big3.salary;
CLASS subjarea;
MODEL annsal=subjarea;
MEANS subjarea/Dunnett('Mathematics');
RUN;

*Using PROC ANOVA Interactively ;
proc anova data=big3.salary; 
   class subjarea; 
   model annsal=subjarea; 
   title 'ANOVA for Teacher Salary Data'; 
run; 
   means subjarea / t; 
   title 'Multiple Comparisons with t Tests'; 
run; 
quit; 



***20171128;
*Create a dataset;
data kilowatt;
input kwh ac dryer @@;
datalines;
35 1.5 1 63 4.5 2 66 5.0 2 17 2.0 0 94 8.5 3 79 6.0 3
93 13.5 1 66 8.0 1 94 12.5 1 82 7.5 2 78 6.5 3 65 8.0 1
77 7.5 2 75 8.0 2 62 7.5 1 85 12.0 1 43 6.0 0 57 2.5 3
33 5.0 0 65 7.5 1 33 6.0 0
;
run;

*Creating Scatter Plots;
*PROC CORR data= plot=scatter;
PROC CORR DATA=kilowatt PLOTS=scatter;
	VAR ac kwh;
RUN;

*PROC CORR plot=scatter(noinset ellipse=none) with variable ac and kwh ;
PROC CORR DATA=kilowatt PLOTS=scatter(noinset ellipse=none);
	VAR ac kwh;
RUN;

*Creating a Scatter Plot Matrix plot=matrix (histogram nvar=all);
PROC CORR DATA=kilowatt PLOTS=matrix(histogram nvar=all);
	VAR ac dryer kwh;
RUN;

*Working with Missing Values;
*Please use the dataset kilowatt2;
LIBNAME big3 'C:\Users\user\Downloads';

*Use PROC CORR to summary the dataset with missing value;
PROC CORR DATA=big3.kilowatt2 PLOTS=matrix(histogram nvar=all);
VAR ac dryer kwh;
RUN;


*limits analyses to the observations where all variables are nonmissing with nomiss option;
PROC CORR DATA=big3.kilowatt2 PLOTS=matrix(histogram nvar=all) NOMISS;
VAR ac dryer kwh;
RUN;

*Fitting a Straight Line with PROC REG ;
PROC REG DATA=kilowatt;
MODEL kwh=ac;
RUN;


*Using PROC REG Interactively;


*Printing Predicted Values and Limits with p(yhat) clm(x's mean) cli (x's individual);
PROC REG DATA=kilowatt ;
MODEL kwh=ac/p clm cli;
RUN;


*Plotting Predicted Values and Limits, PROC REG plots(only)=fit(stats=none);




**20171205;
*Fitting Curves with PROC REG;
data engine;
input speed power @@;
speedsq=speed*speed;
datalines;
   22.0 64.03 20.0 62.47 18.0 54.94 16.0 48.84 14.0 43.73
   12.0 37.48 15.0 46.85 17.0 51.17 19.0 58.00 21.0 63.21
   22.0 64.03 20.0 59.63 18.0 52.90 16.0 48.84 14.0 42.74
   12.0 36.63 10.5 32.05 13.0 39.68 15.0 45.79 17.0 51.17
   19.0 56.65 21.0 62.61 23.0 65.31 24.0 63.89
; 
run;

*Correlation plot;
PROC CORR DATA=engine PLOTs=scatter;
VAR power speed;
RUN;

*Performing the Analysis;
*fitting linear model;
PROC REG DATA=engine;
MODEL power=speed;
RUN;

*fitting a nonliear model;
PROC REG DATA=engine;
MODEL power=speed speedsq;
RUN;

*Changing the Alpha Level;
PROC REG DATA=engine alpha=0.1;
MODEL power=speed speedsq /p cli clm;
RUN;


*Fitting Multiple Regression Models in SAS;
*all the same as single variable but added a new variable;
*利用AC預測KWH;
PROC REG DATA=kilowatt;
MODEL kwh=ac;
RUN;

*dryer predicting kwh;
PROC REG DATA=kilowatt;
MODEL kwh=dryer;
RUN;

*複回歸;
*two variables: ac and dryer;
PROC REG DATA=kilowatt;
MODEL kwh=ac dryer;
RUN;

*殘差;
PROC REG DATA=kilowatt;
MODEL kwh=ac dryer/r;
RUN;

*lack of fit;
PROC REG DATA=kilowatt;
MODEL kwh=ac dryer/lackfit;
RUN;





*Regression with categorical predictors;
*Use data elemapi2;
libname c 'C:\Users\user\Downloads';
*當資料欄位數很多想了解妳有哪些資料;
*按照變項名稱;
PROC CONTENTS DATA=c.elemapi2;
RUN;

*按照欄位名稱;
PROC CONTENTS DATA=c.elemapi2 varnum;
RUN;

*看一下我們所需的variables: api00, some_col, yr_rnd, mealcat, meals;
*PROC PRINT;

*看一下我們所需要變項是屬於連續變項還是類別;
*PROC MEANS and PROC FREQ;

*1. Regression with 0/1 variable;
PROC REG DATA=c.elemapi2;
MODEL api00=yr_rnd;
RUN;

*2. Regression with a 1/2 variable;
*Lets make a copy of the variable yr_rnd called yr_rnd2 that is coded 1/2, 1=non year-round and 2=year-round.
data elem_dummy;
DATA elemapi2;
SET c.elemapi2;
yr_rnd2=yr_rnd+1;
RUN;
PROC REG DATA=elemapi2;
MODEL api00=yr_rnd2;
RUN;

*3. Regression with a 1/2/3 variable;
proc reg data=c.elemapi2;
  model api00 = mealcat;
run;


*create dummy variables;
DATA elemapi2;
SET c.elemapi2;
x1=.;
x2=.;
IF mealcat=1 then do;x1=0; x2=0;end;
IF mealcat=2 then do;x1=1; x2=0;end;
IF mealcat=3 then do;x1=0; x2=1;end;
PROC FREQ DATA=elemapi2;
TABLES mealcat*x1*x2/list;
RUN;
PROC REG DATA=elemapi2;
MODEL api00=x1 x2;
RUN;

*Create dummy variables;
data temp_elemapi;
  set c.elemapi2;
    if mealcat~=.  then x1=0;
    if mealcat~=.  then x2=0;
    if mealcat~=.  then x3=0;
    if mealcat = 1 then x1=1;
    if mealcat = 2 then x2=1;
    if mealcat = 3 then x3=1;
run;
proc freq data=temp_elemapi;
  tables mealcat*x1*x2*x3 /list;
run;
PROC REG DATA=temp_elemapi;
MODEL api00=x1 x2; *參考組是誰就不放;
RUN;
PROC REG DATA=temp_elemapi;
MODEL api00=x2 x3;
RUN;

*4. Using GLM;
proc glm data=c.elemapi2;
class mealcat;
model api00 = mealcat/solution;
run;

proc glm data=c.elemapi2;
class mealcat(ref='1'); *第一組為參考組;
model api00 = mealcat/solution;
run;

*5. Regression with two categorical predictors with yr_rnd mealcat;
proc glm data=c.elemapi2;
class yr_rnd (ref='0') mealcat(ref='1'); 
model api00 = yr_rnd mealcat/solution;
run;

*6. Using GLM to test the interactive effect of variables: yr_rnd mealcat yr_rnd*mealcat;
proc glm data=c.elemapi2;
class yr_rnd (ref='0') mealcat(ref='1'); 
model api00 = yr_rnd mealcat yr_rnd*mealcat/solution;
run;

*7.Continuous and categorical variables ; 
proc glm data=c.elemapi2;
class yr_rnd (ref='0') mealcat(ref='1'); 
model api00 = api99 yr_rnd mealcat /solution;
run;

*畫圖;
proc reg data=c.elemapi2;
  model api00 = yr_rnd some_col;
  output out=pred pred=p;
symbol1 c=blue v=circle h=.8;
symbol2 c=red  v=circle h=.8;
axis1 label=(r=0 a=90) minor=none;
axis2 minor=none; 
proc gplot data=pred;
  plot p*some_col=yr_rnd /vaxis=axis1 haxis=axis2;
run;


****************Chapter 12: Creating and analyzing contingency table;
proc format; 
   value $gentxt 'M' = 'Male' 
                 'F' = 'Female'; 
   value $majtxt 'S' = 'Statistics' 
                 'NS' = 'Other'; 
run;  
data statclas; 
   input student gender $ major $ @@; 
   format gender $gentxt.; 
   format major $majtxt.; 
   datalines; 
	1 M S 2 M NS 3 F S 4 M NS 5 F S 6 F S 7 M NS 8 M NS 9 
	M S 10 F S 11 M NS 12 F S 13 M S 14 M S 15 M NS 16 
	F S 17 M S 18 M NS 19 F NS 20 M S 
; 	
run; 

*PROC FREQ with variable gender and major;
PROC FREQ DATA=statclas;
TABLES gender*major;
RUN;
PROC FREQ DATA=statclas;
TABLES major*gender;
RUN;

*PROC FREQ with some options: norow, nocol, nopercent;
PROC FREQ DATA=statclas;
TABLES gender*major/norow nocol nopercent;
RUN;

*建立表格資料;
data penalty; 
   input decision $ defrace $ count @@; 
   datalines; 
Yes White 19 Yes Black 17 
No White 141 No Black 149 
; 
run; 

*PROC FREQ with weight;

PROC FREQ data=penalty;
TABLES decision*defrace;
WEIGHT count;
RUN;


*Performing tests for independence;
*using penality data with decision and defrace;
*options: expected chisq;
PROC FREQ data=penalty;
TABLES decision*defrace/CHISQ expected;
WEIGHT count;
RUN;



*****************20171219***************;
data cows;    
   input herdsize $ disease numcows @@;    
   datalines; 
large 0 11 large 1 88 large 2 136 medium 0 18 
medium 1 4 medium 2 19 small 0 9 small 1 5 small 2 9 
;  
RUN;



*Creating Measures of Association with Ordinal Variables;
*using cows data;
*options: measure, CI;
*test: kentb, scorr;
PROC FREQ DATA=cows;
TABLES herdsize*disease/measures cl;
TEST scorr kentb;
WEIGHT numcows;
RUN;

*changing the confidence level;
PROC FREQ DATA=cows;
TABLES herdsize*disease/measures cl alpha=0.1;
TEST scorr kentb;
WEIGHT numcows;
RUN;


*side by side bar chars;
proc freq data=statclas; 
   tables gender*major / plots=freqplot; 
   title 'Side-by-Side Charts'; 
run; 

*Stacked Bar Charts; 
proc freq data=statclas; 
   tables gender*major  
    / plots=freqplot(twoway=stacked scale=percent); 
title 'Stacked Percentage Chart'; 
run; 

*************logistic regression;
LIBNAME c 'C:\Users\user\Downloads';
*****data source: binary;

**** Univariate analysis;
PROC TTEST DATA=c.binary;
CLASS admit;
VAR gpa gre;
RUN;

PROC FREQ DATA=c.binary;
TABLES admit*rank/chisq;
RUN;


***** logistic regression;
proc logistic data=c.binary descending;
  class rank / param=ref ;
  model admit = gre gpa rank;
run;

proc logistic data=c.binary ;
  class rank / param=ref ;
  model admit (event='1')= gre gpa rank;
run;

proc logistic data=c.binary ;
  class rank / param=ref ;
  model admit (event='1')= gre gpa rank;
  unit gre=10 20 100;
run;


***** 改變比較組別;
proc logistic data=c.binary descending;
  class rank(ref='1') / param=ref ;
  model admit = gre gpa rank;
run;

**** ROC curve;
proc logistic data=c.binary descending plots=ROC;
  class rank / param=ref ;
  model admit = gre gpa rank;
run;

proc logistic data=c.binary descending;
  class rank / param=ref ;
  model admit = gre gpa rank;
  ROC 'GRE' gre;
  ROC 'GPA' gpa;
  ROC 'RANK' rank;
  roccontrast reference ('rank')/estimate e;
run;


***** odd ratios plot;
ods graphics on;
proc logistic data=c.binary plots(only)=(oddsratio(range=clip) effect);
  class rank / param=ref ;
  model admit = gre gpa rank;
      oddsratio gre;
      oddsratio gpa;
      oddsratio rank;
   run;
   ods graphics off;

proc logistic data=c.binary descending;
  class rank / param=ref ;
  model admit = gre gpa rank;
  contrast 'rank 2 vs 3' rank 0 1 -1 / estimate=parm;

**** predicted probability;

proc logistic data=c.binary descending;
  class rank / param=ref ;
  model admit = gre gpa rank;
  contrast 'gre=200' intercept 1 gre 200 gpa 3.3899 rank 0 1 0  / estimate=prob;
  contrast 'gre=300' intercept 1 gre 300 gpa 3.3899 rank 0 1 0  / estimate=prob;
  contrast 'gre=400' intercept 1 gre 400 gpa 3.3899 rank 0 1 0  / estimate=prob;
  contrast 'gre=500' intercept 1 gre 500 gpa 3.3899 rank 0 1 0  / estimate=prob;
  contrast 'gre=600' intercept 1 gre 600 gpa 3.3899 rank 0 1 0  / estimate=prob;
  contrast 'gre=700' intercept 1 gre 700 gpa 3.3899 rank 0 1 0  / estimate=prob;
  contrast 'gre=800' intercept 1 gre 800 gpa 3.3899 rank 0 1 0  / estimate=prob;
run;


proc logistic data=c.binary descending;
  class rank / param=ref ;
  model admit = gre gpa rank/;
RUN;
```
