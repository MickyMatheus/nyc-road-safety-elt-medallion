-- models/intermediate/postgres/int_pg_infracciones.sql
SELECT
    id_infraccion::NUMBER AS id_infraccion,
    id_expediente::NUMBER AS id_expediente,
    TRIM(UPPER(tipo_infraccion)) AS tipo_infraccion,
    fecha_emision::DATE AS fecha_emision,
    monto_multa::FLOAT AS monto_multa,
    puntos_licencia::NUMBER AS puntos_licencia
FROM {{ ref('stg_pg_infracciones') }}
WHERE fecha_emision <= CURRENT_DATE()
QUALIFY ROW_NUMBER() OVER (PARTITION BY id_infraccion ORDER BY _airbyte_extracted_at DESC) = 1