/****************************************************
Summarizing Data with Accumulating Variables - a collection of snippets

from Summary of Lesson 2: Summarizing Data
SAS Programing 2 course focuses on using the SAS DATA step

- explain how SAS initializes the value of a variable in the PDV
- prevent reinitialization of a variable in the PDV
- create an accumulating variable
- define FIRST. and LAST. processing
- calculate an accumulating total for groups of data
- use a subsetting IF statement to output selected observations
*******************************************************************************/


/*******************************************************************************
1. Creating an Accumulating Variable
*******************************************************************************/
/* An accumulating variable accumulates the value of another variable and keeps its value from one observation to the next.

1.1 Assignment statements

An Assignment statement specifying the addition operator and a RETAIN statement are often used to create an accumulating variable.

/*Code with an error - does not add as Mth2Date has an initial value as '.' missing value. Can not add '.' to any number. */
DATA monthTotalSales;
   SET orion.aprsales;
   Mth2Date = Mth2Date +SaleAmt ;
RUN;

Will this program create the correct values for Mth2Date? No, it won't.
If you run this code, it creates the Mth2Date variable, but all the values for this variable are missing '.'.

By default, when the assignment statement creates a new variable, the value of the variable is initialized to missing at the top of the DATA step. So the initial value of Mth2Date is missing. When you add the value of Mth2Dte to the value of SaleAmt, the resulting value is missing because any mathematical operation on a missing value equals missing.

You need to create an accumulating variable.

An accumulating variable accumulates the value of another variable and keeps its own value from one observation to the next.

You can use the RETAIN statement to create the Mth2Date variable.

/*Code with an error - do not ignores missing values of SaleAmt*/
DATA monthTotalSales;
   SET orion.aprsales;
   RETAIN Mth2Date 0; /*create an accumulating variable with a inicial value = 0 */
   Mth2Date = Mth2Date + SaleAmt ;
RUN;

/* When there's a missing value for SaleAmt, the assignment statement calculates a missing value, and SAS retains the missing value across iterations of the DATA step. */

The RETAIN statement is a compile-time-only statement that prevents SAS from reinitializing the variable at the top of the DATA step. Because the variable is not reinitialized, it retains its value across multiple iterations of the DATA step.

RETAIN variable-name <initial-value> …;

The RETAIN statement includes an optional initial value for the variable. If you don't specify an initial value, the RETAIN statement initializes the variable to missing before the first iteration of the DATA step.

Be sure to specify an initial value of zero when creating an accumulating variable.


1.2 SUM statement

As an alternative to using an Assignment statement and the RETAIN statement, you can use a sum statement. The accumulating variable is specified on the left side of the plus sign, and an expression is specified on the right side.

variable+expression;

By default, the sum statement retains the accumulating variable and initializes it to zero. During each iteration of the DATA step, the expression is evaluated and the resulting value is added to the accumulating variable, ignoring missing values.

You can use the sum statement in SAS to ignore missing input values. */

DATA monthTotalSales2;
   SET orion.aprsales;
   /*there is no need for the RETAIN statement*/
   Mth2Date + SaleAmt ; /*ignores missing values*/
   /*the sum statement creates the variable on the left side of the plus sign if it doesn't already exist. SAS automatically initializes the value of Mth2Dte to 0 before reading the first observation.*/
RUN;

/* The SUM function could be used instead of the addition operator in the expression in the Assignment statement. The SUM function also sums the arguments, but ignores missing values. */

DATA monthTotalSales;
   SET orion.aprsales;
   RETAIN Mth2Date 0;
   Mth2Date=sum(Mth2Date,SaleAmt);
RUN;


/*---PRACTICE 1---*/

/*
Create Accumulating Totals
Task

In this practice, you create a new data set with two accumulating variables.
The data set orion.order_fact contains orders across several years, sorted by Order_Date. Orion Star wants to examine growth in sales from November 1, 2008 to December 14, 2008.

Reminder: Make sure you've defined the Orion library.
1. Create the data set mid_q4.
2. Create an accumulating variable, Sales2Dte, that displays sales-to-date across this range.
3. Create an accumulating variable, Num_Orders, that displays the total number of orders to date.
4. Include a WHERE statement to read just those sales in the specified date range.
5. Print your results displaying Sales2Dte with a DOLLAR10.2 format. Show only the columns Order_ID, Order_Date, Total_Retail_Price, Sales2Dte, and Num_Orders, as well as an appropriate title.

Examine your results.

The mid_q4 data set contains 10 orders. The Sales2Dte total for the specified range is $1,664.20, and the Num_Orders total for the specified range is 10.
*/

data mid_q4;
   set orion.order_fact;
   where '01nov2008'd <= Order_Date
          <= '14dec2008'd;
   Sales2Dte+Total_Retail_Price;
   Num_Orders+1;
run;

title 'Orders from 01Nov2008 through 14Dec2008';
proc print data=mid_q4;
   format Sales2Dte dollar10.2;
   var Order_ID Order_Date Total_Retail_Price
       Sales2Dte Num_Orders;
run;
title;


/*---PRACTICE 2---*/

/*
Create Accumulating Totals Using Conditional Logic
Task

In this practice, you use conditional logic to create a data set with accumulating totals representing three methods of sales.
The data set orion.order_fact contains a group of orders across several years, sorted by Order_Date. Orion Star wants to analyze 2009 data by creating accumulating totals for the number of items sold from retail, catalog, and Internet channels.

Reminder: Make sure you've defined the Orion library.
1. Create the data set typetotals with the accumulating totals TotalRetail, TotalCatalog, and TotalInternet. Order_Type indicates whether the sale was retail (1), catalog (2), or Internet (3). Quantity represents the number of items sold for each order.
2. Use a WHERE statement to read only the orders from 2009.
3. Read only the first 10 observations satisfying the WHERE statement.
4. Print your results showing only Order_ID, Order_Type, Order_Date, Quantity, and the three new variables.

data typetotals;
   set orion.order_fact (obs=10);
   where year(Order_Date)=2009;

   if Order_Type=1 then TotalRetail+Quantity;
   else if Order_Type=2
        then TotalCatalog+Quantity;
   else if Order_Type=3
        then TotalInternet+Quantity;
run;

proc print data=typetotals;
run;

5. Examine the results to ensure that the program correctly calculated values for the accumulating totals.
6. Modify the program by reading all observations satisfying the WHERE statement. Keep only the variables Order_ID, Order_Type, Order_Date, Quantity, TotalRetail, TotalCatalog, and TotalInternet.
7. Print your results and add an appropriate title. View the results.

data typetotals;
   set orion.order_fact;
   where year (Order_Date)=2009;

   if Order_Type=1 then TotalRetail+Quantity;
   else if Order_Type=2
        then TotalCatalog+Quantity;
   else if Order_Type=3
        then TotalInternet+Quantity;

   keep Order_ID Order_Type Order_Date Quantity
        TotalRetail TotalCatalog TotalInternet;
run;

title '2009 Accumulating Totals Broken Out by Type of Order';
proc print data=typetotals;
run;
title

RESULTS:
The typetotals data set contains 90 observations. Notice that each time Order_Type equals 1, TotalRetail is increased by the value of Quantity, and TotalRetail retains its value until the next time Order_Type equals 1.
*/


/*******************************************************************************
2. Accumulating Totals for Grouped Data
*******************************************************************************/

/* 2.1 Sorting by BY-variable
When you need to accumulate totals for groups of data, (for example, if you need to see total salaries by department), the input data set must be sorted on the BY-variable. */

proc sort data=orion.specialsals
   out=salsort;
   by Dept;
run;

/* 2.2 Process the data in groups (BY BY-variable) in the DATA step

You can then use a BY statement in the DATA step to process the data in groups.

DATA output-SAS-data-set;
      SET input-SAS-data-set;
      BY BY-variable …;
         <additional SAS statements>
RUN;
*/

data deptsals (keep=Dept DeptSal);
   set salsort;
   by Dept;
run;

/*  2.3 Finding the First and Last Observations in a Group

/* When a BY statement is included in a DATA step, SAS creates two temporary variables (FIRST.by-variable and LAST.by-variable) for each BY variable listed on the BY statement. SAS sets the value of these variables to identify the first and last observation in each BY group. FIRST.by-variable is set to 1 when the first observation in a group is read, otherwise its value is 0. LAST.by-variable is set to 1 when the last observation in a group is read, otherwise its value is 0.

FIRST. BY-variable
LAST. BY-variable


2.4 Summarizing Data by Groups

You can use the values of the FIRST. and LAST. variables in a DATA step to summarize the grouped data.

First, set the accumulating variable equal to 0 at the start of each BY group.
Second, increment the accumulating variable with a sum statement on each iteration of the DATA step.
Third, output only the last observation of each BY group.


To accumulate totals for multiple groups (for example, if you need to see total salaries allocated to special projects by department), you can specify two or more BY variables on the BY statement. Be sure to list the primary grouping variable first, then the secondary grouping variable, etc. Remember that the input data set must be sorted by the BY variables.

The BY statement creates a FIRST. and LAST. variable for each BY variable. When the last observation for the primary variable is encountered, SAS sets the LAST. variable to 1 for the primary and all subsequent BY variables.

data deptsals (keep=Dept DeptSal);
   set salsort;
   by Dept;
   if First.Dept then DeptSal=0;
   DeptSal+Salary;
   if Last.Dept; /*the subsetting IF statement defines a condition that the observation must meet in order for the DATA step to continue processing*/
run;


/*---PRACTICE 3---*/

/*
Summarize Data Using the DATA Step

Task
In this practice, you create a new data set that summarizes sales based on customer and sales quarter.

The data set orion.order_qtrsum contains information about sales in a particular year for each customer, broken out by month. For a given customer, there might be some months (and quarters) he didn't place an order. In addition, there is also a variable, Order_Qtr, that contains the quarter in which the sale was made.

Reminder: Make sure you've defined the Orion library.
1. Create a new data set, qtrcustomers, that summarizes sales based on the customer ID and the quarter in which the sale was made.
2. Create the variable Total_Sales to contain the total sales for each quarter within each Customer_ID value.
3. Also, create the Num_Months variable to count the total number of months within each quarter that the customer had an order.
4. Keep the Customer_ID, Order_Qtr, Total_Sales, and Num_Months variables.
5. Print your results showing Total_Sales with a DOLLAR11.2 format and add an appropriate title.

The qtrcustomers data set contains 4 variables and 74 observations. The data is sorted by Customer_ID. Each observation shows the Customer_ID, the quarter in which the order was placed, the total sales for the quarter, and the total months within each quarter that the customer had an order.
*/

proc sort data=orion.order_qtrsum out=custsort;
   by Customer_ID Order_Qtr;
run;

data qtrcustomers;
   set custsort;
   by Customer_ID Order_Qtr;
   if first.Order_Qtr=1 then
      do;
         Total_Sales=0;
         Num_Months=0;
      end;

   Total_Sales+Sale_Amt;
   Num_Months+1;

   if last.Order_Qtr=1;

   keep Customer_ID Order_Qtr Total_Sales
        Num_Months;
run;

title 'Total Sales to Each Customer for Each Quarter';
proc print data=qtrcustomers;
   format Total_Sales dollar11.2;
run;
title;

/*---PRACTICE 4---*/

/*
Conditionally Summarize Data and Output

Task
In this practice, you create three new data sets that show the total sales for each customer by order type.
The data set orion.usorders04 contains a group of orders from US customers. Orion Star wants to reward customers who spent $100 or more through any particular sales channel: retail (1), catalog (2), or Internet (3). The variable Total_Retail_Price contains the amount the customer spent for one item on each order.

Reminder: Make sure you've defined the Orion library.
Create Discount1, Discount2, and Discount3 to hold the following information: if a customer spent $100+ in retail orders, then output to Discount1; if a customer spent $100+ in catalog orders, then output to Discount2; and if a customer spent $100+ in Internet orders, then output to Discount3.

Create the variable TotSales to hold the total sales for each customer by order type.

Hint:  The variable Total_Retail_Price contains the amount the customer spent for one item on each order. You must take Quantity into account when you calculate TotSales.

Keep the Customer_ID, Customer_Name, and TotSales variables. Format TotSales with a DOLLAR11.2 format.

Print your results and add an appropriate title.

The data sets Discount1, Discount2, and Discount3 should have 8, 2, and 5 observations, respectively. */

proc sort data=orion.usorders04
   out=usorders04_sorted;
   by Customer_ID Order_Type;
run;

data discount1 discount2 discount3;
   set usorders04_sorted;
   by Customer_ID Order_Type;

   if first.Order_Type=1 then TotSales=0;

   TotSales+(Quantity*Total_Retail_Price);

   if last.Order_Type=1 and TotSales >= 100 then
      do;
         if Order_Type=1
              then output discount1;
         else if Order_Type=2
              then output discount2;
         else if Order_Type=3
              then output discount3;
      end;

   keep Customer_ID Customer_Name TotSales;
   format TotSales dollar11.2;
run;

title 'Customers Spending $100 or more in Retail Orders';
proc print data=discount1 noobs;
run;
title;

title 'Customers Spending $100 or more in Catalog Orders';
proc print data=discount2 noobs;
run;
title;

title 'Customers Spending $100 or more in Internet Orders';
proc print data=discount3 noobs;
run;
title;



/*******************************************************************************
    Sample Programs
*******************************************************************************/

/* 1. Creating an Accumulating Variable */

data mnthtot2;
   set orion.aprsales;
   retain Mth2Dte 0;
   Mth2Dte=sum(Mth2Dte,SaleAmt);
run;

data mnthtot2;
   set orion.aprsales2;
   Mth2Dte+SaleAmt;
run;

/* 2. Accumulating Totals for a Group of Data */

proc sort data=orion.specialsals
   out=salsort;
   by Dept;
run;

data deptsals (keep=Dept DeptSal);
   set salsort;
   by Dept;
   if First.Dept then DeptSal=0;
   DeptSal+Salary;
   if Last.Dept;
run;


proc sort data=orion.projsals out=projsort;
   by Proj Dept;
run;

data pdsals (keep=Proj Dept DeptSal NumEmps);
   set projsort;
   by Proj Dept;
   if First.Dept then
      do;
         DeptSal=0;
         NumEmps=0;
      end;
   DeptSal+Salary;
   NumEmps+1;
   if Last.Dept;
run;
