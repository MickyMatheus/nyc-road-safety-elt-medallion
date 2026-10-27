WITH registro_vehiculo AS (
    SELECT * FROM {{ ref('int_dmv__registro_vehiculo_accidente') }}
),

vehiculos AS (
    SELECT * FROM {{ ref('int_dmv__vehiculos') }}
),

incidentes AS (
    SELECT id_choque, fecha_accidente, id_ubicacion FROM {{ ref('int_transito__incidentes') }}
),

dim_ubicacion AS (
    SELECT ubicacion_key, id_ubicacion_origen FROM {{ ref('dim_ubicacion') }}
),

dim_vehiculo AS (
    SELECT vehiculo_key, id_vehiculo_origen FROM {{ ref('dim_vehiculo') }}
)

SELECT
    ROW_NUMBER() OVER (ORDER BY rv.id_registro_dmv) AS vehiculo_involucrado_key,
    rv.id_choque_transito AS id_choque_origen,
    
    -- Claves foráneas (protegidas)
    COALESCE(TO_NUMBER(TO_CHAR(i.fecha_accidente, 'YYYYMMDD')), 20260101) AS fecha_key,
    COALESCE(u.ubicacion_key, 0) AS ubicacion_key,
    COALESCE(dv.vehiculo_key, 0) AS vehiculo_key,
    
    -- Conteo base
    1 AS cantidad_vehiculo,
    
    -- Métricas de negocio y econometría de parque automotor (Sin NULLs: -1 = Desconocido/No Registrado)
    CASE 
        WHEN v.anio_fabricacion IS NOT NULL AND i.fecha_accidente IS NOT NULL 
             AND EXTRACT(YEAR FROM i.fecha_accidente) >= v.anio_fabricacion
        THEN (EXTRACT(YEAR FROM i.fecha_accidente) - v.anio_fabricacion)::NUMBER
        ELSE -1
    END AS antiguedad_vehiculo,

    -- Indicadores de riesgo y seguro
    CASE WHEN rv.tiene_seguro = TRUE THEN 1 ELSE 0 END AS indicador_con_seguro,
    CASE WHEN rv.tiene_seguro = FALSE THEN 1 ELSE 0 END AS indicador_sin_seguro,

    -- Daño clasificado y severidad material estimada
    COALESCE(rv.danio_estimado, 'NO_EVALUADO') AS danio_estimado,
    CASE 
        WHEN rv.danio_estimado = 'DESTRUCCION_TOTAL' THEN 4
        WHEN rv.danio_estimado = 'SEVERO' THEN 3
        WHEN rv.danio_estimado = 'MODERADO' THEN 2
        ELSE 1 -- LEVE / NO_EVALUADO / DESCONOCIDO
    END AS orden_danio_material

FROM registro_vehiculo rv
LEFT JOIN vehiculos v ON rv.id_vehiculo = v.id_vehiculo
LEFT JOIN incidentes i ON rv.id_choque_transito = i.id_choque
LEFT JOIN dim_ubicacion u ON i.id_ubicacion = u.id_ubicacion_origen
LEFT JOIN dim_vehiculo dv ON rv.id_vehiculo = dv.id_vehiculo_origen