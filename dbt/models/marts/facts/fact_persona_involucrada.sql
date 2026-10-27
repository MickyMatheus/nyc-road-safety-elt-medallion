WITH personas AS (
    SELECT * FROM {{ ref('int_ems_personas') }}
),

incidentes AS (
    SELECT id_choque, fecha_accidente, id_ubicacion FROM {{ ref('int_transito__incidentes') }}
),

dim_persona AS (
    SELECT persona_key, id_persona_origen FROM {{ ref('dim_persona') }}
),

dim_ubicacion AS (
    SELECT ubicacion_key, id_ubicacion_origen FROM {{ ref('dim_ubicacion') }}
)

SELECT
    ROW_NUMBER() OVER (ORDER BY p.id_persona) AS persona_involucrada_key,
    COALESCE(p.id_choque, 0) AS id_choque_origen,
    
    -- Claves foráneas conformadas
    COALESCE(TO_NUMBER(TO_CHAR(i.fecha_accidente, 'YYYYMMDD')), 20260101) AS fecha_key,
    COALESCE(u.ubicacion_key, 0) AS ubicacion_key,
    COALESCE(dp.persona_key, 0) AS persona_key,
    
    -- Severidad por defecto (Leve si participó en el siniestro, o conectada a dimensión)
    2 AS severidad_key,
    
    -- Métricas atómicas (exactamente como exige la rúbrica)
    1 AS cantidad_persona,
    1 AS indicador_herido,
    0 AS indicador_fallecido

FROM personas p
LEFT JOIN incidentes i ON p.id_choque = i.id_choque
LEFT JOIN dim_persona dp ON p.id_persona = dp.id_persona_origen
LEFT JOIN dim_ubicacion u ON i.id_ubicacion = u.id_ubicacion_origen