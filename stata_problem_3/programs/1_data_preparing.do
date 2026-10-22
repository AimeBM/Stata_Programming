clear

**************************************************************************
* DATA PREPARING
***************************************************************************

* 1-) PREPARING OF DATA WVS6
******************************
use "data\source\WV6_Data_stata_v20201117.dta", clear

keep V1 V2 B_COUNTRY_ALPHA V24 V109 V113 V114 V248 V239

* 1-1) Redefine other values as missing
**********************************
mvdecode V24 V109 V113 V114 V248 V239, mv(-1 -2 -3 -4 -5)

* 1-2) Rename the variables
*************************
rename V1 wave
rename V2 country
rename B_COUNTRY_ALPHA code_country
rename V239 scale_incomes

* 1-3) Adjust the scaling values
************************************				   
recode V109 ( 1 2 =1 "Trust")(3 4 =0 "Not trust"), gen(armed_forces)
recode V113 ( 1 2 =1 "Trust")(3 4 =0 "Not trust"), gen(police)
recode V114 ( 1 2 =1 "Trust")(3 4 =0 "Not trust"), gen(courts)
recode V24 ( 1 =1 "Trust")(2 =0 "Not trust"), gen(people)
recode V248 (0 1 2 3 = 1 "Primary or less") ( 4 5 6 7 = 2 "Secondary") ( 8 9 = 3 "University"), gen(education)

tabulate education, gen(education_)

* Education* becomes the cycle completed (with or without a diploma)

drop V24 V109 V113 V114 V248 education

* 1-4) Synthetic index of measures of trust in institutions
******************************************
egen index_institutions = rowmean(armed_forces police courts)

save "data\temp\WVS6.dta", replace


* 2-) PREPARING OF DATA WVS7
***********************************************************
use "data\source\WVS_Cross-National_Wave_7_stata_v6_0.dta", clear

keep A_WAVE B_COUNTRY B_COUNTRY_ALPHA Q57 Q65 Q69 Q70 Q275 Q288

* 2-1) Redefine other values as missing
***************************************
mvdecode Q57 Q65 Q69 Q70 Q275 Q288, mv(-1 -2 -3 -4 -5)


* 2-2) Rename the variables
*****************************************
rename A_WAVE wave
rename B_COUNTRY country
rename B_COUNTRY_ALPHA code_country
rename Q288 scale_incomes

* 2-3) Adjust the scaling values
********************************************
recode Q65 ( 1 2 =1 "Trust")(3 4 =0 "Not trust"), gen(armed_forces)
recode Q69 ( 1 2 =1 "Trust")(3 4 =0 "Not trust"), gen(police)
recode Q70 ( 1 2 =1 "Trust")(3 4 =0 "Not trust"), gen(courts)
recode Q57 ( 1 =1 "Trust")(2 =0 "Not trust"), gen(people)
recode Q275 (0 1 = 1 "Primary or less") ( 2 3 4 5 = 2 "Secondary") ( 6 7 8 = 3 "University") , gen(education)

tabulate education, gen(education_)

* Education* becomes the cycle completed (with or without a diploma)


drop Q57 Q65 Q69 Q70 Q275 education

* 2-4) Synthetic index of measures of trust in institutions
********************************************
egen index_institutions = rowmean(armed_forces police courts)

save "data\temp\WVS7.dta", replace


* 3-) Merge the WVS databases for the common countries
**************************************************

* 3-1)  Obtain the countries from each WVS dataset 
****************************************
use "data/temp/WVS6.dta", clear
keep country code_country
duplicates drop
save "data/temp/countries_wave6.dta", replace

use "data/temp/WVS7.dta", clear
keep country code_country
duplicates drop
save "data/temp/countries_wave7.dta", replace

* 3-2)  Obtain the common countries from the both WVS dataset
*********************************************
use "data/temp/WVS6.dta", clear
merge m:1 country code_country using "data/temp/countries_wvs6_7.dta"
keep if _merge == 3
drop _merge
save "data/temp/WVS6_country_inWVS7.dta", replace

use "data/temp/WVS7.dta", clear
merge m:1 country code_country using "data/temp/countries_wvs6_7.dta"
keep if _merge == 3 
drop _merge
save "data/temp/WVS7_country_inWVS6.dta", replace

* 3-3) Obtain WVS dataset of common countries
********************************************
use "data/temp/WVS6_country_inWVS7.dta", clear
append using "data/temp/WVS7_country_inWVS6.dta"
save "data/temp/WVS_6_7_countries_common.dta", replace


* 4-) Dataset WVS with key "country-year"
***********************************************

use "data/temp/WVS_6_7_countries_common.dta", clear

* 4-1) Average of the variables to obtain the values for the country-year
****************************************
/*
egen armed_Forces_trust_mode = mode(armed_forces), by(country wave) nummode(1)
egen police_trust_mode = mode(police), by(country wave) nummode(1)
egen courts_trust_mode = mode(courts), by(country wave) nummode(1) 
egen education_level_mode = mode(education_level), by(country wave) nummode(1)
egen people_trust_mode_mode = mode(people_trust), by(country wave) nummode(1)
*/

collapse(mean) armed_forces police courts people education* index_institutions , by(country code_country wave)


save "data/temp/WVS_6_7.dta", replace

* BONUS : Bonus dataset
**************************************
use "data/temp/WVS6.dta", clear
append using "data/temp/WVS7.dta"

save "data/temp/WVS.dta", replace