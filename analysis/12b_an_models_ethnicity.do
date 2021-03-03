/*==============================================================================
DO FILE NAME:			12b_an_models_ethnicity
PROJECT:				Anticoagulant in COVID-19 
DATE: 					3 Mar 2021
AUTHOR:					A Wong 		
DESCRIPTION OF FILE:	program 12b, based on program 06b
						restrict to known ethnicity (complete case analysis)
						to fix parameters not being converged
						Objective 1: comparing treated and untreated people 
						with atrial fibrillation 
DATASETS USED:			data in memory ($tempdir/analysis_dataset_STSET_outcome)

DATASETS CREATED: 		none
OTHER OUTPUT: 			logfiles, printed to folder analysis/$logdir
						table8_`outcome', printed to analysis/$outdir
==============================================================================*/

local outcome `1'

local global_option `2'

global reviseddagvarlist i.imd 				///	
				  i.obese4cat			    ///
				  i.smoke_nomiss		    ///
				  i.diabcat					///
				  i.myocardial_infarct		///
				  i.pad						///
				  i.hypertension			///		
				  i.heart_failure			///		
				  i.stroke_tia              ///
				  i.vte                     ///	
				  i.antiplatelet            ///
				  i.flu_vaccine 			///
				  i.care_home_residence

global revisedfullvarlist i.imd 			///
				   i.obese4cat			    ///
				   i.smoke_nomiss		    ///
				   i.diabcat				///
				   i.myocardial_infarct		///
				   i.pad					///
				   i.hypertension			///		
				   i.heart_failure			///		
				   i.stroke_tia             ///
				   i.vte                    ///	
				   i.antiplatelet           ///
				   i.flu_vaccine 			///
				   i.ckd	 				///		
				   i.copd                   ///
				   i.other_respiratory      ///
				   i.immunodef_any		 	///
				   i.cancer     		    ///
				   i.ae_attendance_last_year ///
				   i.gp_consult 			///
				   i.care_home_residence
				   
do `c(pwd)'/analysis/global_`global_option'.do

* Open a log file

cap log close
log using $logdir/06b_an_models_ethnicity_`outcome', replace t

* Open Stata dataset
use $tempdir/analysis_dataset_STSET_`outcome', clear

/* Restrict population========================================================*/ 

preserve 
drop if ethnicity == .u

/* Main Model=================================================================*/

* DAG adjusted WITH ETHNICITY
stcox i.exposure i.male age1 age2 age3  $reviseddagvarlist   ///
										i.ethnicity, strata(practice_id)	
										
estimates save $tempdir/12b_`outcome'_multivar2_ethn, replace 

* DAG adjusted WITHOUT ETHNICITY
stcox i.exposure i.male age1 age2 age3 $reviseddagvarlist , strata(practice_id)	
										
estimates save $tempdir/12b_`outcome'_multivar2_withoutethn, replace 

* Fully adjusted WITH ETHNICITY
stcox i.exposure i.male age1 age2 age3 $revisedfullvarlist   ///
									   i.ethnicity, strata(practice_id)		
										
estimates save $tempdir/12b_`outcome'_multivar3_ethn, replace 

* Fully adjusted WITHOUT ETHNICITY
stcox i.exposure i.male age1 age2 age3 $revisedfullvarlist , strata(practice_id)		
										
estimates save $tempdir/12b_`outcome'_multivar3_withoutethn, replace 

/* Print table================================================================*/ 
*  Print the results for the main model 

cap file close tablecontent
file open tablecontent using $tabfigdir/table8_`outcome'.txt, write text replace

* Column headings 
file write tablecontent ("Table 8: Association between current anticoagulant use and `outcome' - $population Population, restrict to known ethnicity") _n
file write tablecontent _tab ("DAG Adjusted with ethnicity") _tab _tab ///
						("DAG Adjusted without ethnicity") _tab _tab ///
						("Fully Adjusted with ethnicity") _tab _tab ///
						("Fully Adjusted without ethnicity") _tab _tab ///
						_n
file write tablecontent _tab _tab _tab _tab ("HR") _tab ("95% CI") _tab ("HR") _tab ///
						("95% CI") _tab ("HR") _tab ("95% CI") _tab ///
						("HR") _tab ("95% CI") _n
file write tablecontent ("Main Analysis") _n 					

* Row headings 
local lab0: label exposure 0
local lab1: label exposure 1
 
* First row, exposure = 0 (reference)

	file write tablecontent ("`lab0'") _tab
	file write tablecontent ("1.00 (ref)") _tab _tab ("1.00 (ref)") ///
	_tab _tab ("1.00 (ref)") _tab _tab ("1.00 (ref)") _n
	
* Second row, exposure = 1 

file write tablecontent ("`lab1'") _tab  

/* Main Model */ 
estimates use $tempdir/12b_`outcome'_multivar2_ethn
lincom 1.exposure, eform
file write tablecontent %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _tab

estimates use $tempdir/12b_`outcome'_multivar2_withoutethn
lincom 1.exposure, eform
file write tablecontent %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _tab

estimates use $tempdir/12b_`outcome'_multivar3_ethn
lincom 1.exposure, eform
file write tablecontent %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _tab 

estimates use $tempdir/12b_`outcome'_multivar3_withoutethn
lincom 1.exposure, eform
file write tablecontent %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _n 

file write tablecontent _n
file close tablecontent

restore 

* Close log file 
log close












