-- models/intermediate/postgres/int_pg_patrullas.sql
SELECT
    id_patrulla::NUMBER AS id_patrulla,
    id_comisaria::NUMBER AS id_comisaria,
    TRIM(codigo_unidad) AS codigo_unidad,
    TRIM(UPPER(tipo_vehiculo)) AS tipo_vehiculo,
    TRIM(UPPER(estado_operativo)) AS estado_operativo,
    fecha_ultimo_mantenimiento::DATE AS fecha_ultimo_mantenimiento
FROM {{ ref('stg_pg_patrullas') }}
WHERE fecha_ultimo_mantenimiento <= CURRENT_DATE()
QUALIFY ROW_NUMBER() OVER (PARTITION BY id_patrulla ORDER BY _airbyte_extracted_at DESC) = 1