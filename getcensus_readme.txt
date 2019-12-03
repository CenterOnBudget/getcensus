/*******************************************************************************
* File Name: getcensus.ado
*
* File location:
*
* Author(s): Raheem Chaudhry, Vincent Palacios
*
* Start Date: 3/26/2019
*
* Revision Date: 
* 
* Inputs:
* 
* Description: This program is built on top of Vincent and Raheem's "censusapi"
* program.This differs in how it imports data and in some of the defaults.
* This program is meant to make it easier for data analysts to access estimates
* from Census through its API.
*
* Version 1
*******************************************************************************/

/*******************************************************************************
** TESTS
*******************************************************************************/

/*
getcensus B01001_001, geo(state) clear
getcensus B01001_001, geo(county) clear
getcensus B01001_001, geo(metro) clear

getcensus B01001_001, geo(state) years(2012-2017) clear
getcensus C17001_001 C17001_002 C17001_003, geo(metro) years(2012-2017) clear

getcensus S1701, geo(metro) years(2012-2017) clear

*/

/*******************************************************************************
** FUNCTIONALITY
*******************************************************************************/

/*******************************************************************************
** MAJOR CHANGES FROM censusapi
*******************************************************************************/

OVERALL STRUCTURE
Three programs in the overall program: main program (basically unchanged, catalog
(which used to be a separate program), and a point-and-click helper program.

MAIN PROGRAM
- Imports directly from API (without use of insheetjson)
- Gets additional years of data
- Figures out product (e.g., detailed table) from estimate name
- Can get entire table instead of indivdiual estiamtes
- Automatically labels retrieved estimates

POINT AND CLICK SYSTEM
There is a system where you can click options in the Results window to retrieve
estimates.

CATALOG
Now takes a search() and table() parameter

DEPENDENCIES
- Need jsonio
- No longer need insheetjson or libjson

PRE-PACKAGED TABLES
There are keywords to get a set of curated estimates

NEW OPTIONS
- Export as CSV
- Don't label
- No error terms

HELP FILE
Can click to run example commands
Shows (and can click) curated tables

/*******************************************************************************
** TO DO
*******************************************************************************/

TESTS
test fully after making all these changes

CHANGES
what to do about global syntax? alternative, just copy into several different places
more pre packaged tables?
clearer key words
help file add period available under geographies for year option [ask vincent what he meant]
where does it report dataset to the user (ie, 1 vs 5)?


ERROR MESSAGES
if metro and state, explain that you have to identify a single metro area to get a protion within a state; 
taht is, the census api doesn't let you get all metro areas that are in texas
if catalog, we ignore geography, geoids, statefips, county, key, saveas export nolabel noerror
exit errors (otherwise you can't do if !_rc)
error if no arguments passed but options are (if no arguments passed including catalog, it will assume you want just the tips)

MAJOR CHANGE: Should we only run errors if there is a server error? Or should
we not exit on error? The reason is because api may change to include earlier
or later years and we don't want it to exit out if it's possible it will work
(Right now changed so that it exits on all errors EXCEPT displays as warning
if product type and year don't align)

ROLLOUT
Codebyte
Webinar
follow up with nick on web page
Beta testing

BUGS

/*******************************************************************************
** DONE
*******************************************************************************/

TESTS
Run links in help file
data dictionary for CP and DP
does syntax global get dropped?

CHANGES
Help file should include links to ACS documentation

change "sd" to "sch" or "schooldistrict"
clean up dates (last acs years)
automatically convert countyfips to three digit
automatically convert statefips to two digit
do we need browse at end of switches section?
exportcsv still saves dta (yeah?)
exportcsv/saveas save multiple copies
Minus or slash for years? (i think arloc wants both)
review catalog and see if behavior is what i want it to be (right now does everything even if no search term passed)
if search, only keep searchmatch?
remove python details # done but get rid of the comments
explain weird values (negative values)


ERROR MESSAGES
if passing pov and B19013, there should be an error
if not catalog, ignore product and we figure it out ourselves
for point and click, let them know what defaults will be if they don't pass anything
if geo= state, geoids="", statefips!="", just set geoids=statefips?
if dataset not inlist 1 3 5, return error?

(these are all warnings not errors)
DT: 2009 for 5-year (but no groups in 2009), 2010 for 1-year
ST: 2012 for 5-year, 2010 for 1-year
CP: 2015, for 5-year, 2010 for 1-year
DP: 2014 for 5-year, 2010 for 1-year

ROLLOUT
Beta testing with RAs and SPP fellows

BUGS
getcensus pop, years(2017) dataset(1) geography(state) saveas(PopulationByState) export clear
getcensus medicaid, years(2017) dataset(1) geography(state) saveas(MedicaidByState) export clear
E tables. e.g., B19013E
ables that end in A-I name not found, even if you do individual estimates (unless you also get the overall table)
lots of server errors during training, but can't replicate errors when i'm on ethernet
median income table gets same labels for all, not bug but we need to figure out how to get table (e.g., B19013B) names
error with labels that contain quotes, ugh
comparison profiles don't work -- i think because no margins of error?


/*******************************************************************************
** OTHER NOTES
*******************************************************************************/

- Census' documentation is not thorough. Makes it seem like DT available 
2009-present, DP 2011- present, all others post 2013

/*******************************************************************************
** END OF FILE
*******************************************************************************/
https://api.census.gov/data/2017/acs/acs1/subject?get=S2704_C02_006E,S2704_C02_006M,S2704_C02_007E,S2704_C02_007M,S2704_C02_008E,S2704_C02_008M,S2704_C02_009E,S2704_C02_009M,NAME&for=state:*&key=daa1343c8d20e382aa287d308a80674f42fc1f92

