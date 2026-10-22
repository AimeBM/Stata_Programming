clear

* 5-) IMPORTING GDP Data and MERGING to WVS
********************************************

* 5-1) Importing GDP data
*********************
import excel "data\source\P_Data_Extract_From_World_Development_Indicators.xlsx", sheet("Data") cellrange(A1:AB267) firstrow clear

* Reshape
***************************
reshape long YR, i(CountryName) j(year)

rename CountryCode code_country
rename YR GDP_hbt

replace GDP_hbt ="" if GDP_hbt == ".."

destring GDP_hbt, replace

keep CountryName code_country year GDP_hbt

save "data/temp/GDP_hbt.dta", replace



* 5-2) OOntain growth GDP with common countries of WVS
*********************************************************
use "data/temp/GDP_hbt.dta", clear
merge m:1 code_country using "data/temp/countries_wvs6_7.dta"
keep if _merge == 3
drop _merge CountryName
order country code_country year GDP_hbt

* 5-3) Average growth per capita GDP  over the five years after the survey
************************************************************
tsset country year
gen gdp_growth = 100 * (GDP_hbt - L.GDP_hbt) / L.GDP_hbt

gen wave = .
replace wave = 6 if year >= 2010 & year <= 2014
replace wave = 7 if year >= 2017 & year <= 2022

drop if wave==.

collapse(mean)	gdp_growth, by(country code_country wave)
save "data/temp/gdp_growth_5y.dta", replace

* 5-4) MERGING per capita GDP growth to WVS
*******************************************
use "data/temp/WVS_6_7.dta", clear
merge 1:1 wave country code_country using "data\temp\gdp_growth_5y.dta"
keep if _merge==3
drop _merge

save "data/final/WVS_growth.dta", replace


* 5-5) Create quartile of index
**************************************************

use "data\temp\WVS6.dta", clear

collapse(mean) index_institutions, by(country code_country wave)

xtile quartile = index_institutions, nq(4)

keep country code_country quartile

save "data/temp/quartile.dta", replace

* 5-6) Merging per capita GDP to WVS6 quartile
**************************************************
use "data/temp/GDP_hbt.dta", clear
merge m:1 code_country using "data/temp/quartile.dta"
keep if _merge==3
drop _merge

collapse(mean) GDP_hbt, by(year quartile)

save "data/temp/gdp_quartile.dta", replace