clear

********************************************************************************
* Import data for départements numbered : crime_pn
********************************************************************************

* Import departements one-by-one
********************
forvalues year = 2012/2021 {

    * Import the Excel sheet corresponding to the year
	********************************************
    import excel using "data\source\crimes-et-delits-enregistres-par-les-services-de-gendarmerie-et-de-police-depuis-2012.xlsx", ///
        sheet("Services PN `year'") firstrow clear
    
    drop in 1/2 // Remove the first two rows.


    * Rename the variables and their labels
	********************************************
	rename Année`year'servicesdepolice code
	rename Départements type_crimes
	
	label variable code "Code du type de crimes"
	label variable type_crimes "Type de crimes"

	* Convert variables to numeric
	********************************************
    local excl_vars "code type_crimes" // Identify the variables to exclude

    * Convert the other variables to numeric, if possible
    foreach var of varlist * {
        if strpos("`excl_vars'", "`var'") == 0 {  // Check if the variable is not in excl_vars
            destring `var', replace force
        }
    }

	* Identify the department variables based on their unique labels, as their names changed during import
	******************************************************************************************************
    local labels ""
    foreach var of varlist * {
        if strpos("`excl_vars'", "`var'") == 0 {  // Exclude code and type_crimes
            local lbl : variable label `var'
            if "`lbl'" != "" & strpos("`labels'", "`lbl'") == 0 {
                local labels "`labels' `lbl'"
            }
        }
    }

    * Create unique variables for each department
	******************************************************
	/*
	In our database, we have several columns corresponding to the same department.
	In this part, we create a unique department variable, which is the sum of all columns where the department label is the same
	*/
    foreach lbl of local labels {
        gen crime_pn`lbl' = 0
        foreach var of varlist * {
            if strpos("`excl_vars'", "`var'") == 0 {  // Exclude code and type_crimes
                local var_label : variable label `var'
                if "`var_label'" == "`lbl'" {
                    replace crime_pn`lbl' = crime_pn`lbl' + `var'
                }
            }
        }
    }

    * Keep only the new variables, as well as code and type_crimes
	****************************************************************************
    keep code type_crimes crime_pn*

	* Reshape
	**********************************************
	reshape long crime_pn, i(code) j(code_dep) string
	
    * Add a year variable
	****************************
    gen year = `year'

    save "data\temp\crime_pn_`year'", replace
}

*Data combine
****************************
clear

forvalues yea = 2012(1)2021{
append using "data\temp\crime_pn_`yea'"
erase "data\temp\crime_pn_`yea'.dta" // Erase temporary files to save some place
}
order code type_crimes code_dep year crime_pn
save "data\temp\crimes_pn_2012_2021", replace
