{{ config(materialized='table', schema='fact', description='Stores customer order information including totals, dates, and sales channels. This model aggregates order_total from related order items and validates customer existence from stg_customers.') }}

with order_items_agg as (
    select 
        order_id,
        sum(unit_price * quantity) as aggregated_order_total
    from {{ ref('stg_order_items') }}
    group by order_id
),

validated_orders as (
    select 
        o.order_id,
        o.order_external_id,
        o.customer_id,
        /* Generate surrogate key for order using order_id */
        o.order_id as order_key,
        cast(o.order_date as date) as order_date,
        cast(o.order_total as decimal) as order_total,
        o.sales_channel,
        cast(o.created_at as date) as created_at,
        cast(o.updated_at as date) as updated_at
    from {{ ref('stg_orders') }} o
    inner join order_items_agg oi on o.order_id = oi.order_id
    /* Verify that order_total reflects the aggregated sum of order items */
    where o.order_total = oi.aggregated_order_total
),

existing_customers as (
    select distinct customer_id from {{ ref('stg_customers') }}
)

select 
    vo.order_key,
    vo.order_external_id,
    vo.customer_id,
    vo.order_date,
    vo.order_total,
    vo.sales_channel,
    vo.created_at,
    vo.updated_at
from validated_orders vo
inner join existing_customers ec on vo.customer_id = ec.customer_id
;
