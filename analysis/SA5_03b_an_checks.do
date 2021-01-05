/*==============================================================================
DO FILE NAME:			SA5_03b_an_checks
PROJECT:				Anticoauglant in COVID-19 
DATE: 					31 Dec 2020 
AUTHOR:					A Wong 						
DESCRIPTION OF FILE:	Check how many people switch exposure status during follow-up
						& the number of event and person-time in two exposure groups
DEPENDENCIES: 
DATASETS USED:			data in memory (from analysis_dataset_`outcome')

DATASETS CREATED: 		analysis_dataset.dta
						lives in folder analysis/$tempdir 
OTHER OUTPUT: 			logfiles, printed to folder analysis/$logdir
							
==============================================================================*/

local global_option `1'

local outcome `2'

do `c(pwd)'/analysis/global_`global_option'.do

* Open a log file===============================================================* 
cap log close

log using $logdir/SA5_03b_an_checks_`outcome', replace t

/* Use the dataset we derived from the S5-02b program=============================*/ 

use $tempdir/analysis_dataset_STSET_`outcome', clear

bysort patient_id: gen switch_count = _N

sort patient_id _t0

duplicates drop patient_id, force

safetab switch_count exposure, m

* warfarin switched to DOACs
safecount if exposure == 1 & switch_count > 1

* DOAC switched to warfarin
safecount if exposure == 0 & switch_count > 1

/* Print table================================================================*/ 
*  Print the results for the main model 

cap file close tablecontent
file open tablecontent using $tabfigdir/table3_`outcome'.txt, write text replace

* Column headings 
file write tablecontent ("Table 3: Time updated exposure Association between current anticoagulant use and `outcome' - $population Population") _n
file write tablecontent _tab ("Number of events") _tab ("Total person-weeks") _tab ("Rate per 1,000") _tab ("Univariable") _tab _tab ("Age/Sex Adjusted") _tab _tab ///
						("DAG Adjusted") _tab _tab ///
						("Fully adjusted") _tab _tab _n
file write tablecontent _tab _tab _tab _tab ("HR") _tab ("95% CI") _tab ("HR") _tab ///
						("95% CI") _tab ("HR") _tab ("95% CI") _tab ("HR") _tab ("95% CI") _n
file write tablecontent ("Main Analysis") _n 					

* Row headings 
local lab0: label exposure 0
local lab1: label exposure 1
 
/* Counts */
 
* First row, exposure = 0 (reference)

	qui safecount if exposure == 0 & `outcome' == 1
	local event = r(N)
	gen _time = _t - _t0
    bysort exposure: egen total_follow_up = total(_time)
	qui su total_follow_up if exposure == 0
	local person_week = r(mean)/7
	local rate = 1000*(`event'/`person_week')
	
	file write tablecontent ("`lab0'") _tab
	file write tablecontent (`event') _tab %10.0f (`person_week') _tab %3.2f (`rate') _tab
	file write tablecontent ("1.00 (ref)") _tab _tab ("1.00 (ref)") ///
	_tab _tab ("1.00 (ref)") _tab _tab ("1.00 (ref)") _n
	
* Second row, exposure = 1 

file write tablecontent ("`lab1'") _tab  

	qui safecount if exposure == 1 & `outcome' == 1
	local event = r(N)
	qui su total_follow_up if exposure == 1
	local person_week = r(mean)/7
	local rate = 1000*(`event'/`person_week')
	file write tablecontent (`event') _tab %10.0f (`person_week') _tab %3.2f (`rate') _tab

/* Main Model */ 
estimates use $tempdir/`outcome'_univar 
lincom 1.exposure, eform
file write tablecontent %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _tab 

estimates use $tempdir/`outcome'_multivar1 
lincom 1.exposure, eform
file write tablecontent %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _tab 

estimates use $tempdir/`outcome'_multivar2  
lincom 1.exposure, eform
file write tablecontent %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _tab 

estimates use $tempdir/`outcome'_multivar3
lincom 1.exposure, eform
file write tablecontent %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _n 

file write tablecontent _n
file close tablecontent


* Close log file 
log close



