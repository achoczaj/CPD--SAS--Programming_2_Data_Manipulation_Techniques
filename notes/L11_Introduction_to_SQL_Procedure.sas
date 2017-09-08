/*******************************************************************************

Introduction to the SQL Procedure - a collection of snippets

from Summary of Lesson 11: Introduction to the SQL Procedure
SAS Programing 2 course focuses on using the SAS DATA step

- identify the uses of the SQL procedure
- identify the main differences between PROC SQL and the DATA step for joining tables
- query a SAS data set and create a report by using PROC SQL
- create a table that contains the results of a PROC SQL query
- join multiple SAS data sets by using PROC SQL
*******************************************************************************/


/*******************************************************************************
1.Understanding PROC SQL
*******************************************************************************/
/* 1.1 Using PROC SQL*/
/*
Structured Query Language, or SQL, is a standardized language that many software products use to retrieve, join, and update data in tables. Using PROC SQL, you can write ANSI standard SQL queries that retrieve and manipulate data.
PROC SQL;
       SELECT column-1 <, column-2>…
              FROM table-1…
              <WHERE expression>
              <additional clauses> ;
QUIT;

In PROC SQL terminology, a table is a SAS data set or any other type of data file that you can access by using SAS/ACCESS engines. A row in a table is the same as an observation and a column is the same as a variable.

The process of retrieving data from tables by using PROC SQL is called querying tables. PROC SQL stores the retrieved data in a result set. By default, a PROC SQL query generates a report that displays the result set. You can also specify that PROC SQL output the result set as a table.
*/
/* 1.2. using PROC SQL vs. the DATA step */
/*
You can perform many of the same tasks by using PROC SQL or the DATA step. Each technique has advantages.

There are some differences between the syntax of a PROC SQL step and the syntax of other PROC steps. To start the SQL procedure, you specify the PROC SQL statement. When SAS executes a PROC SQL statement, the SQL procedure continues to run until SAS encounters one of the following step boundaries: the QUIT statement, or the beginning of another PROC or DATA step.

A PROC SQL step can contain one or more statements. The SELECT statement (a query) retrieves data from one or more tables and creates a report by default. A PROC SQL step can contain one or more SELECT statements. Other statements besides the SELECT statement can also appear in a PROC SQL step.
*/

/*******************************************************************************
2. Using PROC SQL to Query a Table
*******************************************************************************/
/* 2.1 Clauses of SELECT statement */
/*
Like many PROC SQL statements, the SELECT statement is composed of smaller elements called clauses. Each clause begins with a keyword.

A semicolon appears at the end of the entire SELECT statement, not after each clause.

SAS executes a PROC SQL query as soon as it reaches this semicolon, so you don't need to specify a RUN statement at the end of the step.
 SELECT column-1 <, column-2>…
        FROM table-1…
        <WHERE expression>
        <additional clauses> ; /*only one ';' here as RUN; */

The SELECT and FROM clauses are required in a SELECT statement. All other clauses, including the WHERE clause, are optional.

The SELECT clause specifies the columns to include in the query result.
SELECT column-1<, column-2>…
  FROM table-1…

An asterisk after SELECT indicates that all columns should be included.
The FROM clause specifies the table or tables that contain the columns.
  SELECT *
    FROM table-1…
*/
/* 2.2 Subsetting rows with the WHERE clause */
/*
To subset rows, you use the optional WHERE clause to specify a condition that must be satisfied for each row to be included in the PROC SQL output.
The condition, which is stated in an expression, can be any valid SAS expression.
SELECT column-1<, column-2>…
  FROM table-1…
  <WHERE expression>

*/
/* 2.3 Create an output table with the PROC SQL step instead of a report */
/*
To create an output table instead of a report, you can use the CREATE TABLE statement in your PROC SQL step.
The output table is a SAS data set.

CREATE TABLE table-name AS
       SELECT column-1 <, column-2>…
              FROM table-1…
              <WHERE expression>
              <additional clauses>;
*/
/*******************************************************************************
3. Using PROC SQL to Join Tables
*******************************************************************************/
/* 3.1 Cartesian product*/
/*
Using PROC SQL, you can join tables in different ways.

In the most basic type of join, PROC SQL combines each row from the first table with every row from the second table. The result of joining tables in this way is called the Cartesian product. In a Cartesian product, the number of rows is equal to the product of the number of rows in each of the source tables.

The Cartesian product of large tables can be huge. Typically, you want your result set to contain only a subset of the Cartesian product.
*/
/* 3.2 INNER JOIN of tables*/
/*
The other way that PROC SQL can join tables is by matching rows based on the values of a common column.
An inner join is a specific type of join that returns only a subset of the rows from the first table that matches the rows from the second table.

SELECT column-1<, column-2>…
       FROM table-1, table-2…
       <WHERE join-condition(s)>
       <additional clauses> ;

To join tables, you use the SELECT statement. A basic join uses only the two required clauses: SELECT to specify the columns that appear in the report, and FROM to specify the tables to be joined. The WHERE clause specifies one or more join-conditions used to combine and select rows for the result set. In addition to join-conditions, the WHERE clause can also specify an expression that subsets the rows.
*/
/* 3.2.1 Qualifying the column by specifying the table name */
/*
If the SELECT, FROM, or WHERE clause reference a column that has the same name in multiple tables, you must qualify the column by specifying the table name and a period before the column name.
*/
/* 3.2.2 Using aliases to qualify the column by specifying the table name */
/*
To make your code shorter and easier to read, you can replace the full table name in qualified column names with an alias.
SELECT column-1<, column-2>…
  FROM table-1 <AS> alias-1
           table-2 <AS> alias-2…
  <WHERE join-condition(s)>
  <additional clauses> ;

After the table name, you can optionally specify the keyword AS. Then, you specify the alias that you want to use for the table. An alias can be any valid SAS name.
*/

/*******************************************************************************
  Sample Programs
*******************************************************************************/
/* 1. Querying a Table to Create a Report */
proc sql;
   select Employee_ID, Job_Title, Salary
     from orion.sales_mgmt
     where Gender='M';
quit;

/* 2. Querying a Table to Create an Output Data Set */
proc sql;
   create table direct_reports as
   select Employee_ID, Job_Title, Salary
      from orion.sales_mgmt;
quit;

/* 3.2.1 Joining Tables by Using Full Table Names to Qualify Columns */
proc sql;
   select sales_mgmt.Employee_ID, Employee_Name,
          Job_Title, Salary
   from orion.sales_mgmt,
        orion.employee_addresses
   where sales_mgmt.Employee_ID =
         employee_addresses.Employee_ID;
quit;

/* 3.2.2 Joining Tables by Using Table Aliases to Qualify Columns */
proc sql;
select s.Employee_ID, Employee_Name, Job_Title, Salary
   from orion.sales_mgmt as s,
        orion.employee_addresses as a
   where s.Employee_ID =
         a.Employee_ID;
quit;
