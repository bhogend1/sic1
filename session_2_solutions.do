*** Session 2 ***
*** Programming basics ***

* Exercise 1
/// assignment
clear all

/// solution
viewsource regress.ado										// e-class


* Exercise 2
/// assignment
webuse nhanes2d.dta, clear
quietly keep bpsystol race age sex houssiz sizplace
quietly drop if race==3

/// solution
program define diffcoef, rclass
quietly regress bpsystol race
scalar nocontrols = _b[race]
quietly regress bpsystol race age sex houssiz sizplace
scalar withcontrols = _b[race]
return scalar difference = nocontrols-withcontrols
end

bootstrap r(difference), rep(100): diffcoef


* Exercise 3
/// assignment
webuse nlswork.dta, clear
quietly gen random = runiform()
quietly replace ind_code = . if random>.85
quietly replace c_city =. if random<.15
quietly keep idcode year collgrad ind_code c_city union

/// solution
capture program drop fillmissings
program define fillmissings
syntax varlist(numeric) [if], Group(varname) Time(varname numeric)
bys `group' (`time'): replace `varlist' = `varlist'[_n-1] `if' & `varlist'==.
end
		
fillmissings ind_code if collgrad==1, g(idcode) t(year)		// let's try to fill ind_code using individual scores from previous years, among college graduates, it works!


* Exercise 4
/// assignment
webuse nlswork.dta, clear
quietly decode race, gen(race2)
quietly tostring ind_code, gen(industry)

/// solution
program define myreg
syntax anything [if], [vce(passthru) Group(varname)]
gettoken modeltype allvars : anything

foreach x in `allvars' {
	capture confirm numeric variable `x'
	if _rc!=0 {
		display as error "What the hell are you doing?"
		exit
	}
}

local panel = strpos("`modeltype'","xt")==1
if `panel'==1 {
	if "`group'"=="" {
		display as error "Please, specify a panel variable using the group() option."
		exit
	}
	else {
		xtset `group'
	}
}

`anything' `if', `vce'
end

myreg reg hours age union, vce(robust)						// OLS with robust standard errors
myreg reg hours age union if collgrad==1, vce(robust)		// OLS with robust standard errors, among college graduates
myreg cloglog grade age industry							// String variable, gives a warning, as it should
myreg xtlogit msp age c_city collgrad, g(idcode)			// random effects logistic regressions



* Exercise 5
/// assignment
net install ekhb, from(https://raw.github.com/bhogend1/ekhb/master/)
help ekhb

/// solution
viewsource ekhb.ado											// (a) gsem, (b) ereturn display and matlist `percexpl'
