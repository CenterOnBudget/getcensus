*! version 0.1.0 (beta) 26mar2019   Raheem Chaudhry, Vincent Palacios
*! Description: Import American Community Survey estimates by accessing Census API

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
* Contents
*   To Do
*   Define
*   Dependencies
*   Parse years
*   Error handling
*   Pre-Packaged estimates
*   API Call
*
* Version 1
*******************************************************************************/

/*******************************************************************************
** DEFINE
*******************************************************************************/

cap program drop getcensus
program define getcensus
version 14.0

syntax [anything(id="List of estimates" name=estimates)] [, YEARs(string) DATAset(string) PRoduct(string) GEOgraphy(string) geoids(string) STatefips(string) COunty(string) key(string) SAVEas(string) path(string) NOLabel PYthon clear]

/*******************************************************************************
** DEPENDENCIES
*******************************************************************************/

// do we need libjson.mlib or insheetjson.ado anymore?
foreach program in jsonio {
    capture which `program'
    if _rc    {
        display _newline(1)
        display as result "You don't have `program' installed. Enter -yes- to install or any other key to abort." _request(_y)
        local program = substr("`program'", 1, strpos("`program'", ".")-1)
        if "`y'"=="yes" ssc install `program'
        else {
            display as error "`program' not installed. To use getcensus, first install `program' by typing -ssc install `program'-."
            qui exit 601
        }
    }
}

/*******************************************************************************
** DEFAULTS
*******************************************************************************/

** Estimates
if "`estimates'" == ""  local estimates "B01001_001"

** Dataset
if "`dataset'" == ""                            local dataset "1"

** Years
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

if "`years'" == "" & "`dataset'" == "5"         local years "`lastacs5yr'"
if "`years'" == ""                              local years "`lastacs1yr'"

** Product
if strpos("detailed dt comparison cp data dp subject st", "`product'") == 0 {
    dis as err "You can only pass 'comparison', 'cp', 'data', 'dp', 'subject', or 'st' as products."
    exit
}

if inlist("`product'", "dt", "detailed", "")     {
    local product "DT"
    local productdir ""
}

if inlist("`product'", "comparison", "cp")   {
    local product "CP"
    local productdir "/cprofile"
}
if inlist("`product'", "data", "dp")         {
    local product "DP"
    local productdir "/profile"
}
if inlist("`product'", "subject", "st")      {
    local product "ST"
    local productdir "/subject"
}

local api_estimateslist ""

if strpos("`estimates'", "_")!=0 {
    foreach estimate in `estimates' {
        local api_estimateslist "`api_estimateslist'`estimate'E,`estimate'M,"
    }
}

else {
    local api_estimateslist "group(`estimates')"
}

** Geography
if "`geography'" == "" local geography "state"

if "`geography'" == "cd" local geography "congressional district"

if "`geography'" == "metro" local geography "metropolitan statistical area/micropolitan statistical area"

if "`geography'" == "block" local geography "block group"

if inlist("`geography'", "sd", "school district") local geography "school district (unified)"


** Statefips
if "`statefips'" == "" local statefips "*"

local statefipslist ""
if "`statefips'" == "*" {
    local statefipslist "*"
}
else {
    foreach statefip in `statefips' {
        local statefipslist "`statefipslist'`statefip',"
    }
    local statefipslist = substr("`statefipslist'", 1, length("`statefipslist'") - 1)
}

** Key
if "`key'" == "" local key "$censuskey"

** County
if "`county'" != "" local countycondition "%20county:`county'"

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

** Path
if "`path'" == "" local path "$getcensuspath"
if "`path'" == "" local path "~/getcensus"

/*******************************************************************************
** PARSE YEARS
*******************************************************************************/

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

/*******************************************************************************
** ERROR HANDLING
*******************************************************************************/

if (`c(changed)' | `c(N)' | `c(k)') & "`clear'" == "" {
    dis as err "no; data in memory would be lost"
    exit 4
}

preserve
if "`clear'" != "" {
    clear
}

** Can we pass multiple groups?
if strpos("`estimates'", "_") == 0 & strpos("`estimates'", " ")!= 0 {
    dis as err "Only pass one group at a time."
    exit
}

foreach year in `years' {
    if `year' < 2009 | (`year' < 2010 & "`dataset'" == "1") {
        dis as err "Census API only provide data for 2010 and onward (but 5-year estimates are available for 2009."
        exit
    }
}

foreach year in `years' {
    if `year' > `lastacs1yr' {
        dis as err "Data for `year' have not been released yet."
        exit
    }
}

foreach year in `years' {
    if !inlist(`year', 2012, 2013) & "`dataset'" == "3" {
        dis as err "3-year data only available for 2012 and 2013."
        exit
    }
}

foreach year in `years' {
    if `year' > `lastacs5yr' & "`dataset'" == "5" {
        dis as err "5-year data for `year' have not been released yet."
        exit
    }
}

foreach estimate in `estimates' {
    if inlist(substr("`estimate'", strlen("`estimate'"),.), "E", "M") {
        dis as err "Make sure none of your estimates include 'E' or 'M' in suffix."
        exit
    }
}
    
foreach estimate in `estimates' {
    if ("`product'" == "CP" & strpos("`estimate'", "CP") == 0) | ("`product'" == "DP" & strpos("`estimate'", "DP") == 0) | ("`product'" == "ST" & strpos("`estimate'", "S") == 0) {
        dis as error "You selected '`product'' as product type but the estimates you passed do not appear to be from that product."
        exit
    }
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

if "`geography'" != "block group" & "`county'" != "" {
    dis as err "Cannot pass county unless geography is block."
    exit
}

if "`geography'" == "block group" & "`county'" == "" {
    dis as err "Must pass county if geography is block."
    exit
}

if "`geography'" == "block group" & strpos("`county'", " ") != 0 {
    dis as err "Can only pass one county if geography is block."
    exit
}


if "`dataset'" != "5" & inlist("`geography'", "tract", "block group", "county subdivision") {
    dis as err "`geography' only available using 5-year data."
    exit
}

if "`statefips'" == "*" & inlist("`geography'", "tract", "block group", "county subdivision") {
    dis as err "Census API only allows one state per `geography'."
    exit
}

local geography = subinstr("`geography'", " ", "%20", .)

if strpos("`product'", " ") != 0 {
    dis as err "Can only pass one product type (dt, dp, cp, st) at a time"
    exit
}

local varcount: word count `estimates'
if `varcount' > 25 {
    dis as err "API cannot handle more than 25 IDs at once."
    exit
}

if "`key'" == "" {
    dis as err "Must pass Census key. To acquire, register here: https://api.census.gov/data/key_signup.html. To avoid passing each time, set -global censuskey YOUR_KEY- in your profile.do. Type -help getcensus- for details."
    exit
}

/*******************************************************************************
** PRE-PACKAGED ESTIMATES
*******************************************************************************/

if "`estimates'" == "poverty" local estimates "B17001_001 B17001_002 B17001H_001 B17001H_002 B17001B_001 B17001B_002 B17001D_001 B17001D_002 B17001E_001 B17001E_002 B17001C_001 B17001C_002 B17001I_001 B17001I_002"
if "`estimates'" == "income" local estimates "B19013_001 B19013H_001 B19013B_001 B19013D_001 B19013E_001 B19013C_001  B19013I_001"

/*******************************************************************************
** API CALL
*******************************************************************************/

** Generate URL
tempname temp
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
    dis "`APIcall'"
    if "`python'" == "" {
        import delimited using "`APIcall'"
    }
    else {
        shell python "`path'/getcensus.py" "`APIcall'" "`c(pwd)'" "`temp'"
        import delimited `temp', case(preserve) clear
    }

    qui des
    if r(N) == 0 {
        dis as err "Website did not return data. Most likely one of following: 1) One of Table IDs were wrong, or 2) the Table ID does not belong to the product type you passed."
        exit 672
    }

    ** Post retrieval
    qui gen year = "`year'"
    qui cap drop *ma
    qui cap drop *ea
    qui cap drop v*
    // qui destring year `insheetjson_estimateslist', replace ignore("null")
    qui compress
    
    qui cap append using `temp'
    qui save `temp', replace
}

qui ds
foreach var in `r(varlist)' {
    qui cap replace `var' = subinstr(`var', "[", "", .)
    qui cap replace `var' = subinstr(`var', "]", "", .)
    qui cap replace `var' = subinstr(`var', `"""', "", .)
    label var `var' ""
}

qui destring _all, replace
if "`saveas'" != "" saveold `filename'.dta, replace
if "`saveas'" == "" cap erase `temp'.dta
restore, not

if "`nolabel'" == "" {
    local labelthis ""
    qui ds
    preserve
        clear
        // foreach year in `years' {
        local year = 2017
        local product = subinstr("`productdir'", "/", "", .)
        qui cap confirm file "`path'/acs`product'variables_`dataset'yr_`year'.dta"
        if _rc {
            qui jsonio kv, file("https://api.census.gov/data/`year'/acs/acs`dataset'`productdir'/variables.json") elem("(/variables/)(.*)(label)(.*)")
            qui dis "https://api.census.gov/data/`year'/acs/acs`dataset'`productdir'/variables.json"
            qui drop if inlist(key, "/variables/for/label", "/variables/in/label")
            qui replace key = subinstr(key, "/variables/", "", .)
            qui replace key = subinstr(key, "/label", "", .)
            qui rename key estimateID
            qui rename value estimateLabel
            qui compress
            qui save "`path'/acs`product'variables_`dataset'yr_`year'.dta", replace
        }
        qui use "`path'/acs`product'variables_`dataset'yr_`year'.dta", clear
        local i = 0
        foreach estimate in `r(varlist)' {
            local i = `i' + 1
            qui levelsof estimateLabel if estimateID == upper("`estimate'")
            local label`i' `r(levels)'
            local estimate`i' "`estimate'"
        }
        // }
    restore
    forvalues j = 1/`i' {
        if strlen("`label`j''") > 80 {
            dis as yellow "Label truncated. See notes for `estimate`i''"
        }
        qui label var `estimate`j'' "`label`j''"
        qui notes `estimate`j'': `label`j''
    }
}

end

/*******************************************************************************
** END OF PROGRAM
*******************************************************************************/