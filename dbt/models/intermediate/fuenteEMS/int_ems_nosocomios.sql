-- int_ems_nosocomios.sql
SELECT
    id_nosocomio::NUMBER AS id_nosocomio,
    TRIM(UPPER(borough)) AS borough,
    TRIM(codigo_postal) AS codigo_postal
FROM {{ ref('stg_ems_nosocomios') }}
QUALIFY ROW_NUMBER() OVER (PARTITION BY id_nosocomio ORDER BY _airbyte_extracted_at DESC) = 1