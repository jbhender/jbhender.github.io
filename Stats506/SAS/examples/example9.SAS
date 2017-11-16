/* An example of "data step programming" for Stats 506.
 *
 * This analysis finds the % of single family homes 
 * more than 1 sd above average in terms of electrical
 * usage. This is done by Census Region.
 *
 * Date: Nov 15, 2017
 */

libname mydata '../data/';

/* read full data and subset to single family homes */
data recs1;
    set mydata.recs2009_public_v4;
    if typehuq = 2;
    keep doeid regionc kwh;

/* Sort and then compute summary statistics */
proc sort data=recs1 out=recs2;
    by regionc;

proc summary;
    class regionc;
    output out=meanstats1
        mean(kwh) = mean_kwh
        std(kwh) = std_kwh;

proc sort data=meanstats1 out=meanstats2;
    by regionc;

/* "Remerge" summary stats into sorted recs data */
data recs3;
    merge recs2 meanstats2(keep=regionc mean_kwh std_kwh);
    by regionc;

/* Filter homes 1 sd above mean kwh*/
data recs4;
    set recs3;
    high_kwh = mean_kwh + std_kwh;
    if kwh ge high_kwh;

/* Number above thresholds */
proc summary;           /* Note: data is implicitly recs4 */
    class regionc;
    output out=high_kwh;

proc sort data=high_kwh out=high_kwh2;
  by regionc;

/* Total number */
proc summary data=recs3;
  class regionc;
  output out=all_kwh;

data all_kwh2;
  set all_kwh;
  if _TYPE_ = 0 then delete; 
  N = _FREQ_;
  keep regionc N;

proc sort data=all_kwh2 out=all_kwh3;
  by regionc;
  
/* Merge together */
data pct_tab;
  merge all_kwh3 high_kwh2;
  by regionc;
  if _TYPE_ = 0 then delete;
  high = _FREQ_;
  pct = 100*high / N;
  keep regionc high N pct; 
 
proc print data=pct_tab;
  format pct 4.1;

run; 