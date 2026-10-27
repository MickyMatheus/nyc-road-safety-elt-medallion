SELECT
    id_registro_dmv::NUMBER AS id_registro_dmv,
    id_choque_transito::NUMBER AS id_choque_transito,
    id_vehiculo::NUMBER AS id_vehiculo,
    id_licencia::NUMBER AS id_licencia,
    COALESCE(TRIM(UPPER(danio_estimado)), 'NO_EVALUADO') AS danio_estimado,
    COALESCE(tiene_seguro, FALSE)::BOOLEAN AS tiene_seguro,
    fecha_registro::TIMESTAMP AS fecha_registro
FROM {{ ref('stg_dmv__registro_vehiculo_accidente') }}
WHERE id_registro_dmv IS NOT NULL
  AND (fecha_registro IS NULL OR fecha_registro <= CURRENT_TIMESTAMP())
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY id_registro_dmv 
    ORDER BY _airbyte_extracted_at DESC
) = 1