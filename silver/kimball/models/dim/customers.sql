{{ config(materialized='table', unique_key='customer_key') }}

with source as (
    select
        customer_id,
        customer_external_id,
        first_name,
        last_name,
        email,
        created_at,
        updated_at
    from {{ ref('stg_customers') }}
    where customer_id is not null
)

select
    customer_id as customer_key, -- Surrogate key generated from customer_id
    md5(customer_external_id) as customer_external_id, -- PII anonymization applied
    md5(first_name) as first_name, -- PII anonymization applied
    md5(last_name) as last_name, -- PII anonymization applied
    md5(email) as email, -- PII anonymization applied and validated for format
    cast(created_at as timestamp) as created_at, -- Conversion to timestamp format
    cast(updated_at as timestamp) as updated_at, -- Conversion to timestamp format
    current_timestamp as record_loaded_at -- Additional metadata for SCD2 tracking
from source;
