# Basic programming for longitudinal data in Stata
* **AISSR** Short intensive course
* **Instructor** Bram Hogendoorn
* **Email** b.hogendoorn@uva.nl


# Session 1
## Establishing order
Stata organizes and reads data as rectangles. The rows represent cases or observations. The columns represent variables. This data representation is intuitive for "simple" data, that is, non-nested data.

We say that data are more "complex" when they are nested. Examples of **nesting** include eggs in birds' nests, children in families, pupils in classes, citizens in countries, workers in occupations, political parties in ideologies, repeated measurement moments in patients, and so on.

It can be useful to think of nesting as adding **dimensions** to the data. Simple data have two dimensions. The two dimensions are represented by rows and columns, respectively, yielding a rectangle. Complex data have more dimensions. These extra dimensions cannot intuitively be represented by a rectangle. Perhaps you could deal with three dimensions by stacking your rectangles as a pile of rectangular paper "sheets", where each sheets represents a value of the third dimension (e.g. time points). Unfortunately, your monitor screen is flat, and fourth or higher dimensions would go lost.

Longitudinal data are, by definition, three-dimensional or more:
* **1** Variables
* **2** Time points
* **3** Individuals
* (**4** Class rooms, schools, countries, ...)

Stata offers two formats to organize these extra dimensions:
* **Wide** Extra dimensions are hidden in the columns. For example, the columns income_1, income_2, and income_3 represent the values on the income variable at three different time points.
* **Long** Extra dimensions are hidden in the rows. For example, the first row represents the values on the income variable at time point one, the second row at time point two, and the third row at time point three. This format is superior for most purposes.

We will organize the data using the following commands:
* `sort` Affects the rendition of the data rectangle, but not the format.
* `by` Affects your calculations, but not the data rectangle. Requires that data are sorted.
* `by, sort` Affects your calculations and the data rectangle. Variables in parentheses are sorted but not by'ed.
* `reshape` Restructures your data into either wide or long format.

In addition, we will make use of **indexing**. When preparing data `by` group, you refer to a numbered observation of a variable by adding the number between square brackets after the variable. For example, `by id: gen firstyear = year[1]` creates a new variable called firstyear containing the first value on the year variable of each individual. Refer to the enumerated observation within the group using `_n` as the index number, and to the total number of observations within the group using `_N` as the index number. Stata also offers lag and lead indexing as `L.varname` and `F.varname`, which can be useful if your data contain gaps.

### Exercise 1
```
webuse reshape1.dta, clear
```
* What is the current data format?
* Reshape the data into the other format.
* Reshape the data back to their original format.

### Exercise 2
```
sysuse auto.dta, clear
```
* What variables could the data be nested in?
* Sort the data by price in ascending order.
* Generate a variable containing the mean weight of all domestic cars and of all foreign cars.

### Exercise 3
```
sysuse nlsw88.dta, clear
```
* Sort the data by race (primary) and wage (secondary)
* Generate a variable that indicates, for each individual, the lowest wage in his/her race group.
* Generate a variable that indicates, for each individual, the lowest wage in his/her industry. Do this in one command line.

### Exercise 4
```
sysuse cancer.dta, clear
```
* Generate a variable that indicates, for each patient, how many other patients of the same age took part in the study.
* Generate a variable that indicates, for each patient, how s/he ranks in terms of analyis time compared to other patients that took the same drug.

### Exercise 5
```
sysuse citytemp4.dta, clear
gen random = runiform()
replace tempjuly=. if random>.8
drop division heatdd cooldd random
```
* Tempjan and tempjuly represent the average temperatures in January and July of 956 cities. Fill up the missing July temperatures with the July temperatures of other cities in the same region that have similar January temperatures. Do this in one command line.


## Working with time
Time represents a third dimension in our data. We hide the time dimension in the rectangular data structure using Stata's long format. To do so, we need one variable representing the group id (e.g. student number) and one variable indicating the time point (e.g. year). There are three ways of showing Stata that there are hidden dimensions:
* `xtset` declare panel data
* `tsset` declare time series data
* `stset` declare survival data

There are no particular benefits of declaring your data as any particular style. Stata simply uses it to check for potential errors. However, Stata forces you to declare your data before conducting panel analysis.

One situation in which you need to declare your data, is when working with **unbalanced** panels. Unbalanced panels are panels in which not all individuals are observed at each time point. Panels are **weakly balanced** when there are no gaps between the first and last observation within each group, though the groups are observed over different time periods. Panels are **strongly balanced** when there are no gaps, and when all groups are observed over the same time period. Unbalanced panels typically form no problem for panel analysis. Yet, sometimes you will want to balance the panel. For example, when you can fill up missing values using the values from previous or later waves, connect cross-sectional data to synthesize a pseudo-panel, or construct your own panel from several administrative datafiles. Two commands come in handy here:
* `tsfill` fills gaps in the panel by adding empty rows for each time point, after the data have been `tsset`.
* `egen, seq()` creates a sequence of integers, particularly handy after `expand`.

### Exercise 1
```
webuse tsfillxmpl2.dta, clear
tsset, clear
```
* Create a strongly balanced panel.

### Exercise 2
```
clear all
set obs 100
```
* Generate a new variable indicating the years 1900 to 1999.

### Exercise 3
```
clear all
quietly set obs 10
quietly gen id = _n
quietly expand 10
```
* Generate a new variable indicating the ten time points that each individual is observed.
* For one individual, replace one of the time values by the value 11.
* Create a weakly balanced panel.

### Exercise 4
```
sysuse cancer.dta, clear
quietly rename _t total
quietly gen id = _n
```
* The variable total represents the total analysis time of each patient. Restructure the data into a weakly balanced panel according to the long format, so that each patient has an entry for each time point that s/he was observed. Do this in two command lines.


## Cross-references and loops
Stata uses more information than the data rectangle only. System settings are accessed using `creturn`, subroutine macros using `sreturn`, estimation information using `ereturn`, and general results using `return`. Other information can be stored in the following entities:
* **Matrix** A numeric rectangle.
* **Scalar** A number or string.
* **Global** A number or string, possibly resulting from extended macro functions.
* **Local** A number or string, possible resulting from extended macro functions. Locals are dropped after command execution.

These four entities allow you to pass information from one calculation to another, to store information for export, and to set parameters for multiple calculations.

Local and global **macros** are very useful in programming. They can store any kind of information, including a reference to another local or global macro. They can even refer to themselves, thus enabling them to accumulate information. Locals have several properties that distinguish them from globals:
* They disapear as soon as the code block of which they form part has been executed.
* They cannot travel between the environment and programs.
* They are used in loops.

**Loops** imply the use of locals. When using loops, you repeatedly execute the same command over the same local. The only thing that changes is the content of the local. The following loops are available:
* `foreach in` The most general loop.
* `foreach of` A loop over a local macro, global macro, variable list, or number list.
* `forvalues` A loop over a range of numbers.

Loops require you to specify the changing content of the local beforehand. Sometimes, you want to loop over all possible values of a variable, without specifying them manually. This can be achieved by storing the values in a local using `levelsof`.

### Exercise 1
```
sysuse auto.dta, clear
```
* Replace missing values of rep78 by the average rep78.
* Store your working directory into a global.
* Save the dataset into your working directory under the name "testdata.dta".

### Exercise 2
```
sysuse auto.dta, clear
```
* Conduct a series of regressions of car price on weight, length, and gear ratios, while controlling for mileage.
* Generate variables containing the mean weight, length, and gear ratios, of all domestic cars and of all foreign cars.
* Within each value of rep78, regress price on weight and save the coefficient in a (unique) scalar.

### Exercise 3
```
clear all
```
* Display the outcomes of the following calculations: 1x10, 2x20, 3x30, 4x40, and 5x50.
* There are four animals: cat, dog, cow, pig. There are four sounds: meow, woof, moo, oink-oink. Make each animal say its own sound.

### Exercise 4
```
webuse airacc.dta, clear
```
* Conduct a regression of rec on uit, inprog, and pmiles, with fixed effects for airlines.
* Generate variables containing the averages of uit, inprog, and pmiles by airline. Then regress rec on uit, inprog, and pmiles and their averages.

### Exercise 5
```
webuse airacc.dta, clear
```
* Create a matrix containing the average rec of each airline.



# Session 2
## Tools for loops and programs
Looping can be made easier by automating certain tasks. For instance, you may write a loop that only works for numeric variables, but do not manually want to check if a variable is numeric. Or, you would like to skip some command lines after the first looping round. Certain tools come in handy here:
* `set trace` traces the execution of programs and loops for debugging.
* `capture` suppresses output including error messages, and issues a return code in the scalar `_rc`.
* `quietly` and `noisily` force a command to hide or show its output, respectively.
* `confirm` verifies the state of its arguments.
* `assert` verifies a logical statement.
* `if`, `else if`, and `else` condition the execution of command lines. Differs from `if` inside a command line.
* `continue` and `exit` skip elements in a loop, break out of a loop, break out of a program, or break out of Stata.

### Exercise 1
```
sysuse bplong.dta, clear
```
* Check if all values on age group are either 1, 2, or 3.
* Check if sex is a numeric variable.
* Store the word "hello" in a local, and confirm that the local exists.

### Exercise 2
```
webuse nlswork.dta, clear
quietly decode race, gen(race2)
quietly tostring ind_code, gen(industry)
quietly keep idcode year age race2 union tenure hours industry
```
* Conduct a fixed-effects regression of hours worked on tenure, among those whose union membership is known.
* Conduct a series of fixed-effects regressions of hours worked on all numeric variables. Do this without checking their type manually.
* Repeat, but hide the regression output and only display the coefficient.
* Repeat, but finish the loop when encountering a positive regression coefficient.

### Exercise 3
```
unab allvars : *
local nvars : word count `allvars'
forvalues i = 1/`nvars' {
	local x : word `i' of `allvars'
	capture noisily replace `x'=. if hours > 80
	if _rc!=0 {
		display "How to set all variables, including string variables, to missing for persons who work over 80 hours per week?"
		continue, break
	}
}
```
* Debug the above loop.


## Programming basics
A Stata program consists in a number of command lines. There are several benefits to using programs:
* Repeated execution of the same commands
* Sample selection using `if` or `in`
* Compatible with Stata prefixes
* Embedding in other programs

All built-in commands are **programs**. They are primarily written in Mata, which is the language underneath the surface of Stata, and which we will not cover. All user-written commands are also programs. They are sometimes written in Mata and sometimes in Stata. Programs are called in a command line with a particular structure.

**command** *anything \[if\] \[in\]*, *options*

Stata can interpret commands because it relies on a set of rules that governs their structure. This set of rules is called **syntax**. The syntax tells Stata how to convert a term in a command line into a set of locals, depending on the position of that term. These locals can then be processed inside the program. That is, the command term itself calls the program. The arguments that follow as *anything* are passed to a local called anything. The *\[if\]* and *\[in\]* conditions are passed to two locals called if and in, and can be further processed using `marksample`. The *options* are passed to locals with the name of those options. All syntactic terms are parsed using the `syntax` command inside a program. Alternatively one could use the `args` command, but this is not recommended.

Programs return their results in macros. These macros persist until they are overwritten. To indicate which macros can be overwritten, programs belong to a certain **class**. The idea is that each class of programs overwrites only those macros that were produced by the same class of programs. In practice, the classes are not strictly segregated, since it is possible for a program to overwrite macros of a different class or retain existing macros of their own class. The classes are as follows:
* **nclass** programs do not return results.
* **rclass** programs return results in `r()`, intended for general results.
* **eclass** programs return results in `e()`, intended for estimation information.
* **sclass** programs return results in `s()`, intended for subroutines that parse input, rarely used.

The `viewsource` command allows users see the source code of existing programs. This is especially useful for understanding why a program does not work in your case and for recycling pieces of code.


### Exercise 1
```
clear all
```
* To which class does the regress command belong?

### Exercise 2
```
webuse nhanes2d.dta, clear
quietly keep bpsystol race age sex houssiz sizplace
quietly drop if race==3
```
* Does the difference in between blood pressure between black and white respondents decrease after adding control variables?
* Write a program that returns the change in the race coefficient following the inclusion of control variables, without showing the regression tables.
* Bootstrap the change in the coefficient using 100 replacement samples.

### Exercise 3
```
webuse nlswork.dta, clear
quietly gen random = runiform()
quietly replace ind_code = . if random>.85
quietly replace c_city =. if random<.15
quietly keep idcode year collgrad ind_code c_city union
```
* Write a program that allows you to specify a group identifier (e.g. individual) and a variable with missing values which will be filled using previous values from the same group.
* Allow the program to select samples according to *\[if\]* conditions. Run the program on college graduates only.

### Exercise 4
```
webuse nlswork.dta, clear
quietly decode race, gen(race2)
quietly tostring ind_code, gen(industry)
```
* Write a program that performs any type of cross-sectional regression (e.g. regress, logit, poisson, ...) on any variables specified by the user, on any sample selection, with any type of standard error adjustment (e.g. robust, cluster, ...).
* Allow the program to include any type of random-effects regression (e.g. xtreg, xtlogit, xtcloglog, ...).
* Let the program issue the warning "What the hell are you doing?" when a user specifies a string variable for regression.

### Exercise 5
```
net install ekhb, from(https://raw.github.com/bhogend1/ekhb/master/)
help ekhb
```
* What command is at the basis of the ekhb estimates?
* What two command lines make the program show the results?


# Session 3
## Exporting results
Stata results can be exported in several ways:
* The built-in `save` and the sometimes-available option `saving` export data as datafiles.
* The built-in `export` exports data as comma-separated files.
* The built-in `outfile` exports data as text files.
* The built-in `putexcel` exports matrices to Excel.
* The user-written `asdoc` offers several templates for export to Word.
* The user-written `estout` restructures regression results with some options for export.

Whether a command is helpful or not depends on the situation. It is not unusual to switch between export commands. `putexcel` and `asdoc` are particularly useful in programming, because they allow you to export matrices.

### Exercise 1
```
sysuse cancer.dta, clear
```
* Export the survivor function by `sts list` as a datafile.
* Export the results of a proportional hazards regression of death on age and drug by `stcox` as a Word document.
* Estimate a proportional hazards regression of death without explanatory variables, with only age as the explanatory variable, and with both age and drug as the explanatory variables. Restructure the three regression tables into a nice results table in Stata.

### Exercise 2
```
webuse nlswork.dta, clear
```
* Write a program that allows the user to specify the dependent and independent variables of a linear regression model. The user should also be able to specify a factor variable (e.g. marital status, union membership, industry code) so that the regression model is estimated separately for each level of that factor variable. Each regression table should be exported to a different Word file.

### Exercise 3
```
webuse nlswork.dta, clear
net install ekhb, from(https://raw.github.com/bhogend1/ekhb/master/)
ekhb logit union, decompose(age) mediators(collgrad) vce(cluster idcode)
```
* Add an option to ekhb that enable the user export the "percentage explained" table as a Word document, an Excel sheet, or a text file, to a directory of her choice.

### Exercise 4
```
webuse nlswork.dta, clear
keep 
```
* Write a program that exports the coefficients and standard errors from an OLS and a fixed-effects regression to Excel. The user should be able to specify one dependent variable, one independent variable, and one group identifier.
* Rewrite the program. It should bootstrap the difference between the OLS and the fixed-effects regression coefficient, and export the coefficient and bootstrap standard error of the difference to Excel. Do this by embedding the program into another program.
