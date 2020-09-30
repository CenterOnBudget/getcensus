# getcensus v 2.0.0 

### Enhancements

- Support for 12 additional geographic areas: alaska native regional corporation, american indian area/alaska native area/hawaiian home land, combined statistical area, state legislative district (lower chamber), state legislative district (upper chamber), new england city and town area, combined new england city and town area, urban area, school district (elementary), school district (secondary), public use microdata area, and zip code tabulation area. Users may specify the full name or an abbreviation to `geography()`.
- The name each variable's table is saved as a variable note. Different tables have different universes which are described in the table name rather than the variable names, and it is important for users to be aware of the universe for a given estimate, especially as users may be retrieving variables from multiple tables. (These notes may not appear in all years and product types, as occasionally this field is missing from the API data dictionaries.)


### Breaking changes

- `product()` must be specified with `getcensus catalog`.
- In `geography()`, "bg" replaces "block" to refer to the Census geography "block group". "Block" is a distinct Census geography for which ACS estimates are not available (decennial census only).
- `table()` may no longer be abbreviated to `t()`.


### Non-breaking changes

- `sample()` replaces `dataset()` as it is more consistent with ACS terminology. The `dataset()` option is retained for compatibility; if specified, its contents are copied into `sample()`.
- Both a Stata file and an Excel file are saved by default when `saveas()` is specified; the `exportexcel` option is ignored.
- When one or more variable labels have been truncated, a single message is displayed rather than a message for each truncated label.


### New subroutines

- __`_getcensus_catalog.ado`__ Loads the API data dictionaries and saves two files to the cache: a dataset to load into memory if `getcensus catlog`; and a dataset containing for each variable, the`.do` file text to label the variable, create variable notes, and flag if the variable label has been truncated. After retrieving data from the API, the main program loads the latter dataset, filters it to the retrieved variables, generates a temporary `.do` file, and then runs that `.do` file on the retrieved data. With `getcensus catalog`, if the cached files are already present, this subroutine simply loads the first cached file into memory.
-  __`_getcensus_parse_geography.ado`__ Validates the `geography()` argument and returns for use in the main program: the full name, used to construct the API query; the abbreviation, for reference by error checking code; and the geography hierarchy, for ordering the data retrieved from the API. This program relies on `_getcensus_geo_args.dta`.
-  __`_gensus_expand_keyword.ado`__ Expands keywords into a table ID or list of estimates, and returns the expanded list. 

