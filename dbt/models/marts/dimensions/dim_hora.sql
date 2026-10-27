WITH horas AS (
    SELECT SEQ4() AS hora FROM TABLE(GENERATOR(ROWCOUNT => 24))
)

SELECT
    hora AS hora_key,
    TIME_FROM_PARTS(hora, 0, 0) AS hora_completa,
    hora AS hora,
    0 AS minuto,
    CASE
        WHEN hora BETWEEN 0 AND 5 THEN 'Madrugada'
        WHEN hora BETWEEN 6 AND 11 THEN 'Mañana'
        WHEN hora BETWEEN 12 AND 18 THEN 'Tarde'
        ELSE 'Noche'
    END AS franja_horaria
FROM horas