{{ config(materialized='table') }}

with base as (
    select
        return_id,
        return_external_id,
        order_id,
        return_initiated_date,
        return_received_date,
        refund_issued_date,
        created_at,
        updated_at
    from {{ ref('stg_returns') }}
    where return_initiated_date <= return_received_date
      and return_received_date <= refund_issued_date
),
validated as (
    select
        b.*
    from base b
    inner join {{ ref('stg_orders') }} o
        on b.order_id = o.order_id
    inner join {{ ref('stg_financial_transactions') }} ft
        on b.return_id = ft.return_id
    where exists (
        select 1 from {{ ref('stg_return_items') }} ri
        where ri.return_id = b.return_id
    )
)

select
    return_id as return_key, -- Generate surrogate key using return_id
    case
        when return_external_id is not null then concat(substr(trim(return_external_id), 1, 3), '****')
        else null
    end as return_external_id,
    order_id,
    cast(return_initiated_date as date) as return_initiated_date,
    cast(return_received_date as date) as return_received_date,
    cast(refund_issued_date as date) as refund_issued_date,
    cast(created_at as date) as created_at,
    cast(updated_at as date) as updated_at
from validated;