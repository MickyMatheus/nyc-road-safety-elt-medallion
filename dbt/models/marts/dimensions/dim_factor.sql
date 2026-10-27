WITH factores AS (
    SELECT * FROM {{ ref('int_transito__factores') }}
)

SELECT
    ROW_NUMBER() OVER (ORDER BY id_factor) AS factor_key,
    id_factor AS id_factor_origen,
    descripcion_factor
FROM factores