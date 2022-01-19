* TUTORIAL: getcensus 


																				
* 1. Installation -------------------------------------------------------------

* Install getcensus with:

ssc install getcensus



* 2. Set up Census Bureau API key ---------------------------------------------

																				/*
Sign up for an API key here:

https://api.census.gov/data/key_signup.html


Store your API key to avoid specifying the key() option each time you use 
getcensus by either: 

	Adding the following line of code to your profile.do

			global censuskey "your-api-key-here"
			
	   Learn about where to find your profile.do here: 
	   https://www.stata.com/support/faqs/programming/profile-do-file/

	Including the following line at the top of any .do file using getcensus
			global censuskey "your-api-key-here" 
																				*/


* 3. Help file and online documentation ---------------------------------------
																				/*
View the help file:												
																				*/
	help getcensus
																				/*	
Visit the online documentation:

	https://centeronbudget.github.io/getcensus/
																				*/


* 8. Search the API data dictionary -------------------------------------------

																				/*
To find the variable ID or table ID of the data points you're interested in, 
use getcensus catalog to search the API data dictionaries.


Use table() all estimates in a table
																				*/
getcensus catalog, table(S1701) clear

																				/*
Use search() and product() to find estimates and tables matching a search term 
within a given product type.
																				*/
getcensus catalog, search(poverty) product(ST) clear


										
* 4. Basic queries ------------------------------------------------------------

																				/* 
Retrieve a table
																				*/
getcensus B19013, clear

																				/* 
Retrieve a single estimate
																				*/
getcensus S1701_C02_001, clear

																				/* 
Retrieve more than one estimate 
	Estimates can be from different tables, as long as those tables are of the
	same product type (e.g., detailed table)
																				*/
getcensus S1701_C02_001 S1701_C03_001, clear

																				/* 
Use one of getcensus' 12 built-in keywords to retrieve a curated set of
estimates. 

A list of keywords can be found in the help file:
	help getcensus##keywords
	
The keyword "snap" retrieves data on the percent of households 
participating in SNAP and characteristics of participating households.
																				*/
getcensus snap, clear



* 5. Options ------------------------------------------------------------------

																				/* 
By default, getcensus retrieves 1-year estimates for states for the most recent 
available year.


Specify a year
																				*/
getcensus B19013, year(2018) clear

																				/* 
Specify a range of years
																				*/
getcensus B19013, years(2017/2019) clear

																				/* 
Specify a sample (1-, 3-, or 5-year estimates)
																				*/
getcensus B19013, sample(5) clear

																				/* 
Specify a geography
																				*/
getcensus B19013, geography(county) clear

																				/* 
Specify a year and a geography
																				*/
getcensus B19013, year(2018) geography(county) clear

																				/* 
Specify states by listing state FIPS codes in the statefips() option
																				*/
getcensus B19013, statefips(11)
getcensus B19013, statefips(24 51 11) clear

																				/*
Retreive the table for all counties within states by specifying 'county' in the 
geography() option and listing state FIPS codes in the statefips() option
																				*/
getcensus B19013, geography(county) statefips(24 51 11 48 06) clear
																				/*
You can use statefips() with any geography that is nested within a state.
A list of those geographies can be found in the help file:
	help getcensus##geographies
																				
																				
Use geoids() to retrieve data on a specific geographic unit

geoids() should only contain the last component of the GEOID. If the geography 
is nested within a state, the state code portion of the GEOID should be 
specified in statefips(). 
																				*/
getcensus B19013, geography(county) statefips(24) geoids(005 510)
																				/*
If the geography is nested with a county, the county code should be specified 
in countyfips().
																				*/
getcensus B19013, sample(5) geography(tract) statefips(01) countyfips(001) geoids(020100) clear

																				/*
Use geocomponent() to retrieve data for geographic components, which are 
divisions of a geography by certain criteria (e.g., in metropolitan area, rural)

A list of geographic component codes can be found in the help file:
	help getcensus##geographies
																				*/
getcensus B19013, geography(state) geocomponents(H0) clear



* 6. Export data as Stata or Excel file  ---------------------------------------

																				/*
To export data in Stata's native format, .dta, use the saveas() option. 
																				
Specify a file name to save the data in your current working directory. (Don't 
include a file extension.)
																				*/
getcensus B19013, saveas("getcensus_tutorial") clear 
																				/*
Specify a file path to save the data somewhere else. (Don't include a file 
extension.)
																				*/
* getcensus B19013, saveas("my_drive/folder/getcensus_tutorial") clear

																				/*
To also export data as an Excel spreadsheet, add the exportexcel option.
																				*/
getcensus B19013, saveas("getcensus_tutorial") exportexcel clear 



* 7. Dialog box ---------------------------------------------------------------

																				/*
The getcensus dialog box provides full access to the program in an easy-to-use 
interactive format.

To open the dialog box, run:
																				*/
getcensus



* 8. Getting help --------------------------------------------------------------

																				/*
View the help file:												
																				*/
	help getcensus
																				/*	
Visit the online documentation:

	https://centeronbudget.github.io/getcensus/

	
If you think you've found a bug, file an issue on GitHub:

	https://www.github.com/CenterOnBudget/getcensus/issues
																				*/


																				