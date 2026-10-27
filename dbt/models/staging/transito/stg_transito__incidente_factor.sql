WITH source AS (
    SELECT * FROM {{ source('raw_transito', 'INFC_INCIDENTE_FACTOR') }}
)
SELECT * FROM source