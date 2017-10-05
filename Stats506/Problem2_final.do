* ---------------------------------------------------------------------------- *
* Statistics 506, Fall 2017	  	          
* Example solution to question 2, problem set 1.  
* 
* Files: recs2009_public.dta 
*  	 imported from the address below:
* 
* http://www.eia.gov/consumption/residential/data/2009/csv/recs2009_public.csv     	 
*
* Authors: James Henderson and Tim Tu
* Date: Sep 29, 2017 
* ---------------------------------------------------------------------------- *

*------------------ *
* Set up workspace *
*------------------ *
version 14.2
cd ~/Stats506/Stata/solutions/1/
*log using Problem2.log, text replace
set more off

*--------------------- *
* Load and clean data *
*--------------------- *

// Import data (the first time)
*import delimited recs2009_public.csv
*save recs2009_public.dta
use recs2009_public.dta, clear

// Recode missing values
mvdecode rooftype, mv(-2=.)

// Keep only needed variables
keep doeid rooftype reportable_domain yearmaderange nweight

// Label variables
label define roof_types 1 "Ceramic or Clay" 2 "Wood Shingles" ///
  3 "Metal" 4 "Slate" 5 "Composition" 6 "Asphalt" 7 "Concrete" 8 "Other"
label values rooftype roof_types

label variable reportable_domain "State(s)"
label define states 1 "CT, ME, NH, RI, VT" 2 "MA" 3 "NY" 4 "NJ" ///
  5 "PA" 6 "IL" 7 "IN, OH" 8 "MI" 9 "WI" 10 "IA, MN, ND, SD" ///
  11 "KS, NE" 12 "MO" 13 "VA" 14 "DE, DC, MD, WV" 15 "GA" ///
  16 "NC, SC" 17 "FL" 18 "AL, KY, MS" 19 "TN" 20 "AR, LA, OK" ///
  21 "TX" 22 "CO" 23 "ID, MT, UT, WY" 24 "AZ" 25 "NV, NM" ///
  26 "CA" 27 "AK, HI, OR, WA" 
label values reportable_domain states

label variable yearmaderange "Decade of Construction" 
label define decades 1 "<1950" 2 "1950" 3 "1960" 4 "1970" 5 "1980" ///
                     6 "1990" 7 "2000"
label values yearmaderange decades

*----------------------------------------------------------------------- *
* Part a: Which state has the highest proportion of wood shingle roofs? *
* #(estimated wood roofs in state s)/#(estimated homes in state s)      *
*----------------------------------------------------------------------- *

// Generate indicator for wood shingle roofing.
generate wood_shingle = 1*(rooftype == 2)

// Each house in the sample represents nweigtht houses in the population.
replace wood_shingle = nweight*wood_shingle
replace nweight = 0 if rooftype==.                  // To exclude from denominator

// compute totals by state 
preserve				//so we can restore for part 2
collapse (sum) wood_shingle nweight, by(reportable_domain)

// scale wood_shingle to percent and make pretty 
generate Pct_Wood_Shingles = 100*wood_shingle/nweight
format Pct_Wood_Shingles %3.1f

// Sort table into ascending order
gsort -Pct_Wood_Shingles

// Use list for easy printing
rename reportable_domain State
list State Pct_Wood_Shingles, clean noobs abbreviate(18)

// Or export for later use
keep State Pct_Wood_Shingles
export delimited Wood_Shingles_States.tsv, delimiter(tab) datafmt replace

// Restore full data for next part
restore
*------------------------------------------------------------------------ *

*------------------------------------------------------------------------ *
* Soultion: North/South Carolina has the highest percentage of wood shingle roofs, 
*           while Tennessee has the lowest.
* Caution: If you ignored the sample weights, you are answering the 
*          question only for those units in the sample. 
*          
*          Proportion of _sampled_ wood roofs for state s = 
*          #(wood roofs in state s)/#(observations in state s)
* For more see: 
*  https://www.eia.gov/consumption/residential/methodology/2009/pdf/using-microdata-022613.pdf
*------------------------------------------------------------------------- *

** These values can be checked by the following commands:
** tabulate reportable_domain rooftype, row
** but you have less control over the final reporting.

*---------------------------------------------------------------------- *
* Part b: Which roof type saw the largest relative rise in use between
*         1950 and 2000?
*---------------------------------------------------------------------- *

// count roof-types by decade
egen rooftype_group = group(rooftype)
quietly summarize rooftype_group, meanonly  // This generates r(max) = number of types. 
 ** label list roof_type // This does the same thing, but relies on a value further away.
foreach i of num 1/`r(max)' {
 generate roof_`i' = 0
 replace  roof_`i' = nweight if rooftype_group==`i'  // as above use weights
}

// yearmaderange levels 7 and 8 are one decade
replace yearmaderange = 7 if yearmaderange == 8

// preserve here as the collapse command destroys the data 
preserve

// use collapse to sum roof type counts by levels of yearmaderange
collapse (sum) roof_*, by(yearmaderange)

// Sum across yearmaderange rows and normalize
// Uncomment two `relto' lines to compute relative values here
egen total = rowtotal(roof_1-roof_8)
*local relto = 2 // normalize relative to this value
foreach var of varlist roof_1-roof_8 {
  replace `var' = 100*`var'/total
*  replace `var' = `var'/`var'[`relto'] 
  format `var' %3.1f
}
drop total

* ---------------------------------------------------------- *
*  Below are two graphical approaches to creating a display.
*  These are not nicely formatted examples. 
*  If you took a graphical approach, you sould have nice
*  formatting.
* ---------------------------------------------------------- *

// Create separate graphs and then combine
*local cmd graph combine
*foreach var of varlist roof* {
*  twoway connected `var' yearmade, saving(`var', replace) ylabel(,angle(0))
*  local cmd `cmd' `var'.gph
*}
*`cmd', rows(3)
*graph export RoofTypeTrends.pdf, replace

// Reshape to long for next graph
reshape long roof_, i(yearmade) j(rooftype)

// Here is graphical approach using long format
*label variable roof_ "% New Roofs"
*twoway connected roof_ yearmaderange, by(rooftype) ylabel(,angle(0)) title("`1'")
*graph export RoofTypesByDecade.pdf, replace

* --------------------------------------------------- *
* Here is a tabular approach with root_types in rows.  
* Note: we start with the long fromat data from above. 
* --------------------------------------------------- *

rename roof_ percent
reshape wide percent, i(rooftype) j(yearmade)
generate rel_change = percent7 / percent2
format rel_change  %4.1f
label variable rel_change "Relative Change in proportion, 1950s to 2000s"

// Format for printing and export
label values rooftype roof_types 
* keep rooftype rel_change percent2 percent6
rename (percent1-percent7) (p_pre1950 p_1950s p_1960s p_1970s p_1980s p_1990s p_2000s)
gsort -rel_change

label define roof_types 1 "Ceramic or Clay" 2 "Wood Shingles" ///
  3 "Metal" 4 "Slate" 5 "Composition" 6 "Asphalt" 7 "Concrete" 8 "Other"
label values rooftype roof_types 

list, clean noobs abbreviate(18)
export delimited RoofTypeChange_1950to2000.tsv, delimiter(tab) datafmt replace 

* ------------------------------------------------------- *
* Solution: Ceramic or Clay roofs had the largest
* relative increase between the 1950's and 2000's at 5.5, 
* increasing from 1.1% to 5.7% of all rooftypes.
* ------------------------------------------------------- *