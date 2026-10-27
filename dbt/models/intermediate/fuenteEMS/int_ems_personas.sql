-- int_ems_personas.sql
SELECT
    id_persona::NUMBER AS id_persona,
    person_id::STRING AS person_id,
    id_choque::NUMBER AS id_choque,
    id_vehiculo::STRING AS id_vehiculo,
    edad::NUMBER AS edad,
    TRIM(UPPER(sexo)) AS sexo,
    TRIM(UPPER(tipo_persona)) AS tipo_persona,
    TRIM(UPPER(rol_peaton)) AS rol_peaton,
    TRIM(UPPER(accion_peaton)) AS accion_peaton,
    TRIM(UPPER(ubicacion_peaton)) AS ubicacion_peaton,
    TRIM(UPPER(eyeccion)) AS eyeccion,
    TRIM(UPPER(equipo_seguridad)) AS equipo_seguridad,
    TRIM(UPPER(posicion_en_vehiculo)) AS posicion_en_vehiculo,
    TRIM(UPPER(factor_contribuyente_1)) AS factor_contribuyente_1,
    TRIM(UPPER(factor_contribuyente_2)) AS factor_contribuyente_2
FROM {{ ref('stg_ems_personas') }}
QUALIFY ROW_NUMBER() OVER (PARTITION BY id_persona ORDER BY _airbyte_extracted_at DESC) = 1