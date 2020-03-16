/* UC Stata Coding Exercise 
Adam Kurczewski
3/15-3/18
*/

clear all
set more off

* local working directory
cd "C:\Users\kurczew2\Desktop\UC-stata.assessment\assingment materials"

import delimited STAR_Students.csv, clear

sort stdntid

* Create T indicator for each grade with value label
foreach var in gkclasstype g1classtype g2classtype g3classtype {
	encode `var', g(`var'_treat) label(classT)
	replace `var'_treat = . if `var'_treat == 1
}

*** MAKE LOGIC ADJUSTMENT FOR CLASS SIZE LABEL MANUALLY ***


* number of small class kgtrs
count if gkclasstype_treat == 4

* number of large class 3rd gdrs who were in small kgtrs class
count if gkclasstype == 4 & g3classtype == 2

