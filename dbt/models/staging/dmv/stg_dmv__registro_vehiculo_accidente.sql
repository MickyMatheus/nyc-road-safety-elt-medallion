WITH source AS (
    SELECT * FROM {{ source('raw_dmv', 'REGV_REGISTRO_VEHICULO_ACCIDENTE') }}
)

SELECT * FROM source