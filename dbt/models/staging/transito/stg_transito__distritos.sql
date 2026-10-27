WITH source AS (
    SELECT * FROM {{ source('raw_transito', 'DIST_DISTRITOS') }}
)
SELECT * FROM source