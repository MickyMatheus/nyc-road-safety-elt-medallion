WITH source AS (
    SELECT * FROM {{ ref('stg_311') }}
),

limpieza AS (
    SELECT
        CAST(UNIQUE_KEY AS STRING) AS id_queja,
        CAST(CREATED_DATE AS TIMESTAMP) AS fecha_creacion,
        COALESCE(AGENCY, 'SIN DATO') AS agencia,
        COALESCE(PROBLEM, 'SIN DATO') AS tipo_queja,
        COALESCE(PROBLEM_DETAIL, 'SIN DATO') AS descripcion_queja,
        COALESCE(STATUS, 'SIN ESTADO') AS estado_queja,
        COALESCE(BOROUGH, 'UNSPECIFIED') AS distrito,
        COALESCE(STREET_NAME, 'SIN CALLE') AS calle_principal,
        COALESCE(INTERSECTION_STREET_1, '') AS calle_interseccion_1,
        POLICE_PRECINCT AS precinto_policial,
        CAST(LATITUDE AS FLOAT) AS latitud,
        CAST(LONGITUDE AS FLOAT) AS longitud
    FROM source
    WHERE LATITUDE IS NOT NULL AND LONGITUDE IS NOT NULL
)

SELECT * FROM limpieza