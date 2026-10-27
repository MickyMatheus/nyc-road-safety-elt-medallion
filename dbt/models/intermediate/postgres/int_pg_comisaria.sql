-- models/intermediate/postgres/int_pg_comisarias.sql
SELECT
    id_comisaria::NUMBER AS id_comisaria,
    TRIM(UPPER(distrito)) AS distrito,
    TRIM(nombre_recinto) AS nombre_recinto,
    TRIM(direccion_fisica) AS direccion_fisica,
    TRIM(telefono_contacto) AS telefono_contacto
FROM {{ ref('stg_pg_comisarias') }}
QUALIFY ROW_NUMBER() OVER (PARTITION BY id_comisaria ORDER BY _airbyte_extracted_at DESC) = 1