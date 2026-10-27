SELECT
    id_licencia::NUMBER AS id_licencia,
    id_conductor::NUMBER AS id_conductor,
    id_tipo_licencia::NUMBER AS id_tipo_licencia,
    TRIM(UPPER(numero_licencia)) AS numero_licencia,
    COALESCE(TRIM(UPPER(estado_licencia)), 'DESCONOCIDO') AS estado_licencia,
    fecha_expedicion::DATE AS fecha_expedicion,
    fecha_expiracion::DATE AS fecha_expiracion,
    fecha_actualizacion::TIMESTAMP AS fecha_actualizacion
FROM {{ ref('stg_dmv__licencias') }}
WHERE id_licencia IS NOT NULL
  AND fecha_expedicion <= CURRENT_DATE()
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY id_licencia 
    ORDER BY _airbyte_extracted_at DESC
) = 1