{{ config(materialized='table') }}
with validated_disposition_outcomes as (
    select
        d.disposition_outcome_id as disposition_outcome_key,  -- surrogate key generated from disposition_outcome_id
        d.return_item_id,
        d.chosen_channel,
        cast(d.recovery_value as decimal) as recovery_value,  -- cast to decimal and apply non-negative validation in where clause
        cast(d.processed_date as date) as processed_date,  -- standardized date format
        cast(d.created_at as date) as created_at,
        cast(d.updated_at as date) as updated_at
    from {{ ref('stg_disposition_outcomes') }} d
    -- Join to ensure that return_item_id exists in stg_return_items
    inner join {{ ref('stg_return_items') }} r on d.return_item_id = r.return_item_id
    where 
        d.recovery_value >= 0
        and d.processed_date is not null
)

select *
from validated_disposition_outcomes
;