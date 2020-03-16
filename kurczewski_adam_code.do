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
scalar smallk = r(N)

* number of large class 3rd gdrs who were in small kgtn class
count if gkclasstype_treat == 3 & g3classtype_treat == 1
scalar countsize = r(N)




** Exercise 2 **

*create balance variable list KGTN only

global encodevarlist gender race gksurban gktgen gktrace gkthighdegree gktcareer gkfreelunch ///
gkrepeat gkspeced gkspecin  
			
foreach var in $encodevarlist {
	replace `var' = "" if `var' == "NA"
	encode `var', g(`var'_encoded)
}


global destringvarlist gktyears gkabsent gktreadss gktmathss gktlistss gkwordskillss gkmotivraw gkselfconcraw

foreach var in $destringvarlist {
	replace `var' = "" if `var' == "NA"
	destring `var', g(`var'_encoded)
}


global balancevarlist  gender_encoded race_encoded gksurban_encoded gktgen_encoded gktrace_encoded gkthighdegree_encoded gktcareer_encoded gktyears_encoded gkfreelunch_encoded ///
		gkrepeat_encoded gkspeced_encoded gkspecin_encoded gkabsent_encoded ///
			gktreadss_encoded gktmathss_encoded gktlistss_encoded gkwordskillss_encoded gkmotivraw_encoded gkselfconcraw_encoded

			

* balance test
** output to better format for final write up
iebaltab $balancevarlist, grpvar(gkclasstype_treat) save(balancetest) total replace
* gktgen_encoded = NA due to 0 male KGTN teachers!





** Exercise 3 **

* outcomes = g4treadss & g4tmathss
* compare = small class KGTN // regular size (no aide)

replace g4treadss = ""  if g4treadss == "NA"
destring g4treadss, g(g4reads)

replace g4tmathss = "" if g4tmathss == "NA"
destring g4tmathss, g(g4maths)


* reading scores - small class omitted
reg g4reads ib3.gkclasstype_treat gender_encoded race_encoded gksurban_encoded gktgen_encoded ///
gkthighdegree_encoded gktcareer_encoded gkfreelunch_encoded gkrepeat_encoded gkspeced_encoded ///
 gkspecin_encoded gktyears_encoded gktreadss_encoded gktmathss_encoded gktlistss_encoded gkwordskillss_encoded ///
 gkmotivraw_encoded gkselfconcraw_encoded, baselevels
 
reg g4reads ib3.gkclasstype_treat $balancevarlist, baselevels
eststo readscore


* math scores - small class omitted
reg g4maths ib3.gkclasstype_treat $balancevarlist, baselevels
eststo mathscore

esttab readscore mathscore

* table making options
*outreg2
*esttab

** Exercise 4 **

* small KGTN regular 3rd - taking regular as regular class no aide
count if gkclasstype_treat == 3 & g3classtype_treat == 2
scalar small2reg = r(N)

* number of years in small classes
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

esttab readingxyears mathxyears

