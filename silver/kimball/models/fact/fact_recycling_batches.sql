{{ config(materialized='table') }}

with src as (
    select
        -- Generate surrogate key using batch_id
        batch_id as batch_key,
        trim(processor_name) as processor_name,
        lower(material_type) as material_type,
        cast(weight_kg as decimal) as weight_kg,
        cast(processing_date as date) as processing_date,
        cast(disposal_cost as decimal) as disposal_cost,
        certificate_of_destruction,
        cast(created_at as date) as created_at,
        cast(updated_at as date) as updated_at
    from {{ ref('stg_recycling_batches') }}
)

select
    batch_key,
    processor_name,
    material_type,
    weight_kg,
    processing_date,
    disposal_cost,
    certificate_of_destruction,
    created_at,
    updated_at
from src
where weight_kg > 0
  and disposal_cost >= 0
  and processing_date is not null
  and created_at is not null
  and updated_at is not null