# 2.0.0

**Enhancements**

-   **Add support for 12 geographic areas:**

    -   alaska native regional corporation
    -   american indian area/alaska native area/hawaiian home land
    -   combined statistical area
    -   state legislative district (lower chamber)
    -   state legislative district (upper chamber)
    -   new england city and town area
    -   combined new england city and town area
    -   urban area, school district (elementary)
    -   school district (secondary)
    -   public use microdata area
    -   zip code tabulation area

    Users may specify the full name or an abbreviation to `geography()`.

-   **Additional metadata**: The name of each variable's table is saved as a variable note. Different tables have different universes which are described in the table name rather than the variable names, and it is important for users to be aware of the universe for a given estimate, especially as users may be retrieving variables from multiple tables. The table name note may not appear for all years and product types, as occasionally this field is missing from the API data dictionaries.

**Breaking changes**

-   In `geography()`, "bg" replaces "block" to refer to the "block group" geography. "Block" is a distinct census geography for which ACS estimates are not available.
-   In `geography()`, "unsd" replaces "sch" to refer to the "unified school district" geography. With the addition of elementary and secondary school district as supported geographies (see above), "sch" is too ambiguous.
-   Interactive (point-and-click) mode has been removed from the program.

**Other changes**

-   `sample()` replaces `dataset()`, as it is more consistent with ACS terminology. Also, in the future `getcensus` may support other Census datasets, such as the decennial census and population estimates, so we'd like to preserve the `dataset()` option for future development. For now, the `dataset()` option is retained for compatibility; if specified, its contents are copied into `sample()`.
-   In the help file and error messages, data points are now referred to as "variables" rather than estimates. This is more consistent with the Census Bureau's own API documentation and [user guide](https://www.census.gov/data/developers/guidance/api-user-guide.html), and matches the terminology of the [tidycensus](https://walker-data.com/tidycensus/) R package. It also avoids confusion ("1-year estimates", "estimate" versus "margin of error").
-   Both a Stata file and an Excel file are saved by default when `saveas()` is specified; the `exportexcel` option is ignored.
-   When one or more variable labels have been truncated, a single message is displayed rather than a message for each truncated label.
-   A rewritten help file provides more information on supported geographies and geographic components, includes more links to Census Bureau resources, and is more cleanly organized.

**Under the hood**

getcensus version 2.0.0 is a full refactor of the program. Contributors should review `dev/README.md`.

# 1.1.0

**Main program**

-   Add explicit support for data years 2005-2009
-   Improved and stricter handling of errors when user passes unsupported year-dataset or year-product combinations
-   Some cleanup related to deprecation of `product` option

# 1.0.0

**Main program**

-   Add geographic component (e.g. metro/non-metro) option ([\#11](https://github.com/CenterOnBudget/getcensus/issues/11))
-   Label margin of error variables ([\#12](https://github.com/CenterOnBudget/getcensus/issues/12))
-   Clarify handling of mixed-up `geoid` and `statefips` options ([\#18](https://github.com/CenterOnBudget/getcensus/issues/18))
-   New keywords to easily retrieve poverty ratio tables ([\#21](https://github.com/CenterOnBudget/getcensus/issues/21))
-   Label variables using data dictionary for most recent data year requested by user ([\#24](https://github.com/CenterOnBudget/getcensus/issues/24))

**Help file**

-   Clarify usage of `product` option ([\#14](https://github.com/CenterOnBudget/getcensus/issues/14))
-   Correct description of `cache` option and rename to `cachepath`
-   Several typo fixes and minor edits
-   Add link to GitHub page

# 0.1.2

**Main program**

-   Fix issue [\#13](https://github.com/CenterOnBudget/getcensus/issues/13)
-   When `saveas` option used, new message tells users the path to the saved files. ([\#15](https://github.com/CenterOnBudget/getcensus/issues/15))

**Documentation**

-   Several minor edits and typo fixes

# 0.1.1

**Main program**

-   New keywords to retreive data on housing, children's nativity
-   Preserve left-padded zeros in state and county FIPS codes
-   Fix issues [\#1](https://github.com/CenterOnBudget/getcensus/issues/1), [\#2](https://github.com/CenterOnBudget/getcensus/issues/2), [\#4](https://github.com/CenterOnBudget/getcensus/issues/4), [\#5](https://github.com/CenterOnBudget/getcensus/issues/5)

**Help file**

-   Add required Census Bureau non-endorsement disclaimer
-   Link to FIPS code and GEOID lookup documents
-   Add usage note related to housing keywords
-   Update maintainer info
