# Basic programming for longitudinal data in Stata
* **AISSR** Short intensive course
* **Instructor** Bram Hogendoorn
* **Email** b.hogendoorn@uva.nl


## Establishing order
### Outline
Stata organizes and reads data as a rectangle. The rows represent cases or observations. The columns represent variables. This data representation is intuitive for "simple" data, that is, non-nested data.

We say that data are more "complex" when they are nested. Examples of **nesting** include eggs in birds' nests, pupils in classes, citizens in countries, workers in occupations, political parties in ideologies, repeated measurement moments in patients, and so on.

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
* `by, sort` Affects your calculations and the data rectangle.
* `reshape` Restructures your data into either wide or long format.

In addition, we will make use of **indexing**. When preparing data `by` group, you refer to a numbered observation of a variable by adding the number between square brackets after the variable. For example, `by id: gen firstyear = year[1]` creates a new variable called firstyear containing the first value on the year variable of each individual. Refer to the enumerated observation within the group using `_n` as the index number, and to the total number of observations within the group using `_N` as the index number.

### Exercise 1
`use http://www.stata-press.com/data/r15/reshape1`
* What is the current data format?
* Reshape the data into the other format.
* Reshape the data back to their original format.

### Exercise 2
`sysuse auto.dta, clear`
* Which variables could the data be nested in?
* Sort the data by price in ascending order
* Generate a variable containing the mean weight of all domestic cars and of all foreign cars

### Exercise 3
`sysuse nlsw88, clear`
* Sort the data by race (primary) and wage (secondary)
* Generate a variable that indicates, for each individual, the lowest wage in his/her race group.
* Generate a variable that indicates, for each individual, the lowest wage in his/her industry. Do this in one command line.

### Exercise 4
`sysuse cancer.dta, clear`
* Generate a variable that indicates, for each patient, how many other patients of the same age took part in the study
* Generate a variable that indicates, for each patient, how s/he ranks in terms of analyis time compared to other patients that took the same drug.

### Exercise 5
```
sysuse citytemp4.dta, clear
gen random = runiform()
replace tempjuly=. if random>.8
drop division heatdd cooldd random
```
* Tempjan and tempjuly represent the average temperatures in January and July of 956 cities. Fill up the missing July temperatures with the July temperatures of other cities in the same administrative division that have similar January temperatures. Do this in one command line.

