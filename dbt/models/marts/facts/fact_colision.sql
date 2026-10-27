WITH incidentes AS (
    SELECT * FROM {{ ref('int_transito__incidentes') }}
),

dim_ubicacion AS (
    SELECT ubicacion_key, id_ubicacion_origen FROM {{ ref('dim_ubicacion') }}
)

SELECT
    ROW_NUMBER() OVER (ORDER BY i.id_choque) AS colision_key,
    i.id_choque AS id_choque_origen,
    
    -- Claves foráneas conformadas
    TO_NUMBER(TO_CHAR(i.fecha_accidente, 'YYYYMMDD')) AS fecha_key,
    EXTRACT(HOUR FROM i.hora_accidente) AS hora_key,
    COALESCE(u.ubicacion_key, 0) AS ubicacion_key,
    CASE 
        WHEN i.num_personas_fallecidas > 0 THEN 4 -- FATAL
        WHEN i.num_personas_heridas > 2 THEN 3    -- LESION_GRAVE
        WHEN i.num_personas_heridas > 0 THEN 2    -- LESION_LEVE
        ELSE 1                                    -- SIN_LESION
    END AS severidad_key,
    
    -- Conteo base aditivo
    1 AS cantidad_accidente,
    
    -- Métricas generales de víctimas
    i.num_personas_heridas,
    i.num_personas_fallecidas,
    (i.num_personas_heridas + i.num_personas_fallecidas) AS total_victimas,

    -- Métrica Econométrica Oficial (USD): Enfoque FHWA / NYC DOT
    -- ($10.5M por fallecido + $1.2M por herido crítico + $15,000 costos materiales y administrativos)
    (i.num_personas_fallecidas * 10500000) + (i.num_personas_heridas * 1200000) + 15000 AS costo_social_usd,

    -- Bandera de siniestro con víctimas
    CASE WHEN (i.num_personas_heridas + i.num_personas_fallecidas) > 0 THEN 1 ELSE 0 END AS indicador_con_victimas

FROM incidentes i
LEFT JOIN dim_ubicacion u ON i.id_ubicacion = u.id_ubicacion_origen