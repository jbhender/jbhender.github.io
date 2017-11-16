/* Compute the percent of wood shingled roofs by state 
 * using PROC SQL and the RECS data.
 *
 * Author: James Henderson (jbhender@umich.edu)
 * Date: Nov 15, 2017
 */ 

libname mylib '../data/';

proc sql;

  /* Count total homes by state */
  create table total as
    select sum(nweight) as n_total, reportable_domain
      from mylib.recs2009_public_v4
      where rooftype > 0
      group by reportable_domain;

  /* Count wood shingle roofs by state */
  create table wood_roof as
    select sum(nweight) as n_wood, reportable_domain
      from mylib.recs2009_public_v4
      where rooftype=2
      group by reportable_domain;

  /* Join these two tables */
  create table wood_roof_pct as
    select t.reportable_domain as state, n_wood, n_total, 100*n_wood/n_total as percent_wood
      from total t
      inner join wood_roof w
      on t.reportable_domain=w.reportable_domain
    order by -percent_wood;

  quit;

/* Print the result */
proc print data=wood_roof_pct;
  var state percent_wood;
  format percent_wood 4.1;

run;