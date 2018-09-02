/*****************************************************
An example SAS program for Stats 506.

This file imports RECS data from:
 ./data/recs2009_public.csv
 http://www.eia.gov/consumption/residential/data/2009/index.cfm?view=microdata

Then writes a SAS7BDAT native format to a data library.

Author: James Henderson, PhD (jbhender@umich.edu)
Date: Nov 13, 2017
 *****************************************************
*/

/* data library for reading/writing data */
libname mylib '~/Stats506/SAS/data/';

/* import delimited data */
proc import datafile='./data/recs2009_public.csv' out=recs;

/* use a data step and a set statement to save */
data mylib.recs2009;
 set recs;
 
run;

