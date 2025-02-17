{{ config(materialized='table') }}

with deduped_returns as (
    select *
    from (
        select *,
               row_number() over (partition by return_id order by created_at desc) as rn
        from {{ source('raw', 'returns') }}
    ) sub
    where rn = 1
)

select
    return_id,
    return_external_id,
    order_id,
    return_initiated_date,
    return_received_date,
    refund_issued_date,
    created_at,
    updated_at
from deduped_returns
;