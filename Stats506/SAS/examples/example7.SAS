/*****************************************************
An example SAS program for Stats 506.

This file reads compressed daily temperature data 
for 2016 in '2016.csv.gz' downloaded from:

Then ... ?

Author: James Henderson, PhD (jbhender@umich.edu)
Date: Nov 15, 2017
 *****************************************************
*/

libname mylib '../data';

/* use a filename pipe to read compressed data */ 
filename ghcnd_gz pipe "gzip -dc ../data/2016.csv.gz" lrecl=80;

/* a data step and 'infile' statement allows flexible import. 
 * the 'input' statement names and formats the columns
 * the 'format' statement controls the mmddyy output
 */
data ghcnd;
    infile ghcnd_gz dsd delimiter=',';
    input station : $11. date : yymmdd8. obstype : $ obsval;
    format date mmddyy10.;

/* What is this step doing? */
data mylib.ghcnd_2016;
 set ghcnd;

run; 