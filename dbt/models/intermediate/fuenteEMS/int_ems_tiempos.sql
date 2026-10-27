-- int_ems_tiempos.sql
SELECT
    id_tiempo::NUMBER AS id_tiempo,
    id_incidente::NUMBER AS id_incidente,
    ts_despacho::TIMESTAMP_NTZ AS ts_despacho,
    ts_salida::TIMESTAMP_NTZ AS ts_salida,
    ts_arribo_escena::TIMESTAMP_NTZ AS ts_arribo_escena,
    ts_arribo_hospital::TIMESTAMP_NTZ AS ts_arribo_hospital,
    ts_salida_hospital::TIMESTAMP_NTZ AS ts_salida_hospital,
    ts_cierre::TIMESTAMP_NTZ AS ts_cierre,
    segundos_despacho::NUMBER AS segundos_despacho,
    segundos_traslado::NUMBER AS segundos_traslado,
    segundos_respuesta::NUMBER AS segundos_respuesta,
    tiempo_respuesta_min::FLOAT AS tiempo_respuesta_min,
    TRIM(UPPER(despacho_valido)) AS despacho_valido,
    TRIM(UPPER(respuesta_valida)) AS respuesta_valida
FROM {{ ref('stg_ems_tiempos_respuesta') }}
WHERE ts_cierre <= CURRENT_TIMESTAMP()
QUALIFY ROW_NUMBER() OVER (PARTITION BY id_tiempo ORDER BY _airbyte_extracted_at DESC) = 1