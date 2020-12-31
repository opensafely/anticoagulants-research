/*==============================================================================
DO FILE NAME:			SA5_02b_cr_create_population
PROJECT:				Anticoauglant in COVID-19 
DATE: 					7 Dec 2020 
AUTHOR:					A Wong 						
DESCRIPTION OF FILE:	Based on program 02b, AF population (Objective 2)
						comparing warfarin vs DOACs
						Sensitivity analysis - 
						use time-updated exposure variable (warfarin/DOACs) 
						during the follow-up to evaluate the impact of drug switching
DEPENDENCIES: 
DATASETS USED:			data in memory (from analysis_dataset_`outcome')

DATASETS CREATED: 		analysis_dataset.dta
						lives in folder analysis/$tempdir 
OTHER OUTPUT: 			logfiles, printed to folder analysis/$logdir
							
==============================================================================*/

local outcome `1'

local global_option `2'

do `c(pwd)'/analysis/global_`global_option'.do

* Open a log file===============================================================* 
cap log close

log using $logdir/SA5_02b_cr_create_population_`outcome', replace t

/* Use the dataset we derived from the 02b program=============================*/ 
/* This is used to create a dataset consisting of the last date of follow-up 
which is needed after stset based on exposure status*/

use $tempdir_main_analysis/analysis_dataset_`outcome', clear

keep patient_id stime_`outcome' 

rename stime_`outcome' oac_date_after_mar

save $tempdir/last_date_`outcome', replace

/* Use the dataset we derived from the 02b program=============================*/ 

use $tempdir_main_analysis/analysis_dataset_`outcome', clear

* Reshape dataset from wide to long (warfarin subsequent exposure)

keep patient_id warfarin*

drop warfarin_last_four_months  // remove unnecessary variable

* Destring time-updated variable and convert them to date variable

foreach month in march	///
				 apr	///
				 may	///
				 jun	///
				 jul	///
				 aug	///
				 sep	{
				 	
	foreach order in first ///
					 last  {
					 	
	rename warfarin_`month'_`order' warfarin_`month'_`order'_dstr
	gen warfarin_`month'_`order' = date(warfarin_`month'_`order'_dstr, "YMD")
	drop warfarin_`month'_`order'_dstr
	format warfarin_`month'_`order' %td 
	}
				 }
				 
reshape long warfarin, i(patient_id) j(month) string

rename warfarin oac_date_after_mar

drop month

* remove entries that without subsequent anticoagulant exposure
drop if oac_date_after_mar == .

* remove duplicates for same date in each patient
sort patient_id oac_date_after_mar

duplicates drop patient_id oac_date_after_mar, force

* create a variable indicating warfarin exposure
gen oac = 1

/* SAVE DATA==================================================================*/	
save $tempdir/warfarin_rx_`outcome', replace

/* Use the dataset we derived from the 02b program=============================*/ 
use $tempdir_main_analysis/analysis_dataset_`outcome', clear

* Reshape dataset from wide to long (DOAC subsequent exposure)
keep patient_id  doac*

drop doac_last_four_months  // remove unnecessary variable

* Destring time-updated variable and convert them to date variable

foreach month in march	///
				 apr	///
				 may	///
				 jun	///
				 jul	///
				 aug	///
				 sep	{
				 	
	foreach order in first ///
					 last  {
					 	
	rename doac_`month'_`order' doac_`month'_`order'_dstr
	gen doac_`month'_`order' = date(doac_`month'_`order'_dstr, "YMD")
	drop doac_`month'_`order'_dstr
	format doac_`month'_`order' %td 
	}
				 }
				 
reshape long doac, i(patient_id) j(month) string

rename doac oac_date_after_mar

drop month

* remove entries that without subsequent anticoagulant exposure
drop if oac_date_after_mar == .

* remove duplicates for same date in each patient
sort patient_id oac_date_after_mar

duplicates drop patient_id oac_date_after_mar, force

* create a variable indicating DOAC exposure
gen oac = 0

/* SAVE DATA==================================================================*/	
save $tempdir/doac_rx_`outcome', replace

/* CREATE DATASET ==========================================================*/	
use $tempdir/doac_rx_`outcome', clear

append using $tempdir/warfarin_rx_`outcome'

* keep DOAC record if DOAC and warfarin record on the same date (likely to switch from warfarin to DOACs)
sort patient_id oac_date_after_mar oac
duplicates drop patient_id oac_date_after_mar, force

* remove later records if two records consecutively are the same type of OACs
bysort patient_id: gen oac_lag = oac[_n-1]
drop if oac == oac_lag

drop oac_lag

* add one entry - their end of follow-up (i.e. last date) for each person 
append using $tempdir/last_date_`outcome'

* keep the record of subsequent anticoagulant exposure if it is on the last date
sort patient_id oac_date_after_mar oac
duplicates drop patient_id oac_date_after_mar, force

save $tempdir/oac_rx_`outcome', replace

/* stset the dataset according to exposure status==============================*/

use $tempdir_main_analysis/analysis_dataset_`outcome', clear

merge 1:m patient_id using $tempdir/oac_rx_`outcome', keep(master match) nogen

sort patient_id oac_date_after_mar
bysort patient_id: gen nid = _n

* remove if the first record is the same as the exposure group (i.e. no need to update status)
drop if exposure == 1 & oac == 1 & nid == 1
drop if exposure == 0 & oac == 0 & nid == 1
drop nid

* remove any oac prescription if the date occurred after outcome
drop if oac_date_after_mar > stime_`outcome' 

* reset the outcome status for the time interval fell on the outcome date
replace `outcome' = 0 if stime_`outcome' != oac_date_after_mar

* stset the dataset
stset oac_date_after_mar, fail(`outcome') id(patient_id) enter(enter_date) origin(enter_date) exit(stime_`outcome')

* the exposure status is the one above after stset
sort patient_id oac_date_after_mar	
bysort patient_id: gen oac_after_mar = oac[_n-1]

* the first exposure status is the original assigned exposure group
replace oac_after_mar = exposure if oac_after_mar == .

* label variable of subsequent anticoagulant exposure
label var oac_after_mar "warfarin vs DOACs"

drop warfarin* doac* chadsvas* exposure

/* RENAME EXPOSURE VARIABLE===================================================*/

rename oac_after_mar exposure
cap label drop exposure 
label define exposure 0 "DOAC use" 1 "warfarin use"
label values exposure exposure 

/* SAVE FINAL DATASET=========================================================*/

save $tempdir/analysis_dataset_STSET_`outcome', replace

* Close log file 
log close






