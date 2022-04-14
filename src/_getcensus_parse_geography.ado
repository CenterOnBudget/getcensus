* v 2.0.0

program define _getcensus_parse_geography, sclass

	syntax anything(name=geography), [cachepath(string)]
	
	sreturn clear
	
	capture confirm file "`cachepath'/_getcensus_geo_args.dta"
	if _rc == 0 {
		preserve
		use "`cachepath'/_getcensus_geo_args.dta", clear
		// check if the dataset needs to be updated, and if so, regenerate it
		local date_generated = date("`c(filedate)'", "D M Y hm")
		local date_updated = date("2022-04-14", "YMD")
		if `date_generated' <= `date_updated' {
			local update_geo_args "y"
		}
		restore
	}
	if _rc != 0 | "`update_geo_args'" != "" {
		findfile "_getcensus_geo_args.ado"
		preserve
		import delimited using "`r(fn)'", varnames(1) stringcols(_all) clear
		save "`cachepath'/_getcensus_geo_args.dta", replace
		restore
	}
	
	preserve
	
	use "`cachepath'/_getcensus_geo_args.dta", clear

	levelsof geo_names, local(geo_names)
	levelsof geo_abbrvs, local(geo_abbrvs)

	foreach g of local geo_names {
		if inlist("`is_full'", "", "0"){
			local is_full = inlist("`geography'", `"`g'"')
		}
	}
	foreach g of local geo_abbrvs {
		if inlist("`is_abbrv'", "", "0"){
			local is_abbrv = inlist("`geography'", "`g'")
		}
	}

	if `is_full' {
		levelsof geo_abbrvs if geo_names == "`geography'", local(geo_abbrv) clean
		local geo_name "`geography'"
		local geo_abbrv = cond("`geo_abbrv'" == "", "`geography'", "`geo_abbrv'")
	}
	if `is_abbrv' {
		levelsof geo_names if geo_abbrvs == "`geography'", local(geo_name)
		local geo_name `geo_name'
		local geo_abbrv "`geography'"
	}
	
	levelsof geo_order if geo_names == "`geo_name'", local(geo_order)
	local geo_order `geo_order'
	
	restore
	
	local geo_valid = `is_full' | `is_abbrv'
	
	// use full rather than abbreviation for county
	local geo_abbrv = cond(`"`geo_abbrv'"' == "co", "county", `"`geo_abbrv'"')
	
	sreturn local geo_valid = `geo_valid'
	sreturn local geo_full_name = `"`geo_name'"'
	sreturn local geography = `"`geo_abbrv'"'
	sreturn local geo_order = `"`geo_order'"'
	
end


