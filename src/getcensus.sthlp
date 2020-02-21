{smcl}
{* *! version 0.1.1  2019-12-XX}{...}
{viewerjumpto "Syntax" "getcensus##syntax"}{...}
{viewerjumpto "Description" "getcensus##description"}{...}
{viewerjumpto "Options for getcensus" "getcensus##options"}{...}
{viewerjumpto "Options for getcensus catalog" "getcensus##catalog_options"}{...}
{viewerjumpto "Examples" "getcensus##examples"}{...}
{title:Title}

{p2colset 5 20 22 2}{...}
{p2col:{cmd: getcensus} {hline 2}}Load published estimates from the American Community Survey into memory.{p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{phang}
Main program. Retrieves estimates from the American Community Survey via the Census Bureau API.

{p 8 16 2}
{cmd:getcensus}
{estimate IDs, table ID, or keyword}
[, {it:{help getcensus##options:options}}]

{phang}
Utility program. Searches labels in the API data dictionary to identify relevant estimate IDs.

{p 8 16 2}
{cmd:getcensus catalog}
[, {it:{help getcensus##catalog_options:catalog_options}}]

{synoptset 27 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
    {synopt:{opth years(numlist)}}Years to retrieve. Default is most recent available year.{p_end}
    {synopt:{opt data:set(#)}}ACS 1, 3, or 5-year estimates. Default is "1".{p_end}
    {synopt:{opt pr:oduct(string)}}Product type of table (e.g., detailed table, subject table). Default is "DT".{p_end}
    {synopt:{opt geo:graphy(string)}}Geography to download. Default is "state."{p_end}
    {synopt:{opt br:owse}}Open data browser after execution of command.{p_end}
    {synopt:{opt clear}}Replace data in memory with retrieved results.{p_end}
    {synopt:{opth geoids(numlist)}}GEOIDs of geography to download. Default is usually all.{p_end}
    {synopt:{opt key(string)}}Census key to access API.{p_end}

{syntab:Options}
    {synopt:{opth st:atefips(numlist)}}Two-digit state FIPS code of state(s) for which to download data. Default is usually all.{p_end}
    {synopt:{opt co:untyfips(#)}}Three-digit county FIPS code(s) of county/counties for which to download data.{p_end}
    {synopt:{opth save:as(filename)}}File name to save downloaded data (in .dta format).{p_end}
    {synopt:{opt path(string)}}Path where to store downloaded information.{p_end}
    {synopt:{opt ex:portexcel}}Export data in .xlsx format.{p_end}
    {synopt:{opt nol:abel}}Do not retrieve labels associated with estimate IDs.{p_end}
    {synopt:{opt noerr:or}}Do not retrieve margins of errors associated with estimates.{p_end}
    
{syntab: Catalog options}
    {synopt:{opth t:able(string)}}Search for all estimate IDs within a specific Census table.{p_end}
    {synopt:{opth search(string)}}Search for estimate IDs whose labels contain search term.{p_end}


{marker description}{...}
{title:Description}

{dlgtab:Overview}
{pstd}
{cmd:getcensus} imports data from the American Community Survey (ACS) into 
memory. It accomplishes this by translating the user's input into a query
to the Census Brueau's Application Programming Interface (API), which returns the data
in a structured format. {cmd:getcensus} then parses the data and loads it into Stata. 
{cmd:getcensus} uses the Census Bureau Data API but is not endorsed or certified 
by the Census Bureau.

{pstd}
A link to the Technical Documentation for the American Community Survey can be 
found {browse "https://www.census.gov/programs-surveys/acs/technical-documentation.html":here}. 

{pstd}
To retrieve estimates, users can either pass specific estimate IDs, an entire
table ID, or certain keywords to {cmd:getcensus}. By default, the program will
retrieve the desired estimates using the most recent single year of data 
available from the ACS by state.

{pstd}
Note that {cmd:getcensus} retrieves both the estimate and margin of error 
associated with a statistic, unless you pass the "noerror" option. Estimates 
have the suffix "E", while margins of errors have the suffix "M".

{pstd}
A note on vocabulary: When this documentation talks about a Census "table", 
it refers to Census tables (sometimes referred to as groups) (e.g., S1701, B19013)
that contain many estimates, all of which pertain to a shared concept, such as
number in poverty.

{pstd}
"Estimates" refer to the individual data points within a table. For instance, 
the total number of people in poverty can be found in table B17001. The
estimate ID for this number is B17001_002E.

{pstd}
Below are some commonly used estimates.

{marker estimates}{...}
{synoptset 30}{...}
{synopt:{space 4}{it:Estimate}}Concept{p_end}
{space 4}{synoptline}
{synopt:{space 4}{opt B17001_001}} Total in poverty universe {p_end}
{synopt:{space 4}{opt B17001_002}} Total with income below poverty level {p_end}
{synopt:{space 4}{opt B19013_001}} Median household income {p_end}

{pstd}
You can add a letter to the end of some detailed tables (those that begin with "B" or
"C") to get estimates by race. E.g.,

{marker estimatesbyrace}{...}
{synoptset 30}{...}
{synopt:{space 4}{it:Estimate}}Concept{p_end}
{space 4}{synoptline}
{synopt:{space 4}{opt B17001A_001}} Total in poverty universe, White (including Hispanic) alone{p_end}
{synopt:{space 4}{opt B17001B_001}} Total in poverty universe, Black or African American alone{p_end}
{synopt:{space 4}{opt B17001C_001}} Total in poverty universe, American Indian or Alaska Native alone{p_end}
{synopt:{space 4}{opt B17001D_001}} Total in poverty universe, Asian alone {p_end}
{synopt:{space 4}{opt B17001E_001}} Total in poverty universe, Native Hawaiian or Pacific Islander alone {p_end}
{synopt:{space 4}{opt B17001F_001}} Total in poverty universe, Some other race alone {p_end}
{synopt:{space 4}{opt B17001G_001}} Total in poverty universe, Two or more races {p_end}
{synopt:{space 4}{opt B17001H_001}} Total in poverty universe, non-Hispanic White alone{p_end}
{synopt:{space 4}{opt B17001I_001}} Total in poverty universe, Hispanic (any race){p_end}

{dlgtab:Help: Program syntax}

{pstd}
If users need assistance using the program, they can simply type {cmd: getcensus}
into the Command window without additional arguments. This will print tips on 
getting started with the program.

{dlgtab:Help: Retrieving estimates}

{pstd}
Often, users will not know the estimate or table IDs associated with the 
estimates they are interested in obtaining. This program assists users in 
retrieving relevants estimates in two ways.

{pstd}
First, {cmd:getcensus catalog} is a utility program that will help users search
the API's dictionary to identify the table or estimate IDs they need to pass to
the main program to get desired results. For example 
{cmd: getcensus catalog, product(ST) table(S1701)} will return all estimate IDs
that come from Census table S1701. Users can then view the data in browser to 
identify the specific estimate IDs they want, which they can then pass to the 
main program. E.g., {cmd: getcensus S1701_C02_001, product(ST)}.

{pstd}
Second, users can pass a keyword to {cmd: getcensus}. The keywords are shortcuts 
to a curated set of estimates related to the given topic. For instance, 
{cmd: getcensus snap} retrieves 18 estimates describing households participating
in SNAP.

{pstd}
Note that you can pass multiple keywords or a mix of estimate IDs and keywords
to {cmd: getcensus} (as long as the total number of estimates does not exceed 
50 -- including margins of error -- which is the maximum allowed by the Census 
API).

{pstd}
Below is a full list of the keywords this program accepts (Click on
'run' to retrieve the relevant estimates by state using the most recent
1-year estimates.)

{marker keywords}{...}
{synoptset 30}{...}
{synopt:{space 4}{it:Keyword}}Explanation{p_end}
{space 4}{synoptline}
{synopt:{space 4}{opt pop}}Population, overall and by sex, age, and race ({stata getcensus pop, clear:click to run}){p_end}
{synopt:{space 4}{opt pov}}Poverty, overall and by sex, age, and race ({stata getcensus pov, clear:click to run}){p_end}
{synopt:{space 4}{opt povrate}}Poverty rate, overall and by sex, age, and race ({stata getcensus povrate, clear:click to run}){p_end}
{synopt:{space 4}{opt medinc}}Median household income, overall and by race of householder ({stata getcensus medinc, clear:click to run}){p_end}
{synopt:{space 4}{opt snap}}SNAP participation overall and by poverty status, income, disability status, family composition, and family work effort ({stata getcensus snap, clear:click to run}){p_end}
{synopt:{space 4}{opt medicaid}}Medicaid participants, by age ({stata getcensus medicaid, clear:click to run}){p_end}
{synopt:{space 4}{opt housing_overview}}Various housing-related estimates including occupancy, tenure, costs, and cost burden({stata getcensus housing_overview, clear:click to run}){p_end}
{synopt:{space 4}{opt costburden_renters}}Detailed renter housing cost burden({stata getcensus costburden_renters, clear:click to run}){p_end}
{synopt:{space 4}{opt costburden_owners}}Detailed homeowner housing cost burden ({stata getcensus costburden_owners, clear:click to run}){p_end}
{synopt:{space 4}{opt tenure_inc}}Median household income and poverty status of families, by housing tenure ({stata getcensus tenure_inc, clear:click to run}){p_end}
{synopt:{space 4}{opt kids_nativity}}Nativity of children, by age and parent's natvity ({stata getcensus kids_nativity, clear:click to run}){p_end}
{synopt:{space 4}{opt kids_pov_parents_nativity}}Children by poverty status and parent's nativity ({stata getcensus kids_pov_parents_nativity, clear:click to run}){p_end}

{pstd}
{it}Note: When using the data returned by the keyword {bf}costburden_renters{it} to compute rates of renter housing cost burden, compute the denominator by subtracting the number of renters for whom cost burden is not computed (B25070_011) from the total number of renters (B25070_001). This step is not necessary when using the table returned by the keyword {bf}housing_overview{it}; the total in this table's section on rent burden (DP04_0136) already excludes the number of renters for whom cost burden cannot be computed.{sf}



{marker options}{...}
{title:Options}

{dlgtab:Main}

{phang}
{opth years(numlist)}       Year or list of years to return. Default is most current
                            year. Range of years may be separated with "-" or "/". 
                            API cannot access years before and including 2009 (except
                            5-year data are available for 2009). Data
                            for preceding calendar year are available starting
                            mid-September (e.g., data for 2016 are available
                            starting mid-September 2017).

{phang}
{opt data:set(#)}           Required option that specifies whether to return
                            1-, 3-, or 5-year ACS estimates. Default is {bf:1}.
                            
{phang}
{opt path(string)}          File path where to save results or, if running
                            {cmd:getcensus catalog}, the API's dictionary. The 
                            default path will be in your home directory. To avoid
                            passing your desired path each time, add 
                            {bf:global getcensuspath "YOUR_PATH"} to your
                            profile.do.

{phang}
{opt pr:oduct(string)}      Two-letter acronym representing product type of table.
                            For example, Table B19013 is a detailed table. This 
                            program will figure out the relevant product type
                            for the table or estimate ID you pass. It is only
                            necessary to pass a product when you pass a search
                            term to {cmd:getcensus catalog} so that the program
                            searches the correct dictionary (each product type 
                            has its own dictionary).

{marker product}{...}
{synoptset 30}{...}
{synopt:{space 4}{it:product}}Definition{p_end}
{space 4}{synoptline}
{synopt:{space 4}{opt DT}} Detailed table ({browse "https://api.census.gov/data/2017/acs/acs1/variables.html":dictionary}){p_end}
{synopt:{space 4}{opt ST}} Subject table ({browse "https://api.census.gov/data/2017/acs/acs1/subject/variables.html":dictionary}){p_end}
{synopt:{space 4}{opt DP}} Data profile ({browse "https://api.census.gov/data/2017/acs/acs1/profile/variables.html":dictionary}){p_end}
{synopt:{space 4}{opt CP}} Comparison profile ({browse "https://api.census.gov/data/2017/acs/acs1/cprofile/variables.html":dictionary}){p_end}

{space 4}{synoptline}
{p2colreset}{...}

{phang}
{opt br:owse}               Open data browser after execution of command.

{phang}
{opt clear}                 If there are existing data in memory, replace them with
                            retrieved data.


{dlgtab:Options}

{phang}
{opt key(string)}           To access the API, you must acquire a key from Census: 
                            To acquire, register
                            {browse "https://api.census.gov/data/key_signup.html":here}. 
                            To avoid passing the key each time, add 
                            {bf:global censuskey "YOUR_KEY"} to your profile.do.

{phang}
{opt geo:graphy(string)}    Level of geography to return. Default is "state". Partial list  below.
                            For more details, see {browse "https://api.census.gov/data/2017/acs/acs1/geography.html":here}.
							To look up state FIPS codes and GEOIDs, see 
							{browse "https://www.census.gov/geographies/reference-files/2017/demo/popest/2017-fips.html":here}.

{marker geography}{...}
{synoptset 30}{...}
{synopt:{space 4}{it:geography}}Definition{p_end}
{space 4}{synoptline}
{synopt:{space 4}{opt us}} United States {p_end}
{synopt:{space 4}{opt state}} State {p_end}
{synopt:{space 4}{opt region}} Census Region {p_end}
{synopt:{space 4}{opt division}} Division {p_end}
{synopt:{space 4}{opt county}} County {p_end}
{synopt:{space 4}{opt county subdivision}} County Subdivision. Only available for 5-year data. Must pass single state FIPS.{p_end}
{synopt:{space 4}{opt cd}} Congressional District {p_end}
{synopt:{space 4}{opt metro}} All metropolitan and micropolitan areas. Can optionally pass state FIPS.{p_end}
{synopt:{space 4}{opt tract}} Census tracts. Only available for 5-year data. Must pass single state FIPS.{p_end}
{synopt:{space 4}{opt block}} Census block groups. Only available for 5-year data. Must pass single state FIPS and single county FIPS.{p_end}
{synopt:{space 4}{opt sch}} Unified school districts. Must pass single state FIPS. {p_end}
{synopt:{space 4}{opt place}} Legal or statistical entities. Includes cities, boroughs, towns, villages, or some other concentration of population, housing, or commercial structures identifiable by name.{p_end}

{space 4}{synoptline}
{p2colreset}{...}

{phang}
{opth geoids(numlist)}      Abbreviated GEOIDs for desired geographies. Most
                            commonly, you would pass a two digit FIPS code for a
                            specific state if your geo was "state" (e.g., 01 for
                            Alabama). Default is all. Can explicitly select all
                            with "*".

{phang}
{opth st:atefips(numlist)}  Two digit FIPS code(s) of state(s) for which to
                            return data. Do not pass if geo is "us", "state",
                            "region", or "division". Default is all. Can
                            explicitly select all with "*".
                            
{phang}
{opt co:untyfips(#)}        Three digit FIPS code(s) of single county) for 
                            which to return data. Only passed if geography is 
                            "block".

{phang}
{opth save:as(filename)}     Will save in Stata's native format ({bf:.dta}).

{phang}
{opt ex:portexcel}          Will export table in .xlsx format based on name passed
                            in {bf:saveas}.

{phang}
{opt nol:abel}              Will not retrieve labels associated with estimate IDs.
                            If you do not specify this option, program will either 
                            label variable or save label as note.
                            
{phang}
{opt noerr:or}              Will not retrieve margins of error (MOEs) associated
                            with estimates. If you do not specify, program will
                            automatically retrieve associated MOEs.

{marker catalog_options}{...}
{dlgtab:Catalog options}

{phang}
{opt search(string)}        Searches the estimate labels using the API's dictionary.
                            Returns a variable "searchmatch" that is equal to "1"
                            if an estimate label contains the search term.

{phang}
{opt t:able(string)}        Returns all estimate IDs and labels associated with
                            a single table (e.g., B19013). If table is not a
                            detailed table, pass the relevant product type
                            (see "product" above).

{marker examples}{...}
{title:Examples}
{dlgtab:Main program}
    {pmore}. {bf:getcensus} B17001_001, clear
        // single estimate (most recent 1-year data available)
        ({stata getcensus B17001_001, clear:click to run})
    {p_end}
    
    {pmore}. {bf:getcensus} B17001, clear
        // all estimates from table B17001
        ({stata getcensus B17001, clear:click to run}){p_end}
    
    {pmore}. {bf:getcensus} medinc, years(2014 - 2016) clear
        // various estimates related to median household income, 2014-2016
        ({stata getcensus medinc, years(2014 - 2016) clear:click to run})
    {p_end}
    
    {pmore}. {bf:getcensus} B17001_001 B19013_001, geo(county) clear
        // multiple estimates at county level
        ({stata getcensus B17001_001 B19013_001, geo(county) clear:click to run})
    {p_end}
    
    {pmore}. {bf:getcensus} B17001_001 B19013_001, geo(state) geoids(01 02)years(2014/2016) clear
        // restricted to two states; alternative way of specifying years
        ({stata getcensus B17001_001 B19013_001, geo(state) geoids(01 02) years(2014/2016) clear:click to run})
    {p_end}
    
    {pmore}. {bf:getcensus} B17001_001 B19013_001, dataset(5) geo(tract) states(01) clear
        // five-year estimates at the tract-level in a single state
        ({stata getcensus B17001_001 B19013_001, dataset(5) geo(tract) states(01) clear:click to run})
    {p_end}
    
    {pmore}. {bf:getcensus} B19013_001, geo(metro) clear
        // estimates by metro/micro areas
        ({stata getcensus B19013_001, geo(metro) clear:click to run})
    {p_end}
    
    {pmore}. {bf:getcensus} B19013, data(5) geo(metro) geoids(12260) st(13) clear
        // all estimates from a single table, choose portion of metro area that falls within a single state
        ({stata getcensus B19013, data(5) geo(metro) geoids(12260) st(13) clear:click to run})
    {p_end}
	
	{pmore}. {bf:getcensus} kids_nativity, clear
        // use a keyword to retrieve a curated set of estimates related to children's nativity
        ({stata getcensus kids_nativity, clear:click to run})
    {p_end}
    
{dlgtab:Catalog }
    {pmore}. {bf:getcensus catalog}, clear
        // loads full dictionary for detailed tables
        ({stata getcensus catalog, clear:click to run})
    {p_end}
    
    {pmore}. {bf:getcensus catalog}, product(ST) clear
        // loads full dictionary for subject tables
        ({stata getcensus catalog, product(ST) clear:click to run})
    {p_end}
    
    {pmore}. {bf:getcensus catalog}, table(S1701) clear
        // loads only portion of dictionary corresponding to specified table
        ({stata getcensus catalog, table(S1701) clear:click to run})
    {p_end}
    
    {pmore}. {bf:getcensus catalog}, search(median income) clear
        // searches detailed tables dictionary for labels that include words from search
        ({stata getcensus catalog, search(median income) clear:click to run})
    {p_end}
    
    {pmore}. {bf:getcensus catalog}, search(median income) browse clear
        // opens browser at end of search
        ({stata getcensus catalog, search(median income) browse clear:click to run})
    {p_end}
    
    {pmore}. {bf:getcensus catalog}, search(median income) product(ST) clear
        // searches subject tables instead of detailed tables
        ({stata getcensus catalog, search(median income) product(ST) clear:click to run})
    {p_end}

{marker authors}{...}
{title:Authors}

{pstd} Created by Raheem Chaudhry and Vincent Palacios. {p_end}
{pstd} Maintained by Claire Zippel and Matt Saenz, {browse "http://www.cbpp.org":Center on Budget and Policy Priorities}. {p_end}
{p_end}