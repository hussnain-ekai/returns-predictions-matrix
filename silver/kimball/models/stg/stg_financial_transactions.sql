{{ config(materialized='table') }}

with raw_financial_transactions as (
    select *
    from {{ source('raw', 'financial_transactions') }}
),
cleaned_transactions as (
    select distinct
           transaction_id,
           return_id,
           transaction_type,
           amount,
           transaction_date,
           notes,
           created_at,
           updated_at
    from raw_financial_transactions
    -- Additional cleansing logic can be applied here if necessary
)

select *
from cleaned_transactions