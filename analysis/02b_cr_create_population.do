/*==============================================================================
DO FILE NAME:			02b_cr_create_population
PROJECT:				Anticoauglant in COVID-19 
DATE: 					29 Oct 2020 
AUTHOR:					A Wong (modified from ICS study by A Schultze)							
DESCRIPTION OF FILE:	program 02b, AF population (Objective 2)
						comparing warfarin vs DOACs
						check inclusion/exclusion citeria
						drop patients if not relevant 
DEPENDENCIES: 
DATASETS USED:			data in memory (from analysis/input_af.csv)

DATASETS CREATED: 		analysis_dataset.dta
						lives in folder analysis/$tempdir 
OTHER OUTPUT: 			logfiles, printed to folder analysis/$logdir
							
==============================================================================*/

local outcome `1'

local global_option `2'

do `c(pwd)'/analysis/global_`2'.do

* Open a log file

cap log close
log using $logdir\02b_cr_create_population_`outcome', replace t

/* APPLY INCLUSION/EXCLUIONS==================================================*/ 

use $tempdir\cr_dataset_af , clear

/* RENAME EXPOSURE VARIABLE FOR THIS SEPCIFIC OBJECTIVE==========================*/ 
drop exposure

rename exposure_warfarin exposure

/* APPLY INCLUSION/EXCLUIONS==================================================*/ 
noi di "DROP MISSING GENDER:"
drop if inlist(sex,"I", "U")

noi di "DROP AGE <18:" 
*DONE BY PYTHON

noi di "DROP AGE >110:"
*DONE BY PYTHON

noi di "DROP AGE MISSING:"
*DONE BY PYTHON

noi di "DROP IMD MISSING"
*DONE BY PYTHON

noi di "DROP VALVULAR ATRIAL FIBRILLATION"
drop if valvular_af == 1

noi di "KEEP PEOPLE WHO HAD WARFARIN OR DOAC"
keep if exposure != .

noi di "DROP IF END OF STUDY PERIOD BEFORE INDEX"
drop if stime_`outcome' < date("$indexdate", "DMY")

noi di "DROP PATIENTS WITH ANTIPHOSPHOLIPID SYNDROME"
drop if antiphospholipid_syndrome_date != .

noi di "DROP PATIENTS WITH END STAGE KIDNEY FAILURE"
drop if eskf_exclusion == 1

noi di "PEOPLE PRESCRIBED INJECTABLE ANTICOAGULANT"
drop if lmwh_last_four_months_date != .

/* CHECK INCLUSION AND EXCLUSION CRITERIA=====================================*/ 

* DATA STRUCTURE: Confirm one row per patient 
duplicates tag patient_id, generate(dup_check)
assert dup_check == 0 
drop dup_check

* INCLUSION 1: atrial fibrillation diagnosis before 1 March 2020 (everyone should have a date for this variable)
datacheck af_date != . , nol

* INCLUSION 2: >=18 and <=110 at 1 March 2020 
assert age < .
datacheck age >= 18, nol
datacheck age <= 110, nol
 
* INCLUSION 3: M or F gender at 1 March 2020 
assert inlist(sex, "M", "F")

* INCLUSION 4: PEOPLE PRESCRIBED WARFARIN/DOAC IN THE PAST 4 MONTHS
datacheck exposure == . ,nol

* EXCLUSION 1: 12 months or baseline time 
* [VARIABLE NOT EXPORTED, CANNOT QUANTIFY]

* EXCLUSION 2: MISSING IMD
assert inlist(imd, 1, 2, 3, 4, 5)

* EXCLUSION 3: PATIENTS WITH VALVULAR ATRIAL FIBRILLATION
datacheck valvular_af == ., nol

* EXCLUSION 4: PATIENTS WITH ANTIPHOSPHOLIPID SYNDROME
datacheck antiphospholipid_syndrome_date == ., nol

* EXCLUSION 5: PATIENTS WITH END STAGE RENAL FAILURE
datacheck eskf_exclusion == 0, nol

* EXCLUSION 6: EXCLUDE PEOPLE WITH INJECTABLE ANTICOAGULANT
datacheck lmwh_last_four_months_date == ., nol

*  Drop variables that are needed (those labelled)
ds, not(varlabel)
drop `r(varlist)'

/* SAVE DATA==================================================================*/	

save $tempdir\analysis_dataset_`outcome', replace

* Save a version set on outcomes
stset stime_`outcome', fail(`outcome') id(patient_id) enter(enter_date) origin(enter_date)	
save $tempdir\analysis_dataset_STSET_`outcome', replace

* Close log file 
log close






