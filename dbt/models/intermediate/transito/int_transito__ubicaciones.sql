SELECT
    id_ubicacion::NUMBER AS id_ubicacion,
    id_distrito::NUMBER AS id_distrito,
    latitud::FLOAT AS latitud,
    longitud::FLOAT AS longitud,
    COALESCE(TRIM(UPPER(codigo_postal)), 'SIN_DATO') AS codigo_postal,
    COALESCE(TRIM(UPPER(calle_principal)), 'SIN_DATO') AS calle_principal,
    COALESCE(TRIM(UPPER(calle_transversal)), 'SIN_DATO') AS calle_transversal,
    COALESCE(TRIM(UPPER(direccion_especifica)), 'SIN_DATO') AS direccion_especifica
FROM {{ ref('stg_transito__ubicaciones') }}
WHERE id_ubicacion IS NOT NULL
  AND latitud IS NOT NULL
  AND longitud IS NOT NULL
  AND latitud != 0.0
  AND longitud != 0.0
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY id_ubicacion 
    ORDER BY _airbyte_extracted_at DESC
) = 1