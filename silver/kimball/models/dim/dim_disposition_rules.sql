{{ config(materialized='table') }}

with cleansed as (
    select
        rule_id as rule_key, -- Generate surrogate key using rule_id
        trim(sku) as sku, -- Trim and standardize
        cast(condition_grade_id as int) as condition_grade_id, -- Cast to integer
        lower(preferred_channel) as preferred_channel, -- Normalize channel text
        cast(decision_priority as int) as decision_priority, -- Convert to integer
        to_timestamp(created_at, 'YYYY-MM-DD HH24:MI:SS') as created_at, -- Convert to timestamp
        to_timestamp(updated_at, 'YYYY-MM-DD HH24:MI:SS') as updated_at -- Convert to timestamp
    from {{ ref('stg_disposition_rules') }}
    where rule_id is not null -- Ensure rule_id is non-null
)

select
    c.rule_key,
    c.sku,
    c.condition_grade_id,
    c.preferred_channel,
    c.decision_priority,
    c.created_at,
    c.updated_at
from cleansed c

-- Verify foreign keys exist by joining to product_master and condition_grades
join {{ ref('stg_product_master') }} pm on c.sku = pm.sku
join {{ ref('stg_condition_grades') }} cg on c.condition_grade_id = cg.grade_id
;
