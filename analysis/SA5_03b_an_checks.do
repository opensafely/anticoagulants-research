/*==============================================================================
DO FILE NAME:			SA5_03b_an_checks
PROJECT:				Anticoauglant in COVID-19 
DATE: 					31 Dec 2020 
AUTHOR:					A Wong 						
DESCRIPTION OF FILE:	Check how many people switch exposure status during follow-up
DEPENDENCIES: 
DATASETS USED:			data in memory (from analysis_dataset_`outcome')

DATASETS CREATED: 		analysis_dataset.dta
						lives in folder analysis/$tempdir 
OTHER OUTPUT: 			logfiles, printed to folder analysis/$logdir
							
==============================================================================*/

local global_option `1'

do `c(pwd)'/analysis/global_`global_option'.do

* Open a log file===============================================================* 
cap log close

log using $logdir/SA5_03b_an_checks, replace t

/* Use the dataset we derived from the S5-02b program=============================*/ 

use $tempdir/analysis_dataset_STSET_onscoviddeath, clear

bysort patient_id: gen switch_count = _N

sort patient_id _t0

duplicates drop patient_id, force

safetab switch_count exposure, m

log close



