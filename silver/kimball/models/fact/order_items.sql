{{ config(materialized='table') }}

with order_items_src as (
    select
        order_item_id,
        order_id,
        sku,
        quantity,
        unit_price,
        created_at,
        updated_at
    from {{ ref('stg_order_items') }}
    where quantity >= 0
      and unit_price >= 0
      and created_at is not null
      and updated_at is not null
),
validated_orders as (
    select order_id
    from {{ ref('stg_orders') }}
),
validated_products as (
    select sku
    from {{ ref('stg_product_master') }}
)

select
    -- Generate surrogate key using order_item_id
    order_item_id as order_item_key,
    oi.order_id,
    trim(oi.sku) as sku,
    cast(oi.quantity as int) as quantity,
    cast(oi.unit_price as decimal) as unit_price,
    to_date(oi.created_at, 'YYYY-MM-DD') as created_at,
    to_date(oi.updated_at, 'YYYY-MM-DD') as updated_at
from order_items_src oi

-- Ensure valid order_id exists
inner join validated_orders vo on oi.order_id = vo.order_id
-- Ensure sku exists in product_master
inner join validated_products vp on oi.sku = vp.sku
;
