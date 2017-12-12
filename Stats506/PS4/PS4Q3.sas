/* Solution to problem set 4, question 3 for
 * Stats 506, Fall 2017.
 * 
 * See header for './read_data.sas' for information
 * on data source and part a.
 *
 * See: http://dept.stat.lsa.umich.edu/~kshedden/Courses/Stat506/ps4/
 * for solutions using R's data.table package.
 *
 * Author: James Henderson (jbhender@umich.edu)
 * Date: Nov 30, 2017
 */ 

libname mylib './data/';

/************************************************************ 
 * b: Create totpay 
 ************************************************************ 
 */

data da; 
  set mylib.medicare_ps_puf_2014;
  totpay = line_srvc_cnt*average_medicare_payment_amt;

/************************************************************
 * c (i): Highest average cost for all services and 
 * for services performed more than 100,000 times.
 ************************************************************     
 */

proc sql; 
 create table dax as
   select sum(totpay) as s, sum(line_srvc_cnt) as n, sum(totpay)/sum(line_srvc_cnt) as avg,
   	  hcpcs_code as hcpcs, min(hcpcs_description) as service
   from da
   group by hcpcs_code
   order by -avg;

 create table daz as
   select *
   from dax
   where n > 1e5;

quit;

/* Highest avg cost */
proc print data=dax(obs=1);

/* Highest avg cost among services with n > 1e5 */
proc print data=daz(obs=1);  

/************************************************************  
 * c (ii): Among individual providers ...
 *         - What are the top 10 provider types by frequency
 *             among providers charging more than 1e6 dollars?
 * 	   - What provider types have the two highest and two
 * 	     lowest avg charges per provider.
 ************************************************************  
 */

 proc sql;

  /* Limit the data to individual providers and summarize */ 
  create table dai as
    select npi, sum(totpay) as s, min(provider_type) as type
      from da
     where nppes_entity_code = "I"
    group by npi;

  /* Two ways to obtain frequencies by provider type */
  create table high_cost_freq as 
    select freq(type) as n, type
      from dai
      where s > 1e6
      group by type
     order by -n;

  create table hcf as
    select count(npi) as n, type
      from dai
     where s > 1e6
     group by type
     order by -n; 

  /* Table for average total payments per providers by type */
  create table prov_avg as
    select avg(s) as avg, type
      from dai
    group by type
    order by -avg; 

 quit;

proc print data=high_cost_freq(obs=10);


/* Print the 10 most frequent provider types */
proc print data=high_cost_freq(obs=10);
proc print data=hcf(obs=10);

/* Print two most and least frequent provider types*/ 
proc print data=prov_avg(obs=2);

data low_prov_avg;
  set prov_avg nobs=nobs;
  if _n_ ge (nobs-2);

proc print data=low_prov_avg(obs=2);

run; 