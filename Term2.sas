```SAS
*****************************************************************************
**************** 全民健保資料庫處理與分析 ************************************
*****************************************************************************; 

*****開始之前 我想要改變一下我的介面好讓大家看得清楚;


**************** W02: 如何將原始資料匯入SAS格式 ******************************

*1***************舉例說明: HOSB2000 醫事機構基本資料檔 ************************


*Step1: 建立資料匣;
LIBNAME hosb 'C:\Users\user\Downloads';

*Step2: 利用INPUT將資料匯入 注意長度;

DATA HOSB2000;
INFILE "F:\AN8901\HOSB2000.DAT"  lrecl=258 MISSOVER;
INPUT HOSP_ID $1-34  HOSP_CONT_TYPE $35 CNT_S_DATE $36-43 
             CNT_E_DATE $44-51 HOSP_TYPE_ID $52-53 TYPE_S_DATE $54-61
             TYPE_E_DATE $62-69 HOSP_EDUC_MARK $70 EDUC_S_DATE $71-78
			 EDUC_E_DATE $79-86 HOSP_GRAD_ID $87-88 GRAD_S_DATE $89-96
			 GRAD_E_DATE $97-104 HOSP_OLD_GRAD $105-106 OLDGRAD_S_DATE $107-114
             AREA_NO_H $115-118  HOSP_OWN_ID $119-150 HOSP_OPEN_DATE $151-158 
			 REVIEW_CODE $159 CONT_S_DATE $160-167  CONT_E_DATE $168-175
			 CCNT_S_DATE $176-183 CCNT_E_DATE $184-191 STOP_S_DATE $192-199
			 STOP_E_DATE $200-207 REST_S_DATE $208-215 REST_E_DATE $216-223
			 OLD_HOSP_ID $224-257;
RUN;

*絕大多數你拿的資料都已經匯成SAS檔案了;
*大家只需要對一下你拿到的與譯碼簿相同嗎?

*Step3: 讓我們看一下我們的資料長相吧
*PROC CONTENTS and PROC PRINT;

PROC CONTENTS DATA=hosb.hosb2000;
RUN;
PROC CONTENTS DATA=hosb.hosb2000 VARNUM;
RUN;

*Step4: 資料太長 如何只留下我所需要的變數-KEEP DROP;
DATA hosp_id;
SET hosb.hosb2000;
KEEP hosp_id HOSP_EDUC_MARK ;
RUN;

LIBNAME c 'd:\'; 

*Step5: HOSP_ID最後兩碼是權屬別;
****利用substr文字擷取變數找醫院代碼第33與第34碼;
****我們可以將擷取後文字重新建立一個新的變項-名稱ownership;
DATA hosb2000;
SET c.hosb2000;
ownership=substr(hosp_id,33,2);
PROC FREQ DATA=hosb2000;
TABLES ownership;
RUN;

****請利用PROC FREQ看一下的擷取後的結果;

*辛苦大家了, 做好資料千萬要注意它放在哪裡;
*如果沒有將資料存成永久檔, 就前功盡棄了;

*Step6: 將資料儲存為永久檔;
DATA C.HOSB2000_n; /*請將剛剛命名好的資料儲存位置告訴SAS他才會存在你想要的位置以後你才找的到*/
SET HOSB2000;
RUN;


*Step7: 存撰寫程式;
*辛苦寫好的程式還可以繼續使用;
*別忘了儲存, 方式與我們一般使用office軟體相同;


*Step8: 最後我們來檢查一下我們做那些事情-請看看我們之前的做好的資料匣有甚麼;




****************W03: 認識門診清單明細檔(CD)*********************************************;


*****A: 人次與人數的比較;
*****PROC SORT and PROC SORT nodup and PROC SORT nodupkey;

*Step1: 你的資料到底有幾筆;
*cd2000, 人次: N=1192509;

*Step2: 你的資料到底有幾個人;
PROC SORT DATA=c.cd2000;
BY ID;
RUN;
PROC SORT DATA=c.cd2000 NODUPKEY OUT=cd2000_id;*cd2000_id要看人數有多少;
BY ID;
RUN;
*Step3: 你的資料到底是從幾家醫院或診所來的;
PROC SORT DATA=c.cd2000 NODUPKEY OUT=cd2000_hospid;*cd2000_hospid要看醫院家數有多少;
BY HOSP_ID;
RUN;

****************W04: CD檔同人歸戶*********************************************;

*** PPT範例;
DATA one;
  INPUT prodid $sale @@;
  DATALINES;
C 200 B 160 C 190 B 150
A 250 B 65 A 110 C 70
C 150 A 90 A 120 B 100
;
RUN;
PROC SORT DATA=one;
BY prodid;
PROC PRINT DATA=one;
RUN;

DATA sum(KEEP=prodid salesum);
  SET one;
  RETAIN salesum 0 ;
  BY prodid;
  IF FIRST.prodid THEN DO; 
       salesum=0;  
  END;
  salesum=salesum+sale;
  IF LAST.prodid;
RUN;
PROC PRINT DATA=sum;
RUN;


*****A: 同病人歸戶;

LIBNAME cd 'C:\Users\user\Downloads';

*Step 1: 請將CD2000根據ID(病患代碼)進行排序;

PROC SORT DATA=cd.cd2000;
BY ID;
RUN;

*Step 2: 請利用Retain語法以病患ID為鍵值(KEY)進行垂直累加;
*Step3: 僅保留最後一筆資料;
DATA visit_id (KEEP=ID ID_sex ID_birthday visit total);
	SET cd.cd2000;
	BY ID;
	RETAIN visit 0 total 0 ;
	IF FIRST.ID THEN DO;
	visit=0; total=0;
	END;
	visit=visit+1;
	total=total+T_AMT;
	IF LAST.ID;
RUN;

*Step4: 利用PROC MEANS 觀察平均每年平均門診就醫次數;
PROC MEANS DATA=visit_id;
VAR visit total;
RUN;

PROC MEANS DATA=visit_id MEAN MEDIAN;
VAR visit total;
RUN;



****練習一下 ***請根據同一家醫院歸戶****;
*Step1: 請將CD2000根據HOSP_ID(醫院代碼)進行排序;
*Step2: 請利用Retain語法將醫院HOSP_ID為鍵值(KEY)進行垂直累積(visit+1)及就醫金額(total_amt=total_amt+T_AMT);
*Step3: 僅保留最後一筆資料;
*Step4: 請將做好資料存成永久檔;


*****B: 找出糖尿病病患 *******************************************************;


*Step 1: 利用國際疾病分類代碼找出糖尿病病患;
*Step 1-1: 主診斷;
DATA dm_1;
	SET cd.cd2000;
	IF substr(ACODE_ICD9_1,1,3)='250';
RUN;
/*N=14429, 人次*/
*Step 1-2: 主診斷+次診斷;
DATA dm_2;
	SET cd.cd2000;
	IF substr(ACODE_ICD9_1,1,3)='250' or 
         substr(ACODE_ICD9_2,1,3)='250' or
         substr(ACODE_ICD9_3,1,3)='250' ;
RUN;
/*N=20904, 人次*/

*Step 2: 人數與人次的差異 (nodupkey);
/* NODUPKEY: 排除key重複的人*/
/*人數: N=*/
PROC SORT DATA=dm_1 nodupkey;
BY ID;
PROC SORT DATA=dm_2 nodupkey;
BY ID;
RUN;

*Step 3: 多少次就醫才能定義真正有病的病患, retain;
/*進行垂直累加 計算因為糖尿病就醫次數*/
/*利用freq看因糖尿病就醫次數分布*/
DATA dm_2;
	SET cd.cd2000;
	IF substr(ACODE_ICD9_1,1,3)='250' or 
         substr(ACODE_ICD9_2,1,3)='250' or
         substr(ACODE_ICD9_3,1,3)='250' ;
DATA dm_id (KEEP=ID ID_sex ID_birthday visit total);
	SET dm_2;
	BY ID;
	RETAIN visit 0 total 0 ;
	IF FIRST.ID THEN DO;
	visit=0; total=0;
	END;
	visit=visit+1;
	total=total+T_AMT;
	IF LAST.ID and visit>=3;
RUN;
PROC FREQ DATA=dm_id;
TABLES visit;
RUN;

*Step 4: 將資料存成永久資料檔, 以便後續使用; 
DATA cd.dm_id;
SET dm_id;
RUN;

**************練習一下: 利用CD2000找出因高血壓就醫病患人數;

*Step 1: 先找出高血壓疾病代碼;
*Step 2: 以三次診斷作為定義病患罹患高血壓; 



**************W05: 認識OO檔及門診CD(清單)及OO(醫令)串檔;

*****A: 認識OO檔 *****************************************************;

*Step1: 確認資料匣;
LIBNAME c 'C:\Users\user\Downloads';

*Step2: 利用PROC CONTENTS 觀看資料的筆數, 變項名稱及變項特性;
PROC CONTENTS DATA=c.oo2000 VARNUM;
RUN;
*N=5439895;
*number of variables: 13;

*Step3: 利用網路或健保署文件找出抽血項目;
**08011C, 08012C, 08082C;

*Step4: 利用IF條件式保留符合條件資料及SUBSTR擷取符合文字變數 (DRUG_NO);
DATA blood;
SET c.oo2000;
IF SUBSTR(DRUG_NO, 1, 6) IN ('08011C', '08012C', '08082C');
RUN;
*N=9541;
PROC FREQ DATA=blood;
TABLES DRUG_NO;
RUN;


*******B: MERGE example;

DATA ss1;
	INPUT id $ sex $ birth_date $;
	DATALINES;
	a1 m 19811130
	a2 m 19850315
	a3 f 19661020
	a4 m 19901225
	a5 f 20000105
	a6 f 19460912
;
RUN;

DATA ss2;
	INPUT id $ sex $ birth_date $;
	DATALINES;
	b1 f 19870307
	b2 m 19350915
	b3 m 19281031
	b4 m 19900105
	b5 f 20081015
	b6 m 19361122
;
RUN;

DATA ss3;
	INPUT id $ med_date $ med_type $;
	DATALINES;
	a1 20120103 02
	a2 20061112 13
	a13 20101230 16
	b4 19980308 02
	b5 20070628 04
	a6 19980810 01
;
RUN;

***請做垂直合併 (SET);
DATA ss;
	SET ss1 ss2;
PROC PRINT DATA=ss1;
PROC PRINT DATA=ss2;
PROC PRINT DATA=ss;
RUN;
***請做水平合併(MERGE) merge 之前的重要步驟是SORT BY KEY;
PROC SORT DATA=ss1;BY id;
PROC SORT DATA=ss3;BY id;
DATA ss;
	MERGE ss1 ss3;
	BY id;
PROC PRINT DATA=ss1;
PROC PRINT DATA=ss3;
PROC PRINT DATA=ss;
RUN;

***請做水平合併且加上語法IF a, 以保留ss1資料為主, 將ss3資料含有ss1資料之鍵值做和平合併; 
PROC SORT DATA=ss1;BY id;
PROC SORT DATA=ss3;BY id;
DATA ss;
	MERGE ss1(IN=a) ss3(IN=b);
	BY id;
	IF a;
PROC PRINT DATA=ss;
RUN;

PROC SORT DATA=ss1;BY id;
PROC SORT DATA=ss3;BY id;
DATA ss;
	MERGE ss1(IN=a) ss3(IN=b);
	BY id;
	IF b;
PROC PRINT DATA=ss;
RUN;

PROC SORT DATA=ss1;BY id;
PROC SORT DATA=ss3;BY id;
DATA ss;
	MERGE ss1(IN=a) ss3(IN=b);
	BY id;
	IF  a and b;
PROC PRINT DATA=ss;
RUN;

**************練習C: 門診醫令檔與門診清單明細檔串檔;

*Step1: 確認資料匣;

*Step2: 利用PROC SORT 排序鍵值 (FEE_YM, APPL_TYPE, HOSP_ID, APPL_DATE, CASE_TYPE, SEQ_NO);
*NOTICE: CD檔要排序, OO檔也要排序;
PROC SORT DATA=c.cd2000;
BY FEE_YM APPL_TYPE HOSP_ID APPL_DATE CASE_TYPE SEQ_NO;
PROC SORT DATA=c.oo2000;
BY FEE_YM APPL_TYPE HOSP_ID APPL_DATE CASE_TYPE SEQ_NO;

*Step3: 水平合併(MERGE);
DATA cdoo2000;
	MERGE c.cd2000(IN=a) c.oo2000(IN=b);
	BY FEE_YM APPL_TYPE HOSP_ID APPL_DATE CASE_TYPE SEQ_NO;
	IF a or b;
RUN;

*Step4: 利用IF條件式保留符合條件資料及SUBSTR擷取符合文字變數 (DRUG_NO);

*Step5: 請利用PROC CONTENTS看一下資料筆數及變項數的變化;

**************HW: 想了解糖尿病病患之可能之所有就醫門診醫令;

*Step1:請找出糖尿病病患;

*Step 2: 請將糖尿病病患的就醫門診(DM)依照六個欄位排序;

*Step 3: OO檔也要依照六個欄位排序;
*小提醒老師說過合併前請保留自己需要的即可;

*Step 4: 使用水平合併;
*請注意樣本數變化;

*************HW: 就醫有抽血檢查的人是因為甚麼原因;

*Step1:請找出有抽血檢查的醫令;

*老師說過會最好是一對一或是一對多;
*我們這筆資料會是哪一種呢??
*請檢查一下;

*Step 2: 請將blood (OO)依照六個欄位排序;

*Step 3: CD檔也要依照六個欄位排序;
*小提醒老師說過合併前請保留自己需要的即可;

*Step 4: 使用水平合併;
*請注意樣本數變化;


****************W6:  CD檔與OO檔連結 藥品練習*********************************************;


***************練習A: Excel藥品檔與門診醫令檔串檔;
LIBNAME c 'C:\Users\user\Downloads';

*Step1: 先將EXCEL資料匯入SAS;

*Step2: 利用PROC SORT 排序鍵值 (DRUG_NO);
*NOTICE: EXCEL藥品檔要排序, OO檔也要排序;
PROC SORT DATA=met;
BY drug_no;
RUN;

PROC SORT DATA=c.oo2000;
BY drug_no;
RUN;

*Step3: 注意合併之前請先保留兩個檔案自己所需要變項(KEEP or DROP);
DATA met1;
SET met;
KEEP drug_no;
RUN;

*Step4: 水平合併(MERGE);
DATA oo_met;
MERGE c.oo2000(IN=a) met1(IN=b);
BY drug_no;
IF a;
IF b=1 then met=1;else met=0;
IF b=1 THEN OUTPUT;
RUN;


*Step5: 加上 IF a 條件式保留符合有使用Metformin的資料即可;



***************練習B: Metformin門診醫令檔串檔門診清單;


*Step1: 確認資料;

*Step2: 利用PROC SORT 排序鍵值 (FEE_YM, APPL_TYPE, HOSP_ID, APPL_DATE, CASE_TYPE, SEQ_NO);
*NOTICE: 含有藥品之OO檔要排序, CD檔也要排序;
PROC SORT DATA=c.cd2000;
BY FEE_YM APPL_TYPE HOSP_ID APPL_DATE CASE_TYPE SEQ_NO;
PROC SORT DATA=oo_met;
BY FEE_YM APPL_TYPE HOSP_ID APPL_DATE CASE_TYPE SEQ_NO;
RUN;

*Step3: 注意合併之前請先保留兩個檔案自己所需要變項(KEEP or DROP);
DATA oo_met;
SET oo_met;
KEEP FEE_YM APPL_TYPE HOSP_ID APPL_DATE CASE_TYPE SEQ_NO met;
RUN;

*Step4: 水平合併(MERGE);
DATA cdoo2000;
	MERGE c.cd2000(IN=a) oo_met(IN=b);
	BY FEE_YM APPL_TYPE HOSP_ID APPL_DATE CASE_TYPE SEQ_NO;
	IF a and b;
RUN;
*Step5: 加上 IF a 條件式保留符合有使用Metformin的資料即可;

*Step6: 檢查一下這些有使用metformin的病患是否都有被診斷為糖尿病病患;



***************HW: 使用Meformin病患之就醫地點(HOSB);


*Step1: 確認資料;

*Step2: 利用PROC SORT 排序鍵值 (HOSP_ID);
*NOTICE: metformin病患資料要排序, HOSP_ID檔也要排序;

*Step3: 注意合併之前請先保留兩個檔案自己所需要變項(KEEP or DROP);

*Step4: 水平合併(MERGE);

*Step5: 加上 IF a 條件式保留符合有使用Metformin的糖尿病病患資料即可;


****************W8:  DD檔及同一次住院歸戶及日期由文字變項轉成日期格式*********************************************;

***************練習A: 認識住院醫療費用清單明細檔且找出中風住院病患;

**別忘了資料檔;



***************練習B: 同一次住院歸戶;

*Step1: 先看DD2000住院人次;
*N=7913;

*Step2: 先看看2000年之前有多少人入院;
DATA dd_2000_bf;
	SET dd.dd2000;
	IF substr(IN_DATE,1,4)<2000;
PROC FREQ DATA=dd_2000_bf;
TABLES IN_DATE;
RUN;
*N=381;

*Step3: 再看看有多少人2000年之後出院日期是空白的;
DATA dd_2000_af;
	SET dd.dd2000;
	IF substr(OUT_DATE,1,4)=' ';
PROC FREQ DATA=dd_2000_af;
TABLES IN_DATE;
RUN;
*N=517;

*Step4: 同一次住院歸戶, 歸戶鍵值為同人(ID)同院(HOSP_ID)同天(INDATE);
*NOTICE: 使用垂直累加語法(RETAIN)之前要先排序(SORT);
*NOTICE: 同次住院要累加急慢性住院天數(E_BED_DAY & S_BED_DAY)及申請金額 (MED_AMT)
*NOTICE: 注意同一次住院後歸戶筆數;

DATA dd_2000_retain;
	SET dd.dd2000;
	KEY=ID||HOSP_ID||IN_DATE;
PROC SORT DATA=dd_2000_retain;
BY KEY;
DATA dd_2000_retain;
	SET dd_2000_retain;
	BY KEY;
	RETAIN  E_BED_DAY_s 0 S_BED_DAY_s 0 total_fee 0 ;
	IF FIRST.KEY THEN DO;
	E_BED_DAY_s=0;
    S_BED_DAY_s=0; 
    total_fee=0;
	END;
    E_BED_DAY_s=E_BED_DAY_s+E_BED_DAY;
    S_BED_DAY_s=S_BED_DAY_s+S_BED_DAY; 
    total_fee=total_fee+MED_AMT;	
   IF LAST.KEY;
RUN;
*N=7456;

*Step5: 去頭 (還沒2000年之前入院資料沒有);

*Step6: 去尾 (還有2000年沒出院)

*Step7: 如果有多年資料呢???(請用練習A檔案再歸戶一次);



*****************W09: 文字與數字轉換練習及認識DO檔;

DATA ss;
	INPUT ID $ BIRHT_DATE $ MED_DATE $ MED_TYPE $;
	DATALINES;
	a1 19811130 20120103 01
	a2 19850315 19961112 23
	a3 19661020 20101230 06
	a4 19901215 20070628 04
	a5 20000105 20070628 04
	a6 19460912 19980810 11
	;
RUN;

*方法一;
DATA ss;
	SET ss;
	type1=MED_TYPE*1;
PROC PRINT DATA=ss;
RUN;

*方法二;
DATA ss;
	SET ss;
	type1=MED_TYPE*1;
	type2=INPUT(MED_TYPE, 2.);
PROC PRINT DATA=ss;
RUN;


******************日期格式練習;

*Step1: 請輸入自己的生日MDY;
DATA one;
	birthday=MDY(12, 16, 1977);
PROC PRINT DATA=one;
RUN;

*Step2: SAS 日期格式起始日;
DATA one;
	birthday=MDY(12, 16, 1977);
	begin=MDY(01, 01, 1960);
PROC PRINT DATA=one;
RUN;
*Step3: 看得懂的格式;
DATA one;
	birthday=MDY(12, 16, 1977);
	begin=MDY(1, 1, 1960);
	FORMAT birthday begin YYMMDD10.;
PROC PRINT DATA=one;
RUN;

*Step4: 資料日期可能是負的數字;
DATA one;
	birthday=MDY(12, 16, 1977);
	begin=MDY(1, 1, 1960);
	negative=MDY(12, 31, 1959);
	FORMAT birthday begin YYMMDD10.;
PROC PRINT DATA=one;
RUN;
*Step5: TODAY();
DATA one;
	birthday=MDY(12, 16, 1977);
	begin=MDY(1, 1, 1960);
	negative=MDY(12, 31, 1959);
	today=TODAY();
	FORMAT birthday begin negative today YYMMDD10.;
PROC PRINT DATA=one;
RUN;

******************練習一下將ss檔案之BIRTH_DATE與MED_DATE轉為日期格式;
DATA ss;
	SET ss;
	birth_date1=INPUT(BIRHT_DATE, YYMMDD8.);
	med_date1=INPUT(MED_DATE, YYMMDD8.);
PROC PRINT DATA=ss;
RUN;


******************練習一下將ss檔案之BIRTH_DATE與MED_DATE轉為日期格式;
DATA ss;
	SET ss;
	birth_date1=INPUT(BIRHT_DATE, YYMMDD8.);
	med_date1=INPUT(MED_DATE, YYMMDD8.);
	FORMAT birth_date1 med_date1 YYMMDD10.;
PROC PRINT DATA=ss;
RUN;
***************練習A : 入院日期及出院日期由文字格式轉成數字格式;
LIBNAME dd 'C:\Users\user\Downloads\dd\dd';
DATA dd;
SET dd.dd2001-dd.dd2010;
	in_date1=INPUT(IN_DATE, YYMMDD8.);
	out_date1=INPUT(OUT_DATE, YYMMDD8.);
	FORMAT in_date1 out_date1 YYMMDD10.;
RUN;

***************練習B:  計算入院時年齡~請使用簡易版;
DATA dd;
SET dd;
age1=substr(in_date,1,4)-substr(id_birthday,1,4);
run;


****INTCK 算時間間距;
DATA dd2000;
 	SET dd2000;
 	LOS=INTCK('day', IN_DATE1, OUT_DATE1);
 	AGE1=SUBSTR(IN_DATE,1,4)-SUBSTR(ID_BIRTHDAY,1,4);
	IF substr(ID_BIRTHDAY, 5,2)=" " THEN
		BIRTHDAY=MDY(7, 1, substr(ID_BIRTHDAY, 1,4));
	ELSE IF substr(ID_BIRTHDAY, 7,2)=" " THEN
		BIRTHDAY=MDY(substr(ID_BIRTHDAY,5,2), 15, substr(ID_BIRTHDAY, 1,4));
    FORMAT BIRTHDAY YYMMDD10.;
	AGE2=INTCK('year', BIRTHDAY, IN_DATE1);
RUN;
DATA test;
SET dd2000;
if los2~=los3 or age1~=age2;
run;


*******************W11: 新發個案及DO檔串回DD檔需要注意事項;

**************練習A: 新發中風病患~2001-2010年新發中風個案
*Step1: 請利用以上同一次住院歸戶好資料進行;
*Step2: 請擷取主診斷為430-438的病患;
*Step3: 將入院日為2000年資料output至stroke_2000, 將入院日為2001-2010年資料output至stroke_2001;
*Step4: 進行水平合併, 記得兩個檔案都要排序後才合併, 排序鍵值KEY為ID;
*Step5: MERGE但排除2001-2010年中有2000年的ID的病患;


LIBNAME dd 'C:\Users\user\Downloads\dd';
LIBNAME cd 'C:\Users\user\Downloads\cd2000';

*Step1: 看資料長相 PROC CONTENTS;
PROC CONTENTS DATA=dd.dd2000 VARNUM;
RUN;

*Step2: 將2000至2010年資料進行垂直合併 (SET);
DATA dd;
	SET dd.dd2000-dd.dd2010;
RUN;

*Step3: 找中風病患(就醫主診斷碼符合ICD-9: 430-438);
DATA stroke;
	SET dd;
	IF '430'<=substr(ICD9CM_CODE,1,3)<='438';
	IF ICD9CM_CODE IN: ('430', '431', '432', '433', '434', '435', '436', '437', '438');
RUN;
*N=2642;

*Step4: 就醫人次就醫人數之差異;
PROC SORT DATA=stroke OUT=stroke_id  NODUPKEY;
BY ID;
RUN;
*N=1706;

*Step5: 不同年度之就醫人次, 請先截取住院日期前四碼當作就醫年度;
DATA stroke;
	SET stroke;
	dx_yr=substr(IN_DATE,1,4);
RUN;

PROC FREQ DATA=stroke;
TABLES dx_yr;
RUN;


DATA stroke_dd_2000 stroke_dd_2001_2010;
SET stroke;
IF dx_yr<='2000' THEN OUTPUT stroke_dd_2000;
IF dx_yr>='2001' THEN OUTPUT stroke_dd_2001_2010;
RUN;
*STROKE_2000, N=138 人次;
*STROKE_2001_2010 有 2504人次;

PROC SORT DATA=stroke_dd_2001_2010;
BY ID IN_DATE;
RUN;
DATA stroke_dd_2001_2010_first_id;
SET stroke_dd_2001_2010;
BY ID;
IF FIRST.ID;
RUN;
*STROKE_2001_2010_FIRST_ID 有 1633人數;
PROC SORT DATA=stroke_dd_2000;
BY ID;
DATA stroke_dd_2001_2010_new;
MERGE stroke_dd_2001_2010_first_id(IN=a) stroke_2000(IN=b);
BY ID;
IF a;
IF b=1 THEN DELETE;
RUN;
*STROKE_2001_2010_NEW 有 1596人數;

DATA stroke_cd_2000;
SET cd.cd2000;
IF '430'<=substr(ACODE_ICD9_1,1,3)<='438';
RUN;
PROC SORT DATA=stroke_cd_2000;
BY ID;
DATA stroke_dd_2001_2010_new;
MERGE stroke_2001_2010_new(IN=a) stroke_cd_2000(IN=b);
BY ID;
IF a;
IF b=1 THEN DELETE;
RUN;
*STROKE_2001_2010_NEW 有 1498 人數;

PROC SORT DATA=stroke_2000;
BY ID;
DATA stroke_dd_2001_2010_new;
MERGE stroke_2001_2010_first_id(IN=a) stroke_dd_2000(IN=b) stroke_cd_2000(IN=c);
BY ID;
IF a;
IF b=1 or c=1 THEN DELETE;
RUN;

************HW_A: 新發中風病患再中風住院;
PROC SORT DATA=stroke_dd_2001_2010;
BY ID IN_DATE;
RUN;
*Step 1: 將第一次住院output到stroke_dd_2001_2010_first_id, 其他的部份output到stroke_dd_readmission;
DATA stroke_dd_2001_2010_first_id stroke_dd_readmission;
SET stroke_dd_2001_2010;
BY ID;
IF FIRST.ID THEN OUTPUT stroke_dd_2001_2010_first_id; 
ELSE OUTPUT stroke_dd_readmission;
RUN;
*step 2:將檔案與新發個案做水平合併但合併前僅保留需要變數及排序;
PROC SORT DATA=stroke_dd_readmission(KEEP=ID IN_DATE);
BY ID IN_DATE;
*NOTICE: 合併前相同變數名稱會覆蓋需要重新更名才不會蓋過你所需要訊息;
DATA stroke_dd_readmission;
SET stroke_dd_readmission;
RENAME IN_DATE=RE_IN_DATE;
*Step3: 接回新發個案檔;
*Notice: 一個人可能會接到多筆再住院 請確認需要哪一筆 住院日與再住院日相同則是同次住院，不為再住院;
*Notice: 需要知道再住院為多久請將文字日期轉為數字日期格式即可;
DATA stroke_dd_2001_2010_readmission;
MERGE stroke_dd_2001_2010_new(IN=a) stroke_dd_readmission(IN=b);
BY ID;
IF a;
IF b=1 THEN readmission=1;ELSE readmission=0;
RUN;


*************HW_B: 中風病患且於住院期間使用CT or MRI;
*Step1: 找中風病患2000年, ICD-9: 430-438;
DATA stroke_dd_2000;
	SET dd.dd2000;
	IF '430'<=substr(ICD9CM_CODE,1,3)<='438';
RUN;

*Step2: 有清單中風病患資料, 現在想知道醫令資料是否有CT or MRI的使用
KEY: FEE_YM APPL_TYPE HOSP_ID APPL_DATE CASE_TYPE SEQ_NO
NOTICE: 醫令與清單都需要做排序動作;
PROC SORT=stroke_dd_2000 out=stroke_key(KEEP=FEE_YM APPL_TYPE HOSP_ID APPL_DATE CASE_TYPE SEQ_NO);
BY FEE_YM APPL_TYPE HOSP_ID APPL_DATE CASE_TYPE SEQ_NO;
PROC SORT DATA=do.do2000;
BY FEE_YM APPL_TYPE HOSP_ID APPL_DATE CASE_TYPE SEQ_NO;

*Step3: MERGE, 留下所有中風病患之醫令資料;
DATA stroke_do_2000;
MERGE do.do2000(IN=a) stroke_key(IN=b);
BY FEE_YM APPL_TYPE HOSP_ID APPL_DATE CASE_TYPE SEQ_NO;
IF a=1 and b=1;
RUN;

*Step4: CT or MRI之醫令代碼;
DATA CTMRI(KEEP=FEE_YM APPL_TYPE HOSP_ID APPL_DATE CASE_TYPE SEQ_NO);
SET stroke_do_2000;
WHERE SUBSTR(ORDER_CODE, 1, 6) IN ('33084A', '33084B', '33085A', '33085B', '33067B', '33068B', '33069B', '33070B', '33071B', '33072B', '33098B', '36021C');
RUN;
*NOTICE: 病患可能同時做CT及MRI 我們只需要確認其中一筆即可;
PROC SORT DATA=CTMRI NODUPKEY;
BY FEE_YM APPL_TYPE HOSP_ID APPL_DATE CASE_TYPE SEQ_NO;
RUN;

*Step5: 將有使用者的醫令再重新與清單連結, 確立當次住院有使用該項醫療處置;
DATA stroke_dd_2000_CTMRI;
MERGE stroke_dd_2000(IN=a) CTMRI(IN=b);
BY FEE_YM APPL_TYPE HOSP_ID APPL_DATE CASE_TYPE SEQ_NO;
IF a;
IF b=1 THEN CTMRI=1;ELSE CTMRI=0;
PROC FREQ DATA=stroke_dd_2000_CTMRI;
TABLES CTMRI;
RUN;




***************W11: Lag 函數介紹與再住院 *******************;

data example1;
     input X @@;/*是否忘記了@@的意思?*/
     L_One=lag(x);
     L_Two=lag2(x);/*以第三筆30而言,上上筆就是10了,以此類推*/
     cards;/*資料總共6筆*/
10 20 30 40 50 60
;
run;
PROC PRINT DATA=example1;
RUN;

data example2;
	input year $ sales ;
	datalines;
	1999 42323
	2001 45240
	2002 57865
	2003 62129
	2004 70048
	2005 90738
	;
run;
data example2_L;
     set example2;
     lag_sales=lag(sales);/*前年的sales量塞到lag_sales變項中*/
	 dif=dif(sales);
     increase=(dif(sales)/lag(sales))*100;
run;
PROC PRINT DATA=example2_L;
RUN;

data example3;
	input country $ year $ sales;
	datalines;
	NZ 1999 42323
	NZ 2001 45240
	NZ 2002 57865
	NZ 2003 62129
	NZ 2004 70048
	NZ 2005 90738
	TW 1999 4354
	TW 2001 3582
	TW 2002 8112
	TW 2003 7009
	TW 2004 15442
	TW 2005 6257
	;
run;

data example3_L;
     set example3;
     by country year;/*根據country,year升冪排序*/
     lag_sales=lag(sales);/*原本在if  then…內的lag函數移動到前面執行*/
     dif_sales=dif(sales);
     if first.country then do;/*前一筆與差距的sales擺放好之後再做挑選的動作*/
          lag_sales=.  ;
         dif_sales=.  ;
     end;
     increase=(dif_sales/lag_sales)*100;/*最後做sales成長的計算*/
run;
PROC PRINT DATA=example3_L;
RUN;

*如何利用LAG進行再住院分析;
LIBNAME DD "G:\Chien\Linien\class\CLASS_2016_Spring\健康資料庫分析\10萬抽樣檔\10萬抽樣檔\dd";
*Step 1: 請將住院檔DD2000-DD2010進行垂直合併;
DATA DD;
SET DD.DD2000-DD.DD2010;
RUN;
*Step 2: 請將檔案依照ID、入院日期及出院日期排序;
PROC SORT DATA=DD(KEEP=ID HOSP_ID IN_DATE OUT_DATE);
BY ID IN_DATE OUT_DATE;
RUN;
*Step 3: 請將入院日期及出院日期轉換為日期格式，請格式化成可以看得懂的日期格式;
DATA DD(DROP=IN_DATE OUT_DATE);
SET DD;
IN_DATE1=INPUT(IN_DATE, YYMMDD8.);
OUT_DATE1=INPUT(OUT_DATE, YYMMDD8.);
FORMAT IN_DATE1 OUT_DATE1 YYMMDD10.;
RUN;
*Step 4: 利用Lag(1), LAG ID, LAG in_date 及 LAG out_date;
DATA DD_lag;
SET DD;
BY ID IN_DATE1;
lag_ID=lag(ID);lag_IN_DATE1=lag(IN_DATE1);lag_OUT_DATE1=lag(OUT_DATE1);
IF ID~=lag_ID THEN DO;
lag_ID=.;lag_IN_DATE1=.;lag_OUT_DATE1=.;
END;
FORMAT lag_IN_DATE1 lag_OUT_DATE1 YYMMDD10.;
RUN;

*Step5: 留下你需要的訊息;
*需要滿足以下條件;
*下一次住院日要大於上一次住院日與出院日;
*lag_IN_DATE1~=. and lag_OUT_DATE1~=. 只有單一次住院病患這兩個變數數值為.; 
DATA re_DD;
SET DD_lag;
IF (IN_DATE1>lag_IN_DATE1 and IN_DATE1>lag_OUT_DATE1) and 
    lag_IN_DATE1~=. and lag_OUT_DATE1~=. THEN Readmission=1;ELSE Readmission=0;
RUN;



*** 定義2001年新發糖尿病病患;
LIBNAME cd "G:\Chien\Linien\class\CLASS_2016_Spring\健康資料庫分析\10萬抽樣檔\10萬抽樣檔\cd";
*Step 1:  要定義一年新發個案至少要三年資料;
*留下需要變數;
DATA DM(KEEP=ID FUNC_DATE1);
SET cd.cd2000 cd.cd2001 cd.cd2002;
WHERE ACODE_ICD9_1 IN: ('250') | 
              ACODE_ICD9_2 IN: ('250') | 
              ACODE_ICD9_3 IN: ('250') ;
FUNC_DATE1=INPUT(FUNC_DATE, YYMMDD8.);
FORMAT FUNC_DATE1 YYMMDD10.;
PROC SORT DATA=DM;
BY ID FUNC_DATE1;
RUN;
*Step 2: 一年內三次門診至少要lag2;
DATA DM_lag ;
SET DM;
BY ID FUNC_DATE1;
lag_ID=lag2(ID);
lag_FUNC_DATE1=lag2(FUNC_DATE1);
FORMAT lag_FUNC_DATE1 YYMMDD10.;
IF lag_ID~=ID THEN DO;
lag_ID=.;lag_FUNC_DATE1=.;
END;
IF FUNC_DATE1-lag_FUNC_DATE1<=365;
RUN;
*Step 3: 請留下lag_func_date 必須是2001年才是新發個案;
DATA DM_new;
SET DM_lag;
IF year(lag_FUNC_DATE1)=2001;
RUN;
*Step 4: 每一個只需要留第一筆資料;
DATA DM_new;
SET DM_new;
BY ID;
IF FIRST.ID;
RUN;


****************W13: 簡單MACRO語法;

*練習一下: 如何將新發糖尿病病患改成定義新發高血壓病患;
LIBNAME CD "C:\Users\user\Downloads\cd2000";
LIBNAME DD "C:\Users\user\Downloads\dd\dd";

*Step 1: normal sas code for patients diagnosed with DM;
DATA ICD_DM_ANY;
SET CD.CD2000;
WHERE SUBSTR(ACODE_ICD9_1, 1,3) IN :("250") |
              SUBSTR(ACODE_ICD9_2, 1,3) IN :("250") |
              SUBSTR(ACODE_ICD9_3, 1,3) IN :("250");
RUN;

*Step 2: adding %macro and %mend and macro name;
%MACRO ICD;
DATA ICD_DM_ANY;
SET CD.CD2000;
WHERE SUBSTR(ACODE_ICD9_1, 1,3) IN :("250") |
              SUBSTR(ACODE_ICD9_2, 1,3) IN :("250") |
              SUBSTR(ACODE_ICD9_3, 1,3) IN :("250");
RUN;
%MEND;

*Step 3: adding your macro varaible;
%MACRO ICD(x);
DATA ICD_&x._any;
SET CD.CD2000;
WHERE SUBSTR(ACODE_ICD9_1, 1,3) IN :("&x.") |
              SUBSTR(ACODE_ICD9_2, 1,3) IN :("&x.") |
              SUBSTR(ACODE_ICD9_3, 1,3) IN :("&x.");
RUN;
%MEND;
*step4;
%ICD(250);
%ICD(401);
%ICD(272);

*將時間也當作一個參數放入, 共有兩個參數;
%MACRO ICD(x,y);
DATA ICD_&x._&y.;
SET CD.CD&y.;
WHERE SUBSTR(ACODE_ICD9_1, 1,3) IN :("&x.") |
              SUBSTR(ACODE_ICD9_2, 1,3) IN :("&x.") |
              SUBSTR(ACODE_ICD9_3, 1,3) IN :("&x.");
RUN;
%MEND;
%ICD(250, 2000);
%ICD(250, 2001);

*macro日期回圈;
%MACRO ICD1;
%DO y=2000 %TO 2001;
DATA ICD_&y.;
SET CD.CD&y.;
WHERE SUBSTR(ACODE_ICD9_1, 1,3) IN :("250") |
              SUBSTR(ACODE_ICD9_2, 1,3) IN :("250") |
              SUBSTR(ACODE_ICD9_3, 1,3) IN :("250");
RUN;
%END;
%MEND;
%ICD1;


*中風住院病患之10年住院就醫紀錄
*Step 1: 先寫好要執行的SAS程式;
*Step 2: 在寫好的SAS程式前後加上%MACRO及%MEND，並為該SAS MACRO命名;
*Step 3: 將原先SAS程式中的變數替換為MACRO VARIABLES;
*Step 4: 執行SAS MACRO;
%MACRO ICD1;
%DO y=2000 %TO 2010;
DATA stroke_dd_&y.;
	SET dd.dd&y.;
	IF '430'<=substr(ICD9CM_CODE,1,3)<='438';
RUN;
%END;
%MEND;
%ICD1;



****************W14: 簡單SQL語法;


LIBNAME dd "C:\Users\user\Downloads\dd";

*SQL基礎練習;

******How to use SELECT statement;
******For example;
******ex1. 請選住院檔的病人ID, 醫院代碼, 住院日及出院日;
PROC SQL;
	CREATE TABLE hosp_dd AS
	SELECT ID, HOSP_ID, IN_DATE, OUT_DATE
	FROM dd.dd2000;
QUIT;

*****select all colunm;
******ex2. 所有住院檔;
PROC SQL;
	CREATE TABLE hosp_dd AS
	SELECT *
	FROM dd.dd2000;
QUIT;

*****Eliminating Duplicate Rows 去重複; 
*使用select distinct 後加刪除重複條件 很類似nodupkey;
******ex3. 曾經住院病患的人數;
PROC SQL;
	CREATE TABLE hosp_dd AS
	SELECT DISTINCT ID, IN_DATE
	FROM dd.dd2000;
QUIT;

****** WHERE; *條件式;
******ex4.  住院個案中性別為男性個案;
******也可以用IN;
PROC SQL;
	CREATE TABLE hosp_dd AS
	SELECT *
	FROM dd.dd2000
    WHERE ID_SEX IN ('M');
QUIT;
******ex5.  住院個案中年齡大於65歲個案;
******ex6.  可以多重條件 男性大於65歲個案;
PROC SQL;
	CREATE TABLE hosp_dd AS
	SELECT *, input(substr(IN_DATE,1,4), 4.)-input(substr(ID_birthday,1,4), 4.) as AGE
	FROM dd.dd2000
    WHERE ID_SEX IN ('M')
	HAVING age>65;
QUIT;
*****Order by***; *排序;
**DESC 遞減;
******ex7.  請將年齡由大排到小;
PROC SQL;
	CREATE TABLE hosp_dd AS
	SELECT *, input(substr(IN_DATE,1,4), 4.)-input(substr(ID_birthday,1,4), 4.) as AGE
	FROM dd.dd2000
    WHERE ID_SEX IN ('M')
	HAVING age>65
    ORDER BY age DESC;
QUIT;
****Sorting by Multiple Columns;
****可以同時排序不同變項;
******ex8. 請排ID及請將年齡由小到大;
PROC SQL;
	CREATE TABLE hosp_dd AS
	SELECT *, input(substr(IN_DATE,1,4), 4.)-input(substr(ID_birthday,1,4), 4.) as AGE
	FROM dd.dd2000
    WHERE ID_SEX IN ('M')
	HAVING age>65
    ORDER BY ID, age DESC;
QUIT;
******ex9. 請排ID及請將年齡由大到小;

***Sorting by Calculated Column;
PROC SQL;
	TITLE 'World Population Densities per Square Mile';
	SELECT Name, 
	              Population format=comma12., 
	              Area format=comma8.,
	              Population/Area AS  Density format=comma10.
	FROM sql.countries
	ORDER BY Density DESC;
QUIT;

LIBNAME cd 'C:\Users\user\Downloads';
*group by: 很像retain;
******ex10. 將病患就醫次數;
PROC SQL;
	CREATE TABLE ID_visit AS
	SELECT DISTINCT ID, COUNT(ID) AS VISIT
	FROM cd.cd2000
	GROUP BY ID;
QUIT;

*****Having****; 
*另一種條件式但必須是在group by 之後且符合group by的條件;
******ex11. 將病患就醫次數要超過15次以上;
PROC SQL;
	CREATE TABLE ID_visit AS
	SELECT DISTINCT ID, COUNT(ID) AS VISIT
	FROM cd.cd2000
	GROUP BY ID
    HAVING VISIT>=15;
QUIT;
*****Creating New Columns: Calculating values;
*****Calculating Values: Assigning a Column Alias;
******ex12. 病患醫療費用以美金計價;
PROC SQL;
	CREATE TABLE ID_visit AS
	SELECT DISTINCT ID, COUNT(ID) AS VISIT, 
                                           SUM(T_AMT) AS total_fee
	FROM cd.cd2000
	GROUP BY ID;
QUIT;

LIBNAME  cd 'G:\Chien\Linien\class\CLASS_2016_Spring\健康資料庫分析\10萬抽樣檔\10萬抽樣檔\cd';
LIBNAME  dd 'G:\Chien\Linien\class\CLASS_2016_Spring\健康資料庫分析\10萬抽樣檔\10萬抽樣檔\dd';


*練習一: 請計算門診CD2000因糖尿病就醫病患就醫次數、總醫療費用及平均醫療費用;
*SQL方法;
PROC SQL;
	CREATE TABLE ID_visit AS
	SELECT DISTINCT ID, COUNT(ID) AS VISIT, 
                                           SUM(T_AMT) AS total_fee
	FROM cd.cd2000
	WHERE substr(ACODE_ICD9_1,1,3) in ('250') or
	               substr(ACODE_ICD9_2,1,3) in ('250') or
	               substr(ACODE_ICD9_3,1,3) in ('250')
	GROUP BY ID;
QUIT;
*傳統方法;

**練習二: 同一次住院歸戶;
DATA stroke;
	SET dd.dd2000;
	WHERE "430"<=substr(ICD9CM_CODE, 1,3)<="436";
	KEY=ID||HOSP_ID||IN_DATE;
PROC SORT DATA=stroke;
	BY KEY;
DATA stroke_retain(KEEP=ID HOSP_ID IN_DATE OUT_DATE s_bed_day_s e_bed_day_s amt_s);
	SET stroke;
	BY KEY;
	RETAIN s_bed_day_s 0 e_bed_day_s 0 amt_s 0;
	IF FIRST.KEY THEN DO;
    s_bed_day_s=0; e_bed_day_s=0; amt_s=0;
	END;
    s_bed_day_s=s_bed_day_s+s_bed_day;
    e_bed_day_s=e_bed_day_s+e_bed_day; 
    amt_s=amt_s+MED_amt;
	IF LAST.KEY;
RUN;
DATA stroke_retain;
SET stroke_retain;
IF out_date=' ' THEN DELETE;
IF substr(in_date,1,4)<'2000' THEN DELETE;
RUN;


*利用SQL進行同一次住院歸戶;
PROC SQL;
CREATE TABLE stroke_retain AS
SELECT DISTINCT ID, HOSP_ID, IN_DATE, MAX(OUT_DATE) AS out_date_max,
                                 sum(e_bed_day, s_bed_day) as LOS,
                                 sum(MED_amt) as total_fee 
FROM DD.DD2000
WHERE "430"<=substr(ICD9CM_CODE, 1,3)<="436" and substr(IN_DATE, 1,4)>='2000'
GROUP BY ID, HOSP_ID, IN_DATE
HAVING out_date~=' ' ;
QUIT;
 
*答案跟上面語法相同了;



**SQL join;
*Selecting Data from More than One Table by Using Joins;

DATA one;
	INPUT X Y;
	DATALINES;
	1 2
	2 3
	;
RUN;
DATA two;
	INPUT X Z;
	DATALINES;
	2 5
	3 6
	4 9
	;
RUN;
PROC SQL;
	TITLE 'Table One and Table Two';
   	SELECT *
    FROM one, two;
QUIT;

*Inner joins;
PROC SQL;
	TITLE 'Table One and Table Two';
	SELECT * 
	FROM one, two
	WHERE one.x=two.x;
QUIT;
PROC SQL;
	TITLE 'Table One and Table Two';     
	SELECT * 
	FROM one AS a, two AS b
	WHERE a.x=b.x;
QUIT;


LIBNAME c'C:\Users\user\Downloads';

*進行門診檔與醫事機構基本檔合併;
*傳統方法;
PROC SORT DATA=c.HOSB2000 
    OUT=HOSB(KEEP=HOSP_ID HOSP_CONT_TYPE AREA_NO_H) NODUPKEY;
	BY HOSP_ID;
PROC SORT DATA=c.cd2000;
	BY HOSP_ID;
RUN;
DATA cd_hosb(rename=(AREA_NO_H=AREA));
	MERGE c.cd2000(IN=a) HOSB(IN=b);
	BY HOSP_ID;
	IF a=1 and b=1;
RUN;


*利用SQL
*首先需要先確認醫事機構基本檔是否為唯一家醫院;
*不需要先將資料排序 可以直接進行資料比對;
*可以一起決定要保留哪些變項;
*相同變項名稱可以直接改名;
PROC SQL;
CREATE TABLE cd_hosb AS
SELECT a.*, b.HOSP_CONT_TYPE, b.AREA_NO_H AS AREA
FROM c.cd2000 AS a, c.HOSB2000 AS b
WHERE a.HOSP_ID=b.HOSP_ID;
QUIT;


*健保資料清單醫令串檔;
*請練習DD2000及DO2000串檔;
*DO保留全部;
*DO只保留Order_code;
PROC SQL;
CREATE TABLE dd_do AS
SELECT a.*, b.Order_code 
FROM c.dd2000 AS a, c.do2000 AS b
WHERE a.FEE_YM=b.FEE_YM AND a.APPL_TYPE=b.APPL_TYPE
AND a.HOSP_ID=b.HOSP_ID AND a.APPL_DATE=b.APPL_DATE 
AND a.CASE_TYPE=b.CASE_TYPE AND a.SEQ_NO=b.SEQ_NO;
QUIT;

*擷取中風病患過去一年病史;
DATA stroke(KEEP=ID INDEX_stroke);
SET c.dd2001;
WHERE '430'<=substr(ICD9CM_CODE,1,3)<='436';
INDEX_stroke=INPUT(IN_DATE, YYMMDD8.);
FORMAT INDEX_stroke YYMMDD10.;
IF substr(IN_DATE,1,4)<'2001' or OUT_DATE=' ' THEN DELETE;
RUN;
PROC SORT DATA=stroke;
BY ID INDEX_stroke;
DATA stroke;
SET stroke;
BY ID;
IF FIRST.ID;
RUN;


DATA dd;
SET c.dd2000 c.dd2001;
IN_DATE1=INPUT(IN_DATE, YYMMDD8.);
FORMAT IN_DATE1 YYMMDD10.;
PROC SQL;
CREATE TABLE dd_history AS
SELECT a.*, b.ID as ID_history, b.IN_DATE1 as past_hospital_date
FROM stroke AS a, dd AS b
WHERE (a.ID=b.ID) and 
((a.INDEX_stroke>b.IN_DATE1) and (a.INDEX_stroke-b.IN_DATE1<365))
ORDER BY ID;
QUIT;
PROC SQL;
CREATE TABLE dd_history_id AS
SELECT DISTINCT ID, count(ID)
FROM dd_history
GROUP BY ID;
QUIT;

DATA stroke;
MERGE stroke (in=a) dd_history_id(in=b);
BY ID;
IF a;
IF b=1 then dd_history=1;else dd_history=0;
RUN;
PROC PRINT DATA=stroke;
RUN;
```
