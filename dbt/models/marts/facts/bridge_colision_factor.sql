WITH factor_incidente AS (
    SELECT * FROM {{ ref('int_transito__incidente_factor') }}
),

fact_colision AS (
    SELECT colision_key, id_choque_origen FROM {{ ref('fact_colision') }}
),

dim_factor AS (
    SELECT factor_key, id_factor_origen FROM {{ ref('dim_factor') }}
)

SELECT
    fc.colision_key,
    df.factor_key
FROM factor_incidente fi
INNER JOIN fact_colision fc ON fi.id_choque = fc.id_choque_origen
INNER JOIN dim_factor df ON fi.id_factor = df.id_factor_origen