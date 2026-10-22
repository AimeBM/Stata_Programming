clear

* Import data of crime of national police for departements numbered :
********************************************************************************

forvalues annee = 2012(1)2021 {

    import excel using "data\source\crimes-et-delits-enregistres-par-les-services-de-gendarmerie-et-de-police-depuis-2012.xlsx", ///
        sheet("Services PN `annee'") firstrow clear
    
    drop if _n==1 | _n==2


    * Rename the variables
	rename Année`annee'servicesdepolice id
	rename Départements crime
	

	* Convert variables to numeric

    local vars_string "id crime" // Exclure ces variables lors de la conversion

    * Convert the other variables
    foreach elt of varlist * {
        if strpos("`vars_string'", "`elt'") == 0 { 
            destring `elt', replace force
        }
    }

	* Identify the department variables based
	
    local labels ""
    foreach elt of varlist * {
        if strpos("`vars_string'", "`elt'") == 0 {
            local lab : variable label `elt'
            if "`lab'" != "" & strpos("`labels'", "`lab'") == 0 {
                local labels "`labels' `lab'"
            }
        }
    }

    * sum of columns for each department

    foreach lab of local labels {
        gen pn`lab' = 0
        foreach var of varlist * {
            if strpos("`vars_string'", "`var'") == 0 {
                local var_label : variable label `var'
                if "`var_label'" == "`lab'" {
                    replace pn`lab' = pn`lab' + `var'
                }
            }
        }
    }

    *Vous pouvez juste garder des variables dont vous avez besoin

	* Reshape
	reshape long pn, i(id) j(id_dep) string
	
    gen annee = `annee'

    save "data\temp\pn_`annee'", replace
}

*Data combine
clear

forvalues annee = 2012(1)2021{
append using "data\temp\pn_`annee'"
erase "data\temp\pn_`annee'.dta" // Erase temporary files to save some place
}
order id crime id_dep annee pn
save "data\temp\pn_crime_data", replace
