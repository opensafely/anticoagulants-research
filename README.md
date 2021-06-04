# OpenSAFELY Association between routine use of oral anticoagulants and COVID-19 related outcomes

This is the code and configuration of our pre-print paper available on MedRxiv [here](https://www.medrxiv.org/content/10.1101/2021.04.30.21256119v1). You can sign up for the [OpenSAFELY email newsletter here](https://opensafely.org/contact/) for updates about this study and other OpenSAFELY projects.

* The paper is now under review.
* Raw model outputs, including charts, crosstabs, etc, are in `released_outputs/`
- If you are interested in how we defined our variables, take a look at the [study definition for study 1](analysis/study_definition_af.py) and [study definition for study 2](analysis/study_definition_general_population.py); this is written in `python`, but non-programmers should be able to understand what is going on there
* If you are interested in how we defined our code lists, look in the [codelists folder](./codelists/). All codelists are available online at [OpenCodelists](https://codelists.opensafely.org/) for inspection and re-use by anyone 
* Developers and epidemiologists interested in the framework should review [the OpenSAFELY documentation](https://docs.opensafely.org)

# About the OpenSAFELY framework

The OpenSAFELY framework is a new secure analytics platform for
electronic health records research in the NHS.

Instead of requesting access for slices of patient data and
transporting them elsewhere for analysis, the framework supports
developing analytics against dummy data, and then running against the
real data *within the same infrastructure that the data is stored*.
Read more at [OpenSAFELY.org](https://opensafely.org).