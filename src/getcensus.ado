
*/
run "_getcensus_expand_keyword.ado"
run "_getcensus_catalog.ado"
run "_getcensus_parse_geography.ado"
capture program drop getcensus

**/


program define getcensus

	syntax anything(name=estimates), 									///
		   [YEARs(string) sample(integer 1)]							///
		   [GEOgraphy(string) STatefips(string) COuntyfips(string)]		///
		   [GEOIDs(string) GEOCOMPonent(string)]						///
		   [NOLabel NOERRor]											///
		   [clear SAVEas(string) replace BRowse]						///
		   [PRODuct(string) table(string) search(string)]				///
		   [key(string) CACHEpath(string)]								///
		   [exportexcel DATAset(integer 0)] // for compatibility

	// defaults
	if "`years'" == "" {
		local years 2018
	}

	// prelim checks and parsing  ---------------------------------------------------------
	
	if c(N) != 0 & c(changed) != 0 & "`clear'" == "" {
	    display as error "no; dataset in memory has changed since last saved"
		exit 4
	}
	
	// install dependency
	capture which jsonio
	if _rc != 0 {
		display as result "To use getcensus, the jsonio package must be installed. Type -yes- to install this package (any other key will exit)" _request(_install)
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
		display as error "The Census Bureau only produces 1-, 3-, and 5-year ACS estimates."
		exit
	}

	// parse years
	local years = ustrregexra("`years'", "-", "/")
	numlist "`years'",  sort
	local years = "`r(numlist)'"
	if wordcount("`years'") > 1 {
		local years_list = ustrregexra("`years'", " ", ",")
		local max_year = max(`years_list')
		local min_year = min(`years_list')
	}
	if wordcount("`years'") == 1 {
		local max_year `years'
		local min_year `years'
	}

	// check min year is available for given sample
	local min_avail_year = cond(`sample' == 1, 2005, 2009)
	if `min_year' < `min_avail_year' {
		display as error "`sample'-year ACS estimates are only available for `min_avail_year' and later."
		exit
	}
	if `sample' == 3 {
		capture numlist "`years'", range(>=2012 <=2013)
		if _rc != 0 {
			display as error "3-year ACS estimates are only available for 2012 and 2013."
			exit
		}
	}

	// check max year is available for given sample
	local today = "`c(current_date)'" 
	local this_year = year(td(`today'))
	local release_date = cond(`sample' == 1, 					///
							  td(17sep`this_year'), 			///
							  td(10dec`this_year'))
	local max_avail_year = cond(td(`today') > `release_date',	///
								`this_year' - 1,				///
								`this_year' - 2)
	if `max_year' > `max_avail_year' {
		display as error `"`sample'-year ACS estimates for `max_year' have not yet been released. See the {browse "https://www.census.gov/programs-surveys/acs/news/data-releases.html":ACS data release page} on the Census website."'
		exit
	}


	// set cache location ---------------------------------------------------------

	if "`cachepath'" == "" {
		local cachepath = cond("`c(os)'" == "Windows", 							///
							   "~/AppData/Local/getcensus/dev",					///
							   "~/Library/Application Support/getcensus/dev")
	}
	capture mkdir "`cachepath'"


	// catalog-specific checks ----------------------------------------------------

	// these checks go outside the catalog subroutine, since they are not relevant 
	// if getcensus_catalog is called from within the main program 

	if ustrregexm("`estimates'", "catalog", 1) {
		
		// search only the most recent year specified
		if wordcount("`years") > 1 {
			display as result "Catalog searches only one year at a time. Using most recent year in list, `max_year'."
		}

		// check product is specified
		if "`product'" == "" {
			display as error "Must specify a product to search the catalog."
			exit 0
		}
		
		// run getcensus_catalog
		capture noisily {
		_getcensus_catalog, year(`max_year') sample(`sample') product("`product'")	///
							table("`table'") search("`search'")						///
							cachepath("`cachepath'") load `browse'  
		}
		exit _rc
	}


	// main only ------------------------------------------------------------------

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
		display as error "Something went wrong. Please check that you have inputted a valid table ID, estimate ID(s), or keyword."
		exit
	}
	

	// confirm table id not mixed with estimate(s)
	if `is_table'  {
		if `is_estimate' {
			display as error "Unable to combine table with estimate(s) or a keyword."
			if `is_keyword' {
				display as error "Note: Some keywords are shortcuts for a table and some are shortcuts for estimates."
			}
			exit
		}
		if wordcount("`estimates'") > 1 {
			display as error "Only one table ID at a time is allowed."
			exit
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
			display as error "All estimates must come from the same product."
			if `is_keyword' {
				display as error "Note: If you inputting both a keyword and an estimate(s), the keyword may be a shortcut to estimates from a different product as your estimate(s)."
			}
			exit 
		}
		if `n_products' == 0 | "`product'" == "" {
			display as error "Something went wrong. Please check that you have inputted a valid table ID, estimate ID(s), or keyword."
			exit
		}

		// confirm no suffix on estimates
		if ustrregexm("`estimates'", "\d(E|M)") {
			display as error "Do not include 'E' or 'M' at the end of estimate IDs."
			exit
		}
		
		// confirm within API limit
		local max_estimates = cond("`noerror'" == "" & "`product'" != "CP", 25, 50)
		if wordcount("`n_estimates'") > `max_estimates' {
			display as error "Too many estimates requested. Up to 50 estimates and/or margins of error can be included in a single API query."
			exit
		}
	}
	
	// check product is available for year
	if inlist("`product'", "ST", "CP") & `min_year' < 2010 {
		display as error "Product `product' only available for 2010 and later."
		exit 
	}
	

	// geography ------------------------------------------------------------------

	// default geography
	if "`geography'" == "" {
		local geography "state"
	}

	// parse geography name
	_getcensus_parse_geography `geography', cachepath("`cachepath'")
	if `s(geo_valid)' == 0 {
		display as error "Invalid or unsupported geography."
		exit
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

	// check statefips
	if "`geography'" == "state" {
		// check if statefips conflicts with geoids
		if (("`statefips'" != "*") & ("`geoids'" != "*")) & ("`statefips'" != "`geoids'") {
			display as error "If geography is state, state code(s) can be specified in statefips or geoids, but not both."
			exit
		}
		// switch statefips and geoids if needed
		if "`statefips'" != "*" & "`geoids'" == "*" {
		   local geoids = "`statefips'"
		   local statefips "*"
		}
	}
	if inlist("`geography'", "us", "region", "division", "zcta") & 			///
	   ("`statefips'" != "*") {
		display as error "statefips cannot be specified when geography is `geo_full_name'."
		exit
	}
	if inlist("`geography'", "cousub", "tract", "bg", "sch", "sche", "schs", 	///
			  "slupper", "sllower") &											///
	   (("`statefips'" == "*") | (wordcount("`statefips'") > 1)) {
		display as error "A single state code must be specified in statefips when geography is `geo_full_name'."
		exit
	}

	// check geography is available for sample
	if `sample' != 5 {
		if "`geography'" == "metro" & "`statefips'" != "*" {
			display as error "`sample'-year ACS estimates are not available for geography `geo_full_name' within state(s)."
			exit
		}
		if inlist("`geography'", "zcta", "cousub", "tract", "bg") {
			display as error "`sample'-year ACS estimates are not available for geography `geo_full_name'."
			exit
		}
	}

	// check countyfips
	if "`countyfips'" != "" {
		if !inlist("`geography'", "county", "cousub", "tract", "bg"){
			display as error "countyfips may not be specified when geography is `geo_full_name'."
			exit
		}
		if "`geography'" == "bg" & wordcount("`n_countyfips'") > 1 {
				display as error "Only one county code may be specified in countyfips when geography is `geo_full_name."
				exit
		}
		// switch countyfips and geoids if needed
		if "`geography'" == "county" {
			local geoids "`countyfips'"
			local countyfips ""
		}
	}
	if  "`countyfips'" == "" & "`geography'" == "bg" {
		display as error "Must specify countyfips if geography is `geo_full_name'."
		exit
	}

	// check geocomponent and geography combo
	if "`geocomponent'" != "" {
		local geo_order "`geo_order' geocomp"	// add geocomponent to geo_order
		local geocomponent = strupper("`geocomponent'")
		foreach g in `geocomponent' {
			if !(inlist("`g'", "00", "C0", "C1", "C2", "E0", "E1", "E2", "G0") |		///
				 inlist("`g'", "H0", "01", "43", "89", "90", "91", "92", "93", "94") |	///
				 inlist("`g'", "95", "A0")) {
				display as error "Invalid geocomponent `g'."
				exit
			}
			if inlist("`g'", "89", "90", "91", "92", "93", "94", "95") & 	///
			   "`geography'" != "us" {
				display as error "Geography must be us if geocomponent is `g'."
				exit
			}
			if (inlist("`g'", "C0", "C1", "C2", "E0", "E1", "E2", "G0", "H0") |		///
				inlist("`g'" "01", "43", "A0")) & 									///
			   !inlist("`geography'", "us", "state", "region", "division") {
				display as error "Geography must be us, state, region, or division if geocomponent is `g'."
				exit
			}
		}
	}


	// prep for API call ----------------------------------------------------------

	// check API key is supplied
	if "`key'" != "" {
		display as result "To avoid needing to specify your API key, store it in a global named 'censuskey' in your profile.do. See the {help getcensus:help file} for instructions."
	}
	if "`key'" == "" {
		if "$censuskey" == "" {
			display as error `"You must provide an API key to the key argument or have defined a global named "censuskey" that contains your API key. To acquire an API key, register {browse "https://api.census.gov/data/key_signup.html":here}."'
		}
		if "$censuskey" != "" {
			local key "$censuskey"
		}
	}

	// add suffix(es) to estimate ids
	if `is_estimate' {
		local variables ""
		foreach item of local estimates {
			local variables = "`variables'" + 										///
							  "`item'E " + 											///
							  cond((("`noerror'" == "") | ("`product'" != "CP")), 	///
								   "`item'M ", 										///
								   "")
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


	// compose geography predicate(s) ---------------------------------------------

	local statefips_list = ustrregexra("`statefips'", " ", ",")
	local geoids_list = ustrregexra("`geoids'", " ", ",")
	local countyfips_list = ustrregexra("`countyfips'", " ", ",")

	local county_predicate = cond("`countyfips'" != "", " county:`countyfips'", "")
	local state_predicate = cond("`statefips'" != "*", "&in=state:`statefips_list'", "")

	local geocomp_list ""
	if "`geocomponent'" != "" {
		foreach g of local geocomponent {
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


	// make API calls -------------------------------------------------------------

	clear
	tempfile temp_data
	
	foreach year in `years' {
		
		// construct url
		local api_url_base "https://api.census.gov/data/`year'/acs/acs`sample'`product_dir'"
		local api_url_get "?get=`api_variables'NAME"
		local api_url_geo "`geo_predicate'"
		local api_url_key "&key=`key'"
		local api_url "`api_url_base'`api_url_get'`api_url_geo'`api_url_key'"
		
		// display url
		local show_link = strlen("`api_url'") < 255
		if `show_link' {
			display as result `"{browse "`api_url'": Link to data for `year'}"'
		}
		if !`show_link' {
			display as result "Link to data for `year':" _newline as text _skip(2) "`api_url'"
		}
		
		// make API call
		capture noisily import delimited "`api_url'", stringcols(_all) clear
		if _rc != 0 | c(N) == 0 {
			display as error "The Census API did not return data for `year'. Check that your table or estimate IDs are valid, that your API key is valid, and that you are connected to the internet."
			local see_message = cond(`show_link', 									///
									 `"click {browse "`api_url'":here}"',			///
									 "copy the URL above into a web browser")
			display as error `"To see the error message returned by the Census Bureau API, `see_message'."'
			exit
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
			 replace `var' = subinstr(`var', `"""', "", .)
			 replace `var' = ustrregexra(`var', "(\])|(\[)|(null)", "")
		}
		
		// destring all except geo order
		ds `geo_order', not
		destring `r(varlist)', replace
		
		// replace annotation values with missing 
		ds, has(type numeric)
		foreach var of varlist `r(varlist)' {
			 replace `var' = . if inlist(`var', -222222222, -666666666)
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
		if "`noerror'" != "" {
			drop *_*m
		}
	}
	
	if "`nolabel'" == "" {
		
		// check if label .do data file exists, run catalog if not
		local product_lower = strlower("`product'")
		capture confirm file "`cachepath'/acs_dict_`max_year'_`sample'yr_`product_lower'_do.dta"
		if _rc != 0 & "`nolabel'" == "" {
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
		display as result "Variables labeled using data dictionary for `max_year'."
		if wordcount("`years'") > 1 {
			display as result `"You requested data for multiple years. Check the {browse "https://www.census.gov/programs-surveys/acs/technical-documentation/table-and-geography-changes.html":ACS Table & Geography Changes} on the Census Bureau website."'
		}
		// vars_truncated is a c_local from the catalog program
		if "`vars_truncated'" == "1" {		
			display as result "One or more variable labels truncated. See variable {help notes} for full descriptions."
		}
	}
	
	
	// export results ---------------------------------------------------------
	
	if "`saveas'" != "" {
		
		local saveas = ustrregexra("`saveas'", "((\.xlsx?)$)|((\.dta)$)", "")
		
		// check files don't already exist if no replace
		if "`replace'" == "" {
			foreach ext in xlsx dta {
				capture confirm file "`saveas'.`ext'"
				if _rc == 0 {
					display as error "file `saveas'.`ext' already exists"
					exit 602
				}
			}
		}
	
		quietly putexcel set "`saveas'.xlsx", sheet("acs_`sample'yr") `replace'
		
		// export variable labels to excel
		if "`nolabel'" == "" {
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
				quietly putexcel `col'1 = "`var_header'"
				local ++i
			}
		}
		
		// export data to excel
		local start_cell = cond("`nolabel'" == "", "A2", "A1")
		export excel using "`saveas'.xlsx", 								///
					 cell(`start_cell') sheet("acs_`sample'yr", modify) 	///
					 firstrow(variables)
		
		// export to stata
		save "`saveas'.dta", `replace'
		
	}

	`browse'
	

end


