-- models/intermediate/postgres/int_pg_equipamiento.sql
SELECT
    id_equipamiento::NUMBER AS id_equipamiento,
    TRIM(UPPER(tipo_equipo)) AS tipo_equipo,
    TRIM(numero_serie) AS numero_serie,
    placa_oficial::NUMBER AS placa_oficial,
    fecha_asignacion::DATE AS fecha_asignacion
FROM {{ ref('stg_pg_equipamiento') }}
WHERE fecha_asignacion <= CURRENT_DATE()
QUALIFY ROW_NUMBER() OVER (PARTITION BY id_equipamiento ORDER BY _airbyte_extracted_at DESC) = 1