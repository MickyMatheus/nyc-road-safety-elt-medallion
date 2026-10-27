SELECT
    id_distrito::NUMBER AS id_distrito,
    COALESCE(TRIM(UPPER(nombre_distrito)), 'SIN_DATO') AS nombre_distrito
FROM {{ ref('stg_transito__distritos') }}
WHERE id_distrito IS NOT NULL
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY id_distrito 
    ORDER BY _airbyte_extracted_at DESC
) = 1