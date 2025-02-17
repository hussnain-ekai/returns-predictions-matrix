{{ config(materialized='table') }}

with liq as (
    select
        listing_id as listing_key,
        return_item_id,
        partner_sku_id,
        condition,
        cast(sold_price as decimal) as sold_price,
        cast(listing_date as date) as listing_date,
        trim(buyer_id) as buyer_id,
        cast(created_at as date) as created_at,
        cast(updated_at as date) as updated_at
    from {{ ref('stg_liquidation_listings') }}
    where sold_price >= 0
),
rt as (
    select
        return_item_id
    from {{ ref('stg_return_items') }}
),
ps as (
    select
        partner_sku_id
    from {{ ref('stg_partner_skus') }}
)

select
    liq.listing_key,
    liq.return_item_id,
    liq.partner_sku_id,
    liq.condition,
    liq.sold_price,
    liq.listing_date,
    liq.buyer_id,
    liq.created_at,
    liq.updated_at
from liq
inner join rt on liq.return_item_id = rt.return_item_id
inner join ps on liq.partner_sku_id = ps.partner_sku_id