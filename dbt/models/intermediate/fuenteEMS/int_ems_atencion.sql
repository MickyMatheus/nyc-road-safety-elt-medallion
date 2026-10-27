-- int_ems_atencion.sql
SELECT
    id_atencion::NUMBER AS id_atencion,
    id_persona::NUMBER AS id_persona,
    id_incidente::NUMBER AS id_incidente,
    id_nosocomio::NUMBER AS id_nosocomio,
    id_ambulancia::NUMBER AS id_ambulancia,
    TRIM(UPPER(queja_fisica)) AS queja_fisica,
    TRIM(UPPER(lesion_corporal)) AS lesion_corporal,
    TRIM(UPPER(estado_emocional)) AS estado_emocional,
    TRIM(UPPER(tipo_soporte_vital)) AS tipo_soporte_vital,
    TRIM(UPPER(severidad_preliminar)) AS severidad_preliminar
FROM {{ ref('stg_ems_atencion_medica') }}
QUALIFY ROW_NUMBER() OVER (PARTITION BY id_atencion ORDER BY _airbyte_extracted_at DESC) = 1