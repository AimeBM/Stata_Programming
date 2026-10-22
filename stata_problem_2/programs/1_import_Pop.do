clear

* Import Excel data
****************************************

import excel "data\source\base-pop-historiques-1876-2022.xlsx", sheet("pop_1876_2022") cellrange(A5:AN34944) firstrow


drop if _n==1 // "Remove the first rows as it is not relevant to this work"

* Reshape 
****************************************

reshape long Populationen, i(Codegéographique) j(year) // Reshape


destring Populationen, gen(population) // "Create a variable by converting the population to numeric."

keep Département year population // "Keep only these three variables."

drop if Département == "" // Remove empty rows.

collapse(sum) population, by(Département year) // Group the population by department and year

rename Département code_dep

* Organize
****************************************

order code_dep year population // Cosmetic change of the order of variables

* Save
****************************************
save "data\temp\pop_fr", replace // Save data


* Les noms des départements
****************************************

/*
"In the population database, there are only department numbers without their names. It is therefore advisable to have the names of each department. We have found a database of departments that we will merge with the current one."
*/


* "Import department names"

clear
import excel "data\source\departement.xlsx", sheet("Feuil1") firstrow

rename Code_dep code_dep
rename Département departement
save "data\temp\dep_fr", replace // Save data


* Associate each department number with its name

use "data\temp\dep_fr", clear

merge 1:m code_dep using "data\temp\pop_fr.dta"

drop _merge

save "data\final\population_française", replace