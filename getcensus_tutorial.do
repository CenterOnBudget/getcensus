
* TUTORIAL: getcensus (v 0.1.1)


* 1. Install getcensus --------------------------------------------------------

* Install the program from GitHub
net install getcensus, from(https://raw.githubusercontent.com/CenterOnBudget/getcensus/master/src)

* Check to see if Stata can find getcensus
which getcensus

* If you don't see an error, skip to section 2.

* If you see an error, manually install getcensus by following these steps:

* 	A)	Download getcensus.
* 	   	From the GitHub repository page, click the green "Clone or Download"
*		button. Select "Download ZIP". Find the downloaded file and unzip it.

* 	B) 	Find your adopath
		adopath

* 	C) 	Copy getcensus.ado and getcensus.sthlp into your adopath. 
*    	If you wish to keep getcensus in a different folder, 
*		you will need to add that folder to your adopath in your profile.do.


* 2. Obtain a Census API key --------------------------------------------------

* Sign up for a key here: https://api.census.gov/data/key_signup.html
*
* Direct getcensus to your API key by:
*
* 	A)	Adding the following line of code to your profile.do
*
*	    global censuskey "YOUR_KEY_HERE"
*
*	 	Learn about where to find your profile.do file by visiting:
*		https://www.stata.com/support/faqs/programming/profile-do-file/
*
*	 Or,
*
*	 B) Including the following line at the top of any .do file using getcensus.
*
* 	  	global censuskey "YOUR_KEY_HERE"


* 3. Check out the help file --------------------------------------------------

help getcensus


* 4. Try out some basic queries -----------------------------------------------

* Note: The first time you run the command you may have to install a Stata 
* program called jsonio. 
* If it does not install automatically, run the following command:
* 		ssc install jsonio

* Retrieve a single estimate
getcensus B01001_001, clear

* Retreive more than one estimate 
* Note: all estimates in the list must be from the same table type.
getcensus B01001_001 B25001_001, clear

* Retrieve a table 
getcensus B01001, clear

* Retrieve a different table, and specify a year
getcensus B19013, years(2016) clear

* Specify a geography
getcensus B19013, geography(county) clear

* Specify both a year and a geography
getcensus B19013, years(2015) geography(county) clear

* Retrieve a table for three years: 2015, 2016, and 2017
getcensus B19013, years(2015/2017) clear

* Retrieve the table for a set of five states by listing the state FIPS codes
* in the geoids() option.
getcensus B19013, geoids(24 51 11 48 06) clear

* Retreive the table for all counties in the set of five states by specifying
* county in the geography() option and listing the state FIPS codes in the 
* statefips() option
getcensus B19013, geography(county) statefips(24 51 11 48 06) clear

* Use one of getcensus's 12 built-in keywords to retrieve a curated set of estimates
* SNAP participation overall and by poverty status, income, disability status, 
* family composition, and family work effort
getcensus snap


* 5. Export as .xlsx and .dta ------------------------------------------------

* To export data in Stata's native format, .dta, use the option saveas()

* The files will be exported to your current working directory, 
* which is: 
cd

getcensus B19013, saveas("getcensus_tutorial") clear  // don't include the file extension

* To export data as a spreadshset, add the exportexcel option
getcensus B19013, saveas("getcensus_tutorial") exportexcel clear

* Check that the files were exported
dir "getcensus_tutorial*"


* 6. Enter interactive mode ---------------------------------------------------

* Select one option from each section. Then click "Retrieve my data".
getcensus


* 7. Use catalog mode to search the data dictionary ---------------------------

* Find all estimates and tables whose names include "poverty"
getcensus catalog, search(poverty) clear

* Find all estimates associated with table S1701
getcensus catalog, table(S1701) clear


* That's it! Explore more on your own. ----------------------------------------
* Remember to check out getcensus's extensive help file if you get stuck. 
* View it by running:
* 		help getcensus

