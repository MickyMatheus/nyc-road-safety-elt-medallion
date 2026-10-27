SELECT
    id_factor::NUMBER AS id_factor,
    COALESCE(TRIM(UPPER(descripcion_factor)), 'SIN_DATO') AS descripcion_factor
FROM {{ ref('stg_transito__factores') }}
WHERE id_factor IS NOT NULL
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY id_factor 
    ORDER BY _airbyte_extracted_at DESC
) = 1