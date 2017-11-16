/* **********************************
 * Example9 revisited in proc sql
 * **********************************
 */


libname mydata '../data/';

proc sql;
  
  /* Compute mean and std of kwh for each region */
  create table meanstats as
    select regionc as region, mean(kwh) as mean_kwh, std(kwh) as std_kwh
      from mydata.recs2009_public_v4
      where typehuq = 2
      group by regionc; 

  /* Extract homes above 1 std */
  create table high_kwh as
    select r.doeid as doeid, m.region as region, r.kwh as kwh, 
    	   m.mean_kwh as mean_kwh, m.std_kwh as std_kwh
      from mydata.recs2009_public_v4 r
      inner join meanstats m
      on r.regionc = m.region
      where typehuq = 2
      having r.kwh ge (m.mean_kwh + m.std_kwh);

  /* Create counts */
  create table pct_high as
    select h.region, h.n_high as high, t.n_total as total,
    	    (100*h.n_high/t.n_total) as pct_high
      from (select region, count(doeid) as n_high
              from high_kwh
	      group by region
	   ) h
      inner join
           (select regionc as region, count(doeid) as n_total
	      from mydata.recs2009_public_v4
	      where typehuq = 2
	      group by regionc
            ) t
     on  h.region = t.region;

  quit;


proc print data=pct_high;
  format pct_high 4.1;

run;