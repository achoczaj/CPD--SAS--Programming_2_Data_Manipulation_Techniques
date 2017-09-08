/*******************************************************************************

Using Iterative DO Loops - a collection of snippets

from Summary of Lesson 7: Using Iterative DO Loops
SAS Programing 2 course focuses on using the SAS DATA step

- explain iterative DO loops
- construct a simple DO loop to eliminate redundant code and repetitive calculations
- execute DO loops conditionally
- construct nested DO loops
*******************************************************************************/


/*******************************************************************************
1. Constructing a Simple DO Loop
*******************************************************************************/
/*
Iterative DO loops simplify your code, avoiding repetitive code and redundant calculations. An iterative DO loop executes the statements between the DO and the END statements repetitively.

DO index-variable = start-value TO stop-value <BY increment>;
       iterated SAS statements…
END;

Start and stop values must be numeric constants or expressions that result in a numeric value. If you do not specify an increment for a DO loop, the increment defaults to 1. If the start value is greater than the stop value, you must specify an increment that is negative.


You can use an item list rather than a start and stop value to control your DO loop. The items can be variables or constants, and must be all numeric or all character. The DO loop is executed once for each item in the list.

DO index-variable = item-1 <,… item-n>;
      iterated SAS statements…
END;


You can use an OUTPUT statement within a DO loop to explicitly write an observation to the data set on each iteration of the DO loop.

Egample:
In the data set invest, what would be the stored value for Year?
*/
data invest;
   do Year=2008 to 2012;
      Capital+5000;
      Capital+(Capital*.03);
   end;
run;
/*
The DO loop shown here executes five times.
The initial value for Year is 2008.
At the end of the fifth iteration of the DO loop, the value for Year is incremented to 2013.
Because this value exceeds the stop value, the DO loop ends.
Then, at the bottom of the DATA step, the current values are written to the output data set.
*/


/*******************************************************************************
2. Conditionally Executing DO Loops
*******************************************************************************/
/*
There are two types of conditional DO loops: DO UNTIL and DO WHILE. In a DO UNTIL loop, SAS executes the loop until the condition specified in the DO UNTIL statement is true. Even though the expression is written at the top of the loop, in a DO UNTIL it is evaluated at the bottom of the loop, after each iteration.

The statements in a DO UNTIL loop will always execute at least once.

DO UNTIL (expression);
     iterated SAS statements…
END;

In a DO WHILE statement, SAS executes the loop while the specified condition is true. The condition is evaluated at the top of the loop, before the statements in the loop are executed. If the condiiton is initially false, the statements in a DO WHILE loop will not execute at all.

DO WHILE (expression);
    iterated SAS statements…
END;


It is possible to create a DO WHILE or a DO UNTIL loop that executes infinitely. You should write your conditions and iterated statements carefully.

You can also combine a DO UNTIL or DO WHILE loop with an iterative DO loop. In this case, the loop executes either until the value of the index variable exceeds the stopping value or until the condition is met. This can be used to avoid creating an infinite loop.

DO index-variable=start TO stop <BY increment>
      UNTIL | WHILE (expression);
      iterated SAS statements…
END;
*/

/*******************************************************************************
3. Nesting DO Loops
*******************************************************************************/
/*
Nesting DO Loops
You can nest DO loops in a DATA step. Be sure to use different index variables for each loop, and be certain that each DO statement has a corresponding END statement.

DO index-variable-1=start TO stop <BY increment>;
       iterated SAS statements…
       DO index-variable-2=start TO stop <BY increment>;
             iterated SAS statements…
       END;
       iterated SAS statements…
END;


data invest (drop=Quarter);
   do Year=1 to 5;
      Capital+5000;
      do Quarter=1 to 4;
         Capital+(Capital*(.045/4));
      end;
      output;
   end;
run;
proc print data=invest;
run;

*/

/*******************************************************************************
3. Sample Programs
*******************************************************************************/

/* 1. Using Iterative DO Loops */
data compound;
   Amount=50000;
   Rate=.045;
   do i=1 to 20;
      Yearly+(Yearly+Amount)*Rate;
   end;
   do i=1 to 80;
      Quarterly+((Quarterly+Amount)*Rate/4);
   end;
run;
proc print data=work.compound;
run;

/* 2. Using a DO Loop to Reduce Redundant Code */
data forecast;
   set orion.growth;
   do Year=1 to 6;
      Total_Employees=
         Total_Employees*(1+Increase);
      output;
   end;
run;
proc print data=forecast noobs;
run;

/* 3. Conditionally Executing DO Loops */
data invest;
   do until (Capital>1000000);
      Year+1;
      Capital+5000;
      Capital+(Capital*.045);
   end;
run;
proc print data=invest noobs;
run;

data invest2;
   do while (Capital<=1000000);
      Year+1;
      Capital+5000;
      Capital+(Capital*.045);
   end;
run;
proc print data=invest2 noobs;
run;


/* 4. Using an Iterative DO Loop with a Conditional Clause */
data invest;
   do year=1 to 30 until (Capital>250000);
      Capital+5000;
      Capital+(Capital*.045);
   end;
run;

data invest2;
   do year=1 to 30 while (Capital<=250000);
      Capital+5000;
      Capital+(Capital*.045);
   end;
run;

proc print data=invest;
   title "Invest";
   format Capital dollar14.2;
run;

proc print data=invest2;
   title "Invest2";
   format Capital dollar14.2;
run;
title;

/* 5. Nesting DO Loops */
data invest (drop=Quarter);
   do Year=1 to 5;
      Capital+5000;
      do Quarter=1 to 4;
         Capital+(Capital*(.045/4));
      end;
      output;
   end;
run;

proc print data=invest;
run;
