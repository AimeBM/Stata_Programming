clear

* Data Analysis
*********************
use "data\final\crime_2012_2021.dta", clear

*Limit the analysis to metropolitan France
*************************************************
drop if code_dep == "971" | code_dep == "972" | code_dep == "973" | code_dep == "974" | code_dep == "976"


* Answer 5-a : The 3 departments with the highest total number of crimes that relate to thefts (vols)
********

	* Step 1 : Create an indicator variable for crimes related to thefts (vols) and recel
	****************************************************************
	gen is_target = strpos(lower(type_crimes), "vols") > 0 | strpos(lower(type_crimes), "recels")>0 | strpos(lower(type_crimes), "vol") > 0 | strpos(lower(type_crimes), "recel")>0

	save "data\temp\my_analysis_a_b.dta", replace // Save my analysis data to permit me to answer to questions a and b

	* Step 2 : Aggregate the total_crime by department for crimes related to thefts (vols and recel)
	**************************************************
	use "data\temp\my_analysis_a_b.dta", clear
	collapse (sum) total_crime if is_target == 1, by(departement code_dep)

	* Step 3 : Sort the departments by descending sum and list the top three departments
	************************************************************
	gsort -total_crime // Sort the departments by descending sum

	list code_dep departement total_crime in 1/3 // List the top three departments


	* Step 4 : ANSWER
	**********************************************
	/*
	The 3 departments with the highest total number of crimes that relate to thefts are :
			Nom					Code     Total des crimes
										de vols et recels
		1- Paris    			 75				1613828
		2- Bouches-du-Rhône      13				851226
		3- Nord     			 59				799473 
	*/

* Answer 5-b : Plot the yearly series of theft-related crimes in these 3 départements and in 2 other randomly selected départements.
********

	* Step 1 : Aggregate the total_crime by department for crimes related to thefts (vols and recel)
	use "data\temp\my_analysis_a_b.dta", clear
	collapse (sum) total_crime if is_target == 1, by(departement code_dep year)

	* Step 2 : Create the graph
	********************************************************

	* The graph is for the top 5 departments with the highest number of crimes related to thefts (vols) and receiving stolen goods (recel)

	twoway (line total_crime year if departement == "Paris", lcolor(blue)) ///
		   (line total_crime year if departement == "Bouches-du-Rhône", lcolor(red)) ///
		   (line total_crime year if departement == "Nord", lcolor(green)) ///
		   (line total_crime year if departement == "Seine-St-Denis", lcolor(orange)) ///
		   (line total_crime year if departement == "Rhône", lcolor(purple)), ///
		   legend(label(1 "Paris") label(2 "Bouches-du-Rhône") label(3 "Nord") label(4 "Seine-St-Denis") label(5 "Rhône")) ///
		   title("Total Crime by Year for Selected Departments" , size(4)) ///
		   xlabel(, angle(45)) ylabel(, grid) ///
		xtitle("Year") ytitle("Crimes related to thefts")

	graph save "Graph" "out\Number_crimes related to thefts by Year for five departements where is highest.gph", replace


* Answer 5-c : The 10 departements with the highest average crime rate (i.e., number of all crimes normalized by population)?
*********************************************

	* Step 1 : Aggregate the total_crime by department and year
	******************
	use "data\temp\my_analysis_a_b.dta", clear
	collapse (sum) total_crime , by(departement code_dep year)

	* Step 2 : Merge the aggregated data with the population data
	******************************************
	merge 1:1 code_dep year using "data\temp\pop_fr.dta",

	keep if _merge == 3 // Keep only the data from the crime database (i.e., from 2012 onwards)

	drop _merge

	save "data\temp\my_analysis_c_d.dta", replace // Save my analysis data to permit me to answer to questions c and d

	* Step 3 : Create the crime rate variable and aggregate the data to obtain the average crime rate
	******************************
	use "data\temp\my_analysis_c_d.dta", clear
	gen crime_rate = total_crime * 1000 / population // Crime rate per thousand (‰)

	collapse(mean) crime_rate, by(departement code_dep) // We used the arithmetic mean

	* Step 4 : Sort the departments by descending mean and list the top three departments
	gsort -crime_rate
	 
	list departement crime_rate in 1/10

	* Step 5 : ANSWER
	**********************************************
	/*
	The 10 departements with the highest average crime rate are :

		1- Paris   			119.99 ‰
		2- Seine-St-Denis   87.06 ‰
		3- Bouches-du-Rhône 76.74 ‰
		4- Rhône   			69.61 ‰
		5- Alpes-Maritimes  69.30 ‰
		6- Val-d'Oise   	66.82 ‰
		7- Hauts-de-Seine   66.10 ‰
		8- Hérault   		64.61 ‰
		9- Haute-Garonne   	64.52 ‰
		10- Val-de-Marne   	64.45 ‰

	*/


* Answer 5-d : Plot the national-level yearly series of all crimes, both in numbers and normalized by population
************************************************************************

	* Step 1 : Aggregate the total_crime and population by year
	*************************
	use "data\temp\my_analysis_c_d.dta", clear
	collapse (sum) total_crime population , by(year)

	* Step 2 : Create the crime rate variable
	************************
	gen crime_rate = total_crime * 1000 / population // Crime rate per thousand (‰)

	* Step 3 : Plot the national-level yearly series of all crimes in numbers
	****************************
	line total_crime year, title("Total Crime by Year", size(4)) ///
		xtitle("Year") ytitle("Total Crime")


	graph save "Graph" "out\Plot the national-level yearly series of all crimes in numbers.gph", replace

	* Step 4 : Plot the national-level yearly series of all crimes in normalized by population
	*************************************
	line crime_rate year, title("Crime Rate by Year", size(4)) ///
		xtitle("Year") ytitle("Crime  (‰)")
		
	graph save "Graph" "out\Plot the national-level yearly series of crime rate.gph", replace

