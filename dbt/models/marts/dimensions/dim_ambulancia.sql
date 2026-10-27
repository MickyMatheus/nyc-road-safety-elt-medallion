WITH ambulancias AS (
    SELECT * FROM {{ ref('int_ems_ambulancias') }}
)

SELECT
    ROW_NUMBER() OVER (ORDER BY id_ambulancia) AS ambulancia_key,
    id_ambulancia AS id_ambulancia_origen,
    COALESCE(area_despacho, 'BASE_CENTRAL') AS hospital_base,
    tipo_soporte_vital AS tipo_unidad,
    'ESTÁNDAR' AS modelo_vehiculo,
    'ACTIVA' AS estado_unidad
FROM ambulancias