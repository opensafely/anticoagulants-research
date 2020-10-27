from cohortextractor import patients, combine_codelists, filter_codes_by_category
from codelists import *


common_variables = dict(
    dereg_date=patients.date_deregistered_from_all_supported_practices(
        on_or_before="2020-12-01",
        date_format="YYYY-MM-DD",
        return_expectations={"date": {"earliest": "2020-02-01"}},
    ),
    # Inclusion criteria (PLACEHOLDER)
    af=patients.with_these_clinical_events(
        af_codes,
        on_or_before="2020-03-01",
        return_first_date_in_period=True,
        include_month=True,
        return_expectations={"date": {"latest": "2020-03-01"}},
    ),
    # Exclusion criteria (PLACEHOLDER)
    valvular_AF=patients.with_these_clinical_events(
        heart_failure_codes,
        on_or_before="2020-02-29",
        return_first_date_in_period=True,
        include_month=True,
        return_expectations={"date": {"latest": "2020-02-29"}},
    ),
    # Exclusion criteria (PLACEHOLDER)
    antiphospholipid_syndrome=patients.with_these_clinical_events(
        heart_failure_codes,
        on_or_before="2020-02-29",
        return_first_date_in_period=True,
        include_month=True,
        return_expectations={"date": {"latest": "2020-02-29"}},
    ),
    # OUTCOMES
    died_ons_covid_flag_any=patients.with_these_codes_on_death_certificate(
        covid_identification,
        on_or_after="2020-03-01",
        match_only_underlying_cause=False,
        return_expectations={"date": {"earliest": "2020-03-01"}},
    ),
    died_ons_covid_flag_underlying=patients.with_these_codes_on_death_certificate(
        covid_identification,
        on_or_after="2020-03-01",
        match_only_underlying_cause=True,
        return_expectations={"date": {"earliest": "2020-03-01"}},
    ),
    died_date_ons=patients.died_from_any_cause(
        on_or_after="2020-03-01",
        returning="date_of_death",
        include_month=True,
        include_day=True,
        return_expectations={"date": {"earliest": "2020-03-01"}},
    ),
    first_tested_for_covid=patients.with_test_result_in_sgss(
        pathogen="SARS-CoV-2",
        test_result="any",
        on_or_after="2020-03-01",
        find_first_match_in_period=True,
        returning="date",
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {"earliest": "2020-02-01"},
            "rate": "exponential_increase",
        },
    ),
    first_positive_test_date=patients.with_test_result_in_sgss(
        pathogen="SARS-CoV-2",
        test_result="positive",
        on_or_after="2020-03-01",
        find_first_match_in_period=True,
        returning="date",
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {"earliest": "2020-02-01"},
            "rate": "exponential_increase",
        },
    ),

    covid_admission_date=patients.admitted_to_hospital(
        returning= "date_admitted" ,  # defaults to "binary_flag"
        with_these_diagnoses=covid_identification,  # optional
        on_or_after="2020-03-01",
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD",
        return_expectations={"date": {"earliest": "2020-03-01"}, "incidence" : 0.95},
   ),

    covid_admission_primary_diagnosis=patients.admitted_to_hospital(
        returning="primary_diagnosis",
        with_these_diagnoses=covid_identification,
        on_or_after="2020-03-01",
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {"earliest": "2020-03-01"},
            "incidence": 0.95,
            "category": {"ratios": {"U071": 0.5, "U072": 0.5}},
        },
    ),
    # MEDICATIONS
    # LMWH - PLACEHOLDER
    lmwh_last_four_months=patients.with_these_medications(
        warfarin_codes,
        between=["2019-11-01", "2020-02-29"],
        returning="date",
        find_last_match_in_period=True,
        include_month=True,
        include_day=False,
        return_expectations={
            "date": {"earliest": "2019-11-01", "latest": "2020-02-29"}
        },
    ),
    # Exposure variable (warfarin) 
    warfarin_last_four_months=patients.with_these_medications(
        warfarin_codes,
        between=["2019-11-01", "2020-02-29"],
        returning="date",
        find_last_match_in_period=True,
        include_month=True,
        include_day=False,
        return_expectations={
            "date": {"earliest": "2019-11-01", "latest": "2020-02-29"}
        },
    ),
    # Exposure variable (DAOCs)
    doac_last_four_months=patients.with_these_medications(
        doac_codes,
        between=["2019-11-01", "2020-02-29"],
        returning="date",
        find_last_match_in_period=True,
        include_month=True,
        include_day=False,
        return_expectations={
            "date": {"earliest": "2019-11-01", "latest": "2020-02-29"}
        },
    ),
    # Time updated oral anticoagulant exposure (March)
    warfarin_after_march=patients.with_these_medications(
        warfarin_codes,
        returning="date",
        find_first_match_in_period=True,
        between=["2020-03-01", "2020-03-31"],
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {"earliest": "2020-03-01", "latest": "2020-03-31"}
        },
    ),
    doac_after_march=patients.with_these_medications(
        doac_codes,
        returning="date",
        find_first_match_in_period=True,
        between=["2020-03-01", "2020-03-31"],
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {"earliest": "2020-03-01", "latest": "2020-03-31"}
        },
    ),
    # Time updated oral anticoagulant exposure (April) 
    warfarin_after_apr=patients.with_these_medications(
        warfarin_codes,
        returning="date",
        find_first_match_in_period=True,
        between=["2020-04-01", "2020-04-30"],
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {"earliest": "2020-04-01", "latest": "2020-04-30"}
        },
    ),
    doac_after_apr=patients.with_these_medications(
        doac_codes,
        returning="date",
        find_first_match_in_period=True,
        between=["2020-04-01", "2020-04-30"],
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {"earliest": "2020-04-01", "latest": "2020-04-30"}
        },
    ),
    # Time updated oral anticoagulant exposure (May)
    warfarin_after_may=patients.with_these_medications(
        warfarin_codes,
        returning="date",
        find_first_match_in_period=True,
        between=["2020-05-01", "2020-05-31"],
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {"earliest": "2020-05-01", "latest": "2020-05-31"}
        },
    ),
    doac_after_may=patients.with_these_medications(
        doac_codes,
        returning="date",
        find_first_match_in_period=True,
        between=["2020-05-01", "2020-05-31"],
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {"earliest": "2020-05-01", "latest": "2020-05-31"}
        },
    ),
    # Time updated oral anticoagulant exposure (Jun)
    warfarin_after_jun=patients.with_these_medications(
        warfarin_codes,
        returning="date",
        find_first_match_in_period=True,
        between=["2020-06-01", "2020-06-30"],
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {"earliest": "2020-06-01", "latest": "2020-06-30"}
        },
    ),
    doac_after_jun=patients.with_these_medications(
        doac_codes,
        returning="date",
        find_first_match_in_period=True,
        between=["2020-06-01", "2020-06-30"],
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {"earliest": "2020-06-01", "latest": "2020-06-30"}
        },
    ),
    # Time updated oral anticoagulant exposure (Jul) 
    warfarin_after_jul=patients.with_these_medications(
        warfarin_codes,
        returning="date",
        find_first_match_in_period=True,
        between=["2020-07-01", "2020-07-31"],
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {"earliest": "2020-07-01", "latest": "2020-07-31"}
        },
    ),
    doac_after_jul=patients.with_these_medications(
        doac_codes,
        returning="date",
        find_first_match_in_period=True,
        between=["2020-07-01", "2020-07-31"],
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {"earliest": "2020-07-01", "latest": "2020-07-31"}
        },
    ),
    # Time updated oral anticoagulant exposure (Aug) 
    warfarin_after_aug=patients.with_these_medications(
        warfarin_codes,
        returning="date",
        find_first_match_in_period=True,
        between=["2020-08-01", "2020-08-31"],
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {"earliest": "2020-08-01", "latest": "2020-08-31"}
        },
    ),
    doac_after_aug=patients.with_these_medications(
        doac_codes,
        returning="date",
        find_first_match_in_period=True,
        between=["2020-08-01", "2020-08-31"],
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {"earliest": "2020-08-01", "latest": "2020-08-31"}
        },
    ),
    # Time updated oral anticoagulant exposure (Sep) 
    warfarin_after_sep=patients.with_these_medications(
        warfarin_codes,
        returning="date",
        find_first_match_in_period=True,
        between=["2020-09-01", "2020-09-30"],
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {"earliest": "2020-09-01", "latest": "2020-09-30"}
        },
    ),
    doac_after_sep=patients.with_these_medications(
        doac_codes,
        returning="date",
        find_first_match_in_period=True,
        between=["2020-09-01", "2020-09-30"],
        date_format="YYYY-MM-DD",
        return_expectations={
            "date": {"earliest": "2020-09-01", "latest": "2020-09-30"}
        },
    ),
    # COVARIATES
    age=patients.age_as_of(
        "2020-03-01",
        return_expectations={
            "rate": "universal",
            "int": {"distribution": "population_ages"},
        },
    ),
    sex=patients.sex(
        return_expectations={
            "rate": "universal",
            "category": {"ratios": {"M": 0.49, "F": 0.51}},
        }
    ),
    bmi=patients.most_recent_bmi(
        on_or_after="2010-03-01",
        minimum_age_at_measurement=16,
        include_measurement_date=True,
        include_month=True,
        return_expectations={
            "incidence": 0.6,
            "float": {"distribution": "normal", "mean": 35, "stddev": 10},
        },
    ),
    stp=patients.registered_practice_as_of(
        "2020-02-29",
        returning="stp_code",
        return_expectations={
            "rate": "universal",
            "category": {"ratios": {"STP1": 0.5, "STP2": 0.5}},
        },
    ),
    msoa=patients.registered_practice_as_of(
        "2020-02-29",
        returning="msoa_code",
        return_expectations={
            "rate": "universal",
            "category": {"ratios": {"MSOA1": 0.5, "MSOA2": 0.5}},
        },
    ),

        # GP practice ID 
    practice_id=patients.registered_practice_as_of(
        "2020-02-01", 
        returning="pseudo_id", 
        return_expectations={
            "int": {"distribution": "normal", "mean": 1000, "stddev": 100},
            "incidence": 1,
        },
    ),

    care_home_type=patients.care_home_status_as_of(
        "2020-02-01",
        categorised_as={
            "PC": """
              IsPotentialCareHome
              AND LocationDoesNotRequireNursing='Y'
              AND LocationRequiresNursing='N'
            """,
            "PN": """
              IsPotentialCareHome
              AND LocationDoesNotRequireNursing='N'
              AND LocationRequiresNursing='Y'
            """,
            "PS": "IsPotentialCareHome",
            "U": "DEFAULT",
        },
        return_expectations={
            "rate": "universal",
            "category": {"ratios": {"PC": 0.01, "PN": 0.01, "PS": 0.01, "U": 0.97,},},
        },
    ),

    imd=patients.address_as_of(
        "2020-02-29",
        returning="index_of_multiple_deprivation",
        round_to_nearest=100,
        return_expectations={
            "rate": "universal",
            "category": {"ratios": {"100": 0.1, "200": 0.2, "300": 0.7}},
        },
    ),
    ethnicity=patients.with_these_clinical_events(
        ethnicity_codes,
        returning="category",
        find_last_match_in_period=True,
        include_date_of_match=True,
        return_expectations={
            "category": {"ratios": {"1": 0.8, "5": 0.1, "3": 0.1}},
            "incidence": 0.75,
        },
    ),
    # SMOKING
    smoking_status=patients.categorised_as(
        {
            "S": "most_recent_smoking_code = 'S'",
            "E": """
                     most_recent_smoking_code = 'E' OR (    
                       most_recent_smoking_code = 'N' AND ever_smoked   
                     )  
                """,
            "N": "most_recent_smoking_code = 'N' AND NOT ever_smoked",
            "M": "DEFAULT",
        },
        return_expectations={
            "category": {"ratios": {"S": 0.6, "E": 0.1, "N": 0.2, "M": 0.1}}
        },
        most_recent_smoking_code=patients.with_these_clinical_events(
            clear_smoking_codes,
            find_last_match_in_period=True,
            on_or_before="2020-02-29",
            returning="category",
        ),
        ever_smoked=patients.with_these_clinical_events(
            filter_codes_by_category(clear_smoking_codes, include=["S", "E"]),
            on_or_before="2020-02-29",
        ),
    ),
    smoking_status_date=patients.with_these_clinical_events(
        clear_smoking_codes,
        on_or_before="2020-02-29",
        return_last_date_in_period=True,
        include_month=True,
        return_expectations={"date": {"latest": "2020-02-29"}},
    ),
    # HYPERTENSION - CLINICAL CODES ONLY
    hypertension=patients.with_these_clinical_events(
        hypertension_codes,
        on_or_before="2020-02-29",
        return_first_date_in_period=True,
        include_month=True,
        return_expectations={"date": {"latest": "2020-02-29"}},
    ),
    # HEART FAILURE
    heart_failure=patients.with_these_clinical_events(
        heart_failure_codes,
        on_or_before="2020-02-29",
        return_first_date_in_period=True,
        include_month=True,
        return_expectations={"date": {"latest": "2020-02-29"}},
    ),
    # DIABETES
    diabetes=patients.with_these_clinical_events(
        diabetes_codes,
        on_or_before="2020-02-29",
        return_first_date_in_period=True,
        include_month=True,
        return_expectations={"date": {"latest": "2020-02-29"}},
    ),
    hba1c_mmol_per_mol=patients.with_these_clinical_events(
        hba1c_new_codes,
        find_last_match_in_period=True,
        on_or_before="2020-02-29",
        returning="numeric_value",
        include_date_of_match=True,
        include_month=True,
        return_expectations={
            "date": {"latest": "2020-02-29"},
            "float": {"distribution": "normal", "mean": 40.0, "stddev": 20},
            "incidence": 0.95,
        },
    ),
    hba1c_percentage=patients.with_these_clinical_events(
        hba1c_old_codes,
        find_last_match_in_period=True,
        on_or_before="2020-02-29",
        returning="numeric_value",
        include_date_of_match=True,
        include_month=True,
        return_expectations={
            "date": {"latest": "2020-02-29"},
            "float": {"distribution": "normal", "mean": 5, "stddev": 2},
            "incidence": 0.95,
        },
    ),
    # COPD
    copd=patients.with_these_clinical_events(
        copd_codes,
        on_or_before="2020-02-29",
        return_first_date_in_period=True,
        include_month=True,
        return_expectations={"date": {"latest": "2020-02-29"}},
    ),
    # OTHER RESPIRATORY DISEASES
    other_respiratory=patients.with_these_clinical_events(
        other_respiratory_codes,
        on_or_before="2020-02-29",
        return_first_date_in_period=True,
        include_month=True,
        return_expectations={"date": {"latest": "2020-02-29"}},
    ),
    # CANCER - 3 TYPES
    cancer=patients.with_these_clinical_events(
        combine_codelists(lung_cancer_codes, haem_cancer_codes, other_cancer_codes),
        on_or_before="2020-02-29",
        return_first_date_in_period=True,
        include_month=True,
        return_expectations={"date": {"latest": "2020-02-29"}},
    ),
    # IMMUNOSUPPRESSION
    #### PERMANENT
    permanent_immunodeficiency=patients.with_these_clinical_events(
        combine_codelists(
            hiv_codes,
            permanent_immune_codes,
            sickle_cell_codes,
            organ_transplant_codes,
            spleen_codes,
        ),
        on_or_before="2020-02-29",
        return_last_date_in_period=True,
        include_month=True,
        return_expectations={"date": {"latest": "2020-02-29"}},
    ),
    aplastic_anaemia=patients.with_these_clinical_events(
        aplastic_codes,
        between=["2019-03-01", "2020-02-29"],
        return_last_date_in_period=True,
        include_month=True,
        return_expectations={
            "date": {"earliest": "2019-03-01", "latest": "2020-02-29"}
        },
    ),
    #### TEMPORARY
    temporary_immunodeficiency=patients.with_these_clinical_events(
        temp_immune_codes,
        between=["2019-03-01", "2020-02-29"],
        return_last_date_in_period=True,
        include_month=True,
        return_expectations={
            "date": {"earliest": "2019-03-01", "latest": "2020-02-29"}
        },
    ),
    # CKD
    creatinine=patients.with_these_clinical_events(
        creatinine_codes,
        find_last_match_in_period=True,
        between=["2019-02-28", "2020-02-29"],
        returning="numeric_value",
        include_date_of_match=True,
        include_month=True,
        return_expectations={
            "float": {"distribution": "normal", "mean": 60.0, "stddev": 15},
            "date": {"earliest": "2019-02-28", "latest": "2020-02-29"},
            "incidence": 0.95,
        },
    ),
    #### end stage renal disease codes incl. dialysis / transplant
    esrf=patients.with_these_clinical_events(
        ckd_codes,  # CHECK IS THIS DEF RIGHT HERE
        on_or_before="2020-02-29",
        return_last_date_in_period=True,
        include_month=True,
        return_expectations={"date": {"latest": "2020-02-29"}},
    ),
    #### stroke
    stroke=patients.with_these_clinical_events(
        stroke_codes,
        on_or_before="2020-02-29",
        return_last_date_in_period=True,
        include_month=True,
        return_expectations={"date": {"latest": "2020-02-29"}},
    ),
    #### Transient ischaemic attack (PLACEHOLDER)
    tia=patients.with_these_clinical_events(
        stroke_codes,
        on_or_before="2020-02-29",
        return_last_date_in_period=True,
        include_month=True,
        return_expectations={"date": {"latest": "2020-02-29"}},
    ),
    #### Myocardial infarction
    mi=patients.with_these_clinical_events(
        mi_codes,
        on_or_before="2020-02-29",
        return_last_date_in_period=True,
        include_month=True,
        return_expectations={"date": {"latest": "2020-02-29"}},
    ),
    #### Peripheral artery disease (PLACEHOLDER)
    pad=patients.with_these_clinical_events(
        mi_codes,
        on_or_before="2020-02-29",
        return_last_date_in_period=True,
        include_month=True,
        return_expectations={"date": {"latest": "2020-02-29"}},
    ),
    #### Venous thromboembolism
    vte=patients.with_these_clinical_events(
        vte_codes,
        on_or_before="2020-02-29",
        return_last_date_in_period=True,
        include_month=True,
        return_expectations={"date": {"latest": "2020-02-29"}},
    ),
    # FLU VACCINATION STATUS
    flu_vaccine_tpp_table=patients.with_tpp_vaccination_record(
        target_disease_matches="INFLUENZA",
        between=["2019-09-01", "2020-02-29"],  # current flu season
        find_first_match_in_period=True,
        returning="date",
        return_expectations={
            "date": {"earliest": "2019-09-01", "latest": "2020-02-29"}
        },
    ),
    flu_vaccine_med=patients.with_these_medications(
        flu_med_codes,
        between=["2019-09-01", "2020-02-29"],  # current flu season
        returning="date",
        find_last_match_in_period=True,
        include_month=True,
        include_day=True,
        return_expectations={
            "date": {"earliest": "2019-09-01", "latest": "2020-02-29"}
        },
    ),
    flu_vaccine_clinical=patients.with_these_clinical_events(
        flu_clinical_given_codes,
        ignore_days_where_these_codes_occur=flu_clinical_not_given_codes,
        between=["2019-09-01", "2020-02-29"],  # current flu season
        return_first_date_in_period=True,
        include_month=True,
        return_expectations={
            "date": {"earliest": "2019-09-01", "latest": "2020-02-29"}
        },
    ),
    flu_vaccine=patients.satisfying(
        """
        flu_vaccine_tpp_table OR
        flu_vaccine_med OR
        flu_vaccine_clinical
        """,
    ),
    # A&E ATTENDANCE IN PREVIOUS YEAR
    ae_attendance_last_year=patients.attended_emergency_care(
        between=["2019-03-01", "2020-02-29"],
        returning="number_of_matches_in_period",
        return_expectations={
            "int": {"distribution": "normal", "mean": 2, "stddev": 2},
            "date": {"earliest": "2019-03-01", "latest": "2020-02-29"},
            "incidence": 0.3,
        },
    ),
    ### GP CONSULTATION RATE IN PREVIOUS YEAR
    gp_consult_count=patients.with_gp_consultations(
        between=["2019-03-01", "2020-02-29"],
        returning="number_of_matches_in_period",
        return_expectations={
            "int": {"distribution": "normal", "mean": 4, "stddev": 2},
            "date": {"earliest": "2019-03-01", "latest": "2020-02-29"},
            "incidence": 0.7,
        },
    ),
    has_consultation_history=patients.with_complete_gp_consultation_history_between(
        "2019-03-01", "2020-02-29", return_expectations={"incidence": 0.9},
    ),
    # OESTROGEN USAGE (PLACEHOLDER)
    oestrogen=patients.with_these_medications(
        ppi_med_codes,
        between=["2019-11-01", "2020-02-29"],
        returning="date",
        find_last_match_in_period=True,
        include_month=True,
        include_day=False,
        return_expectations={
            "date": {"earliest": "2019-11-01", "latest": "2020-02-29"}
        },
    ),
    # ANTIPLATELET USAGE (PLACEHOLDER)
    antiplatelet=patients.with_these_medications(
        ppi_med_codes,
        between=["2019-11-01", "2020-02-29"],
        returning="date",
        find_last_match_in_period=True,
        include_month=True,
        include_day=False,
        return_expectations={
            "date": {"earliest": "2019-11-01", "latest": "2020-02-29"}
        },
    ),
)
