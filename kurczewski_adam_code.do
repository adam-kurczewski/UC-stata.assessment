/* UC Stata Coding Exercise 
Adam Kurczewski
3/15-3/18
*/

* package intall
ssc install ietoolkit

clear all

* local working directory
cd "C:\Users\kurczew2\Desktop\UC-stata.assessment\assingment materials"

import delimited STAR_Students.csv, clear

sort stdntid


** Exercise 1 **

* Create T indicator for each grade with value label
foreach var in gkclasstype g1classtype g2classtype g3classtype {
	replace `var' = "" if `var' == "NA"
	encode `var', g(`var'_treat) label(classT)
}

* number of small class kgtn
count if gkclasstype_treat == 3

* number of large class 3rd gdrs who were in small kgtn class
count if gkclasstype_treat == 3 & g3classtype_treat == 1
*scalar countsize = r(N)

** Exercise 2 **

* unhappy with the imprecision from encoding to transform variables - circle back after first pass to manually recode each variable (destring OR encode)

*create balance variable list KGTN only
global encodevarlist gender race gksurban gktgen gktrace gkthighdegree gktcareer gktyears gkfreelunch ///
		gkrepeat gkspeced gkspecin gkpresent ///
			gktreads gktmaths gktlistss gkwordskillss gkmotivraw gkselfconcraw
			
			
foreach var in $encodevarlist {
	replace `var' = "" if `var' == "NA"
	encode `var', g(`var'_encoded)
}

global balancevarlist  gender_encoded race_encoded gksurban_encoded gktgen_encoded gktrace_encoded gkthighdegree_encoded gktcareer_encoded gktyears_encoded gkfreelunch_encoded ///
		gkrepeat_encoded gkspeced_encoded gkspecin_encoded gkpresent_encoded ///
			gktreads_encoded gktmaths_encoded gktlistss_encoded gkwordskillss_encoded gkmotivraw_encoded gkselfconcraw_encoded

			
iebaltab $balancevarlist, grpvar(gkclasstype_treat) save(balancetest) total replace
* gktgen_encoded = NA due to 0 male KGTN teachers!





* table making
outreg2
esttab

