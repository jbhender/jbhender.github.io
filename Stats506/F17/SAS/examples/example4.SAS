/*****************************************************
An example SAS program for Stats 506.

This file reads the RECS data from:
 ./data/recs2009_public.sas7bdat
 http://www.eia.gov/consumption/residential/data/2009/index.cfm?view=microdata

Then demonstrates the use of `proc tabulate`.


Author: James Henderson, PhD (jbhender@umich.edu)
Date: Nov 13, 2017
 *****************************************************
*/

/* data library for reading/writing data */
libname mylib '~/Stats506/SAS/data/';

/* create a short name for recs data */
data recs;
 set mylib.recs2009_public_v4;

/* data step to create urban indicator */
data recs;
 set recs;
 urban=1;
 if ur='R' then urban=0;

/******** 
 Tabulate 
 ******** 
*/

/* get max, min, and Nobs for regionC */
proc tabulate data=recs;
 var regionc;
 table regionc*N regionc*max regionc*min;

/* get # of urban / rural obs by regionc */
proc tabulate data=recs;
 var urban;
 class ur;
 table urban*sum ur*N;

/* grouped tables */
proc tabulate data=recs;
 var cdd65; 
 class regionc;
 table regionc, cdd65*N cdd65*mean; 

proc tabulate data=recs;
 var cdd65;
 class regionc;
 table cdd65*N*regionc cdd65*mean*regionc;

/* twice stratified tables */
proc tabulate data=recs;
 var cdd65;
 class regionc ur;
 table regionc, cdd65*mean*ur;
 

run;

