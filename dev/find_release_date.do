* Second Tuesday of the first full week of September

clear
set obs 10000
generate date = mdy(8, 31, 2023) + _n
format date %td
keep if month(date) == 9
generate month = mofd(date)
format month %tm
bysort month (date): generate week_of_month = sum(dow(date) == 0) 
generate release_date = week_of_month == 2 & dow(date) == 4
keep if release_date
generate day = day(date)
summarize day

* https://journals.sagepub.com/doi/10.1177/1536867X221083928


* First Thursday of the first full week of December
clear
set obs 10000
generate date = mdy(11, 30, 2023) + _n
format date %td
keep if month(date) == 12
generate month = mofd(date)
format month %tm
bysort month (date): generate week_of_month = sum(dow(date) == 0) 
generate release_date = week_of_month == 1 & dow(date) == 4
keep if release_date
generate day = day(date)
summarize day

local year = 2022
local release_year = `year' + 1
local sample = 5
local release_date = cond(`sample' == 1, mdy(9, 12, `release_year'), mdy(12, 5, `release_year'))
display %td `release_date'
local today = today()
display `today' < `release_date'





