{{ config(materialized='table', schema='staging') }}

with base as (
    select distinct
        rule_id,
        sku,
        condition_grade_id,
        preferred_channel,
        decision_priority,
        created_at,
        updated_at
    from {{ source('raw', 'disposition_rules') }}
)

select *
from base;
