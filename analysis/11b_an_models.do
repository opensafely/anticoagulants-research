/*==============================================================================
DO FILE NAME:			11b_an_models
PROJECT:				Anticoagulant in COVID-19 
AUTHOR:					A Wong (modified from ICS study by A Schultze)
DATE: 					3 Mar 2021					
DESCRIPTION OF FILE:	program 11b based on program 05b
						Objective 2: comparing warfarin vs DOACs in people 
						with atrial fibrillation
						After initial run, some parameters didn't converge
						so further investigation
						DAG adjusted regression
						Fully adjusted regression 
						
DATASETS USED:			data in memory ($tempdir/analysis_dataset_STSET_outcome)

DATASETS CREATED: 		none
OTHER OUTPUT: 			logfiles, printed to folder analysis/$logdir
						table7, printed to analysis/$outdir
							
==============================================================================*/

local global_option `1'

do `c(pwd)'/analysis/global_`global_option'.do

* Open a log file

cap log close
log using $logdir/11b_an_models, replace t

/* Outcome: GI bleed death=======================================================*/

* Open Stata dataset
use $tempdir/analysis_dataset_STSET_gi_bleed_ons, clear

* Create new diabetes variable, group Diabetes, no hba1c with uncontrolled diabetes
clonevar diab_control = diabcat
recode diab_control 4=3

* Add checks to outcome count in non-exposed group and the parameters that did not converge
safecount if gi_bleed_ons == 1 & exposure == 1 & diabcat == 4

/* Main Model=================================================================*/

/* Multivariable models */ 

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
				  i.flu_vaccine 			///
				  i.care_home_residence, strata(practice_id)
				  
estimates save $tempdir/11b_gi_bleed_ons_multivar2, replace 	

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
				   i.gp_consult 			///
				   i.care_home_residence, strata(practice_id)
				   
estimates save $tempdir/11b_gi_bleed_ons_multivar3, replace

/* Outcome: Stroke death=======================================================*/

* Open Stata dataset
use $tempdir/analysis_dataset_STSET_stroke_ons, clear

* Create new diabetes variable, group Diabetes, no hba1c with uncontrolled diabetes
clonevar diab_control = diabcat
recode diab_control 4=3

* Add checks to outcome count in non-exposed group and the parameters that did not converge
safecount if stroke_ons == 1 & exposure == 1 & diabcat == 4

safecount if stroke_ons == 1 & exposure == 1 & immunodef_any == 1

/* Main Model=================================================================*/

/* Multivariable models */ 

* DAG adjusted model
* (change to diab_control from main analysis)
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
				  i.flu_vaccine 			///
				  i.care_home_residence, strata(practice_id)
				  
estimates save $tempdir/11b_stroke_ons_multivar2, replace 	

* Fully adjusted model
* (change to diab_control, remove immunodef_any from main analysis)
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
				   i.cancer     		    ///
				   i.ae_attendance_last_year ///
				   i.gp_consult 			///
				   i.care_home_residence, strata(practice_id)
				   
estimates save $tempdir/11b_stroke_ons_multivar3, replace

/* Outcome: MI death=======================================================*/

* Open Stata dataset
use $tempdir/analysis_dataset_STSET_mi_ons, clear

safecount if mi_ons == 1 & exposure == 1 & oestrogen == 1

/* Main Model=================================================================*/

/* Multivariable models */ 

* DAG adjusted model
* (remove oestrogen from main analysis)
stcox i.exposure i.male age1 age2 age3 i.imd ///	
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
				  i.care_home_residence, strata(practice_id)
				  
estimates save $tempdir/11b_mi_ons_multivar2, replace 	

* Fully adjusted model
* (remove oestrogen from main analysis)
stcox i.exposure i.male age1 age2 age3 i.imd ///
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
				   i.care_home_residence, strata(practice_id)
				   
estimates save $tempdir/11b_mi_ons_multivar3, replace


/* Outcome: VTE death=======================================================*/

* Open Stata dataset
use $tempdir/analysis_dataset_STSET_vte_ons, clear

safecount if vte_ons == 1 & exposure == 1 & antiplatelet == 1

safecount if vte_ons == 1 & exposure == 1 & immunodef_any == 1


/* Main Model=================================================================*/

/* Multivariable models */ 

* DAG adjusted model
* (remove antiplatelet from main analysis)
stcox i.exposure i.male age1 age2 age3 i.imd ///	
				  i.obese4cat			    ///
				  i.smoke_nomiss		    ///
				  i.diabcat					///
				  i.myocardial_infarct		///
				  i.pad						///
				  i.hypertension			///		
				  i.heart_failure			///		
				  i.stroke_tia              ///
				  i.vte                     ///
				  i.oestrogen 				///	
				  i.flu_vaccine 			///
				  i.care_home_residence, strata(practice_id)
				  
estimates save $tempdir/11b_vte_ons_multivar2, replace 	

* Fully adjusted model
* (remove antiplatelet & immunodef_any from main analysis)
stcox i.exposure i.male age1 age2 age3 i.imd ///
				   i.obese4cat			    ///
				   i.smoke_nomiss		    ///
				   i.diabcat				///
				   i.myocardial_infarct		///
				   i.pad					///
				   i.hypertension			///		
				   i.heart_failure			///		
				   i.stroke_tia             ///
				   i.vte                    ///
				   i.oestrogen 				///	
				   i.flu_vaccine 			///
				   i.ckd	 				///		
				   i.copd                   ///
				   i.other_respiratory      ///
				   i.cancer     		    ///
				   i.ae_attendance_last_year ///
				   i.gp_consult 			///
				   i.care_home_residence, strata(practice_id)
				   
estimates save $tempdir/11b_vte_ons_multivar3, replace


/* Print table================================================================*/ 
*  Print the results for the main model 

cap file close tablecontent
file open tablecontent using $tabfigdir/table7.txt, write text replace

* Column headings 
file write tablecontent ("Table 7: Association between current anticoagulant use and different outcomes") _n
file write tablecontent _tab ("GI bleed death - DAG adjusted") _tab _tab ///
						("GI bleed death - Fully adjusted") _tab _tab ///
						("Stroke death - DAG Adjusted") _tab _tab ///
						("Stroke death - Fully adjusted") _tab _tab ///
						("MI death - DAG Adjusted") _tab _tab ///
						("MI death - Fully adjusted") _tab _tab ///
						("VTE death - DAG Adjusted") _tab _tab ///
						("VTE death - Fully adjusted") _tab _tab _n
file write tablecontent _tab _tab _tab _tab ("HR") _tab ("95% CI") _tab ///
						("HR") _tab ("95% CI") _tab ///
						("HR") _tab ("95% CI") _tab ///
						("HR") _tab ("95% CI") _tab ///
						("HR") _tab ("95% CI") _tab ///
						("HR") _tab ("95% CI") _tab ///
						("HR") _tab ("95% CI") _tab ///
						("HR") _tab ("95% CI") _n
file write tablecontent ("Main Analysis") _n 					

* Row headings 
local lab0: label exposure 0
local lab1: label exposure 1
 
/* Counts */
 
* First row, exposure = 0 (reference)

	file write tablecontent ("`lab0'") _tab
	file write tablecontent ("1.00 (ref)") _tab _tab ("1.00 (ref)") ///
	_tab _tab ("1.00 (ref)") _tab _tab ("1.00 (ref)") ///
	_tab _tab ("1.00 (ref)") _tab _tab ("1.00 (ref)") ///
	_tab _tab ("1.00 (ref)") _tab _tab ("1.00 (ref)") _n
	
* Second row, exposure = 1 

file write tablecontent ("`lab1'") _tab  

/* Main Model */ 
estimates use $tempdir/11b_gi_bleed_ons_multivar2 
lincom 1.exposure, eform
file write tablecontent %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _tab 

estimates use $tempdir/11b_gi_bleed_ons_multivar3
lincom 1.exposure, eform
file write tablecontent %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _tab 

estimates use $tempdir/11b_stroke_ons_multivar2 
lincom 1.exposure, eform
file write tablecontent %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _tab 

estimates use $tempdir/11b_stroke_ons_multivar3
lincom 1.exposure, eform
file write tablecontent %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _tab 

estimates use $tempdir/11b_mi_ons_multivar2 
lincom 1.exposure, eform
file write tablecontent %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _tab 

estimates use $tempdir/11b_mi_ons_multivar3
lincom 1.exposure, eform
file write tablecontent %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _tab 

estimates use $tempdir/11b_vte_ons_multivar2  
lincom 1.exposure, eform
file write tablecontent %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _tab 

estimates use $tempdir/11b_vte_ons_multivar3
lincom 1.exposure, eform
file write tablecontent %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _n 

file write tablecontent _n
file close tablecontent


* Close log file 
log close












