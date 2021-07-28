/*==============================================================================
DO FILE NAME:			posthoc3_02b_cr_create_population
PROJECT:				Anticoauglant in COVID-19 
DATE: 					26 July 2021
AUTHOR:					A Wong 
DESCRIPTION OF FILE:	Based on program 02b, AF population (Objective 2)
						comparing warfarin vs DOACs
						post-hoc analysis - restrict the study cohort to people with positive covid tests
DEPENDENCIES: 
DATASETS USED:			data in memory (from analysis_dataset_`outcome')

DATASETS CREATED: 		analysis_dataset.dta
						lives in folder analysis/$tempdir 
OTHER OUTPUT: 			logfiles, printed to folder analysis/$logdir
							
==============================================================================*/

local outcome `1'

local global_option `2'

do `c(pwd)'/analysis/global_`global_option'.do

* Open a log file

cap log close
log using $logdir/posthoc3_02b_cr_create_population_`outcome', replace t

/* Use the dataset we derived from the 02b program=============================*/ 

use $tempdir_main_analysis/analysis_dataset_`outcome', clear

* Only keep people with positive test result
noi di "PEOPLE WITH POSITIVE COVID TESTS"
keep if positivecovidtest == 1

safecount

/* SAVE DATA==================================================================*/	

save $tempdir/analysis_dataset_`outcome', replace

* Save a version set on outcomes
stset stime_`outcome', fail(`outcome') id(patient_id) enter(first_positive_test_date) origin(first_positive_test_date)	

* Update the latest exposure status (closest to positive test date)
drop exposure 

* Merge the time-updated exposure dataset from sensitivity analysis 5 to update exposure
* See SA5_02b_cr_create_population.do

merge 1:m patient_id using "$projectdir/output/warfarin_tempdata/sens_analysis_5/analysis_dataset_STSET_`outcome'", ///
 keep(match) keepusing(oac_date_after_mar exposure) nogen

* Sort the time sequence of OAC prescription within each patient

* Generate the prescription start date for each observation of time-updated exposure
sort patient_id oac_date_after_mar
bysort patient_id: gen rxst = oac_date_after_mar[_n-1]
replace rxst = enter_date if rxst == .
format rxst %td

* Drop any prescription received after first positive test date
drop if first_positive_test - rxst < 0

* Generate distance between positive covid test date and the latest date of OAC prescription
gen distance = first_positive_test_date - rxst 
bysort patient_id: egen min_distance = min(distance)

* Keep the record of prescription closest to the positive covid test date
keep if distance == min_distance

* Erase unnecessary variables
drop distance min_distance

* Save final dataset
save $tempdir/analysis_dataset_STSET_`outcome', replace

* Close log file 
log close






