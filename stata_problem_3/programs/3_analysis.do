clear

***************************************************
* ANSWER TO QUESTIONS
***************************************************

use "data/final/WVS_growth.dta", clear

* a- Using ordinary least squares, estimate the cross-section relationship between trust in people and in institutions, on the one side, and GDP growth, on the other side.
***************************************************************************
regress gdp_growth people armed_forces police courts
estimates store reg_linear

/*
The model is not significant at the 5% threshold.
But considering the R², the model explains only 4.24% of the variations in growth per capita GDP_hbt.
Owever,the adjusted R² indicates that the model fails to capture the variations in growth per capita GDP_hbt.
*/

* b- Estimate the same model, complemented with country-level fixed effects
******************************************************************
areg gdp_growth people armed_forces police courts, absorb(country)
estimates store reg_linear_country_fixed

/*
The model is not significant at the 5% threshold.
But considering the R², the model explains only 61.85% of the variations in growth per capita GDP_hbt.
Owever,the adjusted R² indicates that the model explains only 16.29% of the variations in growth per capita GDP_hbt.
*/

* c- Compare the two models
************************************
hausman reg_linear_country_fixed reg_linear

/*
At the 5% significance level, there are no significant differences in the coefficients between the two regressions.
However, the fixed-effects model captures more variations than the simple model.
*/

* d-  Add the measure of education as supplementary explanatory variable in both models.
**************************************************************
regress gdp_growth people armed_forces police courts education*
estimates store reg_linear2

/*
The model is not significant at the 5% threshold.
But considering the R², the model explains only 5.31% of the variations in growth per capita GDP_hbt.
Owever,the adjusted R² indicates that the model fails to capture the variations in growth per capita GDP_hbt.
*/

areg gdp_growth people armed_forces police courts education*, absorb(country)
estimates store reg_linear_country_fixed2

/*
The model is not significant at the 5% threshold.
But considering the R², the model explains only 63.59% of the variations in growth per capita GDP_hbt.
Owever,the adjusted R² indicates that the model explains only 15.40% of the variations in growth per capita GDP_hbt.
*/

hausman reg_linear_country_fixed2 reg_linear2
			
/*
At the 5% significance level, there are no significant differences in the coefficients between the two regressions.
However, the fixed-effects model captures more variations than the simple model.
*/

* e- Export all estimations' results in LATEX.tex and Excel (.xls) formats.
***************************************************
esttab reg_linear reg_linear_country_fixed reg_linear2 reg_linear_country_fixed2 using "out/est_results.tex", replace ///
    se b(3) se(3) label ///
    title("Estimations pour reg_linear et reg_linear_country_fixed") ///
    stats(N p r2 r2_a, labels("N" "P-value" "R-squared" "Adj R-squared")) ///
	nobaselevels noomitted


estout reg_linear reg_linear_country_fixed reg_linear2 reg_linear_country_fixed2 using "out/est_results.xls", ///
    cells(b(star fmt(%9.3f)) se(par) label) ///
    stats(N p r2 r2_a, labels("N" "P-value" "R-squared" "Adj R-squared")) ///
    legend label collabels(none) varlabels(_cons Constant) ///
    nobaselevels noomitted ///
	replace


* 5- Per capita GDP by Year for countries in each quartile of the distribution of the index of trust in institutions
****************************************************************************
use "data/temp/gdp_quartile.dta", clear

twoway ///
    (line GDP_hbt year if quartile == 1, lcolor(blue)) ///
    (line GDP_hbt year if quartile == 2, lcolor(red)) ///
    (line GDP_hbt year if quartile == 3, lcolor(green)) ///
    (line GDP_hbt year if quartile == 4, lcolor(orange)), ///
    legend(label(1 "Countries of Index Quartile 1") ///
           label(2 "Countries of Index Quartile 2") ///
           label(3 "Countries of Index Quartile 3") ///
           label(4 "Countries of Index Quartile 4") size(2.5)) ///
    title("Per capita GDP by Year for countries in each quartile of the distribution of the index of trust in institutions", size(2.5)) ///
    xlabel(, angle(45)) ///
    ylabel(, grid) ///
    xtitle("Year", size(2.5)) ///
    ytitle("Per capita GDP", size(2.5))

	
graph export "out/GDP_quartile.png", replace

graph save "Graph" "out\GDP_quartile.gph", replace


* Bonus. Using the World Values Survey, explore (with estimations, tests and illustrative graphics) how trust in people varies with individual income.
***********************************************************
use "data/temp/WVS.dta", clear

* Tableau et test
*************************************
log using "out/scale_incomes_people.txt", text replace

tab scale_incomes people , col nofreq chi2 

log close

/*
At the 5% significance level, there is a relationship between trust in people and income levels.
*/

* Estimation
*************************************
logit people i.scale_incomes
eststo model_logit

margins, dydx(*)

marginsplot
graph save "Graph" "out\margins_income.gph", replace
graph export "out/margins_income.png", replace


esttab model_logit using "out/sacale_income_people_result.xls", replace ///
    se b(3) se(3) label ///
    title("Estimations pour le modèle logit et les effets marginaux") ///
    stats(N chi2 p r2_p, labels("Number of obs" "LR chi2(9)" "Prob > chi2" "Pseudo R2")) ///
    addnotes("Effets marginaux calculés pour scale_incomes") ///
    nobaselevels noomitted


* Estimation fixed country
*************************************
/*
Nous avons voulu faire le modèle ogit fixé au pays mais il n'y a pas assez de vraiations de la variable d'intérêt dans chaque pays
*/
gen id = _n
xtset id country
clogit people i.scale_incomes, group(id)


