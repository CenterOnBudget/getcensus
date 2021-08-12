## Help file

`dev/getcenus_help.ado` contains the help file content, which written in a mix of markdown and SMCL. Edits to the help file should be made here.

`dev/make_help_file.do` uses the [markdoc Stata package](https://github.com/haghish/markdoc) to render `dev/getcensus_help.ado` as a SMCL document, and copies the rendered file as `src/getcensus.sthlp`.

## Geography dataset

`dev/getcensus_geo_args.xlsx` is a manually created dataset containing supported geographies, their abbreviations, and their geographic hierarchies.

`dev/make_getcensus_geo_args.do` converts `dev/getcensus_geo_args.xlsx` to `src/_getcensus_geo_args.dta`.

The sub-program `src/_getcensus_parse_geography.ado` (see below) uses `src/_getcensus_geo_args.dta` to validate the specified `geography()` and to pass information associated with the geography to the main program.

To add or modify a supported geography, edit `dev/getcensus_geo_args.xlsx` , then run `dev/make_getcensus_geo_args.do` (in addition to whatever modifications are required to the main program).

## Sub-programs

`src/_getcensus_catalog.ado` loads the API data dictionaries and saves two files to the cache: (1) a dataset to load into memory with `getcensus catlog`; and (2) a dataset containing for each variable, the `.do` file text to label the variable, create variable notes, and flag if the variable label has been truncated. With `getcensus catalog`, the main program simply calls this sub-program to load the first dataset into memory, and then exits. Otherwise, the main program, after retrieving data from the API, will load the second dataset, filter it to the retrieved variables, generates a temporary `.do` file, and then run that `.do` file on the retrieved data (unless `nolabel` is specified).

`src/_getcensus_parse_geography.ado` validates the `geography()` argument and returns for use in the main program: the full name, used to construct the API query; the abbreviation, for reference by error checking code; and the geography hierarchy, for ordering the data retrieved from the API. This program relies on `src/_getcensus_geo_args.dta` (see above).

`srv/_gensus_expand_keyword.ado` expands keywords into a table ID or list of estimates, and returns the expanded list.
