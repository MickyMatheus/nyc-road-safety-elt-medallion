WITH personas AS (
    SELECT * FROM {{ ref('int_ems_personas') }}
)

SELECT
    ROW_NUMBER() OVER (ORDER BY id_persona) AS persona_key,
    id_persona::NUMBER AS id_persona_origen,
    
    -- Protegemos la edad contra nulos usando -1 como valor centinela estándar
    COALESCE(edad, -1) AS edad,
    
    COALESCE(TRIM(UPPER(sexo)), 'DESCONOCIDO') AS genero,
    COALESCE(tipo_persona, 'DESCONOCIDO') AS tipo_actor,
    
    -- Lógica de rangos de edad blindada contra nulos
    CASE 
        WHEN edad IS NULL OR edad < 0 THEN 'Desconocido'
        WHEN edad < 18 THEN 'Menor de 18'
        WHEN edad BETWEEN 18 AND 29 THEN '18-29'
        WHEN edad BETWEEN 30 AND 49 THEN '30-49'
        WHEN edad BETWEEN 50 AND 64 THEN '50-64'
        ELSE '65 o más'
    END AS rango_edad

FROM personas