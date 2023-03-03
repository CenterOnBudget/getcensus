*! version 2.1.2
*! getcensus internal program

program define _getcensus_expand_keyword, sclass

	version 13.1
	
	syntax anything(name=estimates)

	sreturn clear
	
	// define keywords -----
	
	// number and percent in poverty
	# delimit ;
	local pov = 
		/* number in poverty */
		"S1701_C02_001 " + /* overall */
		"S1701_C02_002 S1701_C02_006 S1701_C02_010 " + /* age groups */
		"S1701_C02_014 S1701_C02_015 S1701_C02_016 S1701_C02_017 S1701_C02_018 S1701_C02_019 S1701_C02_020 S1701_C02_021 " + /* race/ethnicity */
		/* poverty rate */
		"S1701_C03_001 " + /* overall */
		"S1701_C03_002 S1701_C03_006 S1701_C03_010 " + /* age groups */
		"S1701_C03_014 S1701_C03_015 S1701_C03_016 S1701_C03_017 S1701_C03_018 S1701_C03_019 S1701_C03_020 S1701_C03_021" ; /* race/ethnicity */
	# delimit cr

	// number at various income-to-poverty ratios
	local povratio "B17002"
	
	// characteristics at various income-to-poverty ratios
	local povratio_char "S1703"

	// median income, overall and by race of householder
	local medinc "B19013_001 B19013B_001 B19013C_001 B19013D_001 B19013E_001 B19013F_001 B19013G_001 B19013H_001 B19013I_001"

	// snap
	# delimit ;
	local snap = 
		"S2201_C04_001 " + /* percent of households participating */
		/* characteristics of participating households: */
		"S2201_C04_002 S2201_C04_009 " + /* presence of senior, child */
		"S2201_C04_007 " + /* female-headed family, no spouse */
		"S2201_C04_021 " + /* in poverty */
		"S2201_C04_023 " + /* presence of disabled person */
		"S2201_C04_026 S2201_C04_027 S2201_C04_028 S2201_C04_029 S2201_C04_030 S2201_C04_031 S2201_C04_032 S2201_C04_033 " + /* race/ethnicity */
		"S2201_C03_034 " + /* median income */
		"S2201_C04_036 S2201_C04_037 S2201_C04_038" ; /* number of workers */
	# delimit cr
	
	// medicaid/other means-tested coverage
	# delimit ;
	local medicaid = 
		/* number covered */
		"S2704_C02_006 " + /* overall */
		"S2704_C02_007 S2704_C02_008 S2704_C02_009 " + /* age groups */
		/* percent covered */
		"S2704_C03_006 " + /* overall */
		"S2704_C03_007 S2704_C03_008 S2704_C03_009" ; /* age groups */
	# delimit cr

	// housing characteristics
	local housing_overview "DP04"
	
	// housing cost burden
	local costburden_renters "B25070"
	local costburden_owners "B25091"
	
	// tenure
	# delimit ;
	local tenure_inc = 
		"B25003_001 B25003_002 B25003_003 " + /* number of households */
		"B25119_001 B25119_002 B25119_003 " + /*  median hh income */
		"C17019_001 C17019_002 C17019_003 C17019_004 C17019_005 C17019_006 C17019_007" ; /* family poverty status */
	# delimit cr

	// children and nativity
	local kids_nativity "B05009"
	local kids_pov_parents_nativity "B05010"

	// parse keywords -----
	
	// expand keyword and add to list of estimates
	local estimates_lower = strlower("`estimates'")
	local estimates_expanded ""
	foreach est in `estimates_lower' {
		if !ustrregexm(strupper("`est'"), "(B|C(?!P)|DP|S)(\d)") {
			local est "``est''"
		}
		local estimates_expanded = "`estimates_expanded' `est'"
	}
	
	// return as local
	local estimates = strupper(strtrim("`estimates_expanded'"))
	sreturn local estimates = `"`estimates'"'
	
end


