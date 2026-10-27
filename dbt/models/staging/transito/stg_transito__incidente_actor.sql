WITH source AS (
    SELECT * FROM {{ source('raw_transito', 'INVA_INCIDENTE_ACTOR') }}
)
SELECT * FROM source