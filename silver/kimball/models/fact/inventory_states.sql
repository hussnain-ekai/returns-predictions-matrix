{{ config(materialized='table') }}

with inventory as (
    select
        inventory_state_id,  -- original surrogate key source
        return_item_id,
        location_id,
        current_condition_grade_id,
        current_status,
        updated_at
    from {{ ref('stg_inventory_states') }}
),

validated_inventory as (
    select
        -- Generate surrogate key using inventory_state_id
        inventory_state_id as inventory_state_key,
        return_item_id,
        i.location_id,
        current_condition_grade_id,
        current_status,
        cast(updated_at as timestamp) as updated_at
    from inventory i
    -- Ensure referential integrity by joining to valid location and condition grade records
    inner join {{ ref('stg_inventory_locations') }} il on i.location_id = il.location_id
    inner join {{ ref('stg_condition_grades') }} cg on i.current_condition_grade_id = cg.grade_id
    -- Ensure the return_item_id is valid
    inner join {{ ref('stg_return_items') }} ri on i.return_item_id = ri.return_item_id
    where
        -- Validate that current_status is within the allowed set of status codes
        i.current_status in ('Active', 'Inactive', 'In Transit')
        and
        -- Verify that updated_at can be cast to a valid timestamp
        try_cast(i.updated_at as timestamp) is not null
        and
        -- Load only current state snapshot records that pass all checks
        updated_at is not null
)

select
    inventory_state_key,
    return_item_id,
    location_id,
    current_condition_grade_id,
    current_status,
    updated_at
from validated_inventory