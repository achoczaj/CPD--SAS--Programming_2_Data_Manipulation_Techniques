/****************************************************
Functions Manipulating Character Values - a collection of snippets

from Summary of Lesson 4: Manipulating Character Values
SAS Programing 2 course focuses on using the SAS DATA step

- extract a portion of a character value from a specified position
- change the case of a character value
- separate the values of one variable into multiple variables
- put multiple values together into one value
- remove blanks from a character value
- search a character value to find a particular string
- replace a portion of or all of the contents of a character value
*******************************************************************************/


/*******************************************************************************
1. Using SAS Functions
*******************************************************************************/

A SAS function is a routine that performs a calculation on, or a transformation of, the arguments listed in parentheses and returns a value.

target-variable = function-name(<argument-1><,argument-n>)

A target variable is a variable to which the result of the function is assigned. If the target variable is a new variable, the type and length are determined by the expression on the right side of the equals sign.
If the expression uses a function whose result is numeric, then the target variable is numeric with a length of 8 bytes. If the expression uses a function whose result is character, then the target variable is character and the length is determined by the function.


/*******************************************************************************
2. Extracting and Transforming Character Values
*******************************************************************************/

Function	Purpose
var = SUBSTR(string, start<,length>)
On the right side of an assignment statement, the SUBSTR function extracts a substring of length characters from a character string, starting at a specified position in the string.

LENGTH(argument)
The LENGTH function returns the length of a character string, excluding trailing blanks.

RIGHT(argument)
The RIGHT function right-aligns a value. If there are trailing blanks, they are moved to the beginning of the value.

LEFT(argument)
The LEFT function left-aligns a character value. If there are leading blanks, they are moved to the end of the value.

CHAR(string, position)
The CHAR function returns a single character from a specified position in a character string.

PROPCASE(argument <,delimiter(s)>)
The PROPCASE function converts all letters in a value to proper case.

UPCASE(argument)
The UPCASE function converts all letters in a value to uppercase.

LOWCASE(argument)
The LOWCASE function converts all letters in a value to lowercase.


/* extract a string from a specific position in a character value */
DATA charities1(DROP=Len);
	/* use LENGTH to declare the type and length of new variable */
	LENGTH ID $ 5;

	SET orion.biz_list;
	len=LENGTH(Acct_Code);

	IF SUBSTR(Acct_Code, len, 1)='2';
	  ID = SUBSTR(Acct_Code, 1, len-1);
RUN;

PROC PRINT DATA=charities1 NOOBS;
RUN;


/* another way to extract the identification code from Acct_Code by using SUBSTR with the RIGHT, LEFT, and CHAR functions. */

DATA charities2 (DROP=temp_Rt);
   SET orion.biz_list;

   /* use LENGTH to declare the type and length of new variable */
   LENGTH ID $ 5;

   temp_Rt = RIGHT(Acct_Code);
   IF CHAR(temp_Rt, 6)='2';
   	 ID = LEFT(SUBSTR(temp_Rt, 1, 5));
RUN;

PROC PRINT DATA=charities2 NOOBS;
RUN;


/*use a function to change the case of character values*/
DATA charities3 (DROP=Len);
   SET orion.biz_list;
   /* use LENGTH to declare the type and length of new variable */
   LENGTH ID $ 5;

   len = LENGTH(Acct_Code);
   IF SUBSTR(Acct_Code, len, 1)='2';
     ID = SUBSTR(Acct_Code, 1, len-1);
     Company_Name = PROPCASE(name);
RUN;

PROC PRINT DATA=charities3 noobs;
   VAR ID Company_Name;
RUN;



/*---PRACTICE 1---*/
/*
Extract Characters Based on Position

Task:
In this practice, you create several new variables by extracting characters from the values of existing variables.
The data set orion.au_salesforce contains employee data for the Sales branch in Australia. Orion Star wants to create user ID codes for logging on to the Australian Sales intranet site. Each user ID will consist of the first letter of the first name, the final letter of the first name, and the first four letters of the last name. All these letters should be in lowercase.

Reminder: Make sure you've defined the Orion library.
1. Read orion.au_salesforce and create a new data set named work.codes.
2. Create three new variables. Make all the values lowercase in the new variables.
3. FCode1 contains the first letter of the variable First_Name.
4. FCode2 contains the final letter of the variable First_Name.
5. LCode contains the first four letters of the variable Last_Name.
6. Print the resulting data set. Include only the variables First_Name, FCode1, FCode2, Last_Name, and LCode. Add an appropriate title.
7. Submit your code and verify the results.

RESULTS:
In your results, you can verify that FCode1 and FCode2 have the first and last letter of First_Name. You can also verify that LCode has the first four letters of Last_Name.
*/

DATA work.codes;
  SET orion.au_salesforce;

  LENGTH FCode1 FCode2 $ 1 LCode $ 4;

  /* FCode1 contains the first letter of the variable First_Name */
  FCode1 = LOWCASE( SUBSTR( LEFT(First_Name), 1, 1));

  /* FCode2 contains the final letter of the variable First_Name */
  FCode2 = LOWCASE( SUBSTR( First_Name, LENGTH(First_Name), 1));

  /* LCode contains the first four letters of the variable Last_Name  */
  LCode = LOWCASE(SUBSTR( LEFT(Last_Name), 1, 4));

RUN;

TITLE 'Extracted letters';
PROC PRINT DATA=work.codes;
  VAR First_Name FCode1 FCode2 Last_Name LCode;
RUN;
TITLE;

/*---PRACTICE 2---*/
/*
Extract Characters Based on Position and Subset Data

Task:
In this practice, you extract a character from a variable and use it to create a data set containing a subset of data.
The data set orion.newcompetitors contains data on competing retail stores that have recently opened near existing Orion Star locations.
AU15301W	PERTH	6002
AU12217E	SYDNEY	2000
CA   150	Toronto	M5V 3C6

Reminder: Make sure you've defined the Orion library.
1. Read orion.newcompetitors and create a data set named work.small containing just the small retail stores from these observations.
2. The first numeral in the value of ID indicates the size of the store, and 1 is the code for a small retail store.
Notice that the first numeral occurs at different positions in ID, but never occurs in positions 1 or 2.
3. Write a program to output these observations to the data set Small.
Hint: You might need to use two SUBSTR functions to extract the first numeral in ID.
4. Make sure that the City values appear in proper case.
5. Print your results with an appropriate title.

RESULTS:
The data set work.small has 5 observations.
*/

DATA work.small;
  SET orion.newcompetitors;

  	WHERE SUBSTR( LEFT( SUBSTR(ID, 3)), 1, 1) = '1';
	City = PROPCASE(City);

RUN;

TITLE 'List of small retail stores';
PROC PRINT DATA=work.small NOOBS;

RUN;
TITLE;


/*******************************************************************************
3. Separating and Concatenating Character Values
*******************************************************************************/

You use the SCAN function when you know the relative order of words but their starting positions vary. You use the SUBSTR function when you know the exact position of the string that you want to extract from a character value.

3.1 SCAN function

Functions Separating and Concatenating Character Values:
SCAN (string, n <,'delimiter(s)'>)
The SCAN function separates a character value into words and returns the nth word.
N specifies which word to read. A missing value is returned if there are fewer than N words in the string. If N is negative, SCAN finds the word in the character string by starting from the end of the string.
If you don't specify a delimiter, SAS looks for default delimiters such as a blank, a comma, a forward slash, or a period.

phrase = 'softwear and services'
item_1 = SCAN(phrase, 1, ' '); /* 1 --> first word --> 'softwear' */
item_2 = SCAN(phrase, 3, ' '); /* 3 --> third word --> 'services' */

fruits = 'Mango, kiwi, papaya, banana'
/* use only one delimiter: ',' */
fruit_1 = SCAN(fruits, 1, ','); /* 1 --> first word --> 'Mango' */
fruit_2 = SCAN(fruits, 2, ','); /* 1 --> first word --> ' kiwi' */
fruit_3 = SCAN(fruits, 3, ','); /* 1 --> first word --> ' papaya' */
fruit_4 = SCAN(fruits, 4, ','); /* 1 --> first word --> ' banana' */
/*Some variables will contain one leading blank. There is a leading blank in the values because only the comma is specified as the delimiter.*/

fruits = 'Mango, kiwi, papaya, banana'
/* use two delimiters: ',' and ' ' together*/
fruit_1 = SCAN(fruits, 1, ', '); /* 1 --> first word --> 'Mango' */
fruit_2 = SCAN(fruits, 2, ', '); /* 1 --> first word --> 'kiwi' */
fruit_3 = SCAN(fruits, 3, ', '); /* 1 --> first word --> 'papaya' */
fruit_4 = SCAN(fruits, 4, ', '); /* 1 --> first word --> 'banana' */


DATA labels;
	SET orion.contacts;

	/* use LENGTH to declare the type and length of new variable */
	LENGTH F_M_Name L_Name $ 15;

	L_Name = SCAN(Name, 1, ',');
	F_M_Name = SCAN(Name, 2, ',');
RUN;
PROC PRINT DATA=labels;
RUN;

Question:
In this DATA step, which SCAN function completes the assignment statement to correctly extract the four-digit year from the Text variable? Select all that apply.
data Scan_Quiz;
   Text="New Year's Day, January 1st, 2007";
   Year=________________________;
run;

OK a.   scan(Text,-1)
OK b.   scan(Text,6)
OK c.   scan(Text,6,', ')
All of these SCAN functions extract 2007 from the string in the Text variable.


3.2 CATX function

CATX (separator, string-1,…,string-n)
The CATX function removes leading and trailing blanks, inserts separators, and returns a concatenated character string.

3.2.1 '!!' or '||' - concatenation operator
NewVar = string-1 !! String-2;
or
NewVar = string-1 || String-2;

The concatenation operator joins character strings.

Example:
Suppose you want to concatenate the values in Area_Code and Number and store them in the variable Phone. This assignment statement uses the concatenation operator to create the value in Phone.
Area_Code = '919  ' /* $ 15 */
Number = '531-0000' /* $ 8 */
Phone = '(' || Area_Code || ') ' || Number;
/* so Phone $ 26 <-- 1+15+2+8 */
/* Phone = '(919      ) 531-0000' */
The length of the variable Phone is the sum of the length of each variable and the constants that are used to create the new variable. Here, the length of Phone is 26.
The value of the new variable has embedded blanks because Area_Code contains trailing blanks. Whenever the value of a character variable does not match the length of the variable, SAS pads the value with trailing blanks.
You can use other SAS functions to remove blanks from strings.


3.3 TRIM and STRIP functions

TRIM (argument)
The TRIM function removes trailing blanks from a character string.

STRIP (argument)
The STRIP function removes leading and trailing blanks from a character string.

Example:
Use the TRIM function to remove the trailing blanks from Area_Code before concatenating the string.
Area_Code = '919  ' /* $ 15 */
Number = '531-0000' /* $ 8 */
Phone = '(' || TRIM(Area_Code) || ') ' || Number;
/* so Phone $ 26 <-- 1+15+2+8 */
/* Phone = '(919) 531-0000' */


3.4  family of CAT functions
that you can use to perform a variety of concatenations

CAT (string-1,…,string-n)
CATT (string-1,…,string-n)
CATS (string-1,…,string-n)
CATX (separator, string-1,…,string-n)

These functions return concatenated character strings.
The CAT function does not remove any leading or trailing blanks.
The CATT function trims trailing blanks.
The CATS function strips leading and trailing blanks.
The CATX function removes leading and trailing blanks, inserts separators, and returns a concatenated character string.

Example:
Use the TRIM function to remove the trailing blanks from Area_Code before concatenating the string.
Area_Code = '919  ' /* $ 15 */
Number = '531-0000' /* $ 8 */
CAT_Phone = CAT( '(', Area_Code, ') ', Number);
/* so Phone $ 200 <--  default value, unless it's defined by a LENGTH statement */
/* Phone = '(919  ) 531-0000' */

CATT_Phone = CATT( '(', Area_Code, ') ', Number);
/* so Phone $ 200 <--  default value, unless it's defined by a LENGTH statement */
/* Phone = '(919)531-0000' */
/* CATT trims the trailing blanks from Area_Code. */


/*******************************************************************************
4. Finding and Modifying Character Values
*******************************************************************************/

4.1 Finding and Modifying Character Values Functions:

FIND (string, substring <,modifiers, start>)
The FIND function searches for a specific substring of characters within a character string. The function returns the starting position of the first occurrence of the substring. If the substring is not found in the string, FIND returns a value of 0.
Substring specifies the characters to search for in string.
Optional arguments can be used to modify the search. They can be specified in any order.
The modifier 'I' causes the FIND function to ignore character case during the search. If I is not specified, FIND searches for the same case as the characters specified in substring.
The modifier 'T' trims trailing blanks from string and substring.
Start indicates where in the string to start searching for the substring.
It also specifies the direction of the search. A positive value indicates a forward or right search. A negative value indicates a backward or left search. If you don't specify anything for start, the search starts at position 1 and moves forward.

4.2 Replacing Characters in a Value Using the SUBSTR Function

SUBSTR(string, start <,length>) = value;
On the left side of the assignment statement, the SUBSTR function replaces length characters at a specified position with value.

String specifies the character variables whose values are to be modified. Start specifies the starting position where the replacement is to begin.
Length specifies the number of characters to replace in string. If you don't specify length, all characters from the start position to the end of the string are replaced. If you specify a value for length, it can't be greater than the remaining length of string (including trailing blanks).

Example:
Location = 'Columbus, GA, 43227';
SUBSTR(Location, 11, 2) = 'OH';
/* Location = 'Columbus, OH, 43227' */


4.3 Replacing Characters in a Value Using the TRANWRD Function

TRANWRD(source, target, replacement)
The TRANWRD function replaces or removes all occurrences of a given word (or a pattern of characters) within a character string.
It is different from the SUBSTR function because you don't have to specify the position of the string you want to replace.

Source specifies the source string that you want to change.
Target specifies the string to search for in source and replacement specifies the string that replaces target.
Target and replacement can be variables or character strings. If you specify character strings, be sure to enclose the strings in quotation marks.
New variables created by the function have a default length of 200 bytes if a LENGTH statement is not used.

Example A:
Product_Tags = 'Cap,Small,Red';
Update1_Product_Tags = TRANWRD(Product_Tags, 'Small', 'Medium');
Update2_Product_Tags = TRANWRD(Product_Tags, 'Red', 'purple');
Update3_Product_Tags = TRANWRD(Product_Tags, 'red', 'blue');
/* Update1_Product_Tags = 'Cap,Medium,Red', $ 200 <-- default value*/
/* Update2_Product_Tags = 'Cap,Small,purple', $ 200 <-- default value*/
/* Update3_Product_Tags = 'Cap,Small,Red', $ 200 <-- default value*/

/* In the third example, the TRANWRD function looks in Product_Tags for lowercase 'red'. In Product_Tags, 'Red' has an initial cap, so lowercase 'red' does not match and the string is not replaced with 'blue' as specified in the function arguments.
Keep in mind that when you specify the target, it must match the case of the values in the variable.
In this example, the TRANWRD functions were used to create the new variables Update1_Product_Tags through Update3_Product_Tags. When the TRANWRD function is used in an assignment statement that creates a new variable, the default length of the variable is 200 bytes.
*/

Example B:
Product_Tags = 'Cap,Small,Red'; /* assigned as $ 13*/
Product_Tags = TRANWRD(Product_Tags, 'Red', 'purple');
/* Product_Tags = 'Cap,Medium,pur', $ 13 <-- default value*/
/* TRANWRD function replaces the string Red with the string Purple and assigns it to Product. Product was originally created in this assignment statement and assigned a length of 13.
The new value is 16 characters, so the value is truncated.
If you use the TRANWRD function to replace an existing string with a longer string, you may need to use a LENGTH statement so that the value is not truncated.  */
LENGHT Product_Tags  $ 16;
Product_Tags = 'Cap,Small,Red';
Product_Tags = TRANWRD(Product_Tags, 'Red', 'purple');
/* Product_Tags = 'Cap,Medium,purple', is OK as $ 16 */


4.4 Removing Characters in a Value Using the COMPRESS Function

COMPRESS(source <,chars>)
The COMPRESS function removes the characters listed in the chars argument from the source. If no characters are specified, the COMPRESS function removes all blanks from the source.
If no characters are specified, the COMPRESS function removes all blanks from the source.
If the function creates a new variable, the new variable has the same length as the source.

Example:
ID = '20 01-005 024'; /* $ 13*/
New_ID1 = COMPRESS(ID);
New_ID2 = COMPRESS(ID, '-');
New_ID3 = COMPRESS(ID, ' -');
/* New_ID1 = '2001-005024', $ 13*/
/* New_ID2 = '20 01005 024', $ 13*/
/* New_ID3 = '2001005024', $ 13*/
/*
In the first example, only the source, ID, is specified, so the blanks are removed and the new value is assigned to New_ID1.
In the second example, a hyphen is specified, so the hyphen is removed and the new value is assigned to New_ID2. As in other functions, if you specify a character to remove in the arguments, the default blank is no longer in effect.
In the third example, the blank and hyphen are both specified and both blanks and the hyphen are removed from the value. The new value is assigned to New_ID3.*/

/*******************************************************************************
Sample Programs
*******************************************************************************/

/* Extracting and Transforming Character Values */
data charities(drop=Code_Rt);
   length ID $ 5;
   set orion.biz_list;
   Code_Rt=right(Acct_Code);
   if char(Code_Rt,6)='2';
   ID=left(substr(Code_Rt,1,5));
run;

data charities;
   length ID $ 5;
   set orion.biz_list;
   if substr(Acct_Code,length(Acct_Code),1)='2';
   ID=substr(Acct_Code,1,length(Acct_Code)-1);
   Name=propcase(Name);
run;

data charities(drop=Len);
   length ID $ 5;
   set orion.biz_list;
   Len=length(Acct_Code);
   if substr(Acct_Code,Len,1)='2';
   ID=substr(Acct_Code,1,Len-1);
   Name=propcase(Name);
run;

/* Separating and Concatenating Character Values */
data labels;
   set orion.contacts;
   length FMName LName $ 15
          FullName $ 50;
   FMName=scan(Name,2,',');
   LName=scan(Name,1,',');
   FullName=catx(' ',title,fmname,lname);
run;

/* Finding and Modifying Character Values */
data correct;
   set orion.clean_up;
   if find(Product,'Mittens','I')>0 then do;
      substr(Product_ID,9,1) = '5';
      Product=tranwrd(Product,'Luci ','Lucky ');
   end;
   Product=propcase(Product);
   Product_ID=compress(Product_ID);
run;
