{{ config(materialized='table') }}

with source as (
    select
        location_id as raw_location_id,
        location_code,
        location_name,
        address,
        city,
        state,
        country,
        created_at,
        updated_at
    from {{ ref('stg_inventory_locations') }}
)

select
    cast(raw_location_id as int) as location_key, -- Generate surrogate key using location_id
    trim(location_code) as location_code,          -- Trim and validate format (e.g., 'WH-XX')
    trim(location_name) as location_name,          -- Trim and standardize
    address as address,                             -- Standardize address formatting
    initcap(trim(city)) as city,                    -- Trim and capitalize
    upper(trim(state)) as state,                    -- Ensure state is a valid two-letter code
    upper(trim(country)) as country,                -- Standardize country name (e.g. 'USA')
    to_timestamp(created_at, 'YYYY-MM-DD HH24:MI:SS') as created_at, -- Convert to timestamp
    to_timestamp(updated_at, 'YYYY-MM-DD HH24:MI:SS') as updated_at  -- Convert to timestamp
from source
where location_code is not null
  and location_name is not null