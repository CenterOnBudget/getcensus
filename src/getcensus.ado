*! maintainers  Claire Zippel, Matt Saenz
*! authors      Raheem Chaudhry, Vincent Palacios
*! description  Load published estimates from the American Community Survey into memory.
*! changelog    https://github.com/CenterOnBudget/getcensus/blob/master/NEWS.md


/* DESCRIPTION -----------------------------------------------------------------


This program retrieves American Community Survey data from the Census Bureau API 
and imports it into Stata.
It has three subroutines:
- The main command-driven program
- A "catalog" that helps users search the data dictionaries
- A "point-and-click" system to help users who are new to Stata and may
need some help writing Stata commands


* DEFINE -------------------------------------------------------------------- */

/* // for debugging
cap program drop getcensus
cap program drop getcensus_catalog
cap program drop getcensus_help
cap program drop getcensus_main
*/

program define getcensus
version 14.0

// store syntax in global since it is repeated for each of the subroutines
global syntax "syntax [anything(name=estimates)] [, YEARs(string) DATAset(string) GEOgraphy(string) geoids(string) STatefips(string) COuntyfips(string) key(string) SAVEas(string) CACHEpath(string) PRoduct(string) Table(string) search(string) NOLabel NOERRor EXportexcel BRowse clear]"

${syntax}


* DEPENDENCIES -----------------------------------------------------------------

// This program requires jsonio to run (just "catalog" portion)
foreach program in jsonio {
    capture which `program'
    if _rc    {
        display _newline(1)
        display as result "You don't have `program' installed. Enter -yes- to install or any other key to abort." _request(_y)
        if "`y'"=="yes" ssc install `program'
        else {
            display as error "`program' not installed. To use getcensus, first install `program' by typing -ssc install `program'-."
            exit
        }
    }
}


* DEFAULTS ---------------------------------------------------------------------

** Dataset (Default: 1-year data)
if "`dataset'" == "" local dataset "1"

** Years (Default: most current year)
local curryear  year(td(`c(current_date)'))
local currmonth month(td(`c(current_date)'))
local currday   day(td(`c(current_date)'))

local lastacs1yr = `curryear' - 2
if `currmonth' >= 10 | (`currmonth' == 9 & `currday' >= 13) {
    local lastacs1yr = `curryear' - 1 
    // if past mid-sep, then lastacs1yr is just year before; clean up
}

local lastacs5yr = `curryear' - 2
if `currmonth' >= 12 & `currday' >= 6 {
    local lastacs5yr = `curryear' - 1
    // if past mid-dec, then lastacs5yr is just year before; clean up
}

if "`years'" == ""                              local years "`lastacs1yr'"
if "`years'" == "" & "`dataset'" == "5"         local years "`lastacs5yr'"

** Path (Default: Save data in App Support)
if "`cachepath'" == "" {
    if "`c(os)'" == "Windows" {
        local cachepath "~/AppData/Local/getcensus"
    }
    else {
        local cachepath "~/Library/Application Support/getcensus"
    }
    cap mkdir "`cachepath'"
}


* PARSE YEARS ------------------------------------------------------------------

local switch 0
local allyears ""

foreach split in "-" "/" " - " " / " {
    local years = subinstr("`years'", "`split'", " - ", .)
}

foreach i in `years' {
    if `switch' == 1 {
        local start = `beforesplit' + 1
        local stop = `i' - 1
        if `stop' < `start' & `stop' - `start' != -1 {
            dis as error "Make sure to pass larger years first if separating with delimiter (/ or -)"
            exit
        }
        
        forvalues j = `start'/`stop' {
            local allyears = "`allyears' `j'"
        }
        
        local switch 0
    }

    if "`i'" == "-" {
        local switch = 1
    }
    else {
        local allyears = "`allyears' `i'"
        local beforesplit "`i'"
    }
}

local years = strtrim("`allyears'")
local recentyear 0
foreach year in `years' {
    if `year' > `recentyear' local recentyear `year'
}

* ERROR HANDLING ---------------------------------------------------------------

if (`c(changed)' | `c(N)' | `c(k)') & "`clear'" == "" & "`estimates'" != ""{
    dis as err "no; data in memory would be lost"
    exit
}

foreach year in `years' {
    if (`year' < 2010 & "`dataset'" == "1") {
        dis as yellow "As of last update to getcensus, Census' API only provided data for 2010 and onward for 1-year data."
        // exit
    }
}

foreach year in `years' {
    if `year' > `lastacs1yr' {
        dis as yellow "As of last update for getcensus, data for `year' had not been released."
        // exit
    }
}


foreach year in `years' {
    if !inlist(`year', 2012, 2013) & "`dataset'" == "3" {
        dis as yellow "3-year data only available for 2012 and 2013."
        // exit
    }
}

foreach year in `years' {
    if `year' > `lastacs5yr' & "`dataset'" == "5" {
        dis as yellow "As of last update for getcensus, 5-year data for `year' had not been released."
        // exit
    }
}

if !inlist(`dataset', 1, 3, 5) {
    dis as yellow "Census only produces 1-, 3-, or 5-year estimates."
    // exit
}

* SWITCHES ---------------------------------------------------------------------

if "`estimates'" == "" {
    getcensus_help
}
else if "`estimates'" == "catalog" {
    if "`geography'" != "" | "`geoids'" != "" | "`statefips'" != "" | "`countyfips'" != "" | "`saveas'" != "" {
        dis as err "The 'catalog' program only accepts arguments for 'dataset', 'cachepath', 'product', 'search', 'table', and 'years' options. All other arguments will be disregarded."
    }
    getcensus_catalog, years(`recentyear') dataset(`dataset') cachepath(`cachepath') search(`search') table(`table') product(`product') `browse' `clear'
}
else if "`estimates'" == "point_and_click" {
    if "`exportexcel'" != "" local export "exportexcel saveas(Results)"
    getcensus ${tablelist}, years(${years}) dataset(${dataset}) geography(${geography}) `export' clear
    dis "Here is the code used to produce your estimates. You can revise this as needed:"
    dis "getcensus ${tablelist}, years(${years}) dataset(${dataset}) geography(${geography}) `export' clear"
    macro drop tablelist
    macro drop years
    macro drop dataset
    macro drop geography
}
else {
	getcensus_main `estimates', years(`years') dataset(`dataset') product(`product') geography(`geography') geoids(`geoids') statefips(`statefips') countyfips(`countyfips') key(`key') saveas(`saveas') cachepath(`cachepath') `nolabel' `noerror' `exportexcel' `browse' `clear' recentyear(`recentyear')

}

macro drop syntax
end

* SUBROUTINE: HELP -------------------------------------------------------------

program define getcensus_help
    dis as text "You didn't pass any arguments. Here are some tips for getting started:"
    dis as text ""
    dis as text "For instructions on how to get started, or a browsable list of key tables you"
    dis as text "can retrieve, type 'help getcensus' into the Command window."
    dis as text ""
    dis as text "Type 'getcensus catalog' if you need help finding estimate or table IDs."
    dis as text ""
    dis as text "While you don't need to be an expert at writing Stata code for this program to"
    dis as text "work, it will be most useful to you if you understand the basics."
    dis as text ""
    dis as text "If you know your estimate or table IDs and want to customize your geography or"
    dis as text "other options, the syntax is as follows:"
    dis as text "getcensus *List of estimate or table IDS*, years() geography() statefips() product()"
    dis as text "In Stata, options go after a comma, and each option takes 'arguments' in"
    dis as text "parentheses."
    dis as text ""
    dis as text "That may be intimidating, so we can also help you construct a query below:"
    dis as text "Note, you *must* pick a table. If you don't choose among any of the other options before retrieving the data, the program will retrieve 1-year, state-by-state estimates for the most recent year of data available."

    dis as text ""
    dis as text "First, what types of tables are you looking for?"
    dis "{stata global tablelist ""pop"":Population, overall and by sex, age, and race [pop]}"
    dis "{stata global tablelist ""pov"":Poverty, overall and by sex, age, and race [pov]}"
    dis "{stata global tablelist ""povrate"":Poverty rate, overall and by sex, age, and race [povrate]}"
	dis "{stata global tablelist ""povratio"":Population by ratio of income to poverty level [povratio]}"
	dis "{stata global tablelist ""povratio_char"":Characteristics of the population at specified poverty levels [povratio_char]}"
    dis "{stata global tablelist ""medinc"":Median household income, overall and by race of householder [medinc]}"
    dis "{stata global tablelist ""snap"":SNAP participation by poverty status, income, disability, family composition, and family work experience [snap]}"
    dis "{stata global tablelist ""medicaid"":Medicaid participants, by age [medicaid]}"
	dis "{stata global tablelist ""housing_overview"":Various housing-related estimates including occupancy, tenure, costs, and cost burden [housing_overview]}"
	dis "{stata global tablelist ""costburden_renters"":Detailed renter housing cost burden [costburden_renters]}"
		dis "{stata global tablelist ""costburden_owners"":Detailed homeowner housing cost burden [costburden_owners]}"
    dis "{stata global tablelist ""tenure_inc"":Median household income and poverty status of families, by housing tenure [tenure_inc]}"
    dis "{stata global tablelist ""kids_nativity"":Nativity of children, by age and parent's natvity  [kids_nativity]}"
	dis "{stata global tablelist ""kids_pov_parents_nativity"":Children by poverty status and parent's nativity [kids_pov_parents_nativity]}"
    
    dis as text ""
    dis as text "Are you looking for single-year data or 5-year averages?"
    dis "{stata global dataset 1:1-year data}"
    dis "{stata global dataset 5:5-year averages}"
    
    dis as text ""
    dis as text "Which year do you want data for?"
    dis "{stata global years 2009:2009}"
    dis "{stata global years 2010:2010}"
    dis "{stata global years 2011:2011}"
    dis "{stata global years 2012:2012}"
    dis "{stata global years 2013:2013}"
    dis "{stata global years 2014:2014}"
    dis "{stata global years 2015:2015}"
    dis "{stata global years 2016:2016}"
    dis "{stata global years 2017:2017}"
    dis "{stata global years 2018:2018}"
    
    dis as text "(If you want a range of years, type something like"
    dis as text "'global years 2010-2017' into the Command Window"
    
    dis as text ""
    dis as text "What level of geographic detail are you looking for?"
    dis as text "(Note: You can get more from the program if you use the command line. Type"
    dis as text "'help getcensus' into the Command Window for more details.)"
    dis "{stata global geography ""us"":US}"
    dis "{stata global geography ""state"":State}"
    dis "{stata global geography ""region"":Census Region}"
    dis "{stata global geography ""division"":Division}"
    dis "{stata global geography ""county"":County}"
    dis "{stata global geography ""cd"":Congressional District}"
    
    dis as text ""
    dis as text "When you're ready, click one of the links below:"
    dis "{stata getcensus point_and_click, clear: Retrieve my data}"
    dis "{stata getcensus point_and_click, exportexcel clear: Retrieve my data and export to Excel (will store in current directory)}"
    
    // dis as text ""
    // dis "{stata export excel using Results.xlsx, replace:Click here to export results to Excel (will store in current directory)}"
    
end


* SUBROUTINE: CATALOG ----------------------------------------------------------

program define getcensus_catalog
${syntax}

* ERROR HANDLING ---------------------------------------------------------------

** Product
local table = upper("`table'")

if "`table'" != "" & "`product'" != "" {
    dis "Program will derive product from 'table' and ignore 'product'"
}

if ustrregexm("`table'", "(^B)|(^C(?!P))") == 1 | "`product'" == "" | "`product'" == "DT" {
    local product "DT"
    local productdir ""
}

if strpos("`table'", "CP") == 1 | "`product'" == "CP" {
    local product "CP"
    local productdir "/cprofile"
}

if strpos("`table'", "DP") == 1 | "`product'" == "DP" {
    local product "DP"
    local productdir "/profile"
}

if strpos("`table'", "S") == 1 | "`product'" == "ST" {
    local product "ST"
    local productdir "/subject"
}



** Protect data in memory
preserve
if "`clear'" != "" {
    clear
}


* GET CATALOG ------------------------------------------------------------------

** Download data dictionary if it doesn't exist
qui cap confirm file "`cachepath'/`productdir'variables_`dataset'yr_`years'.dta"
if _rc {
    jsonio kv, file("https://api.census.gov/data/`years'/acs/acs`dataset'`productdir'/variables.json") elem("(/variables/)(.*)(label)(.*)")
    dis "https://api.census.gov/data/`years'/acs/acs`dataset'`productdir'/variables.json"
    drop if inlist(key, "/variables/for/label", "/variables/in/label")
    replace key = subinstr(key, "/variables/", "", .)
    replace key = subinstr(key, "/label", "", .)
    rename key estimateID
    rename value estimateLabel
    compress
    sort estimateID
    save "`cachepath'/`productdir'variables_`dataset'yr_`years'.dta", replace
}

** Conduct search use 'table' and 'search'
if "`table'" == "" {
    use "`cachepath'/`productdir'variables_`dataset'yr_`years'.dta", clear
    dis as result "Searched for all tables for product `product'"
}
else {
    use "`cachepath'/`productdir'variables_`dataset'yr_`years'.dta" if strpos(estimateID, "`table'") != 0, clear
    dis as result "Searched for table `table'"
}

qui ds
foreach var in `r(varlist)' {
    local fmt: format `var'
    local fmt: subinstr local fmt "%" "%-"
    format `var' `fmt'
    
}

if "`search'" != "" {
    local regex = "(.*)(`search')(.*)"
    local regex = subinstr("`regex'", " ", ")(.*)(", .)

    qui sort estimateID

    cap drop searchmatch
    gen searchmatch = regexm(strlower(estimateLabel), "`regex'")
    qui levelsof estimateID if searchmatch == 1

    qui keep if searchmatch == 1
    dis as result "Searched using search term *`search'*"
    // alternative: 
    // br if searchmatch == 1
}

restore, not
    
end

* SUBROUTINE: MAIN -------------------------------------------------------------

program define getcensus_main

syntax [anything(name=estimates)] [, YEARs(string) DATAset(string) GEOgraphy(string) geoids(string) STatefips(string) COuntyfips(string) key(string) SAVEas(string) CACHEpath(string) PRoduct(string) Table(string) search(string) NOLabel NOERRor EXportexcel BRowse clear recentyear(string)]


* PRE-PACKAGED ESTIMATES -------------------------------------------------------

/*
For this program, we have a list of 'curated' tables. These are keywords that
users can pass to get a list of estimates we pick by hand. These are nothing
more than locals which hold the names of the estimates.
*/

** Poverty
local pop_total "S1701_C01_001"
local pop_byage "S1701_C01_002 S1701_C01_006 S1701_C01_010"
local pop_bysex "S1701_C01_011 S1701_C01_012"
local pop_byrace "S1701_C01_014 S1701_C01_015 S1701_C01_016 S1701_C01_017 S1701_C01_018 S1701_C01_019 S1701_C01_020 S1701_C01_021"
local pop "`pop_total' `pop_byage' `pop_bysex' `pop_byrace'"

local pov_total "S1701_C02_001"
local pov_byage "S1701_C02_002 S1701_C02_006 S1701_C02_010"
local pov_bysex "S1701_C02_011 S1701_C02_012"
local pov_byrace "S1701_C02_014 S1701_C02_015 S1701_C02_016 S1701_C02_017 S1701_C02_018 S1701_C02_019 S1701_C02_020 S1701_C02_021"
local pov "`pov_total' `pov_byage' `pov_bysex' `pov_byrace'"

local povrate_total "S1701_C03_001"
local povrate_byage "S1701_C03_002 S1701_C03_006 S1701_C03_010"
local povrate_bysex "S1701_C03_011 S1701_C03_012"
local povrate_byrace "S1701_C03_014 S1701_C03_015 S1701_C03_016 S1701_C03_017 S1701_C03_018 S1701_C03_019 S1701_C03_020 S1701_C03_021"
local povrate "`povrate_total' `povrate_byage' `povrate_bysex' `povrate_byrace'"

local povratio "B17002"
local povratio_char "S1703"

** Income
local medinc "B19013_001"
local medinc_byrace "B19013B_001 B19013C_001 B19013D_001 B19013E_001 B19013F_001 B19013G_001 B19013H_001 B19013I_001"
local medinc "`medinc' `medinc_byrace'"

** Program participation
local snap_total "S2201_C04_001"
local snap_composition "S2201_C04_007 S2201_C04_009"
local snap_poverty "S2201_C04_021"
local snap_disability "S2201_C04_023"
local snap_byrace "S2201_C04_026 S2201_C04_027 S2201_C04_028 S2201_C04_029 S2201_C04_030 S2201_C04_031 S2201_C04_032 S2201_C04_033"
local snap_medinc "S2201_C04_034"
local snap_employment "S2201_C04_035 S2201_C04_036 S2201_C04_037 S2201_C04_038"
local snap "`snap_total' `snap_composition' `snap_poverty' `snap_disability' `snap_byrace' `snap_medinc' `snap_employment'"

local medicaid_total "S2704_C02_006"
local medicaid_byage "S2704_C02_007 S2704_C02_008 S2704_C02_009"
local medicaid "`medicaid_total' `medicaid_byage'"

** Housing
local housing_overview "DP04"
local costburden_renters "B25070"
local costburden_owners "B25091"

local ten "B25003_001 B25003_002 B25003_003"
local ten_medinc "B25119_001 B25119_002 B25119_003"
local ten_pov "C17019_001 C17019_002 C17019_003 C17019_004 C17019_005 C17019_006 C17019_007"
local tenure_inc "`ten' `ten_medinc' `ten_pov'"

** Children and nativity
local kids_nativity "B05009"
local kids_pov_parents_nativity "B05010"

** Create "estimates" based on expanding local if not from table
local prepackaged ""
foreach estimate in `estimates' {
    if !ustrregexm("`estimates'", "^(B|C|DP|S)(?=\d)", 1) {
        local prepackaged "`prepackaged' ``estimate''"
    }
    else {
        local prepackaged "`prepackaged' `estimate'"
    }
    local estimates = strtrim("`prepackaged'")
}

local estimates = upper("`estimates'")


* ERROR HANDLING ---------------------------------------------------------------

preserve
if "`clear'" != "" {
    clear
}

** Product
if "`estimates'" != "" & "`product'" != "" {
    dis "Program will derive product from 'estimates' and ignore 'product'"
}

if (ustrregexm("`estimates'", "(^B)|(^C(?!P))")) == 1 {
    local product "DT"
    local productdir ""
}

if strpos("`estimates'", "CP") == 1 {
    local product "CP"
    local productdir "/cprofile"
}

if strpos("`estimates'", "DP") == 1 {
    local product "DP"
    local productdir "/profile"
}

if strpos("`estimates'", "S") == 1 {
    local product "ST"
    local productdir "/subject"
}

if "`dataset'" == "5" {
    foreach year in `years' {
        if "`product'" == "DT" & `year' < 2010 {
            dis as yellow "As of last update to getcensus, Census' API only provided data for 2010 and onward for 5-year data for product type DT (estimate IDs -- but not table IDs -- work for 2009."
        }
        else if "`product'" == "ST" & `year' < 2012 {
            dis as yellow "As of last update to getcensus, Census' API only provided data for 2012 and onward for 5-year data for product type ST."
        }
        else if "`product'" == "CP" & `year' < 2015 {
            dis as yellow "As of last update to getcensus, Census' API only provided data for 2015 and onward for 5-year data for product type CP."
        }
        else if "`product'" == "DP" & `year' < 2014 {
            dis as yellow "As of last update to getcensus, Census' API only provided data for 2014 and onward for 5-year data for product type DP."
        }
    }
}

local api_estimateslist ""

foreach estimate in `estimates' {
    ** Estimates must all be of the same type
    if ("`product'" != "DT" & strpos("`product'", substr("`estimate'", 1, 1)) != 1) | ///
	("`product'" == "DT" & !(ustrregexm("`estimate'", "(^B)|(^C(?!P))"))) {
        dis as err "`estimate' is not from product `product'. All estimates must come from same product."
        exit
    }
    
    ** Create estimate ID list (ignore if passing group)
    if strpos("`estimates'", "_")!=0 {
    ** Add estimates and MOEs for all products except comparison profiles
        if "`noerror'" == "" & "`product'" != "CP" {
            local api_estimateslist "`api_estimateslist'`estimate'E,`estimate'M,"
        }
        else {
            local api_estimateslist "`api_estimateslist'`estimate'E,"
        }
    }
    else {
        local api_estimateslist "group(`estimates')"
    }
}

** Geography
if "`geography'" == "" local geography "state"

if "`geography'" == "cd" local geography "congressional district"

if "`geography'" == "metro" local geography "metropolitan statistical area/micropolitan statistical area"

if "`geography'" == "block" local geography "block group"

if inlist("`geography'", "sch", "school district") local geography "school district (unified)"

** Statefips
if "`statefips'" == "" local statefips "*"

local statefipslist ""
if "`statefips'" == "*" {
    local statefipslist "*"
}
else {
    foreach statefip in `statefips' {
		local statefip = string(`statefip',"%02.0f")
        local statefipslist "`statefipslist'`statefip',"
    }
    local statefipslist = substr("`statefipslist'", 1, length("`statefipslist'") - 1)
}

** Key
if "`key'" != "" {
    dis "To avoid passing the key each time, set -global censuskey YOUR_KEY- in your profile.do. Type -help getcensus- for details."
}

if "`key'" == "" local key "$censuskey"

** Geoids
if "`geoids'" == "" local geoids "*"

local geoidslist ""
if "`geoids'" == "*" {
    local geoidslist "*"
}
else {
    foreach geoid in `geoids' {
        local geoidslist "`geoidslist'`geoid',"
    }
    local geoidslist = substr("`geoidslist'", 1, length("`geoidslist'") - 1)
}

** Set order of dataset
local geovarname = "`geography'"
if "`geography'" == "county" local geovarname "state county"
if "`geography'" == "tract" local geovarname "state county tract"
if "`geography'" == "congressional district" local geovarname "state congressionaldistrict"
if "`geography'" == "metropolitan statistical area/micropolitan statistical area" local geovarname "metropolitanstatisticalareamicro"
if "`geography'" == "block group" local geovarname "state county tract blockgroup"
if "`geography'" == "school district (unified)" local geovarname "state schooldistrictunified"
if "`geography'" == "county subdivision" local geovarname "state county countysubdivision"

if inlist("`geography'", "us", "state", "region", "division") {
    local sort "year name"
    local order "year `geovarname' name"
}
else {
    local sort "year `geovarname'"
    local order "year `geovarname' name"
}

if strpos("`estimates'", "_") == 0 & strpos("`estimates'", " ")!= 0 {
    dis as err "Only pass one group at a time."
    exit
}

** Varnames
// Note this is only for estimate IDs, if passing an entire table, we ignore this
foreach estimate in `estimates' {
    if inlist(substr("`estimate'", strlen("`estimate'"),.), "E", "M") & strpos("`estimate'", "_") != 0 {
        dis as err "Make sure none of your estimates include 'E' or 'M' in suffix."
        exit
    }
}

** Geography
if "`geography'" == "state" & "`statefips'" != "*" & "`geoids'" == "*" {
    dis as yellow "If chosen geography is 'state', pass selected state(s) to 'geoids' instead of 'statefips'. We'll fix that for you."
	
	* Redefine geoids and geoidslist with statefips and statefipslist
	local geoids "`statefips'"
	local geoidslist "`statefipslist'"
	
	* Reset statefips and statefipslist to default
	local statefips "*"
	local statefipslist "*"
}

if "`geography'" == "state" & "`statefips'" != "*" & "`statefips'" != "`geoids'" {
    dis as err "If chosen geography is 'state', 'statefips' must be blank or equal to 'geoids'."
    exit
}

if inlist("`geography'", "us", "region", "division") & "`statefips'" != "*" {
    dis as err "If chosen geography is `geography', 'statefips' must be blank."
    exit
}

if "`geography'"=="metropolitan statistical area/micropolitan statistical area" & "`dataset'"!="5" & "`statefips'" != "*" {
    dis as err "You can only get part of state for metropolitan or micropolitan statistical areas using 5-year datasets."
    exit
}

if "`geography'" != "block group" & "`countyfips'" != "" {
    dis as err "Cannot pass county unless geography is block."
    exit
}

if "`geography'" == "block group" & "`countyfips'" == "" {
    dis as err "Must pass county if geography is block."
    exit
}

if "`geography'" == "block group" & strpos("`countyfips'", " ") != 0 {
    dis as err "Can only pass one county if geography is block."
    exit
}

if "`countyfips'" != "" local countyfips = string(`countyfips',"%03.0f")
if "`countyfips'" != "" local countycondition "%20county:`countyfips'"

if "`dataset'" != "5" & inlist("`geography'", "tract", "block group", "county subdivision") {
    dis as err "`geography' only available using 5-year data."
    exit
}

if "`statefips'" == "*" & inlist("`geography'", "tract", "block group", "county subdivision") {
    dis as err "Census API only allows one state per `geography'."
    exit
}

local geography = subinstr("`geography'", " ", "%20", .)

** Product
if strpos("`product'", " ") != 0 {
    dis as err "Can only pass one product type (dt, dp, cp, st) at a time"
    exit
}

** Export
if "`exportexcel'"!="" & "`saveas'"=="" {
    dis as err "If you specify the 'exportexcel' option, must pass filename to 'saveas'."
    exit
}

** Table and search
if "`search'" != "" | "`table'" != "" {
    dis "Search and table options only used when searching catalog of estimate IDs."
}

** Varnames
local varcount: word count `estimates'
if `varcount' > 25 {
    exit
    dis as err "API cannot handle more than 25 IDs at once."
}

if "`key'" == "" {
    dis as err "Must pass Census key. To acquire, register here: https://api.census.gov/data/key_signup.html." 
    dis "To avoid passing each time, set -global censuskey YOUR_KEY- in your profile.do. Type -help getcensus- for details."
    exit
}


* API CALL ---------------------------------------------------------------------

** Generate URL
tempname temp
cap erase `temp'.dta

foreach year in `years' {
    clear
    
    // okay, so here's a problem -- if the estimate is wrong, no error. just doesn't execute
    local apiroot "acs/acs"
    if "`year'" == "2009" local apiroot "acs"
    
    if "`geography'" != "state" & "`statefips'" != "*" {
        if "`geography'" == "metropolitan%20statistical%20area/micropolitan%20statistical%20area" {
            local APIcall "https://api.census.gov/data/`year'/`apiroot'`dataset'`productdir'?get=`api_estimateslist'NAME&for=state%20(or%20part):`statefipslist'&in=`geography':`geoidslist'&key=`key'"
        }
        else {
            local APIcall "https://api.census.gov/data/`year'/`apiroot'`dataset'`productdir'?get=`api_estimateslist'NAME&for=`geography':`geoidslist'&in=state:`statefipslist'`countycondition'&key=`key'"
        }
    }
    else {
        local APIcall "https://api.census.gov/data/`year'/`apiroot'`dataset'`productdir'?get=`api_estimateslist'NAME&for=`geography':`geoidslist'&key=`key'"
    }

    ** Retrieve Data
    if strlen("`APIcall'") < 255 {
        local displaylink "{browse "`APIcall'": Link to data for `year'}"
        dis `"`displaylink'"'
    }
    else {
        dis "Link to data for `year': `APIcall'"
    }
    import delimited using "`APIcall'", varnames(1) stringcols(_all)
    
    qui des
    if r(N) == 0 {
        dis as err "The Census API did not return data. This can happen if 1) the Table IDs were wrong; 2) your API key is invalid; 3) you are not connected to the internet or the Census API server is down. Click 'Link to data', or copy the URL into your browser, to view the specific error message sent by the Census API."
        exit
    }

    ** Post retrieval
    qui gen year = "`year'"
    if "`noerror'" != "" qui cap drop *m
    qui cap drop *ma
    qui cap drop *ea
    qui cap drop v*
    qui compress
    
    qui cap append using `temp'
    qui save `temp', replace
    
}

** Clean up
qui ds
foreach var in `r(varlist)' {
    qui cap replace `var' = subinstr(`var', "[", "", .)
    qui cap replace `var' = subinstr(`var', "]", "", .)
    qui cap replace `var' = subinstr(`var', `"""', "", .)
    label var `var' ""
}

restore, not

if "`exportexcel'" != "" {
    putexcel set "`saveas'", replace
}

** Label data using data dictionary
if "`nolabel'" == "" {
    local labelthis ""
    qui ds
    local varlist `r(varlist)'
    preserve
        clear
        local year `recentyear'
		local url_acs_table_changes "https://www.census.gov/programs-surveys/acs/technical-documentation/table-and-geography-changes.html"
		local click_acs_table_changes "{browse "`url_acs_table_changes'":ACS Table & Geography Changes}"
		display as yellow `"Using data dictionary for `year'. If you requested data for multiple years,"'
		display as yellow `"check the `click_acs_table_changes' on the Census Bureau website."'
        local product = subinstr("`productdir'", "/", "", .)
        qui cap confirm file "`cachepath'/acs`product'variables_`dataset'yr_`year'.dta"
        if _rc {
            qui jsonio kv, file("https://api.census.gov/data/`year'/acs/acs`dataset'`productdir'/variables.json") elem("(/variables/)(.*)(label)(.*)")
            qui dis "https://api.census.gov/data/`year'/acs/acs`dataset'`productdir'/variables.json"
            qui drop if inlist(key, "/variables/for/label", "/variables/in/label")
            qui replace key = subinstr(key, "/variables/", "", .)
            qui replace key = subinstr(key, "/label", "", .)
            qui rename key estimateID
            qui rename value estimateLabel
            qui compress
            qui save "`cachepath'/acs`product'variables_`dataset'yr_`year'.dta", replace
        }
        qui use "`cachepath'/acs`product'variables_`dataset'yr_`year'.dta", clear
		qui replace estimateLabel = subinstr(estimateLabel, 					///
									 "(in `year' inflation-adjusted dollars)", 	///
									 "(in nominal dollars)", 					///
									 1)
        local i = 0
        foreach estimate in `varlist' {
            local i = `i' + 1
            qui levelsof estimateLabel if estimateID == upper("`estimate'")
            local label`i' `r(levels)'
            local estimate`i' "`estimate'"
        }
    restore
    forvalues j = 1/`i' {
        if strlen("`label`j''") > 80 {
            dis as yellow "Label truncated. See notes for `estimate`j''"
        }
        qui label var `estimate`j'' "`label`j''"
        qui notes `estimate`j'': `label`j''
    }
}

** Replace missing values with "."
foreach var of varlist _all {
	qui replace `var' = "." if inlist(`var', "null", "-222222222", "-666666666")
}

** Destring, sort, order
qui destring _all, replace
sort `sort'
order `order'

** Restring state and county fips with leading zeros
qui cap tostring state, format(%02.0f) replace
qui cap tostring county, format(%03.0f) replace

** Export using putexcel (so that we can export variable names)
if "`exportexcel'" != "" {
    qui ds
    local i = 1
    foreach var in `r(varlist)' {
        local varlabel "``var'[note1]'"
        if "`varlabel'" == "" {
            local varlabel: variable label `var'
        }
        if "`varlabel'" == "" {
            local varlabel "`var'"
        }
        
        local colnum1 = floor((`i'-1)/26)
        local colnum2 = mod(`i'-1, 26) + 1
        local col1 = upper(word("`c(alpha)'", `colnum1'))
        local col2 = upper(word("`c(alpha)'", `colnum2'))
        local col = "`col1'`col2'"
        
        qui putexcel `col'1 = ("`varlabel'")
        local i = `i' + 1
    }
}

** Save and export
if "`saveas'" != "" {
	local dest_dir = c(pwd)
    qui saveold `saveas'.dta, replace
	dis as yellow `"Results saved as `dest_dir'/`saveas'.dta."'
    if "`exportexcel'" != "" {
        qui export excel using "`saveas'.xlsx", cell(A2) sheetmodify firstrow(var)
		dis as yellow `"Results saved as `dest_dir'`saveas'.xlsx."'
    }
}

cap erase `temp'.dta // should delete automatically but it doesn't
dis "For a discussion of how to interpret negative margins of error, see {browse www.census.gov/data/developers/data-sets/acs-1year/notes-on-acs-estimate-and-annotation-values.html:here}."
// note if there is an error earlier, this command won't run and won't delete the temp file

end

* END --------------------------------------------------------------------------

