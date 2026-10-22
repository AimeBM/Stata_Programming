clear

* Step1 : Merging the two datasets of crime
********
use "data\temp\crimes_pn_2012_2021.dta", clear

merge 1:1 code code_dep year using "data\temp\crimes_gn_2012_2021.dta"
	
drop _merge // Delete this column because it is not relevant
	
* Replace the missing values in the crime columns with 0 in order to calculate the total number of crimes
*********************************************

foreach var in crime_pn crime_gn {
    replace `var' = 0 if missing(`var')
}	

	
gen total_crime = crime_pn + crime_gn // Créer la variable total_crime

save "data\temp\crime.dta", replace


* Associate each department number with its name
use "data\temp\dep_fr.dta", clear

merge 1:m code_dep using "data\temp\crime.dta"
	
drop _merge

order code type_crimes code_dep departement year crime_pn crime_gn total_crime

drop if departement == "" // Keep only the departments of France
	
save "data\final\crime_2012_2021.dta", replace
