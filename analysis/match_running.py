from match import match

# input_af_oac is generated from 02a program
afmatchgeneralpopulation = {
    "case_csv": "input_af_oac",
    "match_csv": "input_general_population",
    "matches_per_case": 10,
    "match_variables": {
        "sex": "category",
        "age": 1,
        "practice_id": "category",
    },
    "closest_match_columns": ["age"],
    "index_date_variable": "indexdate",
    "replace_match_index_date_with_case": "no_offset",
}
match(**afmatchgeneralpopulation)