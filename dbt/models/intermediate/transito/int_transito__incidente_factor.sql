SELECT
    id_incidente_factor::NUMBER AS id_incidente_factor,
    id_choque::NUMBER AS id_choque,
    id_factor::NUMBER AS id_factor,
    vehiculo_orden::NUMBER AS vehiculo_orden
FROM {{ ref('stg_transito__incidente_factor') }}
WHERE id_incidente_factor IS NOT NULL
  AND id_choque IS NOT NULL
  AND id_factor IS NOT NULL
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY id_incidente_factor 
    ORDER BY _airbyte_extracted_at DESC
) = 1