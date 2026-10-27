SELECT
    id_vehiculo::NUMBER AS id_vehiculo,
    id_tipo_vehiculo::NUMBER AS id_tipo_vehiculo,
    COALESCE(TRIM(UPPER(patente_placa)), 'SIN_PLACA') AS patente_placa,
    COALESCE(TRIM(UPPER(marca)), 'SIN_DATO') AS marca,
    COALESCE(TRIM(UPPER(modelo)), 'SIN_DATO') AS modelo,
    COALESCE(TRIM(UPPER(tipo_combustible)), 'DESCONOCIDO') AS tipo_combustible,
    anio_fabricacion::NUMBER AS anio_fabricacion,
    fecha_alta::DATE AS fecha_alta,
    fecha_actualizacion::TIMESTAMP AS fecha_actualizacion
FROM {{ ref('stg_dmv__vehiculos') }}
WHERE id_vehiculo IS NOT NULL
  AND (fecha_alta IS NULL OR fecha_alta <= CURRENT_DATE())
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY id_vehiculo 
    ORDER BY _airbyte_extracted_at DESC
) = 1