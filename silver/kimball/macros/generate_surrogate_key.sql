{% macro generate_surrogate_key(column) %}
    abs(hash({{ column }}))
{% endmacro %}