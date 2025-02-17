{{ config(materialized='table') }}

with raw as (
    select distinct *
    from {{ source('raw', 'recycling_batches') }}
)

select
    batch_id,
    processor_name,
    material_type,
    weight_kg,
    processing_date,
    disposal_cost,
    certificate_of_destruction,
    created_at,
    updated_at
from raw
