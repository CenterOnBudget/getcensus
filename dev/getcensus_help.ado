
/***
{viewerjumpto "Syntax" "getcensus##syntax"}{...}
{viewerjumpto "Description" "getcensus##description"}{...}
{viewerjumpto "Options" "getcensus##options"}{...}
{viewerjumpto "Options: Geography" "getcensus##options_geography"}{...}
{viewerjumpto "Options: Catalog" "getcensus##options_catalog"}{...}
{viewerjumpto "Supported Geographies" "getcensus##geographies"}{...}
{viewerjumpto "Keywords" "getcensus##keywords"}{...}
{viewerjumpto "Examples" "getcensus##examples"}{...}
{viewerjumpto "Website" "getcensus##website"}{...}
{viewerjumpto "Authors" "getcensus##authors"}{...}
Title
====== 

__getcensus__ {hline 2} Load American Community Survey data from the U.S. Census Bureau API into Stata.


{marker syntax}{...}
Syntax
------ 

Retrieve estimates

> __getcensus__ _variable IDs, table ID, or keyword_ [, _options_]

Search the API data dictionary

> __getcensus catalog__ [, _options_] 


{synoptset 30 tabbed}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opth year:s(numlist)}}year(s) to retrieve; default is 2021.
{p_end}
{synopt:{opt samp:le(integer)}}1, 3, or 5; default is {opt sample(1)}.
{p_end}
{synopt:{opt geo:graphy(string)}}geography to retrieve, default is {opt geography(state)}.
{p_end}
{synopt:{opt key(string)}}your Census Bureau API key.
{p_end}
{synopt:{opt nolab:el}}do not label variables with associated metadata from the API data dictionary.
{p_end}
{synopt:{opt noerr:or}}do not retrieve margins of error associated with estimates.
{p_end}
{synopt:{opth saveas(filename)}}save retrieved data as a Stata dataset.
{p_end}
{synopt:{opt ex:portexcel}}if __saveas()__ is specified, also save retrieved data as an Excel spreadsheet.
{p_end}
{synopt:{opt replace}}if __saveas()__ is specified, overwrite existing files.
{p_end}
{synopt:{opt clear}}replace the data in memory, even if the current data have not been saved to disk.
{p_end}
{synopt:{opt browse}}browse the retrieved data in the Data Editor after {bf:getcensus} completes.
{p_end}

{syntab:Geography options}
{synopt:{opt st:atefips(string)}}state FIPS codes of states to retrieve; default is usually all.
{p_end}
{synopt:{opt co:untyfips(string)}}county FIPS codes of counties to retrieve; default is usually all.
{p_end}
{synopt:{opt geoid:s(string)}}GEOIDs of geographies to retrieve; default is usually all.
{p_end}
{synopt:{opt geocomp:onents(string)}}geographic component codes of geographies to retrieve.
{p_end}

{syntab:Catalog options}
{synopt:{opt pr:oduct(string)}}load the API data dictionary for estimates of given product type.
{p_end}
{synopt:{opt t:able(string)}}load the API data dictionary for estimates in a given table.
{p_end}
{synopt:{opt search(string)}}load the API data dictionary for estimates with descriptions matching a search term.
{p_end}

{syntab:Advanced options}
{synopt:{opt cache:path(string)}}customize where __getcensus__ caches API data dictionaries.
{p_end}


{marker description}{...}
Description
-----------

__getcensus__ loads American Community Survey (ACS) estimates from the U.S. Census Bureau API into memory. 

To retrieve ACS data from the API, users may specify one or more variable IDs, 
a single table ID, or a {help getcensus##keywords:keyword}. If a list of 
variable IDs is specified, the variables must come from tables that share the 
same product type (Data Profile, Subject Table, Comparison Profile, or Detailed 
Table).

The Census Bureau publishes thousands of tables of ACS data. Each table has a 
unique table ID. Each data point within a table is called a variable, and each 
variable has a unique variable ID. For instance, table S1701, "Poverty status 
in the past 12 months" contains the estimated number of people in poverty. The 
variable ID for this data point is S1701_C02_001. By default, __getcensus__ 
retrieves both estimates and their margins of error, so users should not suffix 
variable IDs with "E" (for estimate) or "M" (for margin of error).

In a dataset retrieved by __getcensus__, the variable names are the ACS variable 
IDs. Variable labels contain the ACS variable's description and a variable note 
contains the name of the ACS variable's table. If the option __nolabel__ is 
specified, this metadata will not be included.

Users rarely know offhand the variable ID or table ID of the data points they 
would like to retrieve. __getcensus catalog__ allows users to access the API 
data dictionaries. For instance, __getcensus catalog, product(ST)__ will load 
into memory a dataset containing, for every variable in the subject tables 
("ST"): the variable ID, the variable's description, and the name of the 
variable's table. 

If you are new to American Community Survey data, the Census Bureau's handbook 
[Understanding and Using American Community Survey Data: What All Data Users Need to Know](https://www.census.gov/programs-surveys/acs/guidance/handbooks/general.html) 
is the best place to start.

_getcensus uses the Census Bureau Data API but is not endorsed or certified by the Census Bureau._


{marker options}{...}
Options
-------

{dlgtab:Main}

{phang}
{opth years(numlist)} specifies the years (or endyears, if multiyear estimates 
are requested) of the sample to be retrieved. Defaults is the latest available 
year. If multiple years are requested, data for all years requested will be 
appended together. Users requesting multiple years should be aware that not all 
ACS estimates are available for all years, and table specifications and 
geographies may change between years; see 
[ACS Table & Geography Changes](https://www.census.gov/programs-surveys/acs/technical-documentation/table-and-geography-changes.html) 
on the Census Bureau website. Users may deviate from {help numlist} conventions 
and separate ranges with "-" rather than "/" (e.g., "2017-2019" for 2017, 2018 
and 2019).

{phang}
{opt sample(integer)} specifies the sample to retrieve: 1 for one-year 
estimates, 3 for three-year estimates (2007-2013 only), or 5 for five-year 
estimates. Default is 1. One-year estimates are only available for geographic 
areas with more than 65,000 residents; see 
[When to Use 1-year or 5-year Estimates](https://www.census.gov/programs-surveys/acs/guidance/estimates.html) 
on the Census Bureau website.

{phang}
{opt geography(string)} specifies the geographic unit for which to retrieve
data. Default is state. See
{help getcensus##geographies:Supported Geographies}. 

{phang}
{opt key(string)} specifies your Census Bureau API key. If you do not have an
API key, you may acquire at 
[https://api.census.gov/data/key_signup.html](https://api.census.gov/data/key_signup.html)
. To avoid specifying __key()__ each time {bf:getcensus} is used, store your API 
key in a global {help macro} named _censuskey_ in your profile.do. Learn about 
where to find your profile.do in the 
[profile.do FAQ](https://www.stata.com/support/faqs/programming/profile-do-file/) 
on the Stata website. If you are unfamiliar with global macros, simply type 
{it:global censuskey "your-api-key-here"} into your profile.do.

{phang}
__nolabel__ specifies that retrieved data should not be labeled with 
associated metadata from the API data dictionary.

{phang}
__noerror__ specifies that __getcensus__ should not retrieve margins of error 
associated with estimates.

{phang}
{opth saveas(filename)} causes retrieved data to be saved under the name 
_filename_ as a Stata dataset.

{phang}
{opt exportexcel} if __saveas()__ is specified, causes retrieved data to also be 
exported to an Excel spreadsheet.

{phang}
__replace__ if __saveas()__ is specified, allows existing files to be 
overwritten.

{phang}
__clear__ causes the data in memory to be replaced, even if the current data 
have not been saved to disk.

{phang}
__browse__ opens retrieved data in the Data Editor after __getcensus__ 
completes.


{marker options_geography}{...}
{dlgtab:Geography options}

{phang}
{opt statefips(string)} Two-digit FIPS codes of state(s) to retrieve. Default is 
usually all. A listing of state FIPS codes can be found on the 
[FIPS Codes page](https://www.census.gov/library/reference/code-lists/ansi.html#state) 
on the Census Bureau website. 

{phang}
{opt countyfips(string)} Three-digit FIPS codes of counties to retrieve. A list
of county FIPS codes by year can be found on the 
[Geography Reference Files page](https://www.census.gov/geographies/reference-files.html) 
on the Census Bureau website. Note that county FIPS codes may change 
between years; see 
[ACS Table & Geography Changes](https://www.census.gov/programs-surveys/acs/technical-documentation/table-and-geography-changes.html) 
on the Census Bureau website. 

{phang}
{opt geoids(string)} GEOID(s) of geographies to retrieve. Default is usually 
all. GEOIDs are numeric codes that uniquely identify all geographic areas for 
which the Census Bureau tabulates data; see 
[Understanding Geographic Identifiers](https://www.census.gov/programs-surveys/geography/guidance/geo-identifiers.html) 
on the Census Bureau website. Many geography types have GEOIDs that are made up 
of several components. Only the last component should be specified in 
{bf:geoid()}. The state code component of the GEOID should be specified in 
{bf:statefips()}. If the GEOID includes a county code, it should be specified in 
{bf:countyfips()}. See {help getcensus##examples:Examples}. Note that GEOIDs and 
geography definitions may change between years; see 
[ACS Table & Geography Changes](https://www.census.gov/programs-surveys/acs/technical-documentation/table-and-geography-changes.html) 
on the Census Bureau website. __getcensus__ supports most, but not all, 
geographies supported by the ACS API; see 
{help getcensus##geographies:Supported Geographies}.

{phang}
{opt geocomponents(string)} Geographic component codes of the geographic 
components to retrieve. Geographic components are division of a geographic unit 
by certain criteria, such as rural, urban,  in metropolitan statistical area, 
and not in metropolitan statistical area. __getcensus__ does not support all 
geographic components available on the Census Bureau API; see 
{help getcensus##geocomp:Supported Geographies}.

{marker options_catalog}{...}
{dlgtab:Catalog options}

{phang}
{opt product(string)} will load the API data dictionary for variables in tables 
of a given product type, as specified with a two-letter abbreviation. Default is 
DT. For information about ACS tables and product types, see 
[Table IDs Explained](https://www.census.gov/programs-surveys/acs/guidance/which-data-tool/table-ids-explained.html) 
on the Census Bureau website. If both __product()__ and __table()__ are 
specified with __getcensus catalog__, __product()__ is ignored and the 
appropriate product type is determined by the contents of __table()__.

{col 12}{it:product}{col 22}{it:Description}
{space 8}{hline 85}
{col 12}{bf:DP}{col 22}Data Profile
{col 12}{bf:ST}{col 22}Subject Table
{col 12}{bf:CP}{col 22}Comparison Profile
{col 12}{bf:DT}{col 22}Detailed Table
  
{phang}
{opt table(string)} will load the API data dictionary for a given table. For 
information about ACS tables and product types, see 
[Table IDs Explained](https://www.census.gov/programs-surveys/acs/guidance/which-data-tool/table-ids-explained.html) 
on the Census Bureau website. If both __product()__ and __table()__ are 
specified with __getcensus catalog__, __product()__ is ignored and the 
appropriate product type is determined by the contents of __table()__.

{phang}
{opt search(string)} will load the API data dictionary for variables whose 
descriptions match a given search term, such as "children", "poverty", or 
"veteran". A regular expression may be specified to __search()__.
{p_end}


{dlgtab:Advanced options}

{phang}
{opt cachepath(string)} __getcensus__ caches API data dictionaries for future 
retreival. By default, these files are saved in application support 
("~/AppData/Local/" on Windows and "~/Library/Application Support" on Mac). To 
save these files elsewhere, pass your desired location to __cachepath()__.


{marker geographies}{...}
Supported Geographies
-----------

{dlgtab:Geographies}

__getcensus__ supports most, but not all, geographies supported by the Census 
Bureau API. Users who are requesting data for multiple years should be aware 
that ACS geography definitions may change between years; see 
[ACS Table & Geography Changes](https://www.census.gov/programs-surveys/acs/technical-documentation/table-and-geography-changes.html) 
on the Census Bureau website.

A list of geographies supported by __getcensus__ can be found below. For some 
geographies, users may specify an abbreviation rather than the full name. The 
third column indicates whether __statefips()__ or __countyfips()__ may be 
specified with a given geography. Bold indicates the option is required with a 
given geography. 

{col 8}{it:Name}{col 53}{it:Abbreviation}{col 68}{it:Options}
{space 5}{hline 85}
{col 8}us
{col 8}region
{col 8}division
{col 8}state{col 68}statefips
{col 8}county{col 53}co{col 68}statefips
{col 5}*{col 8}county subdivision{col 53}cousub{col 68}{bf:statefips}, countyfips
{col 5}*{col 8}tract{col 68}{bf:statefips}, countyfips
{col 5}*{col 8}block group{col 53}bg{col 68}{bf:statefips}, {bf:countyfips}
{col 8}place{col 68}statefips
{col 5}*{col 8}zip code tabulation area{col 53}zcta{col 68}statefips
{col 5}*{col 8}state legislative district (upper chamber){col 53}sldu{col 68}{bf:statefips}
{col 5}*{col 8}state legislative district (lower chamber){col 53}sldl{col 68}{bf:statefips}
{col 8}congressional district{col 53}cd{col 68}statefips
{col 8}school district (elementary){col 53}elsd{col 68}{bf:statefips}
{col 8}school district (secondary){col 53}scsd{col 68}{bf:statefips}
{col 8}school district (unified){col 53}unsd{col 68}{bf:statefips}
{col 8}public use microdata area{col 53}puma{col 68}statefips
{col 8}alaska native regional corporation{col 53}anrc{col 68}statefips
{col 8}american indian area/alaska native area/
{col 10}hawaiian home land{col 53}aiannh
{col 5}{c 42}{c 42}{col 8}metropolitan statistical area/ 
{col 10}micropolitan statistical area{col 53}metro{col 68}statefips
{col 8}combined statistical area{col 53}cbsa
{col 8}new england city and town area{col 53}necta
{col 8}combined new england city and town area{col 53}cnecta
{col 8}urban area{col 53}urban
    {hline 85}
    {it:*  only 5-year estimates are available for this geography.}
    {it:{c 42}{c 42} only 5-year estimates are available when {bf:statefips()} is specified with this geography.}


{marker geocomp}{...}
{dlgtab:Geographic components}

Geographic components are division of a geographic unit by certain criteria.
__getcensus__ does not support all geographic components available on the Census 
Bureau API.

An example: {bf:getcensus [variable IDs], geography(state) geocomponents(H0 C0)} 
will return two observations for each state: one for the portion of the state 
not in a metropolitan statistical area ("H0"), and one for the portion of the 
state in a metropolitan statistical area ("C0").

{col 8}Available with __geography()__ _us_, _region_, _division_, or _state_
{space 5}{hline 80}
{col 8}00{col 13}Total
{col 8}H0{col 13}Not in metropolitan statistical area
{col 8}C0{col 13}In metropolitan statistical area
{col 8}C1{col 13}In metropolitan statistical area: in principal city
{col 8}C2{col 13}In metropolitan statistical area: not in principal city
{col 8}E0{col 13}In micropolitan statistical area
{col 8}A0{col 13}In metropolitan or micropolitan statistical area
{col 8}E1{col 13}In micropolitan statistical area: in principal city
{col 8}E2{col 13}In micropolitan statistical area: not in principal city
{col 8}G0{col 13}Not in metropolitan or micropolitan statistical area
{col 8}01{col 13}Urban
{col 8}43{col 13}Rural

{col 8}Available with {opt geography(us)} only
{space 5}{hline 80}
{col 8}89{col 13}American Indian Reservation and Trust Land: Federal
{col 5}*{col 8}90{col 13}American Indian Reservation and Trust Land: State
{col 8}91{col 13}Oklahoma Tribal Statistical Area
{col 5}{c 42}{c 42}{col 8}92{col 13}Tribal Designated Statistical Area
{col 8}93{col 13}Alaska Native Village Statistical Area
{col 8}94{col 13}State Designated Tribal Statistical Area
{col 5}*{col 8}95{col 13}Hawaiian Home Land

    {it:*  only 5-year estimates are available for this geographic component.}
    {it:{c 42}{c 42} 1-year estimates are not available for this geographic component.}


{marker keywords}{...}
Keywords
--------

Users may use a keyword to retrieve a curated set of variables. 

{synopt:{it:Keyword}}Description{p_end}
{synoptline}
{synopt:{bf:pov}}Number and percent of population in poverty; overall, by age, and by race{p_end}
{synopt:{bf:povratio}}Population by income-to-poverty ratio{p_end}
{synopt:{bf:povratio_char}}Characteristics of the population at various income-to-poverty ratios{p_end}
{synopt:{bf:medinc}}Median household income, overall and by race of householder{p_end}
{synopt:{bf:snap}}Percent of households participating in SNAP and characteristics of participating households{p_end}
{synopt:{bf:medicaid}}Number and percent of population covered by Medicaid, overall and by age{p_end}
{synopt:{bf:housing_overview}}Housing characteristics, including housing costs*{p_end}
{synopt:{bf:costburden_renters}}Detailed renter housing cost burden*{p_end}
{synopt:{bf:costburden_owners}}Detailed homeowner housing cost burden{p_end}
{synopt:{bf:opt tenure_inc}}Median household income and family poverty status, by housing tenure{p_end}
{synopt:{bf:kids_nativity}}Nativity of children, by age and parent's nativity{p_end}
{synopt:{bf:kids_pov_parents_nativity}}Children by poverty status and parent's nativity {p_end}
{synoptline}

{p 4 4 2}
{it}* When using the data retrieved by keyword {bf:costburden_renters} to 
compute rates of renter housing cost burden, compute the denominator by 
subtracting the number of renters for whom cost burden is not computed 
(B25070_011) from the number of renters (B25070_001). This step is not necessary 
when using the data returned by keyword {bf:housing_overview}; the total in this 
table's section on rent burden (DP04_0136) already excludes the number of 
renters for whom cost burden cannot be computed.{sf}


{marker examples}{...}
Example(s)
----------

{p}{it:Variables, tables, and keywords}{p_end}

	Single table  
		{bf:. getcensus S2701}

	Single variable  
		{bf:. getcensus B19013_001}

	Multiple variables from a single table  
		{bf:. getcensus DP02_0053 DP02_0054 DP02_0055 DP02_0056 DP02_0057}

	Multiple variables from more than one table  
		{bf:. getcensus S1701_C03_001 S2701_C05_001}

	Keyword  
		{bf:. getcensus medinc}

{p}{it:Years and samples}{p_end}

	Single year (default is most recent available)  
		{bf:. getcensus B19013, year(2010)}

	Multiple years  
		{bf:. getcensus B19013, years(2018/2019)}  
		{bf:. getcensus B19013, years(2010 2015 2019)}

	Samples (default is 1)  
		{bf:. getcensus B19013, sample(5)}  
		{bf:. getcensus B19013, sample(3) year(2013)}

{p}{it:Geographies}{p_end}

	Types (default is state)  
		{bf:. getcensus B19013, geography(us)}  
		{bf:. getcensus B19013, geography(county)}  
		{bf:. getcensus B19013, sample(5) geography(sldu) statefips(26)}

	Within a state or set of states  
		{bf:. getcensus B19013, statefips(11)}  
		{bf:. getcensus B19013, geography(county) statefips(04)}  
		{bf:. getcensus B19013, geography(congressional district) statefips(24 51)}  
		{bf:. getcensus B19013, sample(5) geography(metro) statefips(06)}

	With specific GEOIDs  
		{bf:. getcensus B19013_001, geography(metro) geoids(47900)}  
		{bf:. getcensus B19013_001, geography(county) statefips(24) geoids(005 510)}  
		{bf:. getcensus B19013_001, geography(place) statefips(48) geoids(35000)}  
		{bf:. getcensus B19013_001, sample(5) geography(tract) statefips(01) countyfips(001) geoids(020100)}

	Geographic components  
		{bf:. getcensus B19013, geocomponents(H0)}  
		{bf:. getcensus B19013, geocomponents(01 43) statefips(13)}  
		{bf:. getcensus B19013, sample(5) geography(us) geocomponents(92)}

{p}{it:Catalog}{p_end}

	All variables in tables of a given product type  
		{bf:. getcensus catalog, product(DP)}

	Variables from a single table  
		{bf:. getcensus catalog, table(S0901)}

	Variables matching a search term  
		{bf:. getcensus catalog, search(children) product(ST)}  
		{bf:. getcensus catalog, search(educational attainment) table(S1701)}


Website
-------

Online documentation:
[centeronbudget.github.io/getcensus/](https://centeronbudget.github.io/getcensus/)

GitHub repository:
[github.com/CenterOnBudget/getcensus](http://www.github.com/CenterOnBudget/getcensus)


Authors
-------

__getcensus__ is a project of the 
[Center on Budget and Policy Priorities](http://www.cbpp.org), a nonpartisan 
research and policy institute. It is maintained by Claire Zippel and was 
developed by Claire Zippel and Matt Saenz. getcensus was created by Raheem 
Chaudhry and Vincent Palacios. Contributors include Lori Zakalik.
 
***/
