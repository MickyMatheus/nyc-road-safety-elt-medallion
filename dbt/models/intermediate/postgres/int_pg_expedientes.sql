-- models/intermediate/postgres/int_pg_expedientes.sql
SELECT
    id_expediente::NUMBER AS id_expediente,
    TRIM(UPPER(estado_legal)) AS estado_legal,
    id_choque_transito::NUMBER AS id_choque_transito,
    fecha_apertura_caso::DATE AS fecha_apertura_caso,
    TRIM(observaciones_internas) AS observaciones_internas,
    placa_oficial_investigador::NUMBER AS placa_oficial_investigador
FROM {{ ref('stg_pg_expedientes') }}
WHERE fecha_apertura_caso <= CURRENT_DATE()
QUALIFY ROW_NUMBER() OVER (PARTITION BY id_expediente ORDER BY _airbyte_extracted_at DESC) = 1