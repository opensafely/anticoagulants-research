/*==============================================================================
DO FILE NAME:			11a_an_models
PROJECT:				Anticoagulant in COVID-19 
AUTHOR:					A Wong (modified from ICS study by A Schultze)
DATE: 					2 Mar 2021					
DESCRIPTION OF FILE:	program 11a based on program 05a
						Objective 1: comparing treated and untreated people 
						with atrial fibrillation
						After initial run, some parameters didn't converge
						so further investigation
						DAG adjusted regression
						Fully adjusted regression 
DATASETS USED:			data in memory ($tempdir/analysis_dataset_STSET_outcome)

DATASETS CREATED: 		none
OTHER OUTPUT: 			logfiles, printed to folder analysis/$logdir
						table8, printed to analysis/$outdir
							
==============================================================================*/

local global_option `1'

do `c(pwd)'/analysis/global_`global_option'.do

* Open a log file

cap log close
log using $logdir/11a_an_models, replace t

/* Outcome: admitcovid========================================================*/

* Open Stata dataset
use $tempdir/analysis_dataset_STSET_admitcovid, clear

* Create new diabetes variable, group Diabetes, no hba1c with uncontrolled diabetes
clonevar diab_control = diabcat
recode diab_control 4=3

* Add checks to outcome count in non-exposed group and the parameters that did not converge
safecount if admitcovid == 1 & exposure == 0 & diabcat == 4

* DAG adjusted model (change to diab_control from main analysis)
stcox i.exposure i.male age1 age2 age3 i.imd ///	
				  i.obese4cat			    ///
				  i.smoke_nomiss		    ///
				  i.diab_control			///
				  i.myocardial_infarct		///
				  i.pad						///
				  i.hypertension			///		
				  i.heart_failure			///		
				  i.stroke_tia              ///
				  i.vte                     ///
				  i.oestrogen 				///	
				  i.antiplatelet            ///
				  i.flu_vaccine 			
				  
estimates save $tempdir/11a_admitcovid_multivar2, replace 	

* Fully adjusted model (change to diab_control from main analysis)
stcox i.exposure i.male age1 age2 age3 i.imd ///
				   i.obese4cat			    ///
				   i.smoke_nomiss		    ///
				   i.diab_control			///
				   i.myocardial_infarct		///
				   i.pad					///
				   i.hypertension			///		
				   i.heart_failure			///		
				   i.stroke_tia             ///
				   i.vte                    ///
				   i.oestrogen 				///	
				   i.antiplatelet           ///
				   i.flu_vaccine 			///
				   i.ckd	 				///		
				   i.copd                   ///
				   i.other_respiratory      ///
				   i.immunodef_any		 	///
				   i.cancer     		    ///
				   i.ae_attendance_last_year ///
				   i.gp_consult , strata(practice_id)
				   
estimates save $tempdir/11a_admitcovid_multivar3, replace

/* Outcome: onscoviddeath=====================================================*/

* Open Stata dataset
use $tempdir/analysis_dataset_STSET_onscoviddeath, clear

* Create new diabetes variable, group Diabetes, no hba1c with uncontrolled diabetes
clonevar diab_control = diabcat
recode diab_control 4=3

* Add checks to outcome count in non-exposed group and the parameters that did not converge
safecount if onscoviddeath == 1 & exposure == 0 & diabcat == 4

safecount if onscoviddeath == 1 & exposure == 0 & stroke_tia == 1

safecount if onscoviddeath == 1 & exposure == 0 & oestrogen == 1

* DAG adjusted model 
* (change to diab_control, remove stroke_tia and oestrogen from main analysis)
stcox i.exposure i.male age1 age2 age3 i.imd ///	
				  i.obese4cat			    ///
				  i.smoke_nomiss		    ///
				  i.diab_control			///
				  i.myocardial_infarct		///
				  i.pad						///
				  i.hypertension			///		
				  i.heart_failure			///		
				  i.vte                     ///
				  i.antiplatelet            ///
				  i.flu_vaccine 			
				  
estimates save $tempdir/11a_onscoviddeath_multivar2, replace 	

* Fully adjusted model
* (change to diab_control, remove stroke_tia and oestrogen from main analysis)
stcox i.exposure i.male age1 age2 age3 i.imd ///
				   i.obese4cat			    ///
				   i.smoke_nomiss		    ///
				   i.diab_control			///
				   i.myocardial_infarct		///
				   i.pad					///
				   i.hypertension			///		
				   i.heart_failure			///		
				   i.vte                    ///
				   i.antiplatelet           ///
				   i.flu_vaccine 			///
				   i.ckd	 				///		
				   i.copd                   ///
				   i.other_respiratory      ///
				   i.immunodef_any		 	///
				   i.cancer     		    ///
				   i.ae_attendance_last_year ///
				   i.gp_consult , strata(practice_id)
				   
estimates save $tempdir/11a_onscoviddeath_multivar3, replace

/* Print table================================================================*/ 
*  Print the results for the main model 

cap file close tablecontent
file open tablecontent using $tabfigdir/table8.txt, write text replace

* Column headings 
file write tablecontent ("Table 8: Association between current anticoagulant use and different outcomes") _n
file write tablecontent _tab ("admitcovid - DAG adjusted") ///
		_tab _tab ("admitcovid - Fully adjusted") ///
		_tab _tab ("Covid death - DAG Adjusted") _tab _tab ///
		("Covid death - Fully adjusted") _tab _tab _n
file write tablecontent _tab _tab _tab _tab ("HR") _tab ("95% CI") _tab ("HR") _tab ///
						("95% CI") _tab ("HR") _tab ("95% CI") _tab ("HR") _tab ("95% CI") _n
file write tablecontent ("Main Analysis") _n 					

* Row headings 
local lab0: label exposure 0
local lab1: label exposure 1
 
/* Counts */
 
* First row, exposure = 0 (reference)

	file write tablecontent ("`lab0'") _tab
	file write tablecontent ("1.00 (ref)") _tab _tab ("1.00 (ref)") ///
	_tab _tab ("1.00 (ref)") _tab _tab ("1.00 (ref)") _n
	
* Second row, exposure = 1 
file write tablecontent ("`lab1'") _tab  

/* Main Model */ 
estimates use $tempdir/11a_admitcovid_multivar2
lincom 1.exposure, eform
file write tablecontent %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _tab 

estimates use $tempdir/11a_admitcovid_multivar3
lincom 1.exposure, eform
file write tablecontent %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _tab 

estimates use $tempdir/11a_onscoviddeath_multivar2  
lincom 1.exposure, eform
file write tablecontent %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _tab 

estimates use $tempdir/11a_onscoviddeath_multivar3
lincom 1.exposure, eform
file write tablecontent %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _n 

file write tablecontent _n
file close tablecontent


* Close log file 
log close












