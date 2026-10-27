-- models/intermediate/postgres/int_pg_oficiales.sql
SELECT
    placa_oficial::NUMBER AS placa_oficial,
    TRIM(nombre) AS nombre,
    TRIM(apellido) AS apellido,
    fecha_alta::DATE AS fecha_alta,
    id_comisaria::NUMBER AS id_comisaria,
    TRIM(UPPER(rango_policial)) AS rango_policial,
    TRIM(UPPER(estado_servicio)) AS estado_servicio
FROM {{ ref('stg_pg_oficiales') }}
WHERE fecha_alta <= CURRENT_DATE()
QUALIFY ROW_NUMBER() OVER (PARTITION BY placa_oficial ORDER BY _airbyte_extracted_at DESC) = 1