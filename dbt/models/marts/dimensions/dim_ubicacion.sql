WITH ubicaciones AS (
    SELECT * FROM {{ ref('int_transito__ubicaciones') }}
),

distritos AS (
    SELECT * FROM {{ ref('int_transito__distritos') }}
)

SELECT
    ROW_NUMBER() OVER (ORDER BY u.id_ubicacion) AS ubicacion_key,
    u.id_ubicacion AS id_ubicacion_origen,
    COALESCE(d.nombre_distrito, 'SIN_DATO') AS distrito,
    u.codigo_postal,
    u.latitud,
    u.longitud,
    u.calle_principal,
    u.calle_transversal,
    u.direccion_especifica
FROM ubicaciones u
LEFT JOIN distritos d ON u.id_distrito = d.id_distrito