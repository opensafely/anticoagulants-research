/*==============================================================================
DO FILE NAME:			02c_cr_create_population
PROJECT:				Anticoauglant in COVID-19 
DATE: 					6 Nov 2020 
AUTHOR:					A Wong 						
DESCRIPTION OF FILE:	program 02c, AF population (Objective 1)
						comparing oral anticoagulant use vs general population`'
						check inclusion/exclusion citeria
						drop patients if not relevant 
						export a csv file (which identified people with AF and oral anticoagulants)
						for matching
DEPENDENCIES: 
DATASETS USED:			data in memory (from analysis/input_af.csv)

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
log using $logdir/02c_cr_create_population_`outcome', replace t

/* APPLY INCLUSION/EXCLUIONS in the general population cohort (control cohort) ===============================*/ 

noi di "DROP AGE <18:" 
*DONE BY PYTHON

noi di "DROP AGE >110:"
*DONE BY PYTHON

noi di "DROP AGE MISSING:"
*DONE BY PYTHON

noi di "DROP MISSING GENDER:"
*DONE BY PYTHON

noi di "DROP IMD MISSING"
*DONE BY PYTHON

noi di "DROP PEOPLE WHO HAD NO GP CONSULTATION IN THE PAST YEAR"
*DONE BY PYTHON

noi di "DROP ATRIAL FIBRILLATION:"
*DONE BY PYTHON

noi di "PEOPLE PRESCRIBED INJECTABLE ANTICOAGULANT IN THE PAST FOUR MONTHS"
*DONE BY PYTHON

noi di "PEOPLE PRESCRIBED WARFARIN IN THE PAST FOUR MONTHS"
*DONE BY PYTHON

noi di "PEOPLE PRESCRIBED DOACs IN THE PAST FOUR MONTHS"
*DONE BY PYTHON

/* CHECK INCLUSION AND EXCLUSION CRITERIA=====================================*/ 

* DATA STRUCTURE: Confirm one row per patient 
duplicates tag patient_id, generate(dup_check)
assert dup_check == 0 
drop dup_check

* INCLUSION 2: >=18 and <=110 at 1 March 2020 
assert age < .
datacheck age >= 18, nol
datacheck age <= 110, nol
 
* INCLUSION 3: M or F gender at 1 March 2020 
assert inlist(sex, "M", "F")

* EXCLUSION 1: 12 months or baseline time 
* [VARIABLE NOT EXPORTED, CANNOT QUANTIFY]

* EXCLUSION 2: MISSING IMD
assert inlist(imd, 1, 2, 3, 4, 5)

* EXCLUSION 3: NO GP VISIT IN THE PAST YEAR
datacheck gp_consult_count>0, nol

* EXCLUSION 4: no atrial fibrillation diagnosis before 1 March 2020 
datacheck af_date == . , nol

* EXCLUSION 5: EXCLUDE PEOPLE WITH INJECTABLE ANTICOAGULANT
datacheck lmwh_last_four_months_date == ., nol

* EXCLUSION 6: EXCLUDE PEOPLE WITH WARFARIN 
datacheck warfarin_last_four_months == . , nol

* EXCLUSION 6: EXCLUDE PEOPLE WITH DOACs 
datacheck doac_last_four_months == . , nol

/* SAVE DATA==================================================================*/
save $outdir/matched_control_`outcome'.dta , replace

/* Combine the case cohort after matching==================================*/	
* Exposed cohort after matching
import delimited $outdir/af_oac_only_matched_to_general_population.csv, clear
safecount

* Append the matched case cohort
append using $outdir/matched_control_`outcome'.dta

rename case exposure 
sort set_id patient_id

safecount

* Drop the whole matched set if end of study before index in OAC exposed
noi di "DROP IF END OF STUDY PERIOD BEFORE INDEX"

gen remove_invalid_period = 1 if stime_`outcome' < date("$indexdate", "DMY") & exposure == 1
replace remove_invalid_period = 0  if remove_invalid_period == .
bysort setid: egen max_remove_invalid_period = max(remove_invalid_period)
drop if max_remove_invalid_period == 1
drop if stime_`outcome' < date("$indexdate", "DMY") & exposure == 0

/* LABEL VARIABLE==================================================================*/
label var set_id				"Matched setid = patient_id of the case"
label var exposure				"Variable indicating the exposure status"

*  Drop variables that are needed (those labelled)
ds, not(varlabel)
drop `r(varlist)'

/* SAVE DATA==================================================================*/
save $tempdir/analysis_dataset_`outcome', replace

* Save a version set on outcomes
stset stime_`outcome', fail(`outcome') id(patient_id) enter(enter_date) origin(enter_date)	
save $tempdir/analysis_dataset_STSET_`outcome', replace

* Close log file 
log close






