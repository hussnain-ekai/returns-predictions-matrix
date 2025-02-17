{{config(materialized='table')}}

WITH source_data AS (
    SELECT DISTINCT
        sku,
        product_name,
        category,
        brand,
        cost_basis,
        supplier_id,
        created_at,
        updated_at
    FROM {{ source('raw', 'product_master') }}
)

SELECT *
FROM source_data;
