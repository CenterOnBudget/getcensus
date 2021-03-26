* make help files for getcensus

cd "${ghpath}/getcensus"

capture which markdoc
if _rc != 0 {
	net install github, from("https://haghish.github.io/github/") replace
	github install haghish/markdoc, stable
}

markdoc "dev/getcensus_help.ado", export(sthlp) replace style("simple")

copy "dev/getcensus_help.sthlp" "src/getcensus.sthlp", replace