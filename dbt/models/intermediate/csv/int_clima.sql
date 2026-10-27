WITH source AS (
    SELECT * FROM {{ ref('stg_clima') }}
),

limpieza AS (
    SELECT
        CAST(FECHA AS DATE) AS fecha_clima,
        CAST(TEMP_PROMEDIO_C AS FLOAT) AS temp_promedio_c,
        COALESCE(CAST(PRECIPITACION_MM AS FLOAT), 0.0) AS precipitacion_mm,
        COALESCE(CAST(NIEVE_MM AS FLOAT), 0.0) AS nieve_mm
    FROM source
)

SELECT * FROM limpieza