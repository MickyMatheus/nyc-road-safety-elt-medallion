WITH source AS (
    SELECT * FROM {{ source('raw_transito', 'TACT_TIPOS_ACTOR') }}
)
SELECT * FROM source