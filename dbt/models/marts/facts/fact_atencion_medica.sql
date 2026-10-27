WITH atenciones AS (
    SELECT 
        id_atencion,
        id_persona,
        id_incidente,
        id_ambulancia,
        severidad_preliminar
    FROM {{ ref('int_ems_atencion') }}
),

incidentes_ems AS (
    SELECT 
        id_incidente,
        id_choque,
        ts_incidente
    FROM {{ ref('int_ems_incidentes') }}
),

tiempos AS (
    SELECT 
        id_incidente,
        ts_despacho,
        ts_arribo_escena,
        segundos_despacho,
        segundos_traslado,
        tiempo_respuesta_min
    FROM {{ ref('int_ems_tiempos') }}
),

incidentes_transito AS (
    SELECT 
        id_choque,
        id_ubicacion
    FROM {{ ref('int_transito__incidentes') }}
),

dim_ambulancia AS (
    SELECT 
        ambulancia_key,
        id_ambulancia_origen
    FROM {{ ref('dim_ambulancia') }}
),

dim_persona AS (
    SELECT 
        persona_key,
        id_persona_origen
    FROM {{ ref('dim_persona') }}
),

dim_ubicacion AS (
    SELECT 
        ubicacion_key,
        id_ubicacion_origen
    FROM {{ ref('dim_ubicacion') }}
)

SELECT
    ROW_NUMBER() OVER (ORDER BY a.id_atencion) AS atencion_key,
    a.id_atencion AS id_atencion_origen,
    COALESCE(ie.id_choque, 0) AS id_choque_origen,
    
    -- Claves foráneas conformadas
    COALESCE(TO_NUMBER(TO_CHAR(ie.ts_incidente, 'YYYYMMDD')), 20260101) AS fecha_key,
    COALESCE(EXTRACT(HOUR FROM t.ts_despacho), 0) AS hora_despacho_key,
    COALESCE(EXTRACT(HOUR FROM t.ts_arribo_escena), 0) AS hora_arribo_key,
    COALESCE(u.ubicacion_key, 0) AS ubicacion_key,
    COALESCE(dp.persona_key, 0) AS persona_key,
    CASE 
        WHEN a.severidad_preliminar IN ('FALLECIDO', 'FATAL') THEN 4
        WHEN a.severidad_preliminar IN ('LESION_GRAVE', 'CRITICO') THEN 3
        WHEN a.severidad_preliminar IN ('LESION_LEVE', 'MODERADO') THEN 2
        ELSE 1
    END AS severidad_key,
    COALESCE(da.ambulancia_key, 0) AS ambulancia_key,
    
    -- Métricas de rendimiento y latencia médica
    1 AS cantidad_atencion,
    COALESCE(t.tiempo_respuesta_min, 0) AS tiempo_respuesta_min,
    COALESCE(t.segundos_despacho, 0) AS segundos_despacho,
    COALESCE(t.segundos_traslado, 0) AS segundos_traslado,

    -- Indicadores de cumplimiento de estándares de emergencia
    CASE WHEN COALESCE(t.tiempo_respuesta_min, 0) > 10 THEN 1 ELSE 0 END AS indicador_tiempo_excedido,
    CASE WHEN a.severidad_preliminar IN ('LESION_GRAVE', 'CRITICO') THEN 1 ELSE 0 END AS indicador_lesion_grave,
    CASE WHEN a.severidad_preliminar IN ('FALLECIDO', 'FATAL') THEN 1 ELSE 0 END AS indicador_fallecido

FROM atenciones a
LEFT JOIN incidentes_ems ie ON a.id_incidente = ie.id_incidente
LEFT JOIN tiempos t ON a.id_incidente = t.id_incidente
LEFT JOIN incidentes_transito it ON ie.id_choque = it.id_choque
LEFT JOIN dim_ubicacion u ON it.id_ubicacion = u.id_ubicacion_origen
LEFT JOIN dim_ambulancia da ON a.id_ambulancia = da.id_ambulancia_origen
LEFT JOIN dim_persona dp ON a.id_persona = dp.id_persona_origen