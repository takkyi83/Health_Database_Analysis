```SAS
libname c "C:\...\sas檔";
*整理do檔;
data do2000_do2010
(keep= ORDER_CODE FEE_YM APPL_DATE HOSP_ID);
set  c.do2000-c.do2010;
run;
proc sort data=do2000_do2010 nodupkey out=do2000_do2010_id;
by HOSP_ID FEE_YM APPL_DATE;
run;  

*整理dd檔;
data dd2000_dd2010
(keep=ID ICD9CM_CODE FEE_YM APPL_DATE HOSP_ID IN_DATE);
set  c.dd2000-c.dd2010;
run;
proc sort data=dd2000_dd2010 nodupkey out=dd2000_dd2010_id;
by HOSP_ID FEE_YM APPL_DATE;
run; 

*do merge dd;
data do_dd;
merge do2000_do2010_id(in=a) dd2000_dd2010_id(in=b);
by HOSP_ID FEE_YM APPL_DATE;
if a;
run; *N=30442;

*找出產婦;
DATA do_dd_type;
	SET do_dd;
	if substr(ORDER_CODE,1,6) in('97009C ', '81004C', '81028C', '81005C','81029C','97014C' ) then type='1';
	if substr(ORDER_CODE,1,6) in('81017C','81018C','81019C','97004C','97005D','81024C','81025C','81026C','97934C','81034C') then type='0';
run;
data do_dd_type_only;
	SET do_dd_type;
	if type='' then delete;
	run; *n=2149 (只有生產的);
*if first id;
proc sort data=do_dd_type_only;
by id;
run;
DATA do_dd_type_first_id    do_dd_type_readmission;
SET do_dd_type_only;
BY ID;
IF FIRST.ID THEN OUTPUT do_dd_type_first_id; 
ELSE OUTPUT do_dd_type_readmission;
RUN; *n=1778(第一次生產);

*整理cd檔;
data cd2000_cd2010 (keep= ID ACODE_ICD9_1 ACODE_ICD9_2 ACODE_ICD9_3 FEE_YM APPL_DATE HOSP_ID ID_BIRTHDAY FUNC_DATE);
set  c.cd2000-c.cd2010;
run;
proc sort data=cd2000_cd2010 ;
by  ID ACODE_ICD9_1 ACODE_ICD9_2 ACODE_ICD9_3 FEE_YM APPL_DATE HOSP_ID ID_BIRTHDAY;
run;

*篩選精神官能性憂鬱症  人次=243837;
DATA depression;
	SET cd2000_cd2010;
	where substr(ACODE_ICD9_1,1,3)='300' or
         substr(ACODE_ICD9_2,1,3)='300' or
         substr(ACODE_ICD9_3,1,3)='300' ;
	run;
*憂鬱症人數=20066;
proc sort data=depression nodupkey out=depression_id;
by id;
run;

*合併 depression&do_dd;
data do_dd_depression;
merge depression_id(in=a) do_dd_type_first_id(in=b);
by id;
if a=1 then dep='1';
else dep='0';
run; *n=21449 ; 
*去除憂鬱患者中無生產的人;
data do_dd_depression;
set do_dd_depression;
if substr(type,1,1)='' then delete;
run; *n=1778;

***if b 不一樣的做法;
data do_dd_depression1;
merge depression_id(in=a) do_dd_type_first_id(in=b);
by id;
if  b;
run; *n=1778;
***

*los為負值代表產前就有憂鬱，正值為產後才憂鬱;
*注意一直都沒憂鬱症的為空值，要如何修正?;
DATA bf_birth;
SET do_dd_depression;
	in_date1=INPUT(IN_DATE, YYMMDD10.);
	func_date1=INPUT(FUNC_DATE, YYMMDD10.);
	FORMAT in_date1 func_date1 YYMMDD10.;
RUN;
data bf_birth;
set bf_birth;
los = intck('day', in_date1, func_date1);
run;

data final;
set bf_birth;
keep id type dep in_date1 func_date1 los;
run;

proc freq data=final;
table type*dep;
run;

*los總共有1338，扣除負值(135)，剩下(1203)才是研究所要看的樣本數!!! (從freq看);
proc freq data=final;
table los;
run;


***想刪掉負值，no result..qq;
data final2;
set final;
if '0'<=substr(los,1,8) *'1' <='100000' 
then delete;
run;
***

*看結果freq univariate;
proc logistic data=do_dd_depression descending;
  class rank / param=ref ;
  model admit = gre gpa rank;
run;
```
