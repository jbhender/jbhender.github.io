/* Problem Set 4, Question 1
 * Stats 506, Fall 2017
 *
 * Use mixed models to investigate the relationship
 * between age and hearing loss using NHANES audiometry
 * data:
 *  Audiometry: AUX_D.XPT - 
 *  Demographcis: DEMO_D.XPT -
 */

 libname mylib './data/';

 /* (a) Read and merge data. 
  *     I also do part of (b) here.
  */
 libname demod xport './data/DEMO_D.XPT';
 libname auxd  xport './data/AUX_D.XPT'; 

 data nhanes;
  merge demod.DEMO_D auxd.AUX_D;
   by seqn; 
   keep seqn riagendr ridageyr auxu:;
   drop auxu1k2:;
   if auxu1k1r = . then delete;
 

 /* (b) Reshape to long format. 
  *  The approach used here is:
  *   1. separate demographics & AUXU*
  *   2. convert AUXU* to long
  *   3. Merge demographics back in.   
  */

 data nhanes_demo;
   set nhanes(rename=(riagendr=gender ridageyr=age));
     keep seqn gender age;

  data nhanes_aux;
    set nhanes(rename=(AUXU1K1R=AUXU1KR AUXU1K1L=AUXU1KL));
    keep seqn auxu:; 
 
 /* drop additional missing values 888 or 666 */

 proc transpose data=nhanes_aux out=aux_long;
    by seqn; 
    var auxu:;  
  run;

 data nhanes_long; 
    merge aux_long(drop=_LABEL_ rename=(_NAME_=test col1=thresh))
    	  nhanes_demo;
    by seqn;

    ear = 'right'; 
    if prxmatch("/L/",test) then ear = 'left'; 
    right = 1;
    if ear = 'left' then right=0; 

    freq = prxchange('s/AUXU(.)K(.)/$1/', 1, test); 
    if prxmatch("/U500/", test) then freq='5'; 
    fr = input(freq, 1.);
    if fr ne 5 then fr=10*fr; 
    drop freq; 

    if thresh = 888 then delete;
    if thresh = 666 then delete;

    older = 0;
    if age ge 25 then older=1; 
    older_age = age*older; 

    female = 1;
    if gender = 1 then female = 0; 

* proc print data=nhanes_long(obs=12);
  proc export data=nhanes_long
    outfile = '~/nhanes_long.csv'
    dbms=dlm replace;
    delimiter = ',';
  run; 

/* (c) For 1000KH & Right Ear is:
 *     i. Interaction between older and gender? 
 *   
 */
  data nhanes_1kr; 
    set nhanes_long;
    older_female = older*female;
    where ear='right' & fr=10;

/* i. Interaction between older and gender?  */
 proc reg data=nhanes_1kr outest=sum_1kr
          rsquare;
   model thresh = older female older_female; 
 
 proc print data=sum_1kr; 

/* ii. 
 */
 data nhanes_1kr_ii;
   set nhanes_1kr;
   group_age = age - 12;
   if older = 1 then group_age = age - 70; 

  proc reg data=nhanes_1kr_ii outest=sum_1kr_ii rsquare; 
     model thresh = older female group_age; 

  proc print data = sum_1kr_ii; 
 
/* iii. 
 */

  data nhanes_1kr_iii;
   set nhanes_1kr_ii;
   older_age = older*group_age;

  proc reg data=nhanes_1kr_iii outest=sum_1kr_iii rsquare;
     model thresh = older group_age older_age female;  

  proc print data = sum_1kr_iii; 


/* (d) Answer questions i-iii using proc mixed
 *     for all of the data. 
 */ 

 /* add derived variables to full data */
 data nhanes_d;
  set nhanes_long;
   older_female = older*female;
   group_age = age - 12;
   if older = 1 then group_age = age - 70;


 /* after sorting on SEQN we can use it as
  * continuous in specifying random effects
  */

  proc sort data=nhanes_d out=nd_sorted; 
    by seqn ear; 

 /* i.
  * Here and throughout we set "method=REML" for estimation.
  */ 

 proc mixed data=nd_sorted method=REML noclprint;
    class ear;
    model thresh = fr older female older_female /
    	  s cl;   
    random intercept ear / subject=seqn;

 run;

 /* ii. */
  proc mixed data=nd_sorted method=REML noclprint;
    class ear;
    model thresh = fr older female group_age / 
    	  s cl;
    random intercept ear / subject=seqn;

 run;

 /* iii. */
proc mixed data=nd_sorted method=REML noclprint;
    class ear;
    model thresh = fr older female group_age older_age / 
      s cl;
    random intercept ear / subject=seqn;

 run; 