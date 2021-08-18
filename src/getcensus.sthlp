{smcl}
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

{title:Title}

{p 4 4 2}
{bf:getcensus} {hline 2} Retrieve American Community Survey estimates from the Census Bureau API.


{marker syntax}{...}

{title:Syntax}

{p 4 4 2}
Retrieve estimates

{p 8 8 2} {bf:getcensus} {it:variable IDs, table ID, or keyword} [, {it:options}]

{p 4 4 2}
Search the API data dictionary

{p 8 8 2} {bf:getcensus catalog} [, {it:options}] 


{synoptset 30 tabbed}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opth year:s(numlist)}}year(s) to retrieve; default is latest available.
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
{synopt:{opth saveas(filename)}}save retrieved data as a Stata dataset and Excel spreadsheet.
{p_end}
{synopt:{opt replace}}replace the files in {opt saveas()} if they already exist.
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
{synopt:{opt cache:path(string)}}customize where {bf:getcensus} caches API data dictionaries.
{p_end}


{marker description}{...}

{title:Description}

{p 4 4 2}
{bf:getcensus} loads American Community Survey (ACS) estimates from the U.S. Census Bureau API into memory. 

{p 4 4 2}
To retrieve ACS data from the API, users may specify one or more variable IDs, a single table ID, or a {help getcensus##keywords:keyword}. 

{p 4 4 2}
The Census Bureau publishes thousands of tables of ACS data. Each table has a unique table ID. Each data point within a table is called a variable, and each variable has a unique variable ID. For instance, table S1701, "Poverty status in the past 12 months" contains the estimated number of people in poverty. The variable ID for this data point is S1701_C02_001. By default, {bf:getcensus} retrieves both estimates and their margins of error, so users should not suffix variable IDs with "E" (for estimate) or "M" (for margin of error).

{p 4 4 2}
In a dataset retrieved by {bf:getcensus}, the variable names are the ACS variable IDs. Variable labels contain the ACS variable{c 39}s description and a variable note contains the name of the ACS variable{c 39}s table. If the option {opt nolabel} is specified, this metadata will not be included.

{p 4 4 2}
Users rarely know offhand the variable ID or table ID of the data points they would like to retrieve. {bf:getcensus catalog} allows users to access the API data dictionaries. For instance, {bf:getcensus catalog, product(DT)} will load into memory a dataset containing, for every variable in the detailed tables ("DT"): the variable ID, the variable{c 39}s description, and the name of the variable{c 39}s table. 

{p 4 4 2}
If you are new to American Community Survey data, the handbook "Understanding and Using American Community Survey Data: What All Data Users Need to Know" is the best place to start. It is available on the Census Bureau website  {browse "https://www.census.gov/programs-surveys/acs/guidance/handbooks/general.html":here}.

{p 4 4 2}
{it:getcensus uses the Census Bureau Data API but is not endorsed or certified by the Census Bureau.}


{marker options}{...}

{title:Options}

{dlgtab:Main}

{phang}
{opth years(numlist)} specifies the years (or endyears, if multiyear estimates are requested) of the sample to be retrieved. Defaults is the latest available year. If multiple years are requested, data for all years requested will be appended together. Users requesting multiple years should be aware that not all ACS estimates are available for all years, and table specifications and geographies may change between years; see  {browse "https://www.census.gov/programs-surveys/acs/technical-documentation/table-and-geography-changes.html":ACS Table & Geography Changes} on the Census Bureau website. Users may deviate from {help numlist} conventions and separate ranges with "-" rather than "/" (e.g., "2017-2019" for 2017, 2018 and 2019).

{phang}
{opt sample(integer)} specifies the sample to retrieve: 1 for one-year estimates, 3 for three-year estimates (2012-2013 only), or 5 for five-year estimates. Default is 1. One-year estimates are only available for geographic areas with more than 65,000 residents; see  {browse "https://www.census.gov/programs-surveys/acs/guidance/estimates.html":this page} on the Census Bureau website.

{phang}
{opt geography(string)} specifies the geographic unit for which to retrieve data. Default is {opt geography(state)}. See {help getcensus##geographies:Supported Geographies}. 

{phang}
{opt key(string)} specifies your Census Bureau API key. If you do not have an API key, you may acquire one  {browse "https://api.census.gov/data/key_signup.html":here}. To avoid specifying {bf:key()} each time {bf:getcensus} is used, store your API key in a global {help macro} named {it:censuskey} in your profile.do. Learn about where to find your profile.do  {browse "https://www.stata.com/support/faqs/programming/profile-do-file/":here}. If you are unfamiliar with global macros, simply type {it:global censuskey "your-api-key-here"} into your profile.do. 

{phang}
{bf:nolabel} specifies that retrieved data should not be labeled with associated metadata from the API data dictionary.

{phang}
{bf:noerror} specifies that {bf:getcensus} should not retrieve margins of error associated with estimates.

{phang}
{opth saveas(filename)} causes retrieved data to be saved under the name {it:filename} as a Stata dataset ({it:filename.dta}) and also as an Excel spreadsheet ({it:filename.xlsx}). 

{phang}
{bf:replace} if {bf:saveas()} is specified, files will be replaced if they already exist.

{phang}
{bf:clear} causes the data in memory to be replaced, even if the current data have not been saved to disk.

{phang}
{bf:browse} opens retrieved data in the Data Editor after {bf:getcensus} completes.


{marker options_geography}{...}
{dlgtab:Geography options}

{phang}
{opt statefips(string)} Two-digit FIPS codes of state(s) to retrieve. Default is usually all. A listing of state FIPS codes can be found  {browse "https://www.nrcs.usda.gov/wps/portal/nrcs/detail/?cid=nrcs143_013696":here}. 

{phang}
{opt countyfips(string)} Three-digit FIPS codes of counties to retrieve. A listing of county FIPS codes by year can be found  {browse "https://www.census.gov/geographies/reference-files.2019.html":here} on the Census Bureau website. Note that county FIPS codes may change between years; see  {browse "https://www.census.gov/programs-surveys/acs/technical-documentation/table-and-geography-changes.html":ACS Table & Geography Changes} on the Census Bureau website. 

{phang}
{opt geoids(string)} GEOID(s) of geographies to retrieve. Default is usually all. GEOIDs are numeric codes that uniquely identify all geographic areas for which the Census Bureau tabulates data; see  {browse "https://www.census.gov/programs-surveys/geography/guidance/geo-identifiers.html":Understanding Geographic Identifiers} on the Census Bureau website. Many geography types have GEOIDs that are made up of several components. Only the last component should be specified in {bf:geoid()}. The state code component of the GEOID should be specified in {bf:statefips()}. If the GEOID includes a county code, it should be specified in {bf:countyfips()}. See {help getcensus##examples:Examples}. Note that GEOIDs and geography definitions may change between years; see  {browse "https://www.census.gov/programs-surveys/acs/technical-documentation/table-and-geography-changes.html":ACS Table & Geography Changes} on the Census Bureau website. {bf:getcensus} supports most, but not all, geographies supported by the ACS API; see {help getcensus##geographies:Supported Geographies}.

{phang}
{opt geocomponents(string)} Geographic component codes of the geographic components to retrieve. Geographic components are division of a geographic unit by certain criteria, such as rural, urban,  in metropolitan statistical area, and not in metropolitan statistical area. {bf:getcensus} does not support all geographic components available on the Census Bureau API; see {help getcensus##geocomp:Supported Geographies}.

{marker options_catalog}{...}
{dlgtab:Catalog options}

{phang}
{opt product(string)} will load the API data dictionary for variables in tables of a given product type, as specified with a two-letter abbreviation. For information about ACS tables and product types, see  {browse "https://www.census.gov/programs-surveys/acs/guidance/which-data-tool/table-ids-explained.html":this page} on the Census Bureau website. Either {bf:product()} or {bf:table()} must be specified with {bf:getcensus catalog}. If both are specified, {bf:product()} is ignored.

{col 12}{it:product}{col 22}{it:Description}
{space 8}{hline 85}
{col 12}{bf:DP}{col 22}Data profile
{col 12}{bf:ST}{col 22}Subject table
{col 12}{bf:CP}{col 22}Comparison profile
{col 12}{bf:DT}{col 22}Detailed table

{phang}
{opt table(string)} will load the API data dictionary for a given table. For information about ACS tables and product types, see  {browse "https://www.census.gov/programs-surveys/acs/guidance/which-data-tool/table-ids-explained.html":this page} on the Census Bureau website. Either {bf:product()} or {bf:table()} must be specified with {bf:getcensus catalog}. If both are specified, {bf:product()} is ignored.

{phang}
{opt search(string)} will load the API data dictionary for variables whose descriptions match a given search term, such as "children", "poverty", or "veteran". A regular expression may be specified to {bf:search()}.
{p_end}


{dlgtab:Advanced options}

{phang}
{opt cachepath(string)} {bf:getcensus} caches API data dictionaries for future retreival. By default, these files are saved in application support ("~/AppData/Local/" on Windows and "~/Library/Application Support" on Mac). To save these files elsewhere, pass your desired location to {bf:cachepath()}.


{marker geographies}{...}

{title:Supported Geographies}

{dlgtab:Geographies}

{p 4 4 2}
{bf:getcensus} supports most, but not all, geographies supported by the Census Bureau API. Users who are requesting data for multiple years should be aware that ACS geography definitions may change between years; see  {browse "https://www.census.gov/programs-surveys/acs/technical-documentation/table-and-geography-changes.html":ACS Table & Geography Changes} on the Census Bureau website.

{p 4 4 2}
A list of geographies supported by {bf:getcensus} can be found below. For some geographies, users may specify an abbreviation rather than the full name. The third column indicates whether {bf:statefips()} or {bf:countyfips()} may be specified with a given geography. Bold indicates the option is required with a given geography. 

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

{p 4 4 2}
Geographic components are division of a geographic unit by certain criteria. {bf:getcensus} does not support all geographic components available on the Census Bureau API.

{p 4 4 2}
An example: {bf:getcensus [variable IDs], geography(state) geocomponents(H0 C0)} will return two observations for each state: one for the portion of the state not in a metropolitan statistical area ("H0"), and one for the portion of the state in a metropolitan statistical area ("C0").

{col 8}Available with {bf:geography()} {it:us}, {it:region}, {it:division}, or {it:state}
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

{title:Keywords}

{p 4 4 2}
Users may use a keyword to retrieve a curated set of variables. 

{synopt:{it:Keyword}}Description{p_end}
{synoptline}
{synopt:{bf:pov}}Number and percent of the population in poverty, overall and by various demographic characteristics{p_end}
{synopt:{bf:povratio}}Population by ratio of income to poverty level{p_end}
{synopt:{bf:povratio_char}}Characteristics of the population at specified poverty levels{p_end}
{synopt:{bf:medinc}}Median household income, overall and by race of householder{p_end}
{synopt:{bf:snap}}SNAP participation overall and by poverty status, income, disability status, family composition, and family work effort{p_end}
{synopt:{bf:medicaid}}Medicaid participants, by age{p_end}
{synopt:{bf:housing_overview}}Various housing-related estimates including occupancy, tenure, costs, and cost burden*{p_end}
{synopt:{bf:costburden_renters}}Detailed renter housing cost burden*{p_end}
{synopt:{bf:costburden_owners}}Detailed homeowner housing cost burden{p_end}
{synopt:{bf:opt tenure_inc}}Median household income and poverty status of families, by housing tenure{p_end}
{synopt:{bf:kids_nativity}}Nativity of children, by age and parent{c 39}s nativity{p_end}
{synopt:{bf:kids_pov_parents_nativity}}Children by poverty status and parent{c 39}s nativity {p_end}
{synoptline}

{p 4 4 2}
{it:* When using the data retrieved by keyword {bf:costburden_renters} to compute rates of renter housing cost burden, compute the denominator by subtracting the number of renters for whom cost burden is not computed (B25070_011) from the number of renters (B25070_001). This step is not necessary when using the data returned by keyword {bf:housing_overview}; the total in this table{c 39}s section on rent burden (DP04_0136) already excludes the number of renters for whom cost burden cannot be computed.}


{marker examples}{...}

{title:Example(s)}

{p}{it:Variables, tables, and keywords}{p_end}

{p 4 4 2}
	Single table    {break}
		{bf:. getcensus S2701}

{p 4 4 2}
	Single variable    {break}
		{bf:. getcensus B19013_001}

{p 4 4 2}
	Multiple variables from a single table    {break}
		{bf:. getcensus DP02_0053 DP02_0054 DP02_0055 DP02_0056 DP02_0057}

{p 4 4 2}
	Multiple variables from more than one table    {break}
		{bf:. getcensus S1701_C03_001 S2701_C05_001}

{p 4 4 2}
	Keyword    {break}
		{bf:. getcensus medinc}

{p}{it:Years and samples}{p_end}

{p 4 4 2}
	Single year (default is most recent available)    {break}
		{bf:. getcensus B19013, year(2010)}

{p 4 4 2}
	Multiple years    {break}
		{bf:. getcensus B19013, years(2018/2019)}    {break}
		{bf:. getcensus B19013, years(2010 2015 2019)}

{p 4 4 2}
	Samples (default is 1)    {break}
		{bf:. getcensus B19013, sample(5)}    {break}
		{bf:. getcensus B19013, sample(3) year(2013)}

{p}{it:Geographies}{p_end}

{p 4 4 2}
	Types (default is state)    {break}
		{bf:. getcensus B19013, geography(us)}    {break}
		{bf:. getcensus B19013, geography(county)}    {break}
		{bf:. getcensus B19013, sample(5) geography(sldu) statefips(26)}

{p 4 4 2}
	Within a state or set of states    {break}
		{bf:. getcensus B19013, statefips(11)}    {break}
		{bf:. getcensus B19013, geography(county) statefips(04)}    {break}
		{bf:. getcensus B19013, geography(congressional district) statefips(24 51)}    {break}
		{bf:. getcensus B19013, sample(5) geography(metro) statefips(06)}

{p 4 4 2}
	With specific GEOIDs    {break}
		{bf:. getcensus B19013_001, geography(metro) geoids(47900)}    {break}
		{bf:. getcensus B19013_001, geography(county) statefips(24) geoids(005 510)}    {break}
		{bf:. getcensus B19013_001, geography(place) statefips(48) geoids(35000)}    {break}
		{bf:. getcensus B19013_001, sample(5) geography(tract) statefips(01) countyfips(001) geoids(020100)}

{p 4 4 2}
	Geographic components    {break}
		{bf:. getcensus B19013, geocomponents(H0)}    {break}
		{bf:. getcensus B19013, geocomponents(01 43) statefips(13)}    {break}
		{bf:. getcensus B19013, sample(5) geography(us) geocomponents(92)}

{p}{it:Catalog}{p_end}

{p 4 4 2}
	All variables from detailed tables    {break}
		{bf:. getcensus catalog, product(DP)}

{p 4 4 2}
	Variables from a single table    {break}
		{bf:. getcensus catalog, table(S0901) product(ST)}

{p 4 4 2}
	Variables matching a search term    {break}
		{bf:. getcensus catalog, search(children) product(DT)}



{title:Website}

{p 4 4 2}
{browse "http://www.github.com/CenterOnBudget/getcensus":github.com/CenterOnBudget/getcensus}



{title:Authors}

{p 4 4 2}
{bf:getcensus} is a project of the  {browse "http://www.cbpp.org":Center on Budget and Policy Priorities}, a nonpartisan research and policy institute. It is developed and maintained by Claire Zippel and Matt Saenz. It was created by Raheem Chaudhry and Vincent Palacios.



