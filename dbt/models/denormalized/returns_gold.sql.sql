-- This model creates the denormalized returns_gold table
-- Grain: return_items.return_item_id

{{ config(
    materialized='table',
    post_hook=['VACUUM ANALYZE {{ this }}'],
    persist_docs={'relation': True, 'columns': True}
) }}

with return_items as (
    select *
    from {{ source('dbt_project_source', 'return_items') }}
),
returns as (
    select *
    from {{ source('dbt_project_source', 'returns') }}
),
order_items as (
    select *
    from {{ source('dbt_project_source', 'order_items') }}
),
orders as (
    select *
    from {{ source('dbt_project_source', 'orders') }}
),
customers as (
    select *
    from {{ source('dbt_project_source', 'customers') }}
),
product_master as (
    select *
    from {{ source('dbt_project_source', 'product_master') }}
),
partner_skus as (
    select *
    from {{ source('dbt_project_source', 'partner_skus') }}
),
disposition_outcomes as (
    select *
    from {{ source('dbt_project_source', 'disposition_outcomes') }}
),
disposition_rules as (
    select *
    from {{ source('dbt_project_source', 'disposition_rules') }}
),
condition_grades as (
    select *
    from {{ source('dbt_project_source', 'condition_grades') }}
),
financial_transactions as (
    select *
    from {{ source('dbt_project_source', 'financial_transactions') }}
),
inventory_states as (
    select *
    from {{ source('dbt_project_source', 'inventory_states') }}
),
liquidation_listings as (
    select *
    from {{ source('dbt_project_source', 'liquidation_listings') }}
),
refurbishment_records as (
    select *
    from {{ source('dbt_project_source', 'refurbishment_records') }}
),
shipment_records as (
    select *
    from {{ source('dbt_project_source', 'shipment_records') }}
)

select
    ri.return_item_id,
    ri.return_id,
    ri.order_item_id,
    o.order_id,
    o.order_external_id,
    o.order_date,
    o.order_total,
    o.sales_channel,
    c.customer_id,
    c.customer_external_id,
    c.first_name,
    c.last_name,
    c.email,
    c.created_at as customer_created_at,
    pm.sku,
    pm.product_name,
    pm.category,
    pm.brand,
    pm.cost_basis,
    ps.partner_sku,
    ri.condition_received,
    ri.reason_code,
    ri.inspected_grade_id,
    do.chosen_channel,
    do.recovery_value,
    ft.transaction_type,
    ft.amount,
    ft.transaction_date,
    ist.current_status,
    ist.current_condition_grade_id,
    ll.sold_price,
    ll.listing_date,
    ll.buyer_id,
    rr.refurb_grade,
    rr.cost_of_refurb,
    rr.refurb_date,
    sr.tracking_number,
    sr.pickup_date,
    sr.delivery_date,
    sr.status as shipment_status,
    sr.freight_cost,
    -- Placeholder columns for metrics that may be computed later
    NULL as customer_tenure_days,
    NULL as repeat_purchase_count,
    NULL as profit_margin
from return_items ri

    left join disposition_outcomes do
        on ri.return_item_id = do.return_item_id
    left join inventory_states ist
        on ri.return_item_id = ist.return_item_id
    left join order_items oi
        on ri.order_item_id = oi.order_item_id
    left join orders o
        on oi.order_id = o.order_id
    left join customers c
        on o.customer_id = c.customer_id
    left join product_master pm
        on oi.sku = pm.sku
    left join partner_skus ps
        on pm.sku = ps.internal_sku
    left join returns r
        on ri.return_id = r.return_id
    left join financial_transactions ft
        on r.return_id = ft.return_id
    left join liquidation_listings ll
        on ri.return_item_id = ll.return_item_id
    left join refurbishment_records rr
        on ri.return_item_id = rr.return_item_id
    left join disposition_rules dr
        on pm.sku = dr.sku
    left join condition_grades cg
        on dr.condition_grade_id = cg.grade_id and ri.inspected_grade_id = cg.grade_id
    -- The join for shipment_records does not have an explicit condition in template;
    -- Here we assume a relationship by joining orders.order_id to shipment_records.shipment_id for demonstration purposes
    left join shipment_records sr
        on o.order_id = sr.shipment_id
;
