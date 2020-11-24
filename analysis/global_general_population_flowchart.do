import delimited `c(pwd)'/output/input_general_population_flow_chart.csv, clear

adopath + "$dodir/extra_ados"

*set filepaths
global projectdir `c(pwd)'
di "$projectdir"
global outdir "$projectdir/output" 
di "$outdir"
global logdir "$projectdir/output/oac_log"
di "$logdir"

* Create directories required 
capture mkdir "$outdir/oac_log"

