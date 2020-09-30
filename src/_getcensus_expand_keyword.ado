
* capture program drop _getcensus_expand_keyword

program define _getcensus_expand_keyword, sclass

	syntax anything(name=estimates)

	sreturn clear
	
	// poverty
	local pov "S1701"
	local povratio "B17002"
	local povratio_char "S1703"

	// median income
	local medinc "B19013_001"
	local medinc_byrace "B19013B_001 B19013C_001 B19013D_001 B19013E_001 B19013F_001 B19013G_001 B19013H_001 B19013I_001"
	local medinc "`medinc' `medinc_byrace'"

	// snap
	local snap_total "S2201_C04_001"
	local snap_composition "S2201_C04_007 S2201_C04_009"
	local snap_poverty "S2201_C04_021"
	local snap_disability "S2201_C04_023"
	local snap_byrace "S2201_C04_026 S2201_C04_027 S2201_C04_028 S2201_C04_029 S2201_C04_030 S2201_C04_031 S2201_C04_032 S2201_C04_033"
	local snap_medinc "S2201_C04_034"
	local snap_employment "S2201_C04_035 S2201_C04_036 S2201_C04_037 S2201_C04_038"
	local snap "`snap_total' `snap_composition' `snap_poverty' `snap_disability' `snap_byrace' `snap_medinc' `snap_employment'"
	
	// medicaid
	local medicaid_total "S2704_C02_006"
	local medicaid_byage "S2704_C02_007 S2704_C02_008 S2704_C02_009"
	local medicaid "`medicaid_total' `medicaid_byage'"

	// housing
	local housing_overview "DP04"
	local costburden_renters "B25070"
	local costburden_owners "B25091"
	local ten "B25003_001 B25003_002 B25003_003"
	local ten_medinc "B25119_001 B25119_002 B25119_003"
	local ten_pov "C17019_001 C17019_002 C17019_003 C17019_004 C17019_005 C17019_006 C17019_007"
	local tenure_inc "`ten' `ten_medinc' `ten_pov'"

	// children and nativity
	local kids_nativity "B05009"
	local kids_pov_parents_nativity "B05010"

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