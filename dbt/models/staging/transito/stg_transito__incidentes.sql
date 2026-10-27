WITH source AS (
    SELECT * FROM {{ source('raw_transito', 'INCD_INCIDENTES') }}
)
SELECT * FROM source