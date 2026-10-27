-- int_ems_incidentes.sql
SELECT
    id_incidente::NUMBER AS id_incidente,
    id_choque::NUMBER AS id_choque,
    TRIM(UPPER(borough)) AS borough,
    ts_incidente::TIMESTAMP_NTZ AS ts_incidente,
    TRIM(UPPER(area_despacho)) AS area_despacho,
    TRIM(codigo_postal) AS codigo_postal,
    id_ambulancia::NUMBER AS id_ambulancia,
    TRIM(UPPER(severidad_inicial)) AS severidad_inicial,
    TRIM(UPPER(severidad_final)) AS severidad_final,
    precinto_policial::NUMBER AS precinto_policial,
    TRIM(UPPER(codigo_disposicion)) AS codigo_disposicion,
    TRIM(UPPER(tipo_incidente_oem)) AS tipo_incidente_oem,
    TRIM(UPPER(tipo_llamada_inicial)) AS tipo_llamada_inicial,
    TRIM(UPPER(tipo_llamada_final)) AS tipo_llamada_final,
    TRIM(UPPER(indicador_standby)) AS indicador_standby,
    TRIM(UPPER(indicador_retenido)) AS indicador_retenido,
    TRIM(UPPER(indicador_reapertura)) AS indicador_reapertura,
    TRIM(UPPER(indicador_transferencia)) AS indicador_transferencia,
    TRIM(UPPER(indicador_evento_especial)) AS indicador_evento_especial
FROM {{ ref('stg_ems_incidentes') }}
WHERE ts_incidente <= CURRENT_TIMESTAMP()
QUALIFY ROW_NUMBER() OVER (PARTITION BY id_incidente ORDER BY _airbyte_extracted_at DESC) = 1