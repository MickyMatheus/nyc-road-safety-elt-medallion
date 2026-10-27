WITH source AS (
    SELECT * FROM {{ source('raw_dmv', 'LCNC_LICENCIAS') }}
)

SELECT * FROM source