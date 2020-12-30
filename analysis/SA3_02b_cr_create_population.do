/*==============================================================================
DO FILE NAME:			SA3_02b_cr_create_population
PROJECT:				Anticoauglant in COVID-19 
DATE: 					7 Dec 2020 
AUTHOR:					A Wong 						
DESCRIPTION OF FILE:	Based on program 02b, AF population (Objective 2)
						comparing warfarin vs DOACs
						Sensitivity analysis - 
						exclude people who were prescribed both warfarin and DOACs 
						on the same day as the latest OAC prescription
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
log using $logdir/SA3_02b_cr_create_population_`outcome', replace t

/* Use the dataset we derived from the 02b program=============================*/ 

use $tempdir_main_analysis/analysis_dataset_`outcome', clear

noi di "PEOPLE PRESCRIBED DOAC AND WARFARIN ON THE SAME DAY (LATEST PRESCRIPTION)"

drop if sens_exposure_warfarin == 2

/* SAVE DATA==================================================================*/	

save $tempdir/analysis_dataset_`outcome', replace

* Save a version set on outcomes
stset stime_`outcome', fail(`outcome') id(patient_id) enter(enter_date) origin(enter_date)	
save $tempdir/analysis_dataset_STSET_`outcome', replace

* Close log file 
log close






