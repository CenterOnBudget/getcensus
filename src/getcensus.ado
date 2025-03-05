*! version 2.1.4

program define getcensus

	version 13.1

	syntax [anything(name=estimates)], 									///
		   [YEARs(string) SAMPle(integer 1)]							///
		   [GEOgraphy(string) STatefips(string) COuntyfips(string)]		///
		   [GEOIDs(string) GEOCOMPonents(string)]						///
		   [NOLabel NOERRor]											///
		   [clear SAVEas(string) EXportexcel replace BRowse]			///
		   [PRoduct(string) Table(string) search(string)]				///
		   [key(string) CACHEpath(string)]								///
		   [DATAset(integer 0)] // for backwards-compatibility

	// open dialog box if no estimates provided
	if "`estimates'" == "" {
		db getcensus
		exit
	}
	
	// defaults
	if "`years'" == "" {
		local years = 2023
	}
	

	// prelim checks and parsing  ---------------------------------------------
	
	if c(N) != 0 & c(changed) != 0 & "`clear'" == "" {
		error 4
	}
	
	// install dependency
	capture which jsonio
	if _rc != 0 {
		display as result "{p}To use {bf:getcensus}, the {bf:jsonio} package must be installed. Type -yes- to install this package (any other key will exit).{p_end}" _request(_install)
		if "`install'" == "yes" {
			ssc install jsonio
		}
		if "`install'" != "yes" {
			exit
		}
	}
	
	// compatibility
	if `dataset' != 0 {
		local sample `dataset'
	}
	
	// check sample is valid
	if !inlist(`sample', 1, 3, 5) {
		display as error "{p}{bf:sample()} must be 1, 3, or 5.{p_end}"
		exit 198
	}

	// parse years
	local years = ustrregexra("`years'", "-", "/")
	numlist "`years'",  sort
	local years = "`r(numlist)'"
  
	// special handling for 2020, for which 1-year estimates were not released
	if `sample' == 1 & ustrregexm("`years'", "2020") {
	    display as error `"{p}Standard 1-year ACS estimates for 2020 are not available. See the {browse "https://www.census.gov/programs-surveys/acs/news/data-releases/2020.html":2020 ACS Data Release} page on the Census Bureau website.{p_end}"'
		exit 
	}
  
   // flag if multiple years requested
  local multiple_years = wordcount("`years'") > 1
  
  // find min and max years
	if `multiple_years' {
		local years_list = ustrregexra("`years'", " ", ",")
		local max_year = max(`years_list')
		local min_year = min(`years_list')
	}
	if !`multiple_years' {
		local max_year `years'
		local min_year `years'
	}

	// check min year is available for given sample
	if `sample' == 3 {
		capture numlist "`years'", range(>=2007 <=2013)
		if _rc != 0 {
			display as error "{p}3-year ACS estimates are available for 2007 to 2013.{p_end}"
			exit
		}
	}
  if inlist(`sample', 1, 5) {
    local min_avail_year = cond(`sample' == 1, 2005, 2009)
    if `min_year' < `min_avail_year' {
      display as error "{p}`sample'-year ACS estimates are available for `min_avail_year' and later.{p_end}"
      exit
    }
  }


	// set cache location -----------------------------------------------------

	if "`cachepath'" == "" {
    if "`c(os)'" == "Windows" local cachepath "~/AppData/Local/getcensus"
    if "`c(os)'" == "MacOSX" local cachepath "~/Library/Application Support/getcensus"
    if "`c(os)'" == "Unix" local cachepath "~/.local/share/getcensus"
	}
	capture mkdir "`cachepath'"


	// catalog-specific checks ----------------------------------------------------

	// these checks go outside the catalog subroutine, since they are not relevant 
	// if getcensus_catalog is called from within the main program 

	if ustrregexm("`estimates'", "catalog", 1) {
		
		// search only the most recent year specified
		if `multiple_years' {
			display as result "{p}{bf:getcensus catalog} searches only one year at a time. Using most recent year in {bf:years()}, `max_year'.{p_end}"
		}

		// check table
		if "`table'" != "" {
			if wordcount("`table'") != 1 {
				display as error "{p}Only one table ID at a time is allowed in {bf:table()}.{p_end}"
				exit 198
			}
			if ustrregexm("`table'", "_") {
				display as error "{p}{bf:table()} must be a table ID, not a variable ID.{p_end}"
				exit 198
			}
			// find product of specified table
			local product = cond(ustrregexm("`table'", "^S"), "ST",				///
								cond(ustrregexm("`table'", "^DP"), "DP",		///
									cond(ustrregexm("`table'", "^CP"), "CP", 	///
										"DT")))
		}
		
		// run getcensus_catalog
		capture noisily {
		_getcensus_catalog, year(`max_year') sample(`sample') product("`product'")	///
							table("`table'") search("`search'")						///
							cachepath("`cachepath'") load `browse'  
		}
		exit _rc
	}


	// main only --------------------------------------------------------------

	// determine if includes keyword, and if so, expand
	foreach item of local estimates {
		if inlist("`is_keyword'", "", "0") {
			local is_keyword = !ustrregexm(strupper("`item'"), "^(B|C|CP|DP|S)(\d)")
		}
	}
	if `is_keyword' {
		_getcensus_expand_keyword `estimates'
		local estimates = "`s(estimates)'"
		sreturn clear
	}
	
	// uppercase estimates now that keywords (if present) are expanded
	local estimates = strupper("`estimates'")


	// determine if estimate(s) or table id
	foreach item of local estimates {
		if inlist("`is_table'", "", "0") {
			local is_table = ustrregexm("`item'", "^(B|C|CP|DP|S)(\d)") &		///
							 !ustrregexm("`item'", "_")
		}
		if inlist("`is_estimate'", "", "0") {
			local is_estimate = ustrregexm("`item'", "^(B|C|CP|DP|S)(\d)(.*)(_)")
		}
	}
	
	if inlist("`is_table'", "", "0") & inlist("`is_estimate'", "", "0") {
		display as error "{p}Something went wrong. Please check that you have requested a valid table ID, variable IDs, or keyword.{p_end}"
		exit
	}
	

	// confirm table id not mixed with estimate(s)
	if `is_table'  {
		if `is_estimate' {
			display as error "{p}Either variables or a table can be requested at a time, not both.{p_end}"
			if `is_keyword' {
				display as error "{p}Note: Some keywords are shortcuts for a table and some are shortcuts for variables.{p_end}"
			}
			exit 198
		}
		if wordcount("`estimates'") > 1 {
			display as error "{p}Only one table ID at a time is allowed.{p_end}"
			exit 198
		}
	}

	// find product of estimates/table
	foreach est of local estimates {
		if inlist("`product_dt'", "", "0"){
			local product_dt = ustrregexm("`est'", "^((B)|(C(?!P)))(\d{5})")
			// store product type for API query
			local product = cond(`product_dt', "DT", "`product'")
		}
		foreach prod in st dp cp {
			if inlist(`"`product_`prod''"', "", "0"){
				local prod_regex = cond("`prod'" == "st", "s", "`prod'")
				local product_`prod' = ustrregexm("`est'", "`prod_regex'\d", 1)
				// store product type for API query
				local product = cond(`product_`prod'',			///
									 strupper("`prod'"),		///
									 "`product'")
			}
		}
	}

	if `is_estimate' {
		
		// check all estimates from same product
		local n_products = (`product_dt' + `product_st' + `product_dp' + `product_cp')
		if `n_products' > 1 {
			display as error "{p}All variables must come from the same product.{p_end}"
			if `is_keyword' {
				display as error "{p}Note: If you inputting both a keyword and variables, the keyword may be a shortcut to variables from a different product as your variables.{p_end}"
			}
			exit 198
		}
		if `n_products' == 0 | "`product'" == "" {
			display as error "{p}Something went wrong. Please check that you have inputted a valid table ID, variables, or keyword.{p_end}"
			exit
		}

		// confirm no suffix on estimates
		foreach est of local estimates {
			if ustrregexm("`est'", "(E|M)$") {
				display as error "{p}Do not include 'E' or 'M' at the end of variable IDs.{p_end}"
				exit 198
			}
		}
		
		// confirm within API limit
		local max_estimates = cond("`noerror'" == "" & "`product'" != "CP", 25, 50)
		if wordcount("`estimates'") > `max_estimates' {
			display as error "{p}Too many variables requested. Up to 50 estimates and/or margins of error can be included in a single API query.{p_end}"
			exit
		}
	}
	
	// check product is available for year
	if inlist("`product'", "ST", "CP") & `min_year' < 2010 {
		display as error "{p}Product `product' only available for 2010 and later.{p_end}"
		exit 
	}
	

	// geography --------------------------------------------------------------

	// default geography
	if "`geography'" == "" {
		local geography "state"
	}
	
	// lowercase before parsing
	local geography = ustrlower("`geography'")

	// parse geography name
	quietly _getcensus_parse_geography `geography', cachepath("`cachepath'")
	if `s(geo_valid)' == 0 {
		display as error "{p}Invalid or unsupported {bf:geography()}.{p_end}"
		exit 198
	}
	local geography "`s(geography)'"
	local geo_full_name "`s(geo_full_name)'"
	local geo_order "`s(geo_order)'"	// used to order variables later
	sreturn clear

	// replace unspecified geoid and statefips with wildcard
	if "`geoids'" == "" {
		local geoids "*"
	}
	if "`statefips'" == "" {
		local statefips "*"
	}

	// do the reverse to countyfips, since when the county predicate is uneccesary 
	// it can mess up the call
	if "`countyfips'" == "*" {
		local countyfips ""
	}
	
	// check geography is available for sample
	if `sample' != 5 {
		if "`geography'" == "metro" & "`statefips'" != "*" {
			display as error "{p}`sample'-year ACS estimates are not available for the {it:`geo_full_name'} geography within state(s).{p_end}"
			exit
		}
		if inlist("`geography'", "sldu", "sldl", "zcta", "cousub", "tract", "bg") {
			display as error "{p}`sample'-year ACS estimates are not available for the {it:`geo_full_name'} geography.{p_end}"
			exit
		}
	}

	// check statefips
  if "`statefips'" != "*" {
    foreach f of local statefips {
      if strlen("`f'") != 2 | missing(real("`f'")) {
        display as error "{p}{bf:statefips()} must contain two-digit state FIPS code(s).{p_end}"
        exit 198
      }
    }
  }
	if "`geography'" == "state" {
		// check if statefips conflicts with geoids
		if (("`statefips'" != "*") & ("`geoids'" != "*")) & ("`statefips'" != "`geoids'") {
			display as error "{p}With {bf:geography({it:state})}, state code(s) may be specified in either {bf:statefips()} or {bf:geoids()}, but not both.{p_end}"
			exit 184
		}
		// switch statefips and geoids if needed
		if "`statefips'" != "*" & "`geoids'" == "*" {
		   local geoids = "`statefips'"
		   local statefips "*"
		}
	}
	if inlist("`geography'", "us", "region", "division", "cbsa", "necta", "cnecta", "aiannh") &	///
	   ("`statefips'" != "*") {
		display as error "{p}{bf:statefips()} may not be specified with {bf:geography({it:`geo_full_name'})}.{p_end}"
		exit 198
	}
  // statefips can't be specified with ZCTA after 2019/2020
  if "`geography'" == "zcta" {
    local first_unsupported_year = cond("`product'" == "ST", 2019, 2020)
    if `max_year' >= `first_unsupported_year' {
      if "`statefips'" != "*" {
        display as error "{p}Starting with the `first_unsupported_year' 5-year estimates, {bf:statefips()} may not be specified with {bf:geography({it:zcta})} for the product type you have requested.{p_end}"
        exit 198
      }
      local geo_order "zipcodetabulationarea"
    }
  }
  // block group data for 2012 and earlier not on API
  if "`geography'" == "bg" & `min_year' <= 2012 {
    display as error `"{p}Block group ACS estimates for 2012 and earlier are not available via the Census Bureau API. Find this data in the {browse "https://www.census.gov/programs-surveys/acs/data/summary-file/sequence-based.html":ACS Summary File}.{p_end}"'
    exit
  }
	if inlist("`geography'", "cousub", "tract", "bg", "elsd", "scsd", "unsd", 	///
			  "sldu", "sldl") &											///
	   (("`statefips'" == "*") | (wordcount("`statefips'") > 1)) {
		display as error "{p}A single state code must be specified in {bf:statefips()} with {bf:geography({it:`geo_full_name'})}.{p_end}"
		exit 198
	}
	// statefips is sometimes required when geoid is specified
	if inlist("`geography'", "county", "zcta", "place", "cd", "puma") & 		///
	   ("`statefips'" == "*") & ("`geoids'" != "*") {
		display as error "{p}When {bf:geoids()} is specified with {bf:geography({it:`geo_full_name'})}, {bf:statefips()} must also be specified.{p_end}"
		exit 198
	}

	// check countyfips
  if "`countyfips'" != "" {
    foreach f of local countyfips {
      if strlen("`f'") != 3 | missing(real("`f'")) {
        display as error "{p}{bf:countyfips()} must contain three-digit county FIPS code(s).{p_end}"
        exit 198
      }
    }
  }
	if "`countyfips'" != "" & !inlist("`geography'", "cousub", "tract", "bg"){
			display as error "{p}{bf:countyfips()} may not be specified with {bf:geography({it:`geo_full_name'})}.{p_end}"
			if "`geography'" == "county" {
				display as error "{p}County GEOIDs may be specified in {bf:geoids()}.{p_end}"
			}
			exit 198
	}
	if wordcount("`countyfips'") != 1 & "`geography'" == "bg" {
		display as error "{p}A single county code must be specified in {bf:countyfips()} with {bf:geography({it:`geo_full_name'})}.{p_end}"
		exit 198
	}

	// check geocomponent and geography combo
	if "`geocomponents'" != "" {
		local geo_order "`geo_order' geocomp"	// add geocomponent to geo_order
		local geocomponents = ustrupper("`geocomponents'")
		foreach g in `geocomponents' {
			// check if supported
			if !(inlist("`g'", "00", "C0", "C1", "C2", "E0", "E1", "E2", "G0") |		///
				 inlist("`g'", "H0", "01", "43", "89", "90", "91", "92", "93", "94") |	///
				 inlist("`g'", "95", "A0")) {
				display as error "{p}Invalid {bf:geocomponents()} {it:`g'}.{p_end}"
				exit 198
			}
			// check geocomponent and geography combination
			if inlist("`g'", "89", "90", "91", "92", "93", "94", "95") & 	///
			   "`geography'" != "us" {
				display as error "{p}With {bf:geocomponents({it:`g'})}, only allowed {bf:geography()} is {it:us}.{p_end}"
				exit 198
			}
			if (inlist("`g'", "C0", "C1", "C2", "E0", "E1", "E2", "G0", "H0") |		///
				inlist("`g'" "01", "43", "A0")) & 									///
			   !inlist("`geography'", "us", "state", "region", "division") {
				display as error "{p}With {bf:geocomponents({it:`g'})}, only allowed {bf:geography()} are {it:us}, {it:region}, {it:division} or {it:state}.{p_end}"
				exit 198
			}
			// check sample is available for geocomponent
			if `sample' != 5 {
				if inlist("`g'", "90", "95" ) {
					display as error "{p}`sample'-year ACS estimates are not available for {bf:geocomponents({it:`g'})}.{p_end}"
					exit 198
				}
				if `sample' == 1 & "`g'" == "92" {
					display as error "{p}`sample'-year ACS estimates are not available for {bf:geocomponents({it:`g'})}.{p_end}"
					exit 198
				}
			}
		}
	}


	// prep for API call ------------------------------------------------------

	// check API key is supplied
  local has_api_key = "`key'" != "" | "$censuskey" != ""
  if !`has_api_key' {
    display as result "{p}You have not provided an API key. Without a key, you are limited to 500 API queries per day. To use an API key, specify {bf:key()} or store your API key in a global macro named {it:censuskey} in your profile.do.{p_end}"
  }
  if `has_api_key' {
    local key = cond("`key'" != "", "`key'", "$censuskey")
  }

	// add suffix(es) to estimate ids
	if `is_estimate' {
		local variables ""
		foreach item of local estimates {
			if "`noerror'" == "" & "`product'" != "CP" &	///
			   !ustrregexm("`item'", "^B(98|99)") {
				local moe "`item'M "
			}
			local variables = "`variables'" + "`item'E " + "`moe'"
		}
	}

	// variable list or group (table)
	local api_variables = cond(`is_table', 								///
							   "group(`estimates')",					///
							   ustrregexra("`variables'", " ", ","))

	// product directory in API structure
	if "`product'" == "DT" {
		local product_dir ""
	}
	if "`product'" == "DP" {
		local product_dir "/profile"
	}
	if "`product'" == "ST" {
		local product_dir "/subject"
	}
	if "`product'" == "CP" {
		local product_dir "/cprofile"
	}


	// compose geography predicate(s) -----------------------------------------

	local statefips_list = ustrregexra("`statefips'", " ", ",")
	local geoids_list = ustrregexra("`geoids'", " ", ",")
	local countyfips_list = ustrregexra("`countyfips'", " ", ",")

	local county_predicate = cond("`countyfips'" != "", " county:`countyfips_list'", "")
	local state_predicate = cond("`statefips'" != "*", "&in=state:`statefips_list'", "")

	local geocomp_list ""
	if "`geocomponents'" != "" {
		foreach g of local geocomponents {
			local g = "&GEOCOMP=`g'"
			local geocomp_list = "`geocomp_list'" + "`g'"
		}
	}

	if "`statefips'" != "*" & "`geography'" == "metro" {
		local geo_predicate "&for=`geo_full_name' (or part):`geoids_list'&in=state:`statefips_list'"
		local geo_order "state `geo_order'"		// add state to geo order

	} 
	else {
		local geo_predicate "`geocomp_list'&for=`geo_full_name':`geoids_list'`state_predicate'`county_predicate'"
		
	}
	
	// replace spaces with %20
	local geo_predicate = ustrregexra("`geo_predicate'", " ", "%20", 1)


	// make API calls ---------------------------------------------------------

	clear
	tempfile temp_data
	
	foreach year in `years' {
		
		// construct url
		local api_url_base "https://api.census.gov/data/`year'/acs/acs`sample'`product_dir'"
		local api_url_get "?get=`api_variables'NAME"
		local api_url_geo "`geo_predicate'"
		local api_url_key = cond(`has_api_key', "&key=`key'", "")
		local api_url "`api_url_base'`api_url_get'`api_url_geo'`api_url_key'"
		
		// for messages, whether to display link to API call or text of call
		local show_link = ustrlen("`api_url'") < 255
		
		// make API call
		capture noisily {
			import delimited "`api_url'", stringcols(_all) varnames(1) stripquotes(yes) clear
			
			// check if an invalid API key message was returned
			quietly ds
			local v1 = word("`r(varlist)'", 1)
			quietly assert !ustrregexm(`v1', "Invalid Key", 1)
		}
		if _rc == 9 {
			display as error `"{p}You have entered an invalid or inactive API key. If you do not have a key, you may acquire one {browse "https://api.census.gov/data/key_signup.html":here}.{p_end}"'
			clear
			exit
		}
		
		// if unsuccessful, list possible reasons and provide link to API call
		// so users can view error there
		if _rc != 0 | c(N) == 0 {
			display as error "{p}The Census Bureau API did not return data for `year'.{p_end}"
			display as error "{p}This may have happened because:{p_end}" 
			display as error "{phang}{c 149}  Table ID or variable IDs are invalid or are not available for the requested year or geography.{p_end}" 
			if "`geoids'" != "*" {
				display as error "{phang}{c 149}  GEOIDs are invalid, or are not available for the requested sample and/or year.{p_end}"
			}
			if "`geocomponents'" != "" {
				display as error "{phang}{c 149}  Geographic components are not available for the requested sample and/or year, or could not be combined with (if specified) the requested state FIPS codes or GEOIDs.{p_end}"
			}
			display as error "{phang}{c 149}  API key is invalid.{p_end}"
			display as error "{phang}{c 149}  Problems with your internet connection.{p_end}"
			if `show_link' {
				display as error `"{p}To see the error message returned by the Census Bureau API, click {browse "`api_url'":here}.{p_end}"'
			}
			if !`show_link' {
				display as error "{p}To see the error message returned by the Census Bureau API, copy the URL below into a web browser.{p_end}"
				local n_lines = ceil(ustrlen("`api_url'") / `c(linesize)')
				forvalues n = 1/`n_lines' {
					local line : piece `n' `c(linesize)' of "`api_url'"
					display as text "`line'"
				}
			}
			if "`geoids'" != "*" & `sample' != 5 {
				display as error "{p}{it:(If there is no error message, this may be because the request was valid, but no data was returned because `sample'-year estimates are not published for the requested GEOIDs.)}{p_end}"
			}
			exit
		}
		
		// display link to data if successful call
		else {
			if `show_link' {
				display as result `"{browse "`api_url'": Link to data for `year'}"'
			}
			if !`show_link' {
				display as result "Link to data for `year':"
				local n_lines = ceil(ustrlen("`api_url'") / `c(linesize)')
				forvalues n = 1/`n_lines' {
					local line : piece `n' `c(linesize)' of "`api_url'"
					display as text "`line'"
				}
			}
		}
		
		// add year variable
		quietly generate year = `year'

		// append
		capture append using `temp_data'
		quietly save `temp_data', replace
		
	}

	// clean and label data ---------------------------------------------------

	quietly {
		
		use `temp_data', clear
		
		// drop junk variables
		foreach junk_var in *_*ma *_*ea v* {
			capture  drop `junk_var'
		}	   
		
		// remove JSON stuff
		ds year, not
		foreach var of varlist `r(varlist)' {
			 replace `var' = ustrregexra(`var', "(\])|(\[)|(null)", "")
		}
		
		// destring all except geo order
		ds `geo_order', not
		destring `r(varlist)', replace
		
		// replace annotation values with missing 
		ds, has(type numeric)
		foreach var of varlist `r(varlist)' {
			 replace `var' = . if `var' <= -222222222
		}
		
		// put year and geo vars first, and sort
		capture confirm variable geo_id
		local geoid = cond(_rc == 0, "geo_id", "")
		order year `geo_order' `geoid' name
		sort year `geo_order' `geoid'
		
		// remove labels from a few vars
		foreach var of varlist year `geoid' name {
			label variable `var'
		}
		
		// remove JSON junk from geo var labels
		foreach var of varlist `geo_order' {
			local lbl : variable label `var'
			local lbl = subinstr(`"`lbl'"', `"""', "", .)
			local lbl = ustrregexra(`"`lbl'"', "(\])|(\[)|(null)", "")
			label variable `var' `"`lbl'"'
		}
		
		// remove MOEs (present by default if a table is requested) if noerror
		if `is_table' & "`noerror'" != "" {
			drop *_*m
		}
		
		compress
	}
	
	if "`nolabel'" == "" {
		
		// check if label .do data file exists, run catalog if not
		local product_lower = strlower("`product'")
		capture confirm file "`cachepath'/acs_dict_`max_year'_`sample'yr_`product_lower'_do.dta"
		if _rc != 0 & "`nolabel'" == "" {
			display as result "{p}{it:Loading data dictionary. This may take a few moments. Data dictionary will be cached for faster future access.}{p_end}"
		    quietly _getcensus_catalog, year(`max_year') sample(`sample') 					///
										product("`product'") cachepath("`cachepath'")
		}

		// label
		// first make a list of variables in memory
		quietly ds
		local vars = ustrregexra("`r(varlist)'", " ", "|")
		preserve
		quietly {
			// load cached do data file
			use "`cachepath'/acs_dict_`max_year'_`sample'yr_`product_lower'_do.dta", clear
			// keep only rows matching variable list
			keep if ustrregexm(variable, "`vars'")
			keep do
			// output a temporary .do file
			tempfile temp_do
			outfile using "`temp_do'.do", noquote replace
		}
		restore
		// run the temporary do file
		quietly do "`temp_do'.do"
		display as result "{p}Variables labeled using data dictionary for `max_year'.{p_end}"
		if `multiple_years' {
			display as result `"{p}You requested data for multiple years. Check the {browse "https://www.census.gov/programs-surveys/acs/technical-documentation/table-and-geography-changes.html":ACS Table & Geography Changes} on the Census Bureau website.{p_end}"'
		}
		// vars_truncated is a c_local from the catalog program
		if "`vars_truncated'" == "1" {		
			display as result "{p}One or more variable labels were truncated. For full descriptions, {stata notes:list the variable notes}.{p_end}"
		}
	}
	
	
	// export results ---------------------------------------------------------
	
	if "`saveas'" != "" {
		
		// strip file extension
		local saveas = ustrregexra("`saveas'", "\.(.*)$", "") 
		
		// export to stata
		save "`saveas'.dta", `replace'
		
			if "`exportexcel'" != "" {
			
			// check file doesn't already exist if no replace
			if "`replace'" == "" {
				capture confirm file "`saveas'.xlsx"
				if _rc == 0 {
					display as error "file `saveas'.xlsx already exists"
					exit 602
				}
			}
		
			// export variable labels to excel
			if "`nolabel'" == "" {
			    quietly putexcel set "`saveas'.xlsx", sheet("acs_`sample'yr") `replace'
				local i 1
				foreach var of varlist _all {
					// extract variable description from notes (so not truncated)
					// if no note, use variable label 
					// if no label, use variable name
					notes _fetch var_note : `var' 1
					local var_note = ustrregexra("`var_note'", "Variable: ", "")
					local var_lbl : variable label `var'
					local var_header = cond("`var_note'" != "", "`var_note'", "`var_lbl'")
					local var_header = cond("`var_header'" == "", "`var'", "`var_header'")
					// find column index
					local col_1 = strupper(word("`c(alpha)'", floor((`i' - 1) / 26)))
					local col_2 = strupper(word("`c(alpha)'", mod(`i' - 1 , 26) + 1))
					local col = "`col_1'" + "`col_2'"
					// export variable label
					quietly putexcel `col'1 = ("`var_header'")
					local ++i
				}
			}
			
			// export data to excel
			local start_cell = cond("`nolabel'" == "", "A2", "A1")
			export excel using "`saveas'.xlsx", 								///
						 cell(`start_cell') sheet("acs_`sample'yr", modify) 	///
						 firstrow(variables)
		}
	}

	`browse'

end


