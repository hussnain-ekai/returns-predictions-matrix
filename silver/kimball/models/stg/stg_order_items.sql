{{ config(materialized='table', schema='stg') }}

with raw_order_items as (
    select distinct *
    from {{ source('raw', 'order_items') }}
)

select *
from raw_order_items;
