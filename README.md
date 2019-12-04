# getcensus

Loads published estimates from the American Community Survey into memory.


# Introduction

The Census Bureau collects information on the U.S. population, including information on the population's demographics, and economic and social characteristics.

While the data Census collects is extremely useful, it is not always easy to retrieve these data. Many users use [American FactFinder](https://factfinder.census.gov/faces/nav/jsf/pages/index.xhtml) or [data.census.gov](https://data.census.gov/cedsci/) to do so. While these interfaces are helpful, they can sometimes be difficult to navigate, queries arehard to share with others, and its difficult to easily revise queries and retrievethem in an easy-to-use format.

To overcome some of these limitations, CBPP has developed `getcensus`, a Stata program that allows users to construct a query and quickly retrieve Census data and import it directly into Stata, with options to then export the data into Excel.


# Overview

At its core, `getcensus` is a program built to communicate with Census' Application Programming Interface (API). In English, `getcensus` constructs a request to Census based on a user's specifications. For example, it might ask Census to return certain tables for all counties in a given state for a specific year.

The Census API will process the request and return these data to Stata. From there, users can analyze the data like they would with any other dataset, or export the results to an Excel workbook.

The program works in two ways:

- You can write Stata commands to retrieve data
- If you find writing Stata code a little daunting, there is a "point-and-click" interface to help you retrieve data


# Installation

To install this program, type the following command into the Command window:

```
net install getcensus, from(https://raw.githubusercontent.com/CenterOnBudget/getcensus/master/build/)
```

# Features

## Main Program

### Getting Started

You can find complete documentation, including notes on how the program works
by typing `help getcensus` into the Command Window.

Before you start, you need a key from Census' API, which you can acquire
here: [https://api.census.gov/data/key_signup.html](https://api.census.gov/data/key_signup.html).

Once you have that, you can put the following into your `profile.do` or at the top of all your do-files using `getcensus`: `global censuskey "YOUR_KEY"`.

### Syntax

`getcensus [estimate IDs, table ID, or keyword] [, options]`

Some key options include:

- *years*: Years of data to retrieve
- *geography*: Geography to download. Default is "state"
- *geoids*: GEOIDs of geography to download
- *statefips*: Two-digit state FIPS for which to download data

For more information on these and other options, see the `getcensus` [documentation](#help-file).

### Examples

```
** Retrieve data from table B19013 for all states in most recent year
getcensus B19013, clear

** Retrieve data from table B19013 for all counties in most recent year
getcensus B19013, geography(county) clear

** Retrieve data from table B19013 for all states in last three years
getcensus B19013, years(2015/2017) clear

** Retrieve data from table B19013 for all counties in two states
getcensus B19013, years(2015/2017) geography(county) statefips(01 02) clear
```

## Point and Click System

If you find writing Stata code intimidating, have no fear! 

If you type `getcensus` directly into Stata's Command window, a menu will appear in the Results window. Here, you can have access to some limited functionality of the program. You can select from among a number of pre-selected tables, and choose the year and geography. 

Once you're ready, select `Retrieve my data!` to import the data to Stata. Select
`Click here to export results to Excel` to, well, export the results to Excel.


## Help File

If you type `help getcensus` into the Command window, you will gain access
to `getcensus`'s complete -- and rather thorough -- documentation. The help file
includes information on the program's syntax, helpful keywords to easily retrieve
key estimates, details on how to pass options, and many, many examples.

If you ever get stuck using the program, we strongly recommend you start here!


## Data Dictionary

Census' API provides thousands of estimates. However, to access these estimates,
you have to know the specific table number (e.g., S1701) or estimate ID
(e.g., S1701_C01_001E), which are not intuitive.

In order to figure out these table IDs, you could navigate American FactFinder or 
data.census.gov. In order to figure out desired estimate IDs, you have to 
use one of the API's four data dictionaries (one for each type of table (e.g.,
detailed or subject tables). However, these are very clunky and hard to 
use at the moment (you can find the one for the detailed tables 
[here](https://api.census.gov/data/2017/acs/acs1/variables.html)).

This program has a utility function to help users try to figure out the estimate
IDs associated with the estimates they care about.

There are primarily two ways to use this tool:

- `getcensus catalog, table()`: Insert the table number to get all estimate IDs associated with a specific Census table
- `getcensus catalog, search()`: Insert a search term to find all estimate IDs whose labels contain the search term

By default, the program searches in the detailed tables. If you want to search other tables, make sure to add the `product` option. E.g., `getcensus catalog, search(poverty) product(ST)`

