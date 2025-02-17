{{ config(materialized='table') }}

with cleansed as (
    select distinct *
    from {{ source('raw', 'partner_skus') }}
)

select
    partner_sku_id,
    partner_name,
    partner_sku,
    internal_sku,
    created_at,
    updated_at
from cleansed;