*! version 0.1.0 (beta) 26mar2019   Raheem Chaudhry
*! Description: Utility tool for finding estimate IDs needed to access Census' API.

/*******************************************************************************
* File Name: getcensushelp.ado
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
* Description: Users must pass estimate IDs to Census' API. The documentation
* for the API is difficult and burdensome to access so this utility function
* is meant to make it easier to find the relevant estimate ID.
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
** TO DO
*******************************************************************************/

/*******************************************************************************
** DEFINE
*******************************************************************************/

cap program drop getcensushelp
program define getcensushelp
version 14.0

syntax [anything(id="Term to search among estimate labels" name=search)] [, year(string) DATAset(string) PRoduct(string) path(string) Table(string) BRowse clear]

/*******************************************************************************
** ERROR HANDLING
*******************************************************************************/

if strpos("detailed dt comparison cp data dp subject st DT CP DP ST", "`product'") == 0 {
    dis as err "You can only pass 'comparison', 'cp', 'data', 'dp', 'subject', or 'st' as products."
    exit
}

if (`c(changed)' | `c(N)' | `c(k)') & "`clear'" == "" {
    dis as err "no; data in memory would be lost"
    exit 4
}

** Protect data in memory
preserve
if "`clear'" != "" {
    clear
}

/*******************************************************************************
** DEFAULTS
*******************************************************************************/

** Dataset
if "`dataset'" == "" local dataset = 1

** Year
if "`year'" == "" local year = 2017

** Product
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

** Path
if "`path'" == "" local path "$getcensuspath"
if "`path'" == "" local path "~/getcensus"

/*******************************************************************************
** SEARCH
*******************************************************************************/

** Download json file with variable names if necessary
cap confirm file "`path'/`productdir'variables_`dataset'yr_`year'.dta"
if _rc {
    jsonio kv, file("https://api.census.gov/data/`year'/acs/acs`dataset'`productdir'/variables.json") elem("(/variables/)(.*)(label)(.*)")
    dis "https://api.census.gov/data/`year'/acs/acs`dataset'`productdir'/variables.json"
    drop if inlist(key, "/variables/for/label", "/variables/in/label")
    replace key = subinstr(key, "/variables/", "", .)
    replace key = subinstr(key, "/label", "", .)
    rename key estimateID
    rename value estimateLabel
    compress
    sort estimateID
    save "`path'/`productdir'variables_`dataset'yr_`year'.dta", replace
}

** Conduct search
if "`table'" == "" {
    use "`path'/`productdir'variables_`dataset'yr_`year'.dta", clear
}
else {
    use "`path'/`productdir'variables_`dataset'yr_`year'.dta" if strpos(estimateID, "`table'") != 0, clear
}

local regex = "(.*)(`search')(.*)"
local regex = subinstr("`regex'", " ", ")(.*)(", .)


cap drop searchmatch
gen searchmatch = regexm(strlower(estimateLabel), "`regex'")
levelsof estimateID if searchmatch == 1

if "`browse'" != "" {
    br if searchmatch == 1
}

cap drop searchmatch

restore, not
end

/*******************************************************************************
** END OF PROGRAM
*******************************************************************************/
