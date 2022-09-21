* for getcesus dev testing

cd "${ghpath}/getcensus/src"
capture program drop getcensus
capture program drop _getcensus_expand_keyword
capture program drop _getcensus_catalog
capture program drop _getcensus_parse_geography
run "getcensus.ado"
run "_getcensus_expand_keyword.ado"
run "_getcensus_catalog.ado"
run "_getcensus_parse_geography.ado"

//*
cd "${ghpath}/getcensus/"
run "dev/make_getcensus_geo_args.do"
run "dev/make_help_file.do"
**/
