# Basic programming for longitudinal data in Stata
* **AISSR** Short intensive course
* **Instructor** Bram Hogendoorn
* **Email** b.hogendoorn@uva.nl


## Establishing order
### Outline
Stata organizes and reads data as rectangles. The rows represent cases or observations. The columns represent variables. This data representation is intuitive for "simple" data, that is, non-nested data.

We say that data are more "complex" when they are nested. Examples of **nesting** include eggs in birds' nests, children in families, pupils in classes, citizens in countries, workers in occupations, political parties in ideologies, repeated measurement moments in patients, and so on.

It can be useful to think of nesting as adding **dimensions** to the data. Simple data have two dimensions. The two dimensions are represented by rows and columns, respectively, yielding a rectangle. Complex data have more dimensions. These extra dimensions cannot intuitively be represented by a rectangle. Perhaps you could deal with three dimensions by stacking your rectangles as a pile of rectangular paper "sheets", where each sheets represents a values of the third dimension (e.g. time points). Unfortunately, your monitor screen is flat, and fourth or higher dimensions would go lost.

Longitudinal data are, by definition, three-dimensional or more:
* **1** Variables
* **2** Time points
* **3** Individuals
* (**4** Class rooms, schools, countries, ...)

Stata offers two formats to organize these dimensions:
* **Wide** Extra dimensions are hidden in the columns. For example, the columns income_1, income_2, and income_3 represent the values on the income variable at three different time points.
* **Long** Extra dimensions are hidden in the rows. For example, the first row represents the values on the income variable at time point one, the second row at time point two, and the third row at time point three. This format is superior for most purposes.

We will organize the data using the following commands:
* `sort` Affects the rendition of the data rectangle, but not the format.
* `by` Affects your calculations, but not the data rectangle. Requires that data are sorted.
* `by, sort` Affects your calculations and the data rectangle. Variables in parentheses are sorted but not by'ed.
* `reshape` Restructures your data into either wide or long format.

In addition, we will make use of **indexing**. When preparing data `by` group, you refer to a numbered observation of a variable by adding the number between square brackets after the variable. For example, `by id: gen firstyear = year[1]` creates a new variable called firstyear containing the first value on the year variable of each individual. Refer to the enumerated observation within the group using `_n` as the index number, and to the total number of observations within the group using `_N` as the index number.

### Exercise 1
```
use http://www.stata-press.com/data/r15/reshape1
```
* What is the current data format?
* Reshape the data into the other format.
* Reshape the data back to their original format.

### Exercise 2
```
sysuse auto.dta, clear
```
* Which variables could the data be nested in?
* Sort the data by price in ascending order.
* Generate a variable containing the mean weight of all domestic cars and of all foreign cars.

### Exercise 3
```
sysuse nlsw88, clear
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
* Tempjan and tempjuly represent the average temperatures in January and July of 956 cities. Fill up the missing July temperatures with the July temperatures of other cities in the same administrative division that have similar January temperatures. Do this in one command line.

## Working with time
### Outline
Time represents a third dimension in our data. We hide the time dimension in the rectangular data structure using Stata's long format. To do so, we need one variable representing the group id (e.g. student number) and one variable indicating the time point (e.g. year). There are three ways of showing Stata that there are hidden dimensions:
* `xtset` declare panel data
* `tsset` declare time series data
* `stset` declare survival data

There are no special benefits of declaring your data as any particular style. Stata simply uses it to check for potential errors. However, Stata forces you to declare your data before conducting panel analysis.

One situation in which you need to declare your data, is when working with **unbalanced** panels. Unbalanced panels are panels in which not all individuals are observed at each time point. Panels are **weakly balanced** when there are no gaps between the first and last observation within each group, though the groups are observed over different time periods. Panels are **strongly balanced** when there are no gaps, and when all groups are observed over the same time period. Unbalanced panels typically form no problem for panel analysis. Yet, sometimes you will want to balance the panel. For example, when you can fill up missing values using the values from previous or later waves, connect cross-sectional data to synthesize a pseudo-panel, or construct your own panel from several administrative datafiles. Two commands come in handy here:
* `tsfill` fills gaps in the panel by adding empty rows for each time point, after the data have been `tsset`.
* `egen, seq()` creates a sequence of integers, particularly handy after the `expand`.

### Exercise 1
```
webuse tsfillxmpl2, clear
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
set obs 10
gen id = _n
expand 10
```
* Generate a new variable indicating the ten time points that each individual is observed.
* For one individual, replace one of the time values by the value 11.
* Create a weakly balanced panel.

### Exercise 4
```
sysuse cancer.dta, clear
rename _t total
gen id = _n
```
* The variable total represents the total analysis time of each patient. Restructure the data into a weakly balanced panel according to the long format, so that each patient has an entry for each time point that s/he was observed. Do this in two command lines.


## Cross-references and loops
Stata uses more information than the data rectangle only. System settings are accessed using `creturn`, estimation information using `ereturn`, and general results using `return`. Other information can be stored in the following entities:
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

