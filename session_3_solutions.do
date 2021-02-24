*** Session 3 ***
*** Exporting results ***

* Exercise 1
/// assignment
sysuse cancer.dta, clear

/// solution (part a)
sts list, saving("C:\Users\bramh\Documents\survivor_function.dta", replace)

// solution (part b)
asdoc stcox age drug, save(C:\Users\bramh\Documents\prophaz.doc) replace

// solution (part c)
stcox, estimate
eststo m1
stcox age
eststo m2
stcox age drug
eststo m3
esttab m1 m2 m3																	// age is less predictive of death after taking account of drug, suggesting that drugs were more often
																				// administered to older patients (but strictly speaking these non-linear coefficients cannot be compared!)

* Exercise 2
/// assignment
webuse nlswork.dta, clear

/// solution
capture program drop myprog
program define myprog
syntax anything, factor(varname)
levelsof `factor', local(levels)
foreach x of local levels {
	asdoc, save(regression_`x') text(Regression for `factor' equals `x') replace
	asdoc regress `anything' if `factor'==`x', save(regression_`x') append
}
end

myprog wks_ue age, factor(race)													// association between age and weeks unemployed, by race



* Exercise 3
/// assignment
webuse nlswork.dta, clear
net install ekhb, from(https://raw.github.com/bhogend1/ekhb/master/)
ekhb logit union, decompose(age) mediators(collgrad) vce(cluster idcode)

/// solution
///// add this as options in "syntax"
word excel text file(string)

///// add this at the bottom, before "drop latent variables"
if "`word'"!="" {
	quietly asdoc wmat, mat(`percexpl') save(`file') replace
}
if "`excel'"!="" {
	quietly putexcel set "`file'", replace
	quietly putexcel A1 = matrix(`percexpl')
}
if "`text'"!="" {
	quietly mat2txt, matrix(`percexpl') saving(`file') replace
}



* Exercise 4
//assignment
webuse nlswork.dta, clear

// solution (part a)
capture program drop regexcel
program define regexcel
syntax varlist(min=2 max=2), Group(varname) file(string asis)
gettoken depvar indepvar : varlist

reg `depvar' `indepvar', vce(cluster `group')
scalar OLS_b = _b[`indepvar']
scalar OLS_se = _se[`indepvar']

xtset `group'
xtreg `depvar' `indepvar', fe
scalar FE_b = _b[`indepvar']
scalar FE_se = _se[`indepvar']

putexcel set `file', replace
putexcel A2 = "coefficient"
putexcel A3 = "standard error"
putexcel B1 = "OLS"
putexcel C1 = "FE"
putexcel B2 = OLS_b
putexcel B3 = OLS_se
putexcel C2 = FE_b
putexcel C3 = FE_se

end

regexcel ln_wage union, group(idcode) file("C:\Users\bramh\Documents\output.xls")	// effect of union membership on wage, for OLS and FE


// solution (part b)
capture program drop regexcel
program define regexcel
syntax varlist(min=2 max=2), Group(varname) file(string asis)

gettoken depvar indepvar : varlist
bootstrap r(diff): coefdiff, depvar(`depvar') indepvar(`indepvar') group(`group')

putexcel set `file', replace
putexcel A1 = "Coefficient"
putexcel A2 = "Bootstrap SE"
putexcel B1 = _b[_bs_1]
putexcel B2 = _se[_bs_1]
end

capture program drop coefdiff
program define coefdiff, rclass
syntax, depvar(varname) indepvar(varname) group(varname)
reg `depvar' `indepvar'
scalar OLS_b = _b[`indepvar']

xtset `group'
xtreg `depvar' `indepvar', fe
scalar FE_b = _b[`indepvar']

return scalar diff = FE_b-OLS_b
end

regexcel ln_wage union, group(idcode) file("C:\Users\bramh\Documents\output2.xls")	// FE gives a statistically significantly weaker effect of union membership on wage than OLS
