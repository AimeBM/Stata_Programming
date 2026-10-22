clear

* Data preparation
*********************
* Step1 : Data preparation : data for the round 1
********
import excel "data\source\Presidentielle_2017_Resultats_Communes_Tour_1.xls", sheet("Feuil1") cellrange(A4:CQ35500) firstrow
	*Importing data, starting from the variable labels on line 4
	
keep Codedudépartement Libellédudépartement Inscrits Votants Exprimés
	*Keeping only the useful variables in the dataset for the first round
	
rename Codedudépartement code
rename Libellédudépartement departement
rename Inscrits Inscrits_R1
rename Votants Votants_R1
rename Exprimés Exprimés_R1
	*Rename the variables to create a distinction

collapse (sum) Inscrits_R1 Votants_R1 Exprimés_R1, by(code departement)
	*Aggregate votes by department
	
save "data\temp\tour1.dta", replace
	*Save the processed dataset for the first round
clear

* Step2 : Data preparation : data for the round 2
********
import excel "data\source\Presidentielle_2017_Resultats_Communes_Tour_2_c.xls", sheet("Feuil1") cellrange(A4:AF35723) firstrow
	*Importing data, starting from the variable labels on line 4
	
keep Codedudépartement Libellédudépartement Inscrits Votants Exprimés Voix AD
	*Keeping only the useful variables in the dataset for the 2nd round

rename Codedudépartement code
rename Libellédudépartement departement
rename Inscrits Inscrits_R2
rename Votants Votants_R2
rename Exprimés Exprimés_R2
rename Voix MACRON_VOIX_R2
rename AD LE_PEN_VOIX_R2
	*Rename the variables to create a distinction

collapse (sum) Inscrits_R2 Votants_R2 Exprimés_R2 MACRON_VOIX_R2 LE_PEN_VOIX_R2, by(code departement)
save "data\temp\tour2.dta", replace
	*Aggregate votes by department
clear

* Step3 : Merging the two datasets
********
use "data\temp\tour1.dta", clear

merge 1:1 code departement using "data\temp\tour2.dta"
	*Merging the two datasets
	
drop if code == "ZZ"
	*Delete this observation because it corresponds to votes from French citizens abroad
	
drop _merge
	*Delete this column because it is not relevant

save "data\temp\fusion.dta", replace

* Step3 : Create variables for participation by candidate and change in participation between the two rounds
********

use "data\temp\fusion.dta", clear

gen Macron_vote_shares_R2 = MACRON_VOIX_R2 * 100 / Exprimés_R2
gen LE_PEN_vote_shares_R2 = LE_PEN_VOIX_R2 * 100 / Exprimés_R2
	*Les pourcentages des voix par départements des candidats

gen vote_shares_R1 = Votants_R1 * 100 / Inscrits_R1
gen vote_shares_R2 = Votants_R2 * 100 / Inscrits_R2
	*Les PourcentageS des participations par départements des deux tours

gen change_turnout = vote_shares_R1 - vote_shares_R2
	*Change in turnout between the two rounds
	
save "data\final\election.dta", replace

