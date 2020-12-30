/*==============================================================================
DO FILE NAME:			SA1_02c_cr_create_population
PROJECT:				Anticoauglant in COVID-19 
DATE: 					2 Dec 2020 
AUTHOR:					A Wong 						
DESCRIPTION OF FILE:	program 02c, AF population (Objective 1)
						comparing oral anticoagulant use vs general population
						check inclusion/exclusion citeria
						drop patients if not relevant 
						export a csv file (which identified people with AF and oral anticoagulants)
						for matching
DEPENDENCIES: 
DATASETS USED:			data in memory (from analysis_dataset_`outcome')

DATASETS CREATED: 		analysis_dataset.dta
						lives in folder analysis/$tempdir 
OTHER OUTPUT: 			logfiles, printed to folder analysis/$logdir
						input_af_oac in output folder
							
==============================================================================*/

local outcome `1'

local global_option `2'

do `c(pwd)'/analysis/global_`global_option'.do

* Open a log file

cap log close
log using $logdir/SA1_02c_cr_create_population_`outcome', replace t

/* Use the dataset we derived from the 02c program ===========================*/ 

use $tempdir_main_analysis/analysis_dataset_`outcome', clear

* Drop the whole matched set if end of study before index in OAC exposed
noi di "PEOPLE PRESCRIBED ANTIPLATELET IN THE PAST FOUR MONTHS"

gen remove_antiplatelet = 1 if antiplatelet_date != . & exposure == 1
replace remove_antiplatelet = 0  if remove_antiplatelet == .
bysort set_id: egen max_remove_antiplatelet = max(remove_antiplatelet)
drop if max_remove_antiplatelet == 1
drop if antiplatelet_date != . & exposure == 0

/* SAVE DATA==================================================================*/

save $tempdir/analysis_dataset_`outcome', replace

* Save a version set on outcomes
stset stime_`outcome', fail(`outcome') id(patient_id) enter(enter_date) origin(enter_date)	
save $tempdir/analysis_dataset_STSET_`outcome', replace

* Close log file 
log close






