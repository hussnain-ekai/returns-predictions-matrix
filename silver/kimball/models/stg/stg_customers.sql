{{ config(materialized='view') }}

with raw_customers as (
    select *
    from {{ source('raw', 'customers') }}
)

select
    customer_id,
    md5(customer_external_id) as customer_external_id,
    md5(first_name) as first_name,
    md5(last_name) as last_name,
    md5(email) as email,
    created_at,
    updated_at
from raw_customers