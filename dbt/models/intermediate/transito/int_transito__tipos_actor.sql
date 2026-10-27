SELECT
    id_tipo_actor::NUMBER AS id_tipo_actor,
    COALESCE(TRIM(UPPER(nombre_actor)), 'DESCONOCIDO') AS nombre_actor,
    COALESCE(TRIM(UPPER(descripcion)), 'SIN_DATO') AS descripcion
FROM {{ ref('stg_transito__tipos_actor') }}
WHERE id_tipo_actor IS NOT NULL
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY id_tipo_actor 
    ORDER BY _airbyte_extracted_at DESC
) = 1