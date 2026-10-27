-- models/intermediate/postgres/int_pg_mantenimientos.sql
SELECT
    id_mantenimiento::NUMBER AS id_mantenimiento,
    id_patrulla::NUMBER AS id_patrulla,
    fecha_salida::DATE AS fecha_salida,
    fecha_ingreso::DATE AS fecha_ingreso,
    TRIM(UPPER(tipo_servicio)) AS tipo_servicio,
    costo_reparacion::FLOAT AS costo_reparacion
FROM {{ ref('stg_pg_mantenimientos') }}
WHERE fecha_ingreso <= CURRENT_DATE()
  AND fecha_salida <= CURRENT_DATE()
QUALIFY ROW_NUMBER() OVER (PARTITION BY id_mantenimiento ORDER BY _airbyte_extracted_at DESC) = 1