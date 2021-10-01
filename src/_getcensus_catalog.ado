
* capture program drop _getcensus_catalog

program define _getcensus_catalog

	syntax , year(integer) sample(integer) [product(string)]	///
			 [table(string) search(string)]						///
			 cachepath(string) [load browse]
	
	
	// error checking ---------------------------------------------------------

	// check product is valid
	if "`product'" == "" {
		local product "DT"
	}
	local product = strupper("`product'")
	if !inlist("`product'", "DT", "ST", "DP", "CP") {
		display as error "{p}Invalid product. Product must be one of DT, ST, DP, or CP.{p_end}"
		exit 198
	}

	// check product is available for year
	if inlist("`product'", "ST", "CP") & `year' < 2010 {
		display as error "{p}Product `product' only available for 2010 and later.{p_end}"
		exit 
	}	

	
	// check if cached files already exist ------------------------------------
	
	local product_lower = strlower("`product'")
	
	local cached_dict_dta "`cachepath'/acs_dict_`year'_`sample'yr_`product_lower'.dta"
	local cached_dict_dta_do "`cachepath'/acs_dict_`year'_`sample'yr_`product_lower'_do.dta"
	
	capture confirm file "`cached_dict_dta'"
	capture confirm file "`cached_dict_dta_do'"
	
	local create_cache = _rc != 0
	if !`create_cache' & "`load'" == "" {
	    exit 0
	}
	
	if `create_cache' {
		
		display as result "{p}{it:Loading data dictionary. This may take a few moments. Data dictionary will be cached for faster future access.}{p_end}"
	    
	    
	// determine API phrase for product ---------------------------------------
	
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
	
	
	// import and parse dictionary json -------------------------------------------

	preserve
	
	quietly {

	// load, clean, and reshape 
	clear
	jsonio kv, file("https://api.census.gov/data/`year'/acs/acs`sample'`product_dir'/variables.json")
	split key, parse("/")
	keep if !inlist(key3, "for", "in", "ucgid")
	keep if inlist(key4, "label", "concept", "group")
	keep key4 key3 value
	rename (key3 key4) (variable metadata)
	reshape wide value, i(variable) j(metadata) string
	rename value* *
	rename group table
	
	// create concept column if it does not exist (before 2013)
	capture generate concept = ""

	// remove rows not corresponding to an estimate or MOE variable
	drop if label == "Geography" | table == "N/A"

	// replace phrase in calendar year dollars with in nominal dollars,
	// for clarity in case multiple years are being appended
	if "`product'" != "CP" {
		foreach v of varlist label concept {
			replace `v' = ustrregexra(`v', 											///
									  "in (\d{4}) inflation-adjusted dollars", 		///
									  cond("`v'" == "label", 						///
										   "in nominal dollars", 					///
										   ustrupper("in nominal dollars")),		///
									   1)
		}
	}

	// export to cache --------------------------------------------------------

	// this dataset is loaded into memory if catalog mode
	
	tempfile temp_dict
	save `temp_dict', replace
	keep if label != "Geography"
	replace variable = ustrregexra(variable, "E$", "")
	order table concept variable label 
	rename (table concept variable label) 						///
		   (table_id table_name variable_id variable_descrip)
	compress
	// remove variable labels (remnants of reshape)
	foreach v of varlist _all {
		label variable `v'
	}
	save "`cached_dict_dta'", replace
	use `temp_dict', clear

	
	// generate label .do data file -------------------------------------------
	
	// this dataset will contain .do file text to run for each variable
	// it is loaded and filtered by the main program to generate temporary .do 
	// files with which to label retrieved data 

	drop table

	// add rows for MOE variables
	if "`product'" != "CP" {
		generate moe_variable = ustrregexra(variable, "E$", "M") if label != "Geography"
		generate moe_label = ustrregexra(label, "Estimate!!", "Margin of Error!!")
		generate moe_concept = concept
		generate est_variable = variable
		replace variable = ustrregexra(variable, "E$", "")
		rename (label concept) est_=
		reshape long @_variable @_label @_concept, i(variable) j(type) string
		drop variable type
		rename _* *
	}

	// put variable label in note in case was truncated
	// put concept in note
	generate note_1 = "Variable: " + label
	generate note_2 = "Table: " + concept if !missing(concept)
	generate label_81p_char = strlen(label) > 80
	replace label = substr(label, 1, 80)

	// compose .do file text
	replace variable = strlower(variable)
	generate do_label = "capture label variable " + variable + " " + `"""' + label + `"""'
	generate do_note_1 = "capture note " + variable + " : " + note_1 if !missing(note_1)
	generate do_note_2 = "capture note " + variable + " : " + note_2 if !missing(note_2)
	// (feel a bit guilty about using c_local, but don't want to make this program sclass)
	generate do_truncated = "if _rc == 0 c_local vars_truncated 1" if label_81p_char

	// export .do file data
	keep variable do_*
	duplicates drop variable, force
	reshape long do, i(variable) j(content) string
	keep variable do
	drop if do == ""
	save "`cached_dict_dta_do'", replace
	
	restore
	
	}
	}

	// load filtered dataset --------------------------------------------------
	
	// if subroutine not called from within main program

	if "`load'" != "" {
		
		use "`cached_dict_dta'", clear

		if "`table'" != "" {
			quietly keep if ustrregexm(table_id,  "`table'", 1)
			display as result `"Searched for table "`table'"."'
			if _N == 0 {
				display as result "{p}No results. Check that your table ID is valid and available for the year requested.{p_end}"
				clear
			}
		}

		if "`search'" != "" {
			quietly keep if ustrregexm(variable_descrip, "`search'", 1) | 	///
						    ustrregexm(table_name, "`search'", 1) |			///
							ustrregexm(table_id, "`search'", 1) |			///
							ustrregexm(variable_id, "`search'", 1)	
			display as result `"Searched for variables matching "`search'"."'
			if _N == 0 {
				display as result "{p}No results. Check for typos in your search term, or try a less specific search term.{p_end}"
				clear
			}
		}
		
		if "`table'" == "" & "`search'" == "" {
			display as result `"{p}Searched for all variables of product type "`product'".{p_end}"'
		}
		
		if _N > 0 {
			`browse'
		}
	}

end


