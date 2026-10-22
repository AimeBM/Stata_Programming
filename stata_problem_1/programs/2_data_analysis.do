clear

* Data Analysis
*********************
use "data\final\election.dta", clear


* Answer 3-a : Difference in voters between the two rounds
********

sum Inscrits_R1
scalar sum_Inscrits_R1 = r(sum)
	*Total number of registered voters in the first round of the election

sum Inscrits_R2
scalar sum_Inscrits_R2 = r(sum)
	*Total number of registered voters in the 2nd round of the election

scalar Difference_Inscrits = sum_Inscrits_R2 - sum_Inscrits_R1
	*Difference in voters between the two rounds
di Difference_Inscrits

/*
Yes, the number of voters decreased by an average of 13,652 registered voters for the second round across mainland France.
*/


* Answer 2 : The departments in which Le Pen received the 5 highest vote shares
********
gsort -LE_PEN_vote_shares_R2
list departement LE_PEN_vote_shares_R2 in 1/5
	*Sort the data in descending order and display the list

graph hbar LE_PEN_vote_shares_R2 in 1/5, over(departement, sort(1) descending)
	*The chart of the departments in which Le Pen received the 5 highest vote shares

/*
The departments in which Le Pen received the 5 highest vote shares are:
	- Aisne with 52.91% of the votes;
	- Pas-de-Calais with 52.06% of the votes;
	- Var with 49.52% of the votes;
	- Haute-Marne with 49.41% of the votes and
	- Ardennes with 49.27% of the votes.
*/	
	
* Answer 3 : The department where turnout varied the most between the two rounds, and the 3 departments where turnout varied the least.
********
gen variation = abs(change_turnout)
	*Express the variations in absolute terms to answer the question.
	
gsort -variation
list departement variation if _n==1
	*The highest variation
	
** The department with the highest variation between the two rounds is Martinique, with a variation of 10.375%.
	
sort variation
list departement variation in 1/3
graph hbar variation in 1/3, over(departement, sort(1))
	*The 3 smallest variations
/*
The 3 departments with smallest variations are :
	- Saint-Pierre-et-Miquelon with 1.06% ;
	- Haute-Saône with 1.29% et
	- Territoire de Belfort with 1.67% 
*/
	
* Answer 4 :  the national (aggregate) result of the (second round) vote
********
sum Votants_R2
scalar Votants_2 = r(sum)
	*Total number of voters in the second round

scalar Voix_Votants = round(Votants_2 * 100 / sum_Inscrits_R2, 0.01)
	*Percentage of voters
di "Percentage of voters = " Voix_Votants "%"

sum Exprimés_R2
scalar Exprimes_2 = r(sum)
	*Total number of Exprimés in the second round

scalar Voix_Exprimes = round(Exprimes_2 * 100 / Votants_2, 0.01)
	*Percentage of Exprimés
di "Percentage of Exprimés = " Voix_Exprimes "%"

sum LE_PEN_VOIX_R2
scalar LE_PEN_VOIX_Total2 = r(sum)
	*Total number of voters in the second round for LE PEN

scalar LE_PEN_VOIX_2 = round(LE_PEN_VOIX_Total2 * 100 / Exprimes_2, 0.01)
	*Percentage of voters for LE PEN
di "Percentage of voters for LE PEN = " LE_PEN_VOIX_2 "%"

sum MACRON_VOIX_R2
scalar MACRON_Voix_Total2 = r(sum)
	*Total number of voters in the second round for MACRON

scalar MACRON_VOIX_2 = round(MACRON_Voix_Total2 * 100 / Exprimes_2, 0.01)
	*Percentage of voters for MACRON
di "Percentage of voters for MACRON = " MACRON_VOIX_2 "%"

*CONCLUSION
*******
/*
75.35% of the registered voters in the second round of the 2017 presidential election cast their votes. Among them, 88.36% expressed a choice. Therefore, the newly elected president following this election is Emmanuel MACRON with 65.68% of the votes, while Marine LE PEN received 34.32% of the votes.
*/