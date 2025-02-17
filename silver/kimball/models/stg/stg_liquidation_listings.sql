{{ config(materialized='table', schema='staging') }}

with raw_liquidation_listings as (
    select *
    from {{ source('raw', 'liquidation_listings') }}
),

cleaned_listings as (
    select distinct *
    from raw_liquidation_listings
    where listing_id is not null
)

select 
    listing_id,
    return_item_id,
    partner_sku_id,
    condition,
    sold_price,
    listing_date,
    buyer_id,
    created_at,
    updated_at
from cleaned_listings;