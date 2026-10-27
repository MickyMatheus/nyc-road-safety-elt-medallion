{% macro imputar_mediana(columna, tabla_ref) %}
    COALESCE(
        {{ columna }},
        (SELECT MEDIAN({{ columna }}) FROM {{ tabla_ref }})
    )
{% endmacro %}