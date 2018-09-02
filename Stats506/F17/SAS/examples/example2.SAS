/*****************************************************
An example SAS program for Stats 506.

This file reas the RECS data from:
 ./data/recs2009_public.sas7bdat
 http://www.eia.gov/consumption/residential/data/2009/index.cfm?view=microdata

Then writes a sas7bdat native format to a data library.

Author: James Henderson, PhD (jbhender@umich.edu)
Date: Nov 13, 2017
 *****************************************************
*/

/* data library for reading/writing data */
libname mylib '~/Stats506/SAS/data/';

/* Create a data set recs referring to existing file */
data recs;
 set mylib.recs2009_public_v4;  

proc contents data=recs;

run;

