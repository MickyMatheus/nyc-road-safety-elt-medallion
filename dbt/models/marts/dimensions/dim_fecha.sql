WITH date_spine AS (
    SELECT DATEADD(day, SEQ4(), '2020-01-01'::DATE) AS fecha_completa
    FROM TABLE(GENERATOR(ROWCOUNT => 2557)) -- Cubre 2020 a 2026
),

clima AS (
    SELECT 
        fecha_clima,
        temp_promedio_c,
        precipitacion_mm,
        nieve_mm,
        -- Promedio mensual de temperatura histórica para imputar días sin registro
        AVG(temp_promedio_c) OVER (PARTITION BY EXTRACT(MONTH FROM fecha_clima)) AS temp_mensual_promedio
    FROM {{ ref('int_clima') }}
)

SELECT
    TO_NUMBER(TO_CHAR(d.fecha_completa, 'YYYYMMDD')) AS fecha_key,
    d.fecha_completa,
    EXTRACT(DAY FROM d.fecha_completa) AS dia,
    EXTRACT(MONTH FROM d.fecha_completa) AS mes,
    TO_CHAR(d.fecha_completa, 'Mon') AS nombre_mes,
    EXTRACT(QUARTER FROM d.fecha_completa) AS trimestre,
    EXTRACT(YEAR FROM d.fecha_completa) AS anio,
    DAYNAME(d.fecha_completa) AS dia_semana,
    
    -- Atributos de Contexto Meteorológico (Sin valores NULL)
    COALESCE(c.temp_promedio_c, c.temp_mensual_promedio, 12.5)::NUMBER(5,2) AS temp_promedio_c,
    COALESCE(c.precipitacion_mm, 0.0)::NUMBER(5,2) AS precipitacion_mm,
    COALESCE(c.nieve_mm, 0.0)::NUMBER(5,2) AS nieve_mm,
    
    -- Indicadores derivados ya protegidos contra nulos
    CASE WHEN COALESCE(c.precipitacion_mm, 0.0) > 0 THEN 1 ELSE 0 END AS indicador_lluvia,
    CASE WHEN COALESCE(c.nieve_mm, 0.0) > 0 THEN 1 ELSE 0 END AS indicador_nieve,
    CASE 
        WHEN COALESCE(c.precipitacion_mm, 0.0) > 15 OR COALESCE(c.nieve_mm, 0.0) > 5 THEN 'EXTREMO'
        WHEN COALESCE(c.precipitacion_mm, 0.0) > 0 OR COALESCE(c.nieve_mm, 0.0) > 0 THEN 'MODERADO'
        ELSE 'DESPEJADO'
    END AS condicion_climatica

FROM date_spine d
LEFT JOIN clima c ON d.fecha_completa = c.fecha_clima