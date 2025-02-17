{{ config(materialized='table', schema='stg') }}

with disposition_outcomes as (
    select distinct *
    from {{ source('raw', 'disposition_outcomes') }}
)

select *
from disposition_outcomes;