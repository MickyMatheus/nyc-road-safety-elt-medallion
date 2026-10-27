-- models/intermediate/postgres/int_pg_evidencias.sql
SELECT
    id_evidencia::NUMBER AS id_evidencia,
    id_expediente::NUMBER AS id_expediente,
    TRIM(UPPER(tipo_evidencia)) AS tipo_evidencia,
    TRIM(cadena_custodia) AS cadena_custodia,
    fecha_recoleccion::TIMESTAMP_NTZ AS fecha_recoleccion
FROM {{ ref('stg_pg_evidencias') }}
WHERE fecha_recoleccion <= CURRENT_TIMESTAMP()
QUALIFY ROW_NUMBER() OVER (PARTITION BY id_evidencia ORDER BY _airbyte_extracted_at DESC) = 1