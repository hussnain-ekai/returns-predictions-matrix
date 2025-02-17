{{config(materialized='table')}}

with cleaned as (
    select distinct
        location_id,
        location_code,
        location_name,
        address,
        city,
        state,
        country,
        created_at,
        updated_at
    from {{ source('raw', 'inventory_locations') }}
)

select *
from cleaned;
