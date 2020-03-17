/* UC Stata Coding Exercise 
Adam Kurczewski
3/15-3/18
*/

* package intall
ssc install ietoolkit
*ssc install outtable

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

* alternative approach: indicator for small class only
gen smallk_dum = 0
replace smallk_dum = 1 if gkclasstype_treat == 3
replace smallk_dum = . if gkclasstype_treat == .

* number of small class kgtn
count if gkclasstype_treat == 3
scalar smallk_count = r(N)

* number of large class 3rd gdrs who were in small kgtn class
count if gkclasstype_treat == 3 & g3classtype_treat == 1
scalar smallxlarge_count = r(N)




** Exercise 2 **

*create balance variable list KGTN only

global encodevarlist gender race gksurban gktgen gktrace gkthighdegree gkfreelunch 
			
foreach var in $encodevarlist {
	replace `var' = "" if `var' == "NA"
	encode `var', g(`var'_encoded)
}


*codebook indicates these tests were end of year, not prior to randomization - only use teacher years
/*
global destringvarlist gktyears gkabsent gktreadss gktmathss gktlistss gkwordskillss gkmotivraw gkselfconcraw

foreach var in $destringvarlist {
	replace `var' = "" if `var' == "NA"
	destring `var', g(`var'_encoded)
}
*/

replace gktyears = "" if gktyears == "NA"
destring gktyears , g(gktyears_encoded)

*global balancevarlist  gender_encoded race_encoded gksurban_encoded gktgen_encoded gktrace_encoded gkthighdegree_encoded gktcareer_encoded gktyears_encoded gkfreelunch_encoded ///
*		gkrepeat_encoded gkspeced_encoded gkspecin_encoded gkabsent_encoded ///
*			gktreadss_encoded gktmathss_encoded gktlistss_encoded gkwordskillss_encoded gkmotivraw_encoded gkselfconcraw_encoded


global balancevarlist gender_encoded race_encoded gksurban_encoded gktgen_encoded gktrace_encoded gkthighdegree_encoded gkfreelunch_encoded ///
		gktyears_encoded
			

* balance test
** output to better format for final write up
*iebaltab $balancevarlist, grpvar(gkclasstype_treat) save(balancetest) total replace
* gktgen_encoded = NA due to 0 male KGTN teachers!

iebaltab $balancevarlist, grpvar(gkclasstype_treat) savetex(balancetest) ///
 tblnote("Summary statistics and balance test results") replace




** Exercise 3 **

* outcomes = g4treadss & g4tmathss
* compare = small class KGTN ~ regular size (no aide)

replace g4treadss = ""  if g4treadss == "NA"
destring g4treadss, g(g4reads)

replace g4tmathss = "" if g4tmathss == "NA"
destring g4tmathss, g(g4maths)


* reading scores - small class omitted
reg g4reads ib3.gkclasstype_treat $balancevarlist, baselevels
eststo readscore


* math scores - small class omitted
reg g4maths ib3.gkclasstype_treat $balancevarlist, baselevels
eststo mathscore

esttab readscore mathscore, ///
title(Figure 2 \label{fig2}) tex 


* table making options
*outreg2
*esttab

** Exercise 4 **

* small KGTN regular 3rd - taking 'regular' as regular class no aide
count if gkclasstype_treat == 3 & g3classtype_treat == 2
scalar smallxreg_count = r(N)

* number of years in small classes

/* dummy route - drastically dif result not sure why - comments welcome on this
dummies for each year results in 3 new vars per year, one var for each T type
sum small class T type dummies for each year (efficiency concern? - 12 new vars vs 5)

* dummies:
tab gkclasstype_treat, g(tk)
tab g1classtype_treat, g(tone)
tab g2classtype_treat, g(ttwo)
tab g3classtype_treat, g(tthree)

gen smallyears = tk3 + tone3 + ttwo3 + tthree3
*/

gen smallk = 0
gen smallone = 0
gen smalltwo = 0 
gen smallthree = 0

replace smallk = 1 if gkclasstype_treat == 3
replace smallone = 1 if g1classtype_treat == 3
replace smalltwo = 1 if g2classtype_treat == 3
replace smallthree = 1 if g3classtype_treat == 3

gen num_yearssmall = smallk + smallone + smalltwo + smallthree

*crosstab
tab num_yearssmall gkclasstype_treat, matcell(smallxclass)
matrix list smallxclass

** Exercise 5 ** 

* Add precision discussion

* more # years in small class ~ test scores

* reading
reg g4reads num_yearssmall $balancevarlist
eststo readingxyears


* math
reg g4maths num_yearssmall $balancevarlist
eststo mathxyears

esttab readingxyears mathxyears, tex

