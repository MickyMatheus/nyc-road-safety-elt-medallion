SELECT
    id_choque::NUMBER AS id_choque,
    id_ubicacion::NUMBER AS id_ubicacion,
    fecha_accidente::DATE AS fecha_accidente,
    hora_accidente::TIME AS hora_accidente,
    COALESCE(num_personas_heridas::NUMBER, 0) AS num_personas_heridas,
    COALESCE(num_personas_fallecidas::NUMBER, 0) AS num_personas_fallecidas
FROM {{ ref('stg_transito__incidentes') }}
WHERE id_choque IS NOT NULL
  AND fecha_accidente <= CURRENT_DATE()
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY id_choque 
    ORDER BY _airbyte_extracted_at DESC
) = 1