-- int_ems_ambulancias.sql
SELECT
    id_ambulancia::NUMBER AS id_ambulancia,
    TRIM(UPPER(borough)) AS borough,
    TRIM(UPPER(area_despacho)) AS area_despacho,
    TRIM(UPPER(tipo_soporte_vital)) AS tipo_soporte_vital
FROM {{ ref('stg_ems_ambulancias') }}
QUALIFY ROW_NUMBER() OVER (PARTITION BY id_ambulancia ORDER BY _airbyte_extracted_at DESC) = 1