WITH quejas AS (
    SELECT * FROM {{ ref('int_311') }}
),

dim_ubicacion AS (
    SELECT ubicacion_key, distrito, calle_principal 
    FROM {{ ref('dim_ubicacion') }}
)

SELECT
    ROW_NUMBER() OVER (ORDER BY q.fecha_creacion) AS queja_key,
    
    -- Claves foráneas conformadas
    COALESCE(TO_NUMBER(TO_CHAR(q.fecha_creacion, 'YYYYMMDD')), 20260101) AS fecha_key,
    COALESCE(EXTRACT(HOUR FROM q.fecha_creacion), 0) AS hora_key,
    COALESCE(u.ubicacion_key, 0) AS ubicacion_key,
    
    -- Atributos descriptivos de infraestructura
    q.agencia,
    q.tipo_queja,
    q.descripcion_queja,
    q.estado_queja,
    q.distrito,
    q.calle_principal,
    q.calle_interseccion_1,
    q.precinto_policial,
    q.latitud,
    q.longitud,
    
    -- Métrica base aditiva
    1 AS cantidad_queja,
    CASE WHEN q.tipo_queja LIKE '%SIGNAL%' THEN 1 ELSE 0 END AS indicador_semaforo_danado,
    CASE WHEN q.tipo_queja LIKE '%LIGHT%' THEN 1 ELSE 0 END AS indicador_luminaria_apagada,
    CASE WHEN q.estado_queja = 'CLOSED' THEN 1 ELSE 0 END AS indicador_resuelto

FROM quejas q
LEFT JOIN dim_ubicacion u 
    ON UPPER(TRIM(q.distrito)) = UPPER(TRIM(u.distrito)) 
   AND UPPER(TRIM(q.calle_principal)) = UPPER(TRIM(u.calle_principal))