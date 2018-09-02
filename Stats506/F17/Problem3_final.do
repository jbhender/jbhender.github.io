* ---------------------------------------------------------------------------- *        
* Statistics 506, Fall 2017
* Example solution to question 3, problem set 1.
*
* Files: AUX_D.XPT, DEMO_D.XPT
*  imported from the web address below
*  https://wwwn.cdc.gov/nchs/nhanes/search/datapage.aspx?Component=Examination&CycleBeginYear=2005
*  https://wwwn.cdc.gov/Nchs/Nhanes/Search/DataPage.aspx?Component=Demographics&CycleBeginYear=2005
*  
* Authors: James Henderson
* Date: Oct 5, 2017
* ---------------------------------------------------------------------------- *        

*-------------------------------------------*
* a) Import and merge the data sets on SEQN *
*-------------------------------------------*

// Import and save AUX_D data
fdause AUX_D.XPT, clear
quietly compress
gsort +seqn
save AUX_D.dta, replace

//Import DEMO_D and merge AUX_D
fdause DEMO_D.XPT, clear
quietly compress
gsort +seqn
merge 1:1 seqn using AUX_D.dta

// Reduce to matched data
keep if _merge==3
save AUX_DEMO_merge.dta, replace

// Reduce to the variables of interest
keep seqn riagendr ridageyr auxu*

// We will ignore the '2nd read'
drop *1k2* 

// Decode missing values
mvdecode _all, mv(888=.\666=.)

// Create age groups
generate byte young = 0
replace young = 1 if ridageyr <= 25

generate byte old = 0
replace old = 1 if ridageyr >= 50 & ridageyr != .

// Save for repeated use    
save problem3_clean.dta, replace  

****************************************
*--------------------------------------*
* Part b: Compare old and young by ear
*--------------------------------------*
// reshape to long after dropping cases with all missing values
egen nmiss = rowmiss(auxu*)
drop if nmiss==14

// we have to specify that j is a string
reshape long auxu, i(seqn) j(thresh, string) 

// Use a regular expresssion to extract left ear from "thresh"
generate left = 0
replace left = 1 if regexm(thresh,"l$")

// Likewise for frequency
generate freq = .5 if regexm(thresh, "^500")
replace freq = 1 if regexm(thresh, "^1k")
replace freq = 2 if regexm(thresh, "^2k")
replace freq = 3 if regexm(thresh, "^3k")
replace freq = 4 if regexm(thresh, "^4k")
replace freq = 6 if regexm(thresh, "^6k")
replace freq = 8 if regexm(thresh, "^8k")

// compute mean, sd, and count within each group
preserve
collapse (mean) mean=auxu (sd) sd=auxu (count) N=auxu, by(freq old left)  

// reshape to compute diffs after grouping
generate group = 8*left + freq
reshape wide mean sd N, i(group) j(old)
gsort freq left

// compute difference and t
generate difference = mean1 - mean0
generate se = sqrt(sd1^2/N1 + sd0^2/N0) // unpooled as more variance for older
generate lower = difference - 1.96*se
generate upper = difference + 1.96*se

// produce a nicely formatted table
drop group sd0 sd1
generate Avg_Young = mean0, after(freq)
generate Avg_Older = mean1, after(Avg_Young)
generate Ear = "left" if left==1, after(freq)
replace Ear = "right" if left==0
rename freq Frequency
drop mean0 N0 mean1 N1 left se

foreach var in Avg_Young-upper {
 format `var' %3.1f
}

// Print the table
list, abbreviate(18) clean noobs

// Maybe export the table
export delimited diffs_by_freq_and_ear.tsv, delimiter(tab) datafmt replace

restore

* -------------------------------------------------------------------- *   
* Solution: Hearing loss is more pronounced at higher frequencies. 
*           From the table, there does not appear to be large
*           differences in age-related hearing loss between the left
*           and right ears.
* -------------------------------------------------------------------- *

* ----------------------------------- *
*  The approaches below are optional. *
* ----------------------------------- *

// Here is a regression approach
regress auxu c.freq##i.old i.left

** The significant interaction between frequency and age group 
** suggests age-related hearing loss is more pronounced at higher frequencies.

// Add an interaction with ear
regress auxu c.freq##i.old##i.left

regress auxu c.freq##i.old i.left i.left#c.freq i.left#i.old#c.freq

** The interaction between ear and frequency suggests the left
** ear is worse at higher frequencies, but this
** appears to increase only marginally with age.

* -------------------------------- *
* Here is a mixed models approach. *
* -------------------------------- *

mixed auxu c.freq##i.old i.left || seqn: || left: ,reml

** This mixed model confirms that the difference between old
** and young is greater at higher frequencies. The model below
** confirms that the left ear is better at low frequencies, but
** gets worse at higher frequenceis.  

mixed auxu c.freq##i.old i.left i.left#c.freq i.left#i.old#c.freq || seqn: || left: ,reml  

*********************************************************
* ----------------------------------------------------- *
* Part c: Use just the right ear and compare by gender  * 
* ----------------------------------------------------- *

use problem3_clean.dta, clear

// drop if all missing for right ear
egen nmiss = rowmiss(auxu*r)   
drop if nmiss==7

// reshape to long
reshape long auxu, i(seqn) j(thresh, string)

// drop left ear
drop if regexm(thresh, "l$") 
generate freq = .5 if regexm(thresh, "^500")
replace freq = 1 if regexm(thresh, "^1k")
replace freq = 2 if regexm(thresh, "^2k")
replace freq = 3 if regexm(thresh, "^3k")
replace freq = 4 if regexm(thresh, "^4k")
replace freq = 6 if regexm(thresh, "^6k")
replace freq = 8 if regexm(thresh, "^8k")   

preserve
collapse (mean) mean=auxu (sd) sd=auxu (count) N=auxu, by(freq old riagendr)
rename riagendr gender

// reshape to wide by old
generate group = 8*gender + freq
reshape wide mean sd N, i(group) j(old)

// compute differences
generate diff = mean1 - mean0
generate se = sqrt(sd1^2/N1 + sd0^2/N0) // unpooled variance, compare sd1 vs sd0
generate lower = diff - 1.96*se 
generate upper = diff + 1.96*se

// produce a nicely formatted table    
generate Avg_Young = mean0, after(freq) 
generate Avg_Older = mean1, after(Avg_Young) 
generate Gender = "Male" if gender==1, after(freq)    
replace Gender = "Female" if gender==2
rename freq Frequency
gsort Freq gender
drop mean0 mean1 N0 N1 sd0 sd1 se group gender

foreach var in Avg_Young-upper { 
  format `var' %3.1f
}

// Print or export table
list, abbreviate(18) clean noobs  
export delimited diffs_right_by_freq_and_gender.tsv, delimiter(tab) datafmt replace

restore
* -------------------------------------------------------------------- *   
* Solution: From the table, we see that the differences between the 
* 	    older and younger groups is more pronounced for males at 
*	    higher frequencies. 
* -------------------------------------------------------------------- *   

// Here are mixed models to investigate further.

mixed auxu c.freq##i.old##i.riagendr || seqn: , reml 

mixed auxu c.freq##i.old c.freq#i.old#i.riagendr || seqn: , reml

** Make sure you have a return or the last line won't be run.