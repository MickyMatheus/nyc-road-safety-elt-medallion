WITH source AS (
    SELECT * FROM {{ source('raw_transito', 'LOCN_UBICACIONES') }}
)
SELECT * FROM source