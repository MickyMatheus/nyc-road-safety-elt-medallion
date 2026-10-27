SELECT 
    1 AS severidad_key, 
    'SIN_LESION' AS nivel_severidad, 
    'Sin daños personales ni lesiones físicas' AS descripcion_severidad, 
    1 AS orden_severidad
UNION ALL
SELECT 
    2, 
    'LESION_LEVE', 
    'Lesiones menores atendidas en sitio o sin riesgo vital', 
    2
UNION ALL
SELECT 
    3, 
    'LESION_GRAVE', 
    'Lesiones críticas con traslado hospitalario de urgencia', 
    3
UNION ALL
SELECT 
    4, 
    'FATAL', 
    'Fallecimiento en escena o en traslado', 
    4