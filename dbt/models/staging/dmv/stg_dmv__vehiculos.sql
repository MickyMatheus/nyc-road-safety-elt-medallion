WITH source AS (
    SELECT * FROM {{ source('raw_dmv', 'VHCL_VEHICULOS') }}
)

SELECT * FROM source