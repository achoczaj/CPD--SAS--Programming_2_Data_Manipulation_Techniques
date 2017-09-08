/*******************************************************************************

An Introduction to the SAS Macro Facility - a collection of snippets

from Summary of Lesson 12: An Introduction to the SAS Macro Facility
SAS Programing 2 course focuses on using the SAS DATA step

- state the purpose of the macro facility
- describe the two types of macro variables
- create and use macro variables
- display the values of macro variables in the SAS log
*******************************************************************************/


/*******************************************************************************
1. What is the Macro Facility
*******************************************************************************/
/* 1.1 macro variables / macro programs */
/*
The SAS macro facility is a tool for extending and customizing SAS and for reducing the amount of text that you must enter to complete tasks. The macro facility consists of the macro processor and the SAS macro language.

By using the macro facility, you can package small or large amounts of text into units that have names. The text packages that you create are known as either macro variables or macro programs.

You can use macro variables to substitute text into a SAS program, which makes the program easier to maintain.
Macro programs, also known as macros, generate custom SAS code.
*/
/*******************************************************************************
2. Basic Concepts of Macro Variables
*******************************************************************************/
/* 2.1 Two types of macro variables */
/*
There are two types of macro variables: automatic macro variables, which SAS provides, and user-defined macro variables, which you create and define. Whether automatic or user-defined, a macro variable is independent of a SAS data set and it contains one text string value that remains constant until you change it.

To substitute the value of a macro variable into your program, you must reference the macro variable in your code. You precede the macro variable name with an ampersand (&).
The reference causes the macro processor to search for a stored value of the named macro variable and to substitute that value into the program in place of the reference.
The macro processor does its work before the program compiles and executes.
  &macro-variable-name

Example:
DATA new;
  SET orion.sales;
  WHERE Salary > &Amount;
RUN;
This program references the macro variable Amount. When you submit this program, SAS replaces the macro variable reference with the stored value of Amount before the program compiles.

If you need to reference a macro variable within quotation marks, such as in a TITLE statement, you must use double quotation marks.
Example:
  TITLE "Total Sales for &Country";
This example shows a reference to the macro variable Country in a title, and the title text is enclosed in double quotation marks. The macro processor resolves the reference and the resulting title includes the value of the macro variable.

The macro processor will not resolve macro variable references that appear within single quotation marks. Instead, SAS interprets the macro variable reference as part of the text string.
*/
/*******************************************************************************
3. Using Automatic Macro Variables
*******************************************************************************/
/* 3.1 Automatic Macro Variables */
/*
Automatic macro variables contain system information such as the date and time that the current SAS session began. SAS creates these automatic macro variables when the SAS session begins, and they are always available.

Common automatic macro variables include:
SYSDATE - stores the date when the current SAS session began (in DATE7. format);
SYSDATE9 - stores the date when the current SAS session began (in DATE9. format);
SYSDAY - stores the day of the week that the current SAS session began;
SYSLAST - stores the name of the last data set that was created;
SYSSCP -  stores the abbreviation for the operating system you are using (such as OS, WIN, HP 64, and so on);
SYSTIME - stores the time that the current SAS session began;
SYSVER - stores the version of SAS that you are using.
*/
/*******************************************************************************
4. Creating and Using Your Own Macro Variables
*******************************************************************************/
/* 4.1 User-defined Macro Variables */
/*
You use the %LET statement to create a macro variable and assign a value to it. The name that you assign to a macro variable must follow SAS naming rules and cannot be a word that is reserved by SAS. The value can be any text string and quotation marks are not required.
  %LET macro-variable = value;

Example:
  %LET year = 2017; /*creates a macro variable named year that has a text value of 2017*/

SAS doesn't evaluate mathematical expressions in macro variable values.
  %LET last_year = 2017-1; /*creates a macro variable named year that has a text value of '2017-1'*/

SAS stores quotation marks as part of the macro variable value.
SAS removes leading and trailing blanks from the macro variable value before storing it.
SAS doesn't remove blanks within the macro variable value.
*/
/* 4.2 Referencing a User-Defined Macro Variable */
/*
You reference a user-defined macro variable in your code the same way that you reference an automatic macro variable. You precede the name of the macro variable with an ampersand.
When you submit the program, the macro processor resolves the reference and substitutes the macro variable's value before the program compiles and executes.
*/
/*******************************************************************************
5. Displaying Macro Variables in the SAS Log
*******************************************************************************/
/*
When you submit a program that contains macro variable references, you don't get to see the values that are substituted into your program. You might see the value of the macro variable in the output, depending on the program.

There are several methods that you can use to display the values of macro variables in the SAS log.
*/
/* 5.1 Displaying Macro Variables - SYMBOLGEN system option */
/*
The SYMBOLGEN system option controls whether or not SAS writes messages about the resolution of macro variable references to the SAS log.
  OPTIONS SYMBOLGEN;
*/
/* 5.2 Displaying Macro Variables - using the %PUT statements */
/*
Another way to display the values of macro variables in the SAS log is to write your own messages to the log by using the %PUT statement followed by the text you want to display. If the text contains a macro variable reference, it will resolve before the text is written to the log.

You can use the _ALL_ argument in a %PUT statement to list all macro variables and their values in the log.
_AUTOMATIC_ lists the values of the automatic macro variables, and _USER_ lists the values of the user-defined macro variables.
  %PUT text;
  %PUT _ALL_ | _AUTOMATIC_ | _USER_;
*/

/*******************************************************************************
    Sample Programs
*******************************************************************************/

/* Using Automatic Macro Variables */
proc print data=orion.customer_type noobs;
   title 'Listing of Customer_Type Data Set';
   /*change single quotation marks to double quotation marks in footnotes
     or the macro processor won't be able to resolve
     these macro variable references */
   footnote1 "Created &SYSTIME &SYSDAY, &SYSDATE9";
   footnote2 "on the &SYSSCP System Using SAS Release &SYSVER";
run;

/* Creating and Using User-Defined Variables Variables */

   %let year=2011;
   proc print data=orion.order_fact;
      where year(order_date)=&year;
      title "Orders for &year";
   run;

   proc means data=orion.order_fact mean;
      where year(order_date)=&year;
      class order_type;
      var total_retail_price;
      title "Average Retail Price for &year";
      title2 "by Order_Type";
   run;

/* Displaying Macro Variables in the SAS Log */
   options symbolgen;
   %put  _user_;
