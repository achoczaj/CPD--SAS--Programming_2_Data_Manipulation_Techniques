/*******************************************************************************

Functions Manipulating Numeric Values - a collection of snippets

from Summary of Lesson 5: Manipulating Numeric Values
SAS Programing 2 course focuses on using the SAS DATA step

- use SAS functions to compute descriptive statistics of numeric values
- work with SAS variable lists
- use SAS functions to truncate numeric values
- explain the automatic conversion that SAS uses to convert values between data types
- explicitly convert values between data types
*******************************************************************************/


/*******************************************************************************
1. Using Descriptive Statistics Functions
*******************************************************************************/
/* 1.1 Descriptive Statistics Functions */
/*
A SAS function is a routine that performs a calculation on, or a transformation of, the arguments listed in parentheses and returns a value.

function-name(argument-1, argument-2,…,argument-n)

Descriptive Statistics Functions:
SUM	the sum of the nonmissing arguments
MEAN	the arithmetic mean (average) of the arguments
MIN	the smallest value from the arguments
MAX	the largest value from the arguments
N	the number of nonmissing arguments
NMISS	the number of missing numeric arguments
CMISS	the number of missing numeric or character arguments

You can list all the variables in the function, or you can use a variable list by preceding the first variable name in the list with the keyword OF.

Total = SUM(qtr1, qtr2, qtr3, qtr4, qtr5, ..., qtr16)
equals
Total = SUM(OF qtr1-qtr16)
*/

/* 1.2 types of Variable Lists */
/*
There are several types of Variable Lists including numbered ranges, name ranges, name prefixes, and special SAS names.

Variable List	type:
a) Numbered Range List
x1-xn
  all variables x1 to xn, inclusive
Total=sum(of Qtr1-Qtr4);

b) Name Range List
x--a
  all variables ordered as they are in the program data vector (PDV), from x to a inclusive
Total=sum(of Qtr1--Fourth);
  You can also use a name range list to specify all numeric variables from x to a inclusive (x - numeric - a) or all character variables from x to a inclusive (x - character - a).
Total=sum(of x-numeric-a);

c) Name Prefix List
Product:
  all variables that begin with the same string
Total=sum(of Tot:);
  Tot: indicates the starting prefix for the variable names to be included in the calculation.

d) Special SAS Name List

  Special SAS Name List	all of the variables, all of the character variables, or all of the numeric variables that are already defined in the current DATA step
Total=sum(of _All_);
Total=sum(of _Character_);
Total=sum(of _Numeric_);
*/

/*******************************************************************************
2. Truncating Numeric Values
*******************************************************************************/
/* 2.1 truncation functions - ROUND, CEIL, FLOOR, INT*/
/*
There are four truncation functions that you can use to truncate numeric values. They are the ROUND, CEIL, FLOOR, and INT functions.

The ROUND function returns a value rounded to the nearest multiple of the round-off unit. If you don't specify a round-off unit, the argument is rounded to the nearest integer.

ROUND(argument<,round-off-unit>)
The argument must be a number or a numeric expression.
The round-off unit must be numeric and positive. If you don't specify a round-off unit, the argument is rounded to the nearest integer.

For example, this assignment statement rounds the values of TotalSales to the nearest integer.
Rnd_TotalSales = ROUND(TotalSales);
*/

DATA truncate;
  NewVar1 = ROUND(12.12);
  NewVar2 = ROUND(42.65, .1);
  NewVar3 = ROUND(-6.478);
  NewVar4 = ROUND(96.47, 10);
  NewVar5 = ROUND(12.69, .25);
  NewVar6 = ROUND(42.65, .5);
RUN;
/* NewVar1 = 12 */
/* NewVar2 = 42.7 */
/* NewVar3 = -6 */
/* NewVar4 = 100 */
/* NewVar5 = 12.75 */
/* NewVar6 = 42.5 */


/* 2.2 Exploring the CEIL, FLOOR, and INT Functions */
/*
The CEIL function returns the smallest integer greater than or equal to the argument.
CEIL(argument)

The FLOOR function returns the greatest integer less than or equal to the argument.
FLOOR(argument)

The INT function returns the integer portion of the argument.
INT(argument)
*/

DATA truncate;
  Var1 = 6.478;
  CeilVar1 = CEIL(Var1);
  FloorVar1 = FLOOR(Var1);
  IntVar1 = INT(Var1); /* integer portion of the argument */
  Var2 = -6.478;
  CeilVar2 = CEIL(Var2);
  FloorVar2 = FLOOR(Var2);
  IntVar2 = INT(Var2); /* integer portion of the argument */
RUN;
/* CeilVar1 = 7 */
/* FloorVar1 = 6 */
/* IntVar1 = 6 */
/* CeilVar2 = -6 */
/* FloorVar2 = -7 */
/* IntVar2 = -6 */

/*******************************************************************************
3. Converting Values Between Data Types
*******************************************************************************/
/* 3.1 Automatic Character-to-Numeric Conversion */
/*
You can allow SAS to automatically convert data to a different data type for you, but it can be more efficient to use SAS functions to explicitly convert data to a different data type. By default, if you reference a character variable in a numeric context, SAS tries to convert the variable values to numeric. Automatic character-to-numeric conversion uses the w. informat, and it produces a numeric missing value from any character value that does not conform to standard numeric notation.
*/

/* 3.2 Explicit Character-to-Numeric Conversion */
/*
You can use the INPUT function to explicitly convert character values to numeric values. The INPUT function returns the value that is produced when the source is read with a specified informat.

INPUT(source, informat)

Example:
Test = INPUT(SaleTest, comma9.);
The INPUT function uses the numeric informat COMMA9. to read the values of the character variable SaleTest. Then the resulting numeric values are stored in the variable Test.
When you use the INPUT function, be sure to select a numeric informat that can read the form of the values. You must specify a width for the informat that is equal to the length of the character variable that you need to convert.
*/

/* 3.3 Converting an Existing Variable to Another Type
/*
Suppose though that you do want to convert GrossPay to a numeric variable.
You might think about using an ASSIGNMENT statement with an INPUT function to perform this task.
GrossPay = INPUT(GrossPay, comma6.);
But, that won't work.
Remember that after a variable’s type is established, it can't be changed.
But, by following a few steps, you can get a new variable with the same name and a different type.
*/

/* The first step is to use the RENAME= data set option to rename the variable you want to convert. */
DATA hrdata;
  SET orion.convert(rename=(GrossPay=Char_GrossPay));
  GrossPay = INPUT(Char_GrossPay, comma6.);
  (DROP=Char_GrossPay)
RUN;

/* The next step is to use the INPUT function in an assignment statement to create a new variable with the original name of the variable you just renamed. */
DATA hrdata;
  SET orion.convert(rename=(GrossPay=Char_GrossPay));
  GrossPay = INPUT(Char_GrossPay, comma6.);
RUN;

/* You can then use a DROP= data set option in the DATA statement to exclude CharGross from the output data set. */
DATA hrdata (DROP=Char_GrossPay);
  SET orion.convert(rename=(GrossPay=Char_GrossPay));
  GrossPay = INPUT(Char_GrossPay, comma6.);
RUN;


/* 3.4 Automatic Numeric-to-Character Conversion */
/*
Numeric data values are automatically converted to character values whenever they are used in a character context. For example, SAS automatically converts a numeric value to a character value when you use the concatenation operator.
When SAS automatically converts a numeric value to a character value, SAS writes the numeric value with the BEST12. format and right aligns the value.

Example:
Since SAS automatically converts a numeric value to a character value when you use the concatenation operator, you might try concatenating the value of 'Code' with parentheses and the value of 'Mobile'.
*/

DATA hrdata;
  KEEP Phone Code Mobile;
  SET orion.convert;
  Phone = '(' || Code || ') ' Mobile;
RUN;
/* The resulting value might contain leading blanks. */
/* Phone = '     (303) 123456' */


/* 3.5 Explicit Numeric-to-Character Conversion */
/*
You can use the PUT function to explicitly control the numeric-to-character conversion using a format.

PUT(source, informat)
Source indicates the numeric variable, constant, or expression to be converted to a character value.
A format matching the data type of the source must also be specified.
*/

DATA hrdata;
  KEEP Phone Code Mobile;
  SET orion.convert;
  Phone = '(' || PUT(Code, 3.) || ') ' Mobile;
RUN;
/*
or you can use the CAT function as an alternative to the PUT function.

Remember that the CAT function returns a value that is the concatenation of the named strings. This assignment using the CAT function produces the same results as this assignment using the PUT function.
*/
DATA hrdata;
  KEEP Phone Code Mobile;
  SET orion.convert;
  Phone = CAT('(',Code,') ',Mobile);
RUN;
/* If you use the CAT function, no note is written to the log. */


/*******************************************************************************
    Sample Programs
*******************************************************************************/

/* 1. Using Descriptive Statistics Functions and Truncating Numeric Values */
data donation_stats;
   set orion.employee_donations;
   keep Employee_ID Total AvgQT NumQT;
   Total=sum(of Qtr1-Qtr4);
   AvgQT=round(Mean(of Qtr1-Qtr4),1);
   NumQt=n(of Qtr1-Qtr4);
run;
proc print data=donation_stats;
run;

/* 2. Converting Values Between Data Types */
data hrdata;
   keep EmpID GrossPay Bonus Phone HireDate;
   set orion.convert;
   EmpID=input(ID,2.)+11000;
   Bonus=input(GrossPay,comma6.)*.10;
   Phone='(' !! put(Code,3.) !! ') ' !! Mobile;
   HireDate=input(Hired,mmddyy10.);
run;
proc print data=hrdata;
   format HireDate mmddyy10.;
run;
