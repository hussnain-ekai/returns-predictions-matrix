{{ config(materialized='table') }}

with source_data as (
    select
        inventory_state_id,
        return_item_id,
        location_id,
        current_condition_grade_id,
        current_status,
        updated_at
    from {{ source('raw', 'inventory_states') }}
    where inventory_state_id is not null
)

select
    distinct inventory_state_id,
    return_item_id,
    location_id,
    current_condition_grade_id,
    current_status,
    updated_at
from source_data