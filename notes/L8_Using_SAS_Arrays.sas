/*******************************************************************************

Using SAS Arrays - a collection of snippets

from Summary of Lesson 8: Using SAS Arrays
SAS Programing 2 course focuses on using the SAS DATA step

- define a SAS array
- reference elements of the SAS array
- use SAS arrays to perform repetitive calculations
- use SAS arrays to create new variables
- use SAS arrays to perform a table lookup
- use a DATA step with arrays and DO loop processing to restructure a data set
*******************************************************************************/


/*******************************************************************************
1. Understanding SAS Arrays
*******************************************************************************/
/*

A SAS array is a temporary grouping of variables that exists only for the duration of the DATA step in which it is defined.
An array is identified by a single, unique name.
The variables in the array are called elements, and are referred to by combining the array name and a subscript.

The variables that are grouped together in an array must be the same type: either all character or all numeric.
Unlike arrays in other programming languages, SAS arrays are not data structures.
*/

/*******************************************************************************
2. Creating SAS Arrays
*******************************************************************************/
/*

You use the ARRAY statement to define an array. Array-name specifies the name of the array.
Dimension describes the number of elements in the array.
Array-elements lists the variables to include in the array. Array elements can be listed in any order. If no elements are listed, SAS creates new variables with default names by combining the array name with consecutive integers.

ARRAY array-name {dimension} <array-elements>;
*/

/* 1.3 Specifying the Array Dimension */
/*
There are a few syntax variations for the ARRAY statement.
e.g. ARRAY contrib{4}  Qtr1 Qtr2 Qtr3 Qtr4;

This ARRAY statement creates an array named contrib that groups the four numeric variables Qtr1 through Qtr4.
Another way to indicate the dimension of a one-dimensional array is by using an asterisk.

e.g. ARRAY contrib{*}  Qtr1 Qtr2 Qtr3 Qtr4;
When you use an asterisk for the dimension, SAS determines the number of elements by counting the variables in the array-elements list.
This list must be included if you use an asterisk.

The array dimension must be enclosed in either braces, brackets, or parentheses.
e.g. ARRAY contrib{4}  Qtr1 Qtr2 Qtr3 Qtr4;
e.g. ARRAY contrib[4]  Qtr1 Qtr2 Qtr3 Qtr4;
e.g. ARRAY contrib(4)  Qtr1 Qtr2 Qtr3 Qtr4;
It is best to use braces or brackets so that there is no confusion with functions.
*/

/* 1.3 Specifying the Array Elements */
/*
There are also various ways to specify the list of array elements. You can list each variable name separated by a space, use variable lists – either a numbered range list or a name range list – to specify the array elements, or use the special SAS names _NUMERIC_ or _CHARACTER_. If you use one of these keywords, the array includes either all the numeric variables or all the character variables that were already defined in the current DATA step.
e.g. ARRAY contrib[4]  Qtr1 Qtr2 Qtr3 Qtr4;  <-- list each variable
e.g. ARRAY contrib[4]  Qtr1-Qtr4;  <-- use variable lists
e.g. ARRAY contrib[4]  _NUMERIC_;  <-- use special SAS names
e.g. ARRAY contrib[4]  _CHARACTER_;  <-- use special SAS names

Example:
The trial data set contains five numeric variables that store data collected during an experimental trial. Which ARRAY statement groups the variables T1, T2, T3, T4, and T5 into an array named test?
	 a.  array test{*} T1 T2 T3 T4 T5;
	 b.  array test{5} T1-T5;
	 c.  array test{*} _numeric_;
	 d.  OK -> all of the above

Example of another valid ARRAY statement:
e.g. ARRAY contrib[4]  Qtr1 Qtr2 ThrdQ Qtr4;
Variables that are elements of an array do not need to have similar, related, or numbered names.
They also do not need to be stored sequentially or be adjacent to one another.
The order of elements in an array is determined by the order in which they are listed in the ARRAY statement.
*/

/*******************************************************************************
3. Processing SAS Arrays
*******************************************************************************/
/* 3.1 Referencing Elements of an Array */
/*
When you define an array in a DATA step, each array element is referenced using a subscript.

array-name{subscript}

The subscripts are assigned in the order of the array elements.
The first element has a subscript of 1, the second element has a subscript of 2, etc.
The syntax for an array reference is the name of the array, followed by a subscript enclosed in braces, brackets, or parentheses.
The subscript can be an integer, a variable, or a SAS expression.
*/

/* 3.2 Using a DO Loop to Reference Elements in an Array */
/*
Typically, DO loops are used to process arrays. This allows you to process multiple variables and to perform repetitive calculations using the array name with the DO loop index variable as the subscript, allowing you to reference a different array element on each iteration of the loop.

Example:
Convert the values stored in the variables Weight1-Weight8 from kilograms to pounds.
*/
data hrd.convert;
    set hrd.fitclass;
    array wt{*} Weight1-Weight8;
    do i=1 to 8;
      wt{i} = wt{i}*2.2046;
    end;
run;

/* 3.3 Using the DIM Function to Determine the Number of Elements in an Array */
/*
The DIM function returns the number of elements in an array.

 DIM(array-name)

You can use the DIM function to specify the stop value of a DO loop. This is useful when an astersik is used in the ARRAY statement to determine the array size dynamically.

DO index-variable = start TO DIM(array-name);
Example:
Convert the values stored in the variables Weight1-Weight8 from kilograms to pounds.
*/
data hrd.convert;
    set hrd.fitclass;
    array wt{*} Weight1-Weight6;
    do i=1 to DIM(wt);
      wt{i} = wt{i}*2.2046;
    end;
run;
/*
What value does the DIM function return?
The function returns 6 because the array has six elements.

One convenient feature of using the DIM function is that you do not have to change the stop value of the iterative DO statement if you change the dimension of the array.
*/

/*******************************************************************************
4. Using an Array to Create Variables
*******************************************************************************/

/* 4.1 Using SAS Arrays to Create Variables */
Perform Calculations

/*
You can use an ARRAY statement to create many variables of the same type.
The variable names are created by concatenating the array name and the numbers 1, 2, 3, and so on, up to the array dimension.
e.g. Array sales[3];
results: sales1, sales2, sales3
In this case, you must specify a dimension.

You can also create variables by listing the new variable names in the array-elements list in the ARRAY statement.
e.g. Array discount[4] Discount1-Discount4;
results: Discount1, Discount2, Discount3, Discount4
e.g. Array shipment{3} Oct12 Oct19 Oct26;
results: Oct12, Oct19, Oct26
The array name does not have to match the new variable names.

Variables that you create in an ARRAY statement all have the same variable type.
  ARRAY array-name {dimension} <$> <length> <array-elements>;

If you want to create an array of character variables, you must add a dollar sign after the array dimension.
e.g. Array gadget{5} $;
By default, all character variables that are created in an ARRAY statement are assigned a length of 8.
You can assign a different length by specifying the length after the dollar sign.
e.g. Array gadget{5} $ 30;

The length that you specify is automatically assigned to all variables that are created by the ARRAY statement.
If you want to create several variables of different lengths, you can use a LENGTH statement before the ARRAY statement.
*/

/* 4.2. pass an entire array to a function*/
/*
If you reference an array element which does not exist, SAS automatically creates the non-existing variables, assigning default names based on the array name.

You can pass an entire array to a function as if it were a variable list. Remember that when you pass a variable list to a function, you must use the keyword OF.

SUM(OF array-name {* }

When using arrays to perform calculations, you can easily reference any array element by manipulating the index variable.
*/

/*******************************************************************************
5. Assigning Initial Values to an Array
*******************************************************************************//
/*
To assign initial values to array elements, you place the values in an initial-value-list in the ARRAY statement.
  ARRAY array-name {dimension} <_TEMPORARY_>
              <array-elements> <(initial-value-list)>;

Elements and values are matched by position, so the initial values must be listed in the order of the array elements.
e.g.: ARRAY Target{5} (50,100,125,150,200);

The values must be comma or blank separated, and you must enclose the list in parentheses.
If you are assigning character values, each value must be enclosed in quotation marks.


When you specify an initial value list, all elements behave as if they were named in a RETAIN statement. This creates a lookup table, that is, a list of values to refer to during DATA step processing.

This creates a static list of values that can be used as a lookup table during DATA step processing.
*/

/* 5.2. Temporary arrays */
/*
Temporary arrays can improve performance and are useful when you only need the array to perform a calculation or to look up a value.
To create a temporary array, you use the keyword _TEMPORARY_ following the dimension in the ARRAY statement.

Temporary arrays are created in memory. No corresponding variables are created in the program data vector, so there is no need to drop the array elements. You can improve performance time by using temporary arrays.

When you create a temporary array, SAS sets aside an area of memory and accesses that memory directly, instead of creating slots in the PDV. Since a temporary array doesn’t create variables in the PDV, you can’t refer to the values by variable names. Instead, you must refer to the table values using the array name and subscript.

Question
Which ARRAY statement correctly defines a temporary lookup table named country with three elements that are initialized to AU, NZ, and US?

	 a.  array country{3} _temporary_ ('AU','NZ','US');
	 b.  array country{3} $ 2 _temporary_ (AU,NZ,US);
	 c.  array country{3} $ 2 _temporary_ ('AU','NZ','US');
Answer: c
$ 2 indicates that each value in the lookup table is a character data type with a length of 2.
You use the keyword  _TEMPORARY_ to specify a temporary array.
You must enclose the initial character values in quotation marks.
*/

/*******************************************************************************
5. Restructuring a Data Set
*******************************************************************************/

/* 5. Restructuring a Data Set */
/*
wide data set:
Some data sets store all the information about one entity in a single observation.

narrow data set:
Other data sets have multiple observations per entity, and each observation typically contains a small amount of data.
Missing values might or might not be stored in the observations.

At times you might want to restructure a data set from one form to another to prepare it for further processing.
Restructuring a data set is sometimes referred to as rotating a data set.

You can use arrays and DO loops to restructure a SAS data set.





Sample Programs

Processing SAS Arrays
data charity;
   set orion.employee_donations;
   keep employee_id qtr1-qtr4;
   array contrib{*} qtr1-qtr4;
   do i=1 to dim(contrib);
      contrib{i}=contrib{i}*1.25;
   end;
run;
proc print data=charity;
run;

/* 2. Using an Array to Create Variables */
data percent(drop=i);
   set orion.employee_donations;
   array contrib{4} qtr1-qtr4;
   array Pct{4};
   Total=sum(of contrib{*});
   do i=1 to 4;
      pct{i}=contrib{i}/Total;
   end;
run;
proc print data=percent;
   var Employee_ID Pct1-Pct4;
   format Pct1-Pct4 percent6.;
run;

/* 3. Using an Array to Perform Calculations and Create Variables */
data change;
   set orion.employee_donations;
   drop i;
   array contrib{4} Qtr1-Qtr4;
   array Diff{3};
   do i=1 to 3;
      diff{i}=contrib{i+1}-contrib{i};
   end;
run;
proc print data=change;
   var Employee_ID Qtr1-Qtr4 Diff1-Diff3;
run;

/* 4. Assigning Initial Values to an Array */
data compare(drop=i);
   set orion.employee_donations;
   array contrib{4} Qtr1-Qtr4;
   array Diff{4};
   array goal{4} _temporary_ (10,20,20,15);
   do i=1 to 4;
      diff{i}=sum(contrib{i},-goal{i});
   end;
run;
proc print data=compare;
   var Employee_ID Diff1-Diff4;
run;

/* 5. Restructuring a Data Set */
data rotate (keep=Employee_ID Period Amount);
   set orion.employee_donations
            (drop=Recipients Paid_By);
   array contrib{4} qtr1-qtr4;
   do i=1 to 4;
       if contrib{i} ne . then do;
             Period=cats("Qtr",i);
             Amount=contrib{i};
             output;
       end;
    end;
run;

proc freq data=rotate;
   tables Period / nocum nopct;
run;
