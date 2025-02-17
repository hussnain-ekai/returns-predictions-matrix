{{ config(materialized='table') }}

with orders as (
    select distinct
        order_id,
        order_external_id,
        customer_id,
        order_date,
        order_total,
        sales_channel,
        created_at,
        updated_at
    from {{ source('raw', 'orders') }}
)

select *
from orders;
