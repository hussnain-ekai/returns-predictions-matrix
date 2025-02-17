{{ config(materialized='table') }}

with deduped as (
    select
        *,
        row_number() over (partition by return_item_id order by created_at, updated_at) as rn
    from {{ source('raw', 'return_items') }}
)

select
    return_item_id,
    return_id,
    order_item_id,
    condition_received,
    reason_code,
    inspected_grade_id,
    disposition_outcome_id,
    created_at,
    updated_at
from deduped
where rn = 1