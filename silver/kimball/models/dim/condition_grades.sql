{{ config(materialized='table') }}

with source as (
    select
        grade_id,
        grade_code,
        description,
        created_at,
        updated_at
    from {{ ref('stg_condition_grades') }}
    where grade_id is not null
)

select
    grade_id as grade_key,  -- Generated surrogate key using grade_id
    UPPER(TRIM(grade_code)) as grade_code,  -- Trim and convert to uppercase
    TRIM(description) as description,  -- Trim and standardize textual description
    CAST(created_at as timestamp) as created_at,  -- Convert string to timestamp
    CAST(updated_at as timestamp) as updated_at  -- Convert string to timestamp
from source;