/*****************************************************
An example SAS program for Stats 506.

This file imports RECS data from:
 ./data/recs2009_public.csv
 http://www.eia.gov/consumption/residential/data/2009/index.cfm?view=microdata

Then prints some basic information about the file.

Author: James Henderson, PhD (jbhender@umich.edu)
Date: Nov 13, 2017
 *****************************************************
*/

/* import delimited data */
proc import datafile='./data/recs2009_public.csv' out=recs;

/* print the first 5 rows for a few variales */
proc print data=recs(obs=5);      /* (obs=5) is an 'option' */
    var DOEID NWEIGHT REGIONC;    /* This is a 'statement'  */

/* get some basic information about the imported data */
proc contents data=recs;

run;

