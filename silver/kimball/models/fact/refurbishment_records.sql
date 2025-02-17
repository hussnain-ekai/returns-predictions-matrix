{{ config(materialized='table') }}

with base as (
    select r.*
    from {{ ref('stg_refurbishment_records') }} r
    inner join {{ ref('stg_return_items') }} rt on rt.return_item_id = r.return_item_id
    inner join {{ ref('stg_partner_skus') }} ps on ps.partner_sku_id = r.partner_sku_id
    inner join {{ ref('stg_condition_grades') }} cg on cg.grade_code = r.refurb_grade
    where r.cost_of_refurb >= 0
)

select
    r.refurb_id as refurb_key, -- Generated surrogate key using refurb_id
    r.return_item_id,         -- Direct mapping with validation against return_items
    r.partner_sku_id,         -- Map and verify existence in partner_skus
    trim(upper(r.refurb_grade)) as refurb_grade, -- Standardize grade and validate against condition_grades
    cast(r.cost_of_refurb as decimal) as cost_of_refurb, -- Cast to decimal and check non-negative
    cast(r.refurb_date as date) as refurb_date, -- Convert to date
    cast(r.warranty_period_days as int) as warranty_period_days, -- Cast to integer and validate range
    trim(r.notes) as notes, -- Trim and store text as-is
    cast(r.created_at as date) as created_at, -- Convert to date
    cast(r.updated_at as date) as updated_at -- Convert to date
from base r