```SAS
libname c 'C:\Users\...\期末';
*1.上呼吸道感染;
data cd2001_cd2010
(keep=FEE_YM HOSP_ID APPL_DATE FUNC_DATE ID_BIRTHDAY ID PART_NO ACODE_ICD9_1 ACODE_ICD9_2 ACODE_ICD9_3 ID_SEX);
set c.cd2001-c.cd2010; 
IF FUNC_DATE=' ' THEN DELETE;
IF substr(FUNC_DATE,1,4)<'2001' THEN DELETE;
run;

data cd2001_cd2010;
set cd2001_cd2010;
where '460'<=substr(ACODE_ICD9_1,1,3)<='465' or
		  '460'<=substr(ACODE_ICD9_2,1,3)<='465' or
		  '460'<=substr(ACODE_ICD9_3,1,3)<='465' ;
run; *n=3189782;

data cd2001_cd2010;
set cd2001_cd2010;
year=substr(FUNC_DATE,1,4);
run;

data cd2001_cd2010;
set cd2001_cd2010;
person_time='1';
run;

*2.描述上呼吸道感染就醫人次不同就醫年度之變化 長條圖請見WORD檔;
proc freq data=cd2001_cd2010;
   tables year*person_time;
run; 

*3.連結hosb2000;
proc sort data=cd2001_cd2010;
by hosp_id;
run;
proc sort data=c.hosb2000;
by hosp_id;
run;
data cd2001_cd2010_hosb;
merge cd2001_cd2010(in=a) c.hosb2000(in=b);
by hosp_id;
if a=1 and b=1;
run; * N=2472677;

*4.就醫地點分類 ;
data cd2001_cd2010_hosb;
set cd2001_cd2010_hosb;
IF HOSP_CONT_TYPE=1 then type1=1;
else type1=0;
run;

DATA  cd2001_cd2010_hosb;
SET  cd2001_cd2010_hosb;
IF HOSP_CONT_TYPE=2 THEN type2=1;
else type2 =0;
RUN;

DATA  cd2001_cd2010_hosb;
SET  cd2001_cd2010_hosb;
IF HOSP_CONT_TYPE=3 THEN type3=1;
else type3 =0;
RUN;

DATA  cd2001_cd2010_hosb;
SET  cd2001_cd2010_hosb;
IF HOSP_CONT_TYPE=4 THEN type4=1;
else type4 =0;
RUN;

*描述不同醫院層級與不同年度之上呼吸道感染就醫人次及比例變化情形 長條圖請見WORD檔;
proc freq data=cd2001_cd2010_hosb;
   tables year*type1;
run; 
proc freq data=cd2001_cd2010_hosb;
   tables year*type2;
run; 
proc freq data=cd2001_cd2010_hosb;
   tables year*type3;
run; 
proc freq data=cd2001_cd2010_hosb;
   tables year*type4;
run; 


* 5. 每位病患分別至各層級醫療機構就醫之次數;
proc sort data=cd2001_cd2010_hosb;
by id;
run;
DATA cd2001_cd2010_hosb_type;
	SET cd2001_cd2010_hosb;
	retain type1sum;
	BY ID;
	IF FIRST.ID THEN type1sum=0;
	type1sum=type1sum+type1;
	IF LAST.ID;
RUN; 

proc sort data=cd2001_cd2010_hosb_type;
by id;
run;
DATA cd2001_cd2010_hosb_type;
	SET cd2001_cd2010_hosb_type;
	retain type2sum;
	BY ID;
	IF FIRST.ID THEN type2sum=0;
	type2sum=type2sum+type2;
	IF LAST.ID;
RUN; 

proc sort data=cd2001_cd2010_hosb_type;
by id;
run;
DATA cd2001_cd2010_hosb_type;
	SET cd2001_cd2010_hosb_type;
	retain type3sum;
	BY ID;
	IF FIRST.ID THEN type3sum=0;
	type3sum=type3sum+type3;
	IF LAST.ID;
RUN; 

proc sort data=cd2001_cd2010_hosb_type;
by id;
run;
DATA cd2001_cd2010_hosb_type;
	SET cd2001_cd2010_hosb_type;
	retain type4sum;
	BY ID;
	IF FIRST.ID THEN type4sum=0;
	type4sum=type4sum+type4;
	IF LAST.ID;
RUN; 

*每位病患上呼道感染就醫總次數;
DATA cd2001_cd2010_hosb_id;
	SET cd2001_cd2010_hosb_type;
idSum= type1sum+type2sum+type3sum+type4sum;
run; *n= 91956;

*6.經常性至高層級醫療機構(醫學中心及區域醫院)就醫人口;
DATA cd2001_cd2010_hosb_id;
	SET cd2001_cd2010_hosb_id;
type12sum= type1sum+type2sum;
run; 

DATA cd2001_cd2010_hosb_id_type12Freq;
	SET cd2001_cd2010_hosb_id;
if type12sum/idsum >0.5 than type12Freq=1;
else type12Freq=0;
run;

proc freq data = cd2001_cd2010_hosb_id_type12Freq;
tables type12Freq;
run;
*非經常性樣本數 77551;
*經常性樣本數 14405;

*7. 	進一步與ID檔進行比對，排除沒有ID的個案;
data id2010
(keep=ID);
set c.id2010;
run;

proc sort data=cd2001_cd2010_hosb_id_type12Freq;
by id;
run;
proc sort data=id2010;
by id;
run;
data cd_id;
merge cd2001_cd2010_hosb_id_type12Freq(in=a) id2010(in=b);
by id;
if a=1 and b=1;
run; *排除沒有ID的個案後n=91956;

*8. 請完成以下表格;
*經常性高層級醫院病患平均年齡(SD) ;
data cd_id_1;
set cd_id;
if type12Freq =1;
run;

data cd_id_1;
set cd_id_1;
age = 2009 - substr(ID_BIRTHDAY,1,4);
proc means data = cd_id_1;
var age;
run;

*非經常性高層級醫院病患平均年齡(SD) ;
data cd_id_0;
set cd_id;
if type12Freq =0;
run;

data cd_id_0;
set cd_id_0;
age = 2009 - substr(ID_BIRTHDAY,1,4);
proc means data = cd_id_0;
var age;
run;

*年齡分組  經常性高層級醫院;
data cd_id_1_age_count;
set cd_id_1;
if 2009 - substr(ID_BIRTHDAY,1,4) <=19 then age0_19 = 1;
else age0_19 =0;
if 20<=2009 - substr(ID_BIRTHDAY,1,4) <=39 then age20_39 = 1;
else age20_39 =0;
if 40<=2009 - substr(ID_BIRTHDAY,1,4) <=59 then age40_59 = 1;
else age40_59 =0;
if 60<=2009 - substr(ID_BIRTHDAY,1,4) <=79 then age60_79 = 1;
else age60_79 =0;
if 80<=2009 - substr(ID_BIRTHDAY,1,4)  then age80 = 1;
else age80 =0;
run;

proc freq data = cd_id_1_age_count;
tables age0_19;
tables age20_39;
tables age40_59;
tables age60_79;
tables age80;
run;

*年齡分組 非經常性高層級醫院;
data cd_id_0_age_count;
set cd_id_0;
if 2009 - substr(ID_BIRTHDAY,1,4) <=19 then age20_19_0 = 1;
else age0_19_0 =0;
if 20<=2009 - substr(ID_BIRTHDAY,1,4) <=39 then age20_39_0 = 1;
else age20_39_0 =0;
if 40<=2009 - substr(ID_BIRTHDAY,1,4) <=59 then age40_59_0 = 1;
else age40_59_0 =0;
if 60<=2009 - substr(ID_BIRTHDAY,1,4) <=79 then age60_79_0 = 1;
else age60_79_0 =0;
if 80<=2009 - substr(ID_BIRTHDAY,1,4)  then age80_0 = 1;
else age80_0 =0;
run;

proc freq data = cd_id_0_age_count;
tables age0_19_0;
tables age20_39_0;
tables age40_59_0;
tables age60_79_0;
tables age80_0;
run;

*性別  經常性高層級醫院;
proc freq data =cd_id_1;
tables ID_SEX;
RUN;

*性別  非經常性高層級醫院;
proc freq data =cd_id_0;
tables ID_SEX;
RUN;

*過去疾病史;
*上呼吸道感染(ICD-9:460-465);
data cd2001_cd2010_uri;
set cd2001_cd2010;
where '460'<=substr(ACODE_ICD9_1,1,3)<='465' or
		  '460'<=substr(ACODE_ICD9_2,1,3)<='465' or
		  '460'<=substr(ACODE_ICD9_3,1,3)<='465' ;
run; *n=3189782;

*高血壓(ICD-9:401-405);
data cd2001_cd2010_htn;
set cd2001_cd2010;
where '401'<=substr(ACODE_ICD9_1,1,3)<='405' or
		  '401'<=substr(ACODE_ICD9_2,1,3)<='405' or
		  '401'<=substr(ACODE_ICD9_3,1,3)<='405' ;
run; *n=832957;

*merge 上呼吸道和高血壓;
proc sort data =cd2001_cd2010_uri;
by id;
run;
proc sort data=cd2001_cd2010_htn;
by id;
run;

data uri_htm;
merge cd2001_cd2010_uri(in=a) cd2001_cd2010_htn(in=b);
by id;
if a=1 and  b=1;
run; * 1105440;

*一年內三次門診至少要lag2;
DATA uri_htm_lag;
SET uri_htm;
FUNC_DATE1=INPUT(FUNC_DATE, YYMMDD8.);
FORMAT FUNC_DATE1 YYMMDD10.;
PROC SORT DATA=uri_htm_lag;
BY ID FUNC_DATE1;
RUN;

DATA uri_htm_lag;
SET uri_htm_lag;
BY ID FUNC_DATE1;
lag_ID=lag2(ID);
lag_FUNC_DATE1=lag2(FUNC_DATE1);
FORMAT lag_FUNC_DATE1 YYMMDD10.;
IF lag_ID~=ID THEN DO;
lag_ID=.;lag_FUNC_DATE1=.;
END;
IF FUNC_DATE1-lag_FUNC_DATE1<=365;
RUN;

*每一個只需要留第一筆資料;
DATA uri_htm_new;
SET uri_htm_lag;
BY ID;
IF FIRST.ID;
RUN; *n=18824;

*有高血壓病史，經常性至高層級醫院;
proc sort data=uri_htm_new;
by id;
run;
proc sort data=cd_id_1;
by id;
run;

data uri_htm_new_1;
merge uri_htm_new(in=a) cd_id_1(in=b);
by id;
if a=1 and b=1;
run; *n=3050;

*有高血壓病史，非經常性至高層級醫院;
proc sort data=uri_htm_new;
by id;
run;
proc sort data=cd_id_0;
by id;
run;
data uri_htm_new_0;
merge uri_htm_new(in=a) cd_id_0(in=b);
by id;
if a=1 and b=1;
run; *n=15406;

*高血脂(ICD-9:272);
data hc;
set cd2001_cd2010;
where substr(ACODE_ICD9_1,1,3)='272' or
		  substr(ACODE_ICD9_2,1,3)='272' or
		  substr(ACODE_ICD9_3,1,3)='272' ;
run; *n= 314745;

*merge 上呼吸道和高血脂;
proc sort data =cd2001_cd2010_uri;
by id;
run;
proc sort data=hc;
by id;
run;
data uri_hc;
merge cd2001_cd2010_uri(in=a) hc(in=b);
by id;
if a=1 and  b=1;
run; *  732725;

*一年內三次門診至少要lag2;
DATA uri_hc_lag;
SET uri_hc;
FUNC_DATE1=INPUT(FUNC_DATE, YYMMDD8.);
FORMAT FUNC_DATE1 YYMMDD10.;
PROC SORT DATA=uri_hc_lag;
BY ID FUNC_DATE1;
RUN;

DATA uri_hc_lag;
SET uri_hc_lag;
BY ID FUNC_DATE1;
lag_ID=lag2(ID);
lag_FUNC_DATE1=lag2(FUNC_DATE1);
FORMAT lag_FUNC_DATE1 YYMMDD10.;
IF lag_ID~=ID THEN DO;
lag_ID=.;lag_FUNC_DATE1=.;
END;
IF FUNC_DATE1-lag_FUNC_DATE1<=365;
RUN;

*每一個只需要留第一筆資料;
DATA uri_hc_new;
SET uri_hc_lag;
BY ID;
IF FIRST.ID;
RUN; *17553;

*有高血脂病史，經常性至高層級醫院;
proc sort data=uri_hc_new;
by id;
run;
proc sort data=cd_id_1;
by id;
run;
data uri_hc_new_1;
merge uri_hc_new(in=a) cd_id_1(in=b);
by id;
if a=1 and b=1;
run; *n=2781;

*有高血脂病史，非經常性至高層級醫院;
proc sort data=uri_hc_new;
by id;
run;
proc sort data=cd_id_0;
by id;
run;
data uri_hc_new_0;
merge uri_hc_new(in=a) cd_id_0(in=b);
by id;
if a=1 and b=1;
run; *n=14499;

*糖尿病(ICD-9:250-251);
data dm;
set cd2001_cd2010;
where '250'<=substr(ACODE_ICD9_1,1,3)='251' or
	      '250'<=substr(ACODE_ICD9_2,1,3)='251' or
	      '250'<=substr(ACODE_ICD9_3,1,3)='251' ;
run; *n= 1479;

*merge 上呼吸道和糖尿病;
proc sort data =cd2001_cd2010_uri;
by id;
run;
proc sort data=dm;
by id;
run;
data uri_dm;
merge cd2001_cd2010_uri(in=a) dm(in=b);
by id;
if a=1 and  b=1;
run; *  22260;

*一年內三次門診至少要lag2;
DATA uri_dm_lag;
SET uri_dm;
FUNC_DATE1=INPUT(FUNC_DATE, YYMMDD8.);
FORMAT FUNC_DATE1 YYMMDD10.;
PROC SORT DATA=uri_dm_lag;
BY ID FUNC_DATE1;
RUN;

DATA uri_dm_lag;
SET uri_dm_lag;
BY ID FUNC_DATE1;
lag_ID=lag2(ID);
lag_FUNC_DATE1=lag2(FUNC_DATE1);
FORMAT lag_FUNC_DATE1 YYMMDD10.;
IF lag_ID~=ID THEN DO;
lag_ID=.;lag_FUNC_DATE1=.;
END;
IF FUNC_DATE1-lag_FUNC_DATE1<=365;
RUN;

*每一個只需要留第一筆資料;
DATA uri_dm_new;
SET uri_dm_lag;
BY ID;
IF FIRST.ID;
RUN; *605;

*有糖尿病病史，經常性至高層級醫院;
proc sort data=uri_dm_new;
by id;
run;
proc sort data=cd_id_1;
by id;
run;
data uri_dm_new_1;
merge uri_dm_new(in=a) cd_id_1(in=b);
by id;
if a=1 and b=1;
run; *n=104;

*有糖尿病病史，非經常性至高層級醫院;
proc sort data=uri_dm_new;
by id;
run;
proc sort data=cd_id_0;
by id;
run;
data uri_dm_new_0;
merge uri_dm_new(in=a) cd_id_0(in=b);
by id;
if a=1 and b=1;
run; *n=494;

*過去是否曾經住院;
data dd
(keep= ID IN_DATE OUT_DATE PART_MARK);
set c.dd2001-c.dd2010;
IF out_date=' ' THEN DELETE;
IF substr(in_date,1,4)<'2001' THEN DELETE;
run;

proc sort data=dd nodupkey out = dd_uni;
by id;
run; *2001-2010住院人數=37947;

*過去曾經住院，經常性高層級醫院;
proc sort data=dd_uni;
by id;
run;
proc sort data=cd_id_1;
by id;
run;
data dd_uni_1;
merge dd_uni (in=a) cd_id_1(in=b);
by id;
if a=1 and b=1;
run; *n=7555;

*過去曾經住院，非經常性高層級醫院;
proc sort data=dd_uni;
by id;
run;
proc sort data=cd_id_0;
by id;
run;
data dd_uni_0;
merge dd_uni (in=a) cd_id_0(in=b);
by id;
if a=1 and b=1;
run; *n=28627;

*是否有重大傷病(PART_NO);
data injury;
set cd2001_cd2010;
if substr(PART_NO, 1, 3)='001' then injury=1;
else injury=0;
run;

proc freq DATA=injury;
tables injury;
RUN; *無重大傷病n=13263210 有重大傷病n=278721;

*有重大傷病，經常性高層級醫院;
data injury_1;
set injury;
if injury=1;
run;

proc sort data=injury_1 nodupkey out =injury_1;
by id;
run; 

proc sort injury_1;
by ID;
run;
proc sort cd_id_1;
by ID;
run;
data injury_1_merge;
merge injury_1  (in=a) cd_id_1(in=b);
by id;
if a=1 and b=1;
run;

proc freq data=injury_1_merge;
tables injury;
run; *n=1106;

*有重大傷病，非經常性高層級醫院;
proc sort cd_id_0;
by ID;
run;

data injury_0_merge;
merge injury_1  (in=a) cd_id_0(in=b);
by id;
if a=1 and b=1;
run;

proc freq data=injury_0_merge;
tables injury;
run; *n= 3293;


*社經地位指標;
data id
(keep= INS_AMT UNIT_INS_TYPE ID);
set c.id2010;
run;

*投保金額(INS_AMT)分群;
proc contents data = id VARNUM; *INS_AMT為數字變項;
run;

data id_AMT_0;
set id;
if INS_AMT = '0' then AMT_0 = 1;
else delete;
run;

data id_AMT_1_20K;
set id;
if 1<=INS_AMT<=19999 then AMT_1_20K = 1;
else delete;
run;

data id_AMT_20K_40K;
set id;
if 20000<=INS_AMT<=39999 then AMT_20K_40K = 1;
else delete;
run;

data id_AMT_40K;
set id;
if 40000<=INS_AMT then AMT_40K = 1;
else delete;
run;

*各個投保金額，經常性高層級醫院;
proc sort data= id_AMT_0;
by id;
proc sort data= id_AMT_1_20K;
by id;
proc sort data= id_AMT_20K_40K;
by id;
proc sort data=id_AMT_40K;
by id;
run;
proc sort data = cd_id_1;
by id;
proc sort data=cd_id_0;
by id;
run;

data AMT0_merge;
merge id_AMT_0 (in=a) cd_id_1(in=b);
by id;
if a=1 and b=1;
run; *n=7226;

data AMT_1_20K_merge;
merge id_AMT_1_20K(in=a) cd_id_1(in=b);
by id;
if a=1 and b=1;
run; *n=2448;

data AMT_20K_40K_merge;
merge id_AMT_20K_40K(in=a) cd_id_1(in=b);
by id;
if a=1 and b=1;
run; *n=3078;

data AMT_40K_merge;
merge id_AMT_40K(in=a) cd_id_1(in=b);
by id;
if a=1 and b=1;
run; *n=1653;

*各個投保金額，非經常性高層級醫院;
data AMT0_merge;
merge id_AMT_0 (in=a) cd_id_0(in=b);
by id;
if a=1 and b=1;
run; *投保金額0 n=26923;

data AMT_1_20K_merge;
merge id_AMT_1_20K(in=a) cd_id_0(in=b);
by id;
if a=1 and b=1;
run; *投保金額1~19999 n=15193;

data AMT_20K_40K_merge;
merge id_AMT_20K_40K(in=a) cd_id_0(in=b);
by id;
if a=1 and b=1;
run; *投保金額20000~39999 n=25469;

data AMT_40K_merge;
merge id_AMT_40K(in=a) cd_id_0(in=b);
by id;
if a=1 and b=1;
run; *投保金額 >=40000 n=9966;

*各個保險所屬單位(UNIT_INS_TYPE);
data id_11_15;
set id;
where '11'<=substr(UNIT_INS_TYPE, 1, 2)<='15';
run;

data id_21_32;
set id;
where '21'<=substr(UNIT_INS_TYPE, 1, 2)<='32';
run;

data id_51_52;
set id;
where '51'<=substr(UNIT_INS_TYPE, 1, 2)<='52';
run;

data id_61;
set id;
where substr(UNIT_INS_TYPE, 1, 2)<='61';
run;

data id_62;
set id;
where substr(UNIT_INS_TYPE, 1, 2)<='62';
run;

proc sort data= id_11_15;
by id;
proc sort data= id_21_32;
by id;
proc sort data =id_51_52;
by id;
proc sort data= id_61;
by id;
proc sort data =id_62;
by id;
proc sort data = cd_id_1;
by id;
proc sort data=cd_id_0;
by id;
run;

*各個保險所屬單位(UNIT_INS_TYPE)，經常性高層級醫院;
data id_11_15_merge;
merge id_11_15(in=a) cd_id_1(in=b);
by id;
if a=1 and b=1;
run; *白領階級(11-15) n=3538;

data id_21_32_merge;
merge id_21_32(in=a) cd_id_1(in=b);
by id;
if a=1 and b=1;
run; *公、農、水利及漁會成員(21-32) n=1887;

data id_51_52_merge;
merge id_51_52(in=a) cd_id_1(in=b);
by id;
if a=1 and b=1;
run; *低收入戶(51-52) n=234;

data  id_61_merge;
merge  id_61(in=a) cd_id_1(in=b);
by id;
if a=1 and b=1;
run; *榮民榮眷(61) n=13362;

data  id_62__merge;
merge  id_62(in=a) cd_id_1(in=b);
by id;
if a=1 and b=1;
run; *一般地區人口(62) n=14408;

*各個保險所屬單位(UNIT_INS_TYPE)，非經常性高層級醫院;
data id_11_15_merge;
merge id_11_15(in=a) cd_id_0(in=b);
by id;
if a=1 and b=1;
run; *白領階級(11-15) n=26035;

data id_21_32_merge;
merge id_21_32(in=a) cd_id_0(in=b);
by id;
if a=1 and b=1;
run; *公、農、水利及漁會成員(21-32) n=15943;

data id_51_52_merge;
merge id_51_52(in=a) cd_id_0(in=b);
by id;
if a=1 and b=1;
run; *低收入戶(51-52) n=922;

data  id_61_merge;
merge  id_61(in=a) cd_id_0(in=b);
by id;
if a=1 and b=1;
run; *榮民榮眷(61) n=70886;

data  id_62_merge;
merge  id_62(in=a) cd_id_0(in=b);
by id;
if a=1 and b=1;
run; *一般地區人口(62) n=77551;
```
