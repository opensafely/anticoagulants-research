from cohortextractor import StudyDefinition, patients, codelist, filter_codes_by_category, combine_codelists, codelist_from_csv
from common_variables import common_variables
from codelists import *


study = StudyDefinition(
    default_expectations={
        "date": {"earliest": "1900-01-01", "latest": "today"},
        "rate": "exponential_increase",
        "incidence": 0.7,
    },

    # STUDY POPULATION
    population=patients.satisfying(
        """
        registration_history AND
        af AND
        (age >=18 AND age <= 110) AND
        imd >0 AND NOT (
        valvular_AF OR
        ESRD OR
        antiphospholipid_syndrome
        )

        """,
        registration_history=patients.registered_with_one_practice_between(
            "2019-02-28", "2020-02-29"
        ),
    ),
    **common_variables
)
