WITH vehiculos AS (
    SELECT * FROM {{ ref('int_dmv__vehiculos') }}
)

SELECT
    ROW_NUMBER() OVER (ORDER BY id_vehiculo) AS vehiculo_key,
    id_vehiculo AS id_vehiculo_origen,
    patente_placa,
    marca,
    modelo,
    anio_fabricacion,
    'ESTÁNDAR' AS tipo_vehiculo,
    tipo_combustible,
    'ACTIVO' AS estado_registro
FROM vehiculos