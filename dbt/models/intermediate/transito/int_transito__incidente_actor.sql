SELECT
    id_incidente_actor::NUMBER AS id_incidente_actor,
    id_choque::NUMBER AS id_choque,
    id_tipo_actor::NUMBER AS id_tipo_actor,
    COALESCE(num_heridos::NUMBER, 0) AS num_heridos,
    COALESCE(num_fallecidos::NUMBER, 0) AS num_fallecidos
FROM {{ ref('stg_transito__incidente_actor') }}
WHERE id_incidente_actor IS NOT NULL
  AND id_choque IS NOT NULL
  AND id_tipo_actor IS NOT NULL
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY id_incidente_actor 
    ORDER BY _airbyte_extracted_at DESC
) = 1