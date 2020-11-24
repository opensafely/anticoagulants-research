import delimited `c(pwd)'/output/input_af_population_flow_chart.csv, clear

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

* Create directories required 
capture mkdir "$outdir/oac_log"