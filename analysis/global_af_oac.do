import delimited `c(pwd)'/output/input_af.csv, clear

adopath + "$dodir/extra_ados"

/***************************************************************************
***************************************************************************
Objective 1: Compare oral anticoagulant treated vs untreated
in people with atrial fibrillation
***************************************************************************
======================================================================*/
*set filepaths
global projectdir `c(pwd)'
di "$projectdir"
global outdir "$projectdir/output" 
di "$outdir"
global logdir "$projectdir/output/oac_log"
di "$logdir"
global tempdir "$projectdir/output/oac_tempdata" 
di "$tempdir"
global tabfigdir "$projectdir/output/oac_tabfig" 
di "$tabfigdir"

* Create directories required 
capture mkdir "$outdir/oac_tabfig"
capture mkdir "$outdir/oac_log"
capture mkdir "$outdir/oac_tempdata"

* Set globals that will print in programs and direct output

global population "Obj_1_AF"
global df 3
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
				  i.antiplatelet            ///
				  i.flu_vaccine 			

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
				   i.antiplatelet           ///
				   i.flu_vaccine 			///
				   i.ckd	 				///		
				   i.copd                   ///
				   i.other_respiratory      ///
				   i.immunodef_any		 	///
				   i.cancer     		    ///
				   i.ae_attendance_last_year ///
				   i.gp_consult 			