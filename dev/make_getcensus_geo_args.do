
cd "${ghpath}/getcensus/dev/"

import excel "getcensus_geo_args.xlsx", firstrow clear 	// manually created 

generate clean_name = strtoname(ustrregexra(geo_names, "( )|(\))|(\()|(\/)", "", 1))

generate geo_order = cond(geo_hierarchy != "", 					///
						  geo_hierarchy + " " + clean_name,		///
						  clean_name)
						  
keep geo_names geo_abbrvs geo_order

save "_getcensus_geo_args.dta", replace