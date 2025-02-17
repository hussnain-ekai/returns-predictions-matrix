{{ config(materialized='table') }}

SELECT
    grade_id,
    grade_code,
    description,
    created_at,
    updated_at
FROM {{ source('raw', 'condition_grades') }}