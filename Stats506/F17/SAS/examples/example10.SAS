/* Professor Shedden's Example of using PROC SQL.
 *
 * This script finds all single family homes with 
 * "heating degree days" above 2000.
 *
 * Date: Nov 15, 2017
 */
libname mydata '../data';

proc sql;

    create table recs as
        select doeid, reportable_domain, mean(hdd65) as mean_hdd65, cufeetng
        from mydata.recs2009_public_v4
        where typehuq = 2
        group by reportable_domain
        having mean(hdd65) ge 2000;
    quit;

proc print data=recs;

run;

/* Question: How would you modify this script to 
   return only a single row per reportable_domain ?
 */