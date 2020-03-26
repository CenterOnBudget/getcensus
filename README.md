<img align="right" width="200" src="https://www.cbpp.org/sites/all/themes/custom/cbpp/logo.png">

# getcensus

Load published estimates from the American Community Survey into memory.


# Table of Contents

[Introduction](#introduction)  
[Getting Started](#getting-started)  
[Features](#features):

  - [Main Program](#main-program)
  - [Interactive Mode](#interactive-mode)
  - [Data Dictionary Search Mode](#data-dictionary-search-mode)
  
[Reporting Bugs](#reporting-bugs)  
[License](#license)

# Introduction

The U.S. Census Bureau's [American Community Survey](https://www.census.gov/programs-surveys/acs) (ACS) collects detailed information on the U.S. population, including demographic, economic, and housing characteristics.

The most popular way to access ACS data is by visiting [data.census.gov](https://data.census.gov/), the successor to the Census's [American FactFinder](https://factfinder.census.gov/) website. While these web tools are invaluable for browsing, they can be cumbersome for retrieving data at scale. That's why Census data users who need to obtain data for many years or geographies, or who need many estimates from multiple tables, often rely on the Census Bureau's [Application Programming Interface](https://www.census.gov/data/developers/updates/new-discovery-tool.html) (API). In simple terms, data users use the Census API to query to the Census's databases, and the Census Bureau server sends the requested data back to the user.

Composing API data queries and transforming the returned data into an easy-to-use format can be tricky. That's why the [Center on Budget and Policy Priorities](https://www.cbpp.org) has developed `getcensus`, a Stata program to help policy analysts obtain ACS tables and portions of tables through the Census API. With `getcensus`, Stata users can easily compose API queries, retrieve data fast, and import it into Stata or Excel, ready for analysis. 

`getcensus` uses the Census Bureau Data API but is not endorsed or certified by the Census Bureau.


# Getting Started

### Installation

To install this program, type the following command into the Command window:

```
net install getcensus, from(https://raw.githubusercontent.com/CenterOnBudget/getcensus/master/src) replace
```

`getcensus` requires Stata version 14.0 or later.

This program is updated regularly with enhancements and important bug fixes. To update your installation of `getcensus` to the latest version, run:

```
ado update getcensus
```

### Obtaining & Storing an API Key

To use the Census API, you'll need an API key, which you can acquire
at: [https://api.census.gov/data/key_signup.html](https://api.census.gov/data/key_signup.html).

Next, you'll need to direct the `getcensus` program to your API key. You can accomplish this one of two ways:

  - Add `global censuskey "YOUR_KEY_HERE"` to your Stata `profile.do` file (recommended). Learn about where to find this file [here](https://www.stata.com/support/faqs/programming/profile-do-file/). This only needs to be done once.

  - Include `global censuskey "YOUR_KEY_HERE"` at the top of every `.do` file using `getcensus`.


# Features

### Help File

You can find a complete description of `getcensus` in the help file, accessible by typing `help getcensus` into the Command Window. The help file includes information on the program's syntax, details on how to pass options, a list of keywords you can use to retreive popular sets of estimates, and many examples. If you ever get stuck using the program, we strongly recommend you start with the help file.

A `getcensus` tutorial can be found in this repository: [`getcensus_tutorial.do`](https://github.com/CenterOnBudget/getcensus/blob/master/getcensus_tutorial.do).

### Main Program

__Syntax__

`getcensus [estimate IDs, table ID, or keyword] [, options]`

Some useful options include:

- `years`: Year(s) of data to retrieve.
- `geography`: Geography to download. Default is state.
- `geoids`: GEOIDs of geography to download.
- `statefips`: Two-digit state FIPS codes for which to download data.

For more information on these and other options, see the `getcensus` [help file](#help-file).

Note: FIPS codes for the 50 states, District of Columbia, and Puerto Rico are listed [here](https://www.census.gov/library/reference/code-lists/ansi/ansi-codes-for-states.html). GEOIDs for counties, places, and other geographies can be found [here](https://www.census.gov/geographies/reference-files/2018/demo/popest/2018-fips.html).


__Examples__

```
* Retrieve data from table B19013 for all states in most recent year
getcensus B19013, clear

* Retrieve data from table B19013 for all counties in most recent year
getcensus B19013, geography(county) clear

* Retrieve data from table B19013 for all states in 2015, 2016, and 2017
getcensus B19013, years(2015/2017) clear

* Retrieve data from table B19013 for all counties in two states (Alabama and Wyoming) in three years
getcensus B19013, years(2015/2017) geography(county) statefips(01 56) clear
```

### Interactive Mode

If you find writing Stata code intimidating, you may be interested in `getcensus`'s interactive (point-and-click) mode. This mode provides access to a limited set of `getcensus` functionality through an easy to use, point-and-click interface. 

Enter interactive mode by typing `getcensus` directly into Stata's Command window. A menu will appear in the Results window. Here, you can choose from among a number of pre-selected tables, and select the year and geography. After making your selections, click <kbd>Retrieve my data</kbd> to load the data into Stata. Or, select <kbd> Retrieve my data and export to Excel</kbd> to save the data as an Excel spreadsheet in your current working directory.


### Data Dictionary Search Mode

To retreive data from the Census API, users must supply the table or estimate ID. For instance, the table ID of "[Poverty Status in the Past 12 Months](https://data.census.gov/cedsci/table?q=s1701)" is S1701. The estimate ID of "Population for whom poverty status is determined" (the first estimate in table S1701) is S1701_C01_001E. 

Few users know offhand the table number or estimate ID for the data they're interested in. One option is to search for a topic on [data.census.gov](https://data.census.gov/), find a table of interest, and locate the TableID. Finding estimate IDs is less straightforward; it requires searching through the API data dictionaries. You can take a look at the API data dictionary for the detailed tables [here](https://api.census.gov/data/2017/acs/acs1/variables.html).

A more convenient option is `getcensus`'s data dictionary search mode. The `getcensus catalog` sub-program  allows users to search the API data dictionaries from within Stata. 

There are primarily two ways to search: 

- `getcensus catalog, table()`: Insert a table ID between the parentheses to retreive all the estimate IDs and estimate labels associated with the table.
- `getcensus catalog, search()`: Insert a search term, such as "income" or "Hispanic" to find all estimate IDs whose labels contain the search term.

By default, the program searches the detailed tables. If you want to search other table types, make sure use the `product` option. For instance, to search the subject tables: `getcensus catalog, search(poverty) product(ST)`. More information on ACS table types can be found [here](https://www.census.gov/programs-surveys/acs/guidance/which-data-tool/table-ids-explained.html).


# Reporting Bugs

If you've thoroughly read the [help file](#help-file) and are still having trouble, you may have found a bug. Check the [Issues](https://github.com/CenterOnBudget/getcensus/issues) to see if it's already been reported. If not, you can let us know by submiting a new issue (requires a [free GitHub account](www.github.com/join)). State Priorities Partnership members may contact the CBPP Data Team on The Loop.


# License

`getcensus` is made available under the following [license](https://github.com/CenterOnBudget/getcensus/blob/master/LICENSE):

> Copyright (c) 2020 Center on Budget and Policy Priorities 
> 
> Permission is hereby granted, free of charge, to members of the State Priorities 
> Partnership network described at [https://statepriorities.org/state-priorities-partners/](https://statepriorities.org/state-priorities-partners/), 
> and to all other organizations and individuals granted permission by the Center on 
> Budget and Policies Priorities, to use copies of this software and associated 
> documentation files (the "Software") without restriction, subject to the following 
> conditions:
> 
> The above copyright notice and this permission notice shall be included in all
> copies or substantial portions of the Software.
> 
> The Software is provided "as is", without warranty of any kind, express or
> implied, including but not limited to the warranties of merchantability,
> fitness for a particular purpose and noninfringement. In no event shall the
> authors or copyright holders be liable for any claim, damages or other
> liability, whether in an action of contract, tort or otherwise, arising from, 
> out of or in connection with the software or the use or other dealings in the
> Software.


# Contributors

`getcensus` is maintained by [Claire Zippel](https://www.cbpp.org/claire-zippel) and [Matt Saenz](https://www.cbpp.org/matt-saenz). The program was created by [Raheem Chaudhry](https://github.com/raheem03) and [Vincent Palacios](https://github.com/vincentpalacios).  


[![HitCount](http://hits.dwyl.io/CenterOnBudget/getcensus.svg)](http://hits.dwyl.io/CenterOnBudget/getcensus)
