* TUTORIAL: getcensus (v 0.1.1)


* 1. Install getcensus ---------------------------------------------------------


* Install getcensus by running the following command:

net install getcensus, from("https://raw.githubusercontent.com/CenterOnBudget/getcensus/master/src")


* Now, check to see if Stata can locate getcensus:

which getcensus


* If you don't get an error, move on to the next section


* If you get an error, manually install getcensus by following these steps:

/*

A) Download getcensus
   Go to the GitHub repository page for getcensus and click the green
   "Clone or Download" button. Select "Download ZIP" and unzip the
   downloaded file.

B) Locate your adopath
   Run the following command to locate you adopath:
   adopath

C) Copy getcensus.ado and getcensus.sthlp into your adopath
   If you want to keep getcensus in a different folder, you will need to
   add that folder to your adopath in your profile.do.


Here is the link to GitHub repository page for getcensus:
https://github.com/CenterOnBudget/getcensus

And you can learn more about your profile.do here:
https://www.stata.com/support/faqs/programming/profile-do-file/

*/


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


/* 

Note:

The first time you run getcensus you may have to install a Stata  program
called jsonio. If it does not install automatically, run the following
command:

ssc install jsonio

*/


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

*/

getcensus B19013, geography(county) statefips(24 51 11 48 06) clear


/*

Use one of getcensus' 12 built-in keywords to retrieve a curated set of
estimates. Keyword "snap" retrieves data on SNAP participation overall and
by poverty status, income, disability status, family composition, and family
work effort.

*/

getcensus snap, clear


* 5. Export data as Stata or Excel file  ---------------------------------------


/*

To export data in Stata's native format, .dta, use the saveas() option.
The file will be exported to your current working directory.

*/

cd // Current working directory

getcensus B19013, saveas("getcensus_tutorial") clear  // Don't include file extension


* To export data as an Excel spreadshset, add the exportexcel option

getcensus B19013, saveas("getcensus_tutorial") exportexcel clear


* 6. Enter interactive mode ----------------------------------------------------


* Select one option from each section and then click "Retrieve my data"

getcensus


* 7. Use catalog mode to search the data dictionary ----------------------------


* Find all estimates and tables whose names include "poverty"

getcensus catalog, search(poverty) clear


* Find all estimates associated with table S1701

getcensus catalog, table(S1701) clear


* That's it! -------------------------------------------------------------------


/*

Remember to check out getcensus' helpfile if you get stuck. You can access
it by running:

*/


help getcensus


* End of script ----------------------------------------------------------------

