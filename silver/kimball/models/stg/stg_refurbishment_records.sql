{{ config(materialized='table') }}

with source_data as (
    select
        refurb_id,
        return_item_id,
        partner_sku_id,
        refurb_grade,
        cost_of_refurb,
        refurb_date,
        warranty_period_days,
        notes,
        created_at,
        updated_at,
        row_number() over (partition by refurb_id order by updated_at desc) as rn
    from {{ source('raw', 'refurbishment_records') }}
)

select
    refurb_id,
    return_item_id,
    partner_sku_id,
    refurb_grade,
    cost_of_refurb,
    refurb_date,
    warranty_period_days,
    notes,
    created_at,
    updated_at
from source_data
where rn = 1