{smcl}
{* *! version 0.1.0  27mar2019}{...}
{viewerjumpto "Syntax" "getcensus##syntax"}{...}
{viewerjumpto "Menu" "getcensus##menu"}{...}
{viewerjumpto "Description" "getcensus##description"}{...}
{viewerjumpto "Options" "getcensus##options"}{...}
{viewerjumpto "Examples" "getcensus##examples"}{...}
{title:Title}

{p2colset 5 20 22 2}{...}
{p2col:{cmd: getcensus} {hline 2}}Import estimates from the American Community Survey{p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 8 16 2}
{cmd:getcensus}
{varlist}
[, {it:{help getcensus##options:options}}]


{synoptset 27 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
    {synopt:{opth key(string)}}Census key to access API.{p_end}
    {synopt:{opth years(numlist)}}Years to retrieve. Default is most recent year. {p_end}
    {synopt:{opth data:set(#)}}ACS 1, 3, or 5-year estimates. Default is "1".{p_end}
    {synopt:{opth geo:graphy(string)}}Geography to download. Default is "state".{p_end}
    {synopt:{opth geoids(varlist)}}GEOIDs of geography to download. Default is usually all.{p_end}
    {synopt:{opth st:atefips(varlist)}}States for which to download data. Default is usually all states.{p_end}
    {synopt:{opth pr:oduct(string)}}Type of table. E.g., detailed tables, subject tables.{p_end}
    {synopt:{opth path(string)}}Path where to store Census API dictionary. {p_end}

{syntab:Options}
    {synopt:{opt save:as(filename)}}Filename to save downloaded data.{p_end}
    {synopt:{opt nol:abel}}Do not retrieve labels associated with estimate IDs.{p_end}


{marker description}{...}
{title:Description}

{pstd}
{cmd:getcensus} passes a list of arguments to the Census' Application Programming
    Interface (API), which loads data from American Community Survey (ACS)
    into memory.

{pstd}
By default, {cmd:getcensus} retrieves a 1-year estimate for the U.S. of 
B01001_001E and B01001_001M, the estimates and margin of error for population.

{pstd}
Be advised, {cmd:getcensus} retrieves both the estimate and margin of error 
associated with a statistic. Estimates have the suffix "E", while margins of 
errors have the suffix "M".

{pstd}
Below are some commonly used estimates.
Full list {browse "https://api.census.gov/data/2017/acs/acs1/variables.html":here}

{marker estimates}{...}
{synoptset 30}{...}
{synopt:{space 4}{it:Estimate}}Concept{p_end}
{space 4}{synoptline}
{synopt:{space 4}{opt B17001_001}} Total in poverty universe {p_end}
{synopt:{space 4}{opt B17001_002}} Total living below poverty line {p_end}
{synopt:{space 4}{opt B19013_001}} Median household income {p_end}

{pstd}
You can add a letter to the end of some "B" or "C" tables to get estimates by race. E.g.,

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
{synopt:{space 4}{opt B17001H_001}} Total in poverty universe, non-Hispanic White {p_end}
{synopt:{space 4}{opt B17001I_001}} Total in poverty universe, Hispanic {p_end}


{marker options}{...}
{title:Options}

{dlgtab:Main}

{phang}
{opth key(string)}          To access the API, you must acquire a key from Census: 
                            To acquire, register
                            {browse "https://api.census.gov/data/key_signup.html":here}. 
                            To avoid passing the key each time, add 
                            {bf:global censuskey "YOUR_KEY"} to your profile.do.

{phang}
{opth years(numlist)}       Year or list of years to return. Default is most current
                            year. Range of years may be separated with "-" or "/". 
                            API cannot access years before and including 2009 (except
                            5-year data are available for 2009). Data
                            for preceding calendar year are available starting after
                            the second Thursday of every September (e.g., data for
                            2016 are available starting mid-September 2017).

{phang}
{opth data:set(#)}          Required option that specifies whether to return
                            1-, 3-, or 5-year ACS estimates. Default is {bf:1}.

{phang}
{opth geo:graphy(string)}   Level of geography to return. Default is "state". Partial list  below.
                            For more details, see 
                            {browse "https://api.census.gov/data/2016/acs/acs1/geography.html":here}.

{marker geography}{...}
{synoptset 30}{...}
{synopt:{space 4}{it:geo}}Definition{p_end}
{space 4}{synoptline}
{synopt:{space 4}{opt us}} United States {p_end}
{synopt:{space 4}{opt states}} State {p_end}
{synopt:{space 4}{opt region}} Census Region {p_end}
{synopt:{space 4}{opt division}} Division {p_end}
{synopt:{space 4}{opt county}} County {p_end}
{synopt:{space 4}{opt county subdivision}} County Subdivision. Only available for 5-year data. Must pass single statefips. {p_end}
{synopt:{space 4}{opt cd}} Congressional District {p_end}
{synopt:{space 4}{opt metro}} All metropolitan and micropolitan areas. Cannot pass statefips {p_end}
{synopt:{space 4}{opt tract}} Census tracts. Only available for 5-year data. Must pass single statefips.{p_end}
{synopt:{space 4}{opt block}} Census block groups. Only available for 5-year data. Must pass single statefips and countyfips{p_end}
{synopt:{space 4}{opt sd}} Unified school districts. Must pass single statefips. {p_end}

{space 4}{synoptline}
{p2colreset}{...}

{phang}
{opth geoids(varlist)}      Abbreviated GEOIDs for desired geographies. Most
                            commonly, you would pass a two digit FIPS code for a
                            specific state if your geo was "state" (e.g., 01 for
                            Alabama). Default is all. Can explicitly select all
                            with "*".

{phang}
{opth st:atefips(varlist)}  Two digit FIPS code(s) of state(s) for which to
                            return data. Do not pass if geo is "us", "state",
                            "region", or "division". Default is all. Can
                            explicitly select all with "*".

{phang}
{opth pr:oduct(string)}     Type of table. Default is "detailed". Only pass one.
                            See full list 
                            {browse "https://api.census.gov/data/2016/acs/acs1.html":here}.
                            

{marker geo}{...}
{synoptset 17}{...}
{synopt:{space 4}{it:geo}}Definition{p_end}
{space 4}{synoptline}
{synopt:{space 4}{opt dt}} Detailed Table {p_end}
{synopt:{space 4}{opt st}} Subject Table {p_end}
{synopt:{space 4}{opt cp}} Comparison Profile {p_end}
{synopt:{space 4}{opt dp}} Data Profile {p_end}
{space 4}{synoptline}
{p2colreset}{...}                          
                          
{phang}
{opth path(string)}         This program downloads the Census API dictionary in 
                            order to label variables and to help search the codebook.
                            {browse "https://api.census.gov/data/key_signup.html":here}.
                            You can pass a path where you would like this to be
                            downloaded; otherwise, the default path will be in your
                            home directory. To avoid passing your desired path each
                            time, add {bf:global getcensuspath "YOUR_PATH"} to your
                            profile.do.

{dlgtab:Options}

{phang}
{opt save:as(filename)}     Will save in Stata's native format ({bf:.dta}).

{phang}
{opt nol:abel}              Will not retrieve labels associated with estimate IDs.
                            If you do not specify this option, program will either 
                            label variable or save label as note.


{marker examples}{...}
{title:Examples}

    {pmore}. {bf:getcensus} B17001_001, clear{p_end}
    {pmore}. {bf:getcensus} B17001_001, years(2014 - 2016) clear{p_end}
    {pmore}. {bf:getcensus} B17001, years(2014 - 2016) clear{p_end}
    {pmore}. {bf:getcensus} B17001_001 B19013_001, geo(county){p_end}
    {pmore}. {bf:getcensus} B17001_001 B19013_001, geo(state) geoids(01 02) years(2014/2016){p_end}
    {pmore}. {bf:getcensus} B17001_001 B19013_001, dataset(5) geo(tract) states(01) clear {p_end}
    {pmore}. {bf:getcensus} B17001_001 B19013_001, geo(metro) clear {p_end}
    {pmore}. {bf:getcensus} B19013, data(5) geo(metro) geoids(12260) st(13) clear {p_end}

{marker authors}{...}
{title:Authors}

{pstd} Vincent Palacios, {browse "mailto:palacios@cbpp.org":palacios@cbpp.org}; Raheem Chaudhry, {browse "mailto:rchaudhry@cbpp.org":rchaudhry@cbpp.org}{p_end}
{pstd} Center on Budget and Policy Priorities {p_end}