/*******************************************************************************

Creating and Maintaining Permanent Formats - a collection of snippets

from Summary of Lesson 10: Creating and Maintaining Permanent Formats
SAS Programing 2 course focuses on using the SAS DATA step

- create permanent formats
- create formats from SAS data sets
- access permanent formats
- maintain formats
*******************************************************************************/


/*******************************************************************************
1. Creating Permanent Formats
*******************************************************************************/
/*1.1 define your own custom formats */
/*
You can use the FORMAT procedure to define your own custom formats for displaying values of variables.
The VALUE statement defines the format.
First, you specify a name for the format. Then, you specify how you want each value or range of values to be displayed.
  PROC FORMAT;
        VALUE format-name value-or-range1 = 'formatted-value1'
                          value-or-range2 = 'formatted-value2'
                          . . . ;
  RUN;

After the format is defined, you can apply it to a variable by using a FORMAT statement in a DATA step or PROC step.

In a FORMAT statement you must specify a period after the format name, the same way that you do for a SAS supplied format. You do not include a period after a user-defined format name when you create it.
*/
/*1.2 storing user-defined formats in a library*/
/*
User-defined formats are stored in a SAS catalog named work.formats, and are available for the duration of the SAS session. Work is a temporary library and its contents will be deleted when the session ends. Therefore the user-defined formats stored in work.formats will be deleted.

You can store user-defined formats in a permanent library. You can also create a format from an existing SAS data set instead including hard-coded values in a VALUE statement.
*/
/* 1.3 create a format from a SAS data set */
/*
To create a format from a SAS data set, the data set must contain value and label information, in specially named variables. This is called a control data set.
You specify the control data set name using the CNTLIN= option in the PROC FORMAT statement. The CNTLIN= option builds formats without using a VALUE statement.
 PROC FORMAT CNTLIN = SAS-data-set;

The control data set must contain variables that supply the same information that a VALUE statement would: FmtName, Start, Label, and possibly End and Type. FmtName must be assigned the name of the format, and has the same value in every observation in the control data set. Start contains a data value to be formatted, and Label contains the associated label to be displayed instead of that data value. If the format applies to a range of values, then Start specifies the first value in the range, and another variable, End, specifies the last value in the range. If no End variable exists, SAS assumes that the ending value of the format range is equal to the value of Start. The control data set must also contain the variable Type for character formats unless the value for FmtName begins with a dollar sign.

Most data sets do not contain the required variables, so you need to restructure them before you can use them as a control data set. You can restructure the data by using a DATA step or another PROC step. You can also create a control data set using an interactive application such as the VIEWTABLE window in the SAS windowing environment or the New Data Wizard in SAS Enterprise Guide.

Recall that user-defined formats are stored in the temporary catalog, work.formats. To permanently store frequently used formats in a permanent catalog, you add the LIBRARY= option to the PROC FORMAT statement.
If you specify only a libref without a catalog name, SAS permanently stores the format in the Formats catalog in that library.
If you specify a libref and a catalog name, SAS permanently stores the format in that catalog.
  PROC FORMAT LIBRARY = libref<.catalog>;
*/
/*******************************************************************************
2. Applying Permanent Formats
*******************************************************************************/
/* 2.1 Using permanent format  */
/*
When you reference a format, SAS searches for the format, loads it from the catalog entry into memory, performs a binary search on the format to execute the lookup, and returns a single result for each lookup.

When you use permanent formats, SAS automatically searches for formats in work.formats and then in library.formats. You can take advantage of this automatic search path by assigning the libref, library, to the SAS library that contains your formats catalog.

A better option is to use the FMTSEARCH= option to identify the locations of your permanent formats, and to control the order in which SAS searches for format catalogs.

You can use the OPTIONS statement to set the FMTSEARCH= option. After the keyword FMTSEARCH=, you list the catalog names in parentheses. SAS searches work.formats, then library.formats, and then the catalogs in the FMTSEARCH= list in the order that they are listed, until it finds the format.
  OPTIONS FMTSEARCH = (catalog-specification-1... catalog-specification-n);

If you use a format that SAS can't load, SAS issues an error message and stops processing the step. This behavior is due to the FMTERR system option which is in effect by default.
To prevent this default action, you can change the system option to NOFMTERR. This option replaces missing formats with the w. or $w. default format, issues a note and continues processing the program.
  OPTIONS NOFMTERR;

You can create a format that references and adds to an existing format. This technique is called nesting formats. In general, you should try to avoid nesting formats more than one level because the resource requirements increase dramatically with each additional level.

*/
/*******************************************************************************
3. Managing Permanent Formats
*******************************************************************************/
/* 3.1 CATALOG procedure*/
/*
When you create a large number of permanent formats, it's easy to forget the exact spelling of a specific format name or its range of values. You can use the CATALOG procedure to manage the entries in SAS catalogs.
  PROC CATALOG CATALOG = <libref.>catalog <options>;

To document your formats, you can add the FMTLIB option to the PROC FORMAT statement. The FMTLIB option prints a table of information for each format entry in the catalog specified in the LIBRARY= option. In addition to the name, range, and label, the format description includes the length of the longest label, the number of values defined by this format, the version of SAS this format is compatible with, and the date and time of creation.
  PROC FORMAT LIBRARY = libref.catalog FMTLIB;

As you create additional permanent formats, it's helpful to subset the catalog by adding the SELECT or EXCLUDE statement to the PROC FORMAT step to document only certain formats.
*/
/*******************************************************************************
4. Maintaining Permanent Formats
*******************************************************************************/
/* 4.1  */
/*
After you create a format, you might need to update it. If you created the format from a VALUE statement and saved the code, you can modify and resubmit the original PROC FORMAT step.

If the original program or control data set is not available, you can use the CNTLOUT= option to update a format. This option creates an output control data set from an existing format.

PROC FORMAT LIBRARY=libref.catalog
                           CNTLOUT=SAS-data-set;

You follow a three-step process for using the CNTLOUT= option to update a format. First, you submit a PROC FORMAT step using the CNTLOUT= option to create a SAS data set from the values in the format specified in the SELECT statement. Second, you edit the data set. To edit the data set you can use a DATA or PROC SQL step, or you can edit the data set interactively thru a Viewtable window or Data Grid. Third, you submit another PROC FORMAT step to re-create the format from the updated SAS data set using the CNTLIN= option.
*/
/*******************************************************************************
    Sample Programs
*******************************************************************************/
/* 1. Creating Permanent Formats */

data country_info;
   keep Start Label FmtName;
   retain FmtName '$country';
   set orion.country(rename=(Country=Start
                             Country_Name=Label));
run;

proc format library=orion cntlin=country_info;
run;

/* 2. Applying Permanent Formats */
options nofmterr fmtsearch=(orion);
data supplier_country;
   set orion.shoe_vendors;
   Country_Name=put(Supplier_Country, $country.);
run;
proc print data=supplier_country;
run;

/* 3. Nesting Formats */
proc format library=orion;
   value $extra
         ' '='Unknown'
         other=[$country30.];
run;

/* 1. Creating Permanent Formats */
Managing Permanent Formats

proc catalog catalog=orion.formats;
   contents;
run;

proc format library=orion fmtlib;
   select $country;
run;

/* 1. Creating Permanent Formats */
Maintaining Permanent Formats

proc format library=orion cntlout=countryfmt;
   select $country;
run;
Note: The countryfmt data set needs to be modified with code or by editing interactively.

proc format library=orion.formats cntlin=countryfmt fmtlib;
   select $country;
run;
