WITH source AS (
    SELECT * FROM {{ source('raw_transito', 'CONT_FACTORES') }}
)
SELECT * FROM source