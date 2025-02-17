{{ config(materialized='table') }}

WITH valid_partner_skus AS (
    SELECT
        partner_sku_id,
        partner_name,
        partner_sku,
        internal_sku,
        created_at,
        updated_at
    FROM {{ ref('stg_partner_skus') }}
    WHERE partner_sku_id IS NOT NULL
      AND partner_name IS NOT NULL AND partner_name <> ''
      AND partner_sku IS NOT NULL AND partner_sku <> ''
),
valid_product_master AS (
    SELECT sku
    FROM {{ ref('stg_product_master') }}
)

SELECT
    partner_sku_id AS partner_sku_key,
    TRIM(partner_name) AS partner_name,
    TRIM(partner_sku) AS partner_sku,
    TRIM(internal_sku) AS internal_sku,
    CAST(created_at AS timestamp) AS created_at,
    CAST(updated_at AS timestamp) AS updated_at
FROM valid_partner_skus
JOIN valid_product_master
    ON valid_partner_skus.internal_sku = valid_product_master.sku