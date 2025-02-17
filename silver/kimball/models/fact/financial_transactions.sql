{{ config(materialized='table') }}

with transactions as (
    select 
        transaction_id as transaction_key,
        return_id,
        'Refund' as transaction_type,
        CAST(amount as decimal) as amount,
        CAST(transaction_date as date) as transaction_date,
        CAST(created_at as date) as created_at,
        CAST(updated_at as date) as updated_at
    from {{ ref('stg_financial_transactions') }}
    where amount >= 0
)

select t.*
from transactions t
join {{ ref('stg_returns') }} r on t.return_id = r.return_id