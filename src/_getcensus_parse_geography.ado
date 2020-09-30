
* capture program drop _getcensus_parse_geography

program define _getcensus_parse_geography, sclass

	syntax anything(name=geography), [cachepath(string)]
	
	sreturn clear
	
	preserve

	sysuse "_getcensus_geo_args.dta", clear

	quietly levelsof geo_names, local(geo_names)
	quietly levelsof geo_abbrvs, local(geo_abbrvs)

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
		quietly levelsof geo_abbrvs if geo_names == "`geography'", local(geo_abbrv) clean
		local geo_name "`geography'"
		local geo_abbrv = cond("`geo_abbrv'" == "", "`geography'", "`geo_abbrv'")
	}
	if `is_abbrv' {
		quietly levelsof geo_names if geo_abbrvs == "`geography'", local(geo_name)
		local geo_name `geo_name'
		local geo_abbrv "`geography'"
	}
	
	quietly levelsof geo_orders if geo_names == "`geo_name'", local(geo_order)
	local geo_order `geo_order'
	
	restore
	
	local geo_valid = `is_full' | `is_abbrv'
	
	sreturn local geo_valid = `geo_valid'
	sreturn local geo_full_name = `"`geo_name'"'
	sreturn local geography = `"`geo_abbrv'"'
	sreturn local geo_order = `"`geo_order'"'
	

end

