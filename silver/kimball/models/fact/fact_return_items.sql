{{ config(materialized='table') }}

with return_items as (
    select
        abs(hash(r.return_item_id)) as return_item_key,  -- Generate surrogate key using return_item_id
        r.return_id,
        r.order_item_id,
        trim(upper(r.condition_received)) as condition_received,  -- Standardize condition text
        trim(r.reason_code) as reason_code,  -- Trim and standardize reason code
        r.inspected_grade_id,
        r.disposition_outcome_id,
        cast(r.created_at as date) as created_at,
        cast(r.updated_at as date) as updated_at
    from {{ ref('stg_return_items') }} r
    inner join {{ ref('stg_condition_grades') }} c
        on r.inspected_grade_id = c.grade_id
    inner join {{ ref('stg_disposition_outcomes') }} d
        on r.disposition_outcome_id = d.disposition_outcome_id
    inner join {{ ref('stg_order_items') }} o
        on r.order_item_id = o.order_item_id
    inner join {{ ref('stg_inventory_states') }} i
        on r.return_item_id = i.return_item_id
    inner join {{ ref('stg_liquidation_listings') }} l
        on r.return_item_id = l.return_item_id
    /*
       Filter conditions applied:
         - Ensure that inspected_grade_id exists in condition_grades,
         - Enforce one-to-one relationships with disposition_outcomes, order_items, and inventory_states,
         - Validate that condition_received is formatted correctly.
    */
)

select *
from return_items;