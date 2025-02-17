{{ config(materialized='table', scd_type='Type 2') }}

with source as (
    select
        sku,
        product_name,
        category,
        brand,
        cost_basis,
        supplier_id,
        created_at,
        updated_at
    from {{ ref('stg_product_master') }}
)

select
    md5(sku) as product_key,  -- Generate surrogate key using sku
    trim(product_name) as product_name,  -- Trim and standardize product name
    trim(category) as category,  -- Standardize category naming
    upper(trim(brand)) as brand,  -- Capitalize and trim brand name
    cast(cost_basis as decimal) as cost_basis,  -- Cast to decimal and validate numeric value
    trim(supplier_id) as supplier_id,  -- Trim and validate reference format
    to_timestamp(created_at, 'YYYY-MM-DD HH24:MI:SS') as created_at,  -- Convert string to timestamp
    to_timestamp(updated_at, 'YYYY-MM-DD HH24:MI:SS') as updated_at  -- Convert string to timestamp
from source
where sku is not null  -- Ensures that the primary key exists
;