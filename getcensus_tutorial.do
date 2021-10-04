* TUTORIAL: getcensus (v 0.1.1)

/* 

For additional getcensus documentation, visit: 
https://centeronbudget.github.io/getcensus/ 

*/

* 1. Install getcensus ---------------------------------------------------------


* Install getcensus by running the following command:

net install getcensus, from("https://raw.githubusercontent.com/CenterOnBudget/getcensus/master/src")


* Now, check to see if Stata can locate getcensus:

which getcensus


* 2. Obtain a Census API key ---------------------------------------------------


/*

Sign up for a key here:
https://api.census.gov/data/key_signup.html

Now, direct getcensus to your API key by:

A) Adding the following line of code to your profile.do
   global censuskey "YOUR_KEY_HERE"

B) Including the following line at the top of any .do file using getcensus
   global censuskey "YOUR_KEY_HERE"

Learn more about your profile.do here:
https://www.stata.com/support/faqs/programming/profile-do-file/

*/


* 3. Check out the help file ---------------------------------------------------


help getcensus


* 4. Try out some basic queries ------------------------------------------------


* Retrieve a single estimate, number in poverty by state

getcensus b17001_002, clear


* Retreive more than one estimate (all estimates must be from the same table type)

getcensus B17001_001 b17001_002, clear


* Retrieve a full table, median household income by state

getcensus B19013, clear


* Specify a year

getcensus B19013, year(2016) clear


* Specify a geography

getcensus B19013, geography(county) clear


* Specify a year and a geography

getcensus B19013, year(2015) geography(county) clear


* Specify 3 years: 2015, 2016, and 2017

getcensus B19013, years(2015/2017) clear


* Specify 5 states by listing state FIPS codes in the geoids() option

getcensus B19013, geoids(24 51 11 48 06) clear


/*

Retreive the table for all counties in those 5 states by specifying
county in the geography() option and listing the state FIPS codes in the 
statefips() option

You can use statefips() rather than geoids() when your georgraphy() is
state or a sub-geography of state

*/

getcensus B19013, geography(county) statefips(24 51 11 48 06) clear


/*
 
Use geoids() to retrieve data on specific statistical geographic areas

When geoids() is a sub-geography of state and includes state or county code,
state code should be specified in statefips() and county code should be 
specified in countyfips()

geoids() should only contain the last component of the GEOID. 

*/

getcensus B19013, sample(5) geography(tract) statefips(01) countyfips(001) geoids(020100) clear


* Specify a geocomponent (a geographic unit defined by certain criteria)

getcensus B19013, geography(state) geocomponents(H0) clear


/*

Use one of getcensus' 12 built-in keywords to retrieve a curated set of
estimates. Keyword "snap" retrieves data on SNAP participation overall and
by poverty status, income, disability status, family composition, and family
work effort.

*/

getcensus snap, clear



* 5. Use the getcensus dialog box to form a query ---------------------------

/*

The dialog box provides full access to the program in an easy-to-use
interactive format.

*/

getcensus

* or

db getcensus


* 6. Export data as Stata or Excel file  ---------------------------------------


/*

To export data in Stata's native format, .dta, use the saveas() option.
The file will be exported to your current working directory.

*/

cd // Current working directory

getcensus B19013, saveas("getcensus_tutorial") clear  // Don't include file extension


/* 
To export data as an Excel spreadsheet, add the exportexcel option.
This saves a .xls/.xlsx  file in your working directory.
*/

getcensus B19013, saveas("getcensus_tutorial") exportexcel clear


* 7. Enter interactive mode ----------------------------------------------------


* Select one option from each section and then click "Retrieve my data"

getcensus


* 8. Use catalog mode to search the data dictionary ----------------------------


* Find all estimates and tables whose names include "poverty"

getcensus catalog, search(poverty) clear


* Find all estimates associated with table S1701

getcensus catalog, table(S1701) clear


* 9. Getting Help --------------------------------------------------------------

/* 

If you are having trouble installing getcensus, report your issue here:
https://github.com/CenterOnBudget/getcensus/issues 

*/

/*

Remember to check out getcensus' helpfile if you get stuck. You can access
it by running:

*/

help getcensus

/*

For further getcensus documentation, visit: 
https://centeronbudget.github.io/getcensus/

*/

* That's it! -------------------------------------------------------------------

* End of script ----------------------------------------------------------------

