/***************************************************************************
***************************************************************************
Objective 2: Compare warfarin vs DOACs
in people with atrial fibrillation
***************************************************************************
======================================================================*/
*set filepaths
global projectdir `c(pwd)'
di "$projectdir"
global outdir "$projectdir/output" 
di "$outdir"
global tempdir_main_analysis "$projectdir/output/warfarin_tempdata" 
di "$tempdir_main_analysis"
global logdir "$projectdir/output/warfarin_log/sens_analysis_3"
di "$logdir"
global tempdir "$projectdir/output/warfarin_tempdata/sens_analysis_3" 
di "$tempdir"
global tabfigdir "$projectdir/output/warfarin_tabfig/sens_analysis_3" 
di "$tabfigdir"

adopath + "$projectdir/analysis/extra_ados"

* Create directories required 
capture mkdir "$outdir/warfarin_tabfig/sens_analysis_3"
capture mkdir "$outdir/warfarin_log/sens_analysis_3"
capture mkdir "$outdir/warfarin_tempdata/sens_analysis_3"

* Set globals that will print in programs and direct output

global population "Obj_2_AF"
global cum_death_ymax 0.1
global dagvarlist i.imd 					///	
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
				  i.antiplatelet            ///
				  i.care_home_residence

global fullvarlist i.imd 					///
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
				   i.immunodef_any		 	///
				   i.cancer     		    ///
				   i.ae_attendance_last_year ///
				   i.gp_consult 			///
				   i.antiplatelet           ///
				   i.care_home_residence
				   
/* SET FU DATES===============================================================*/ 
* Censoring dates for each outcome
* https://github.com/opensafely/rapid-reports/blob/master/notebooks/latest-dates.ipynb
global onscoviddeathcensor   	= "28/09/2020"
global apcscensor           	= "01/10/2020"
global indexdate 			    = "01/03/2020"
global covidtestcensor          = "30/09/2020"
