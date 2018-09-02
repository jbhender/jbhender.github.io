/*****************************************************
An example SAS program for Stats 506.

This file reads the RECS data from:
 ./data/recs2009_public.sas7bdat
 http://www.eia.gov/consumption/residential/data/2009/index.cfm?view=microdata

Then creates urban and rural subsets
and writes as sas7bdat.

Author: James Henderson, PhD (jbhender@umich.edu)
Date: Nov 13, 2017
 *****************************************************
*/

/* data library for reading/writing data */
libname mylib '~/Stats506/SAS/data/';

/* Create a rural subset */
data rural;
 set mylib.recs2009_public_v4;
  if ur='U' then delete;

data mylib.recs_rural;
  set rural;

/* Create and write an urban subset */
data urban;
 set mylib.recs2009_public_v4;
  if ur='R' then delete;
 
data mylib.recs_urban;
 set urban;

run;

