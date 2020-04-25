# 1.1.0

__Main program__

  - Add explicit support for data years 2005-2009
  - Improved and stricter handling of errors when user passes unsupported year-datset or year-product combinations
  - Some cleanup related to deprecation of `product` option

# 1.0.0

__Main program__

  - Add geographic component (e.g. metro/non-metro) option ([#11](https://github.com/CenterOnBudget/getcensus/issues/11))
  - Label margin of error variables ([#12](https://github.com/CenterOnBudget/getcensus/issues/12))
  - Clarify handling of mixed-up `geoid` and `statefips` options ([#18](https://github.com/CenterOnBudget/getcensus/issues/18))
  - New keywords to easily retrieve poverty ratio tables ([#21](https://github.com/CenterOnBudget/getcensus/issues/21))
  - Label variables using data dictionary for most recent data year requested by user ([#24](https://github.com/CenterOnBudget/getcensus/issues/24))

__Help file__

  - Clarify usage of `product` option ([#14](https://github.com/CenterOnBudget/getcensus/issues/14))
  - Correct description of `cache` option and rename to `cachepath`
  - Several typo fixes and minor edits
  - Add link to GitHub page
  
# 0.1.2

__Main program__

  - Fix issue [#13](https://github.com/CenterOnBudget/getcensus/issues/13) 
  - When `saveas` option used, new message tells users the path to the saved files. ([#15](https://github.com/CenterOnBudget/getcensus/issues/15))

__Documentation__

  - Several minor edits and typo fixes

# 0.1.1

__Main program__

  - New keywords to retreive data on housing, children's nativity
  - Preserve left-padded zeros in state and county FIPS codes
  - Fix issues [#1](https://github.com/CenterOnBudget/getcensus/issues/1), [#2](https://github.com/CenterOnBudget/getcensus/issues/2),  [#4](https://github.com/CenterOnBudget/getcensus/issues/4), [#5](https://github.com/CenterOnBudget/getcensus/issues/5)


__Help file__

  - Add required Census Bureau non-endorsement disclaimer
  - Link to FIPS code and GEOID lookup documents
  - Add usage note related to housing keywords
  - Update maintainer info


