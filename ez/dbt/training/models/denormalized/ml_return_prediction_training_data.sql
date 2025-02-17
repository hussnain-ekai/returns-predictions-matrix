{{ config(materialized='table', post_hook='ANALYZE TABLE {{ this }}', persist_docs={'relation': 'description', 'columns': True}) }}

with returns as (
    select * from {{ source('dbt_project_source', 'returns') }}
),
orders as (
    select * from {{ source('dbt_project_source', 'orders') }}
),
customers as (
    select * from {{ source('dbt_project_source', 'customers') }}
),
order_items as (
    select * from {{ source('dbt_project_source', 'order_items') }}
),
return_items as (
    select * from {{ source('dbt_project_source', 'return_items') }}
),
disposition_outcomes as (
    select * from {{ source('dbt_project_source', 'disposition_outcomes') }}
),
inventory_states as (
    select * from {{ source('dbt_project_source', 'inventory_states') }}
),
product_master as (
    select * from {{ source('dbt_project_source', 'product_master') }}
),
disposition_rules as (
    select * from {{ source('dbt_project_source', 'disposition_rules') }}
),
financial_transactions as (
    select * from {{ source('dbt_project_source', 'financial_transactions') }}
),
liquidation_listings as (
    select * from {{ source('dbt_project_source', 'liquidation_listings') }}
),
partner_skus as (
    select * from {{ source('dbt_project_source', 'partner_skus') }}
),
inventory_locations as (
    select * from {{ source('dbt_project_source', 'inventory_locations') }}
),
refurbishment_records as (
    select * from {{ source('dbt_project_source', 'refurbishment_records') }}
),
shipment_records as (
    select * from {{ source('dbt_project_source', 'shipment_records') }}
),
recycling_batches as (
    select * from {{ source('dbt_project_source', 'recycling_batches') }}
),
condition_grades as (
    select * from {{ source('dbt_project_source', 'condition_grades') }}
)

select
    returns.return_id,
    returns.return_external_id,
    orders.order_id,
    orders.order_date,
    orders.order_total,
    orders.sales_channel,
    customers.customer_external_id,
    null as customer_age_bracket,
    product_master.category as product_categories,
    product_master.brand as product_brands,
    order_items.sku as order_item_skus,
    order_items.quantity,
    order_items.unit_price,
    financial_transactions.amount as refund_amount,
    financial_transactions.transaction_date as refund_transaction_date,
    returns.return_initiated_date,
    returns.return_received_date,
    returns.refund_issued_date,
    return_items.condition_received,
    disposition_outcomes.chosen_channel as disposition_channel,
    disposition_outcomes.recovery_value,
    liquidation_listings.condition as listing_condition,
    liquidation_listings.sold_price,
    shipment_records.status as shipment_status,
    shipment_records.freight_cost as shipment_freight_cost,
    disposition_outcomes.processed_date,
    refurbishment_records.refurb_grade,
    refurbishment_records.cost_of_refurb,
    refurbishment_records.warranty_period_days,
    recycling_batches.material_type as recycling_material_type,
    recycling_batches.weight_kg as recycling_weight,
    recycling_batches.disposal_cost,
    recycling_batches.certificate_of_destruction as certified_destruction,
    null as engineered_feature1,
    null as engineered_feature2,
    null as engineered_feature3,
    null as label,
    orders.order_total as total_order_value,
    order_items.unit_price as average_unit_price,
    financial_transactions.amount as total_refund_value
from returns
join orders on returns.order_id = orders.order_id
join customers on orders.customer_id = customers.customer_id
join order_items on orders.order_id = order_items.order_id
join return_items on order_items.order_item_id = return_items.order_item_id
    and returns.return_id = return_items.return_id
join disposition_outcomes on return_items.disposition_outcome_id = disposition_outcomes.disposition_outcome_id
join inventory_states on return_items.return_item_id = inventory_states.return_item_id
join product_master on order_items.sku = product_master.sku
join disposition_rules on product_master.sku = disposition_rules.sku
join financial_transactions on returns.return_id = financial_transactions.return_id
join liquidation_listings on return_items.return_item_id = liquidation_listings.return_item_id
join partner_skus on liquidation_listings.partner_sku_id = partner_skus.partner_sku_id
join inventory_locations on inventory_states.location_id = inventory_locations.location_id
join refurbishment_records on return_items.return_item_id = refurbishment_records.return_item_id
    and refurbishment_records.partner_sku_id = partner_skus.partner_sku_id
join shipment_records on (shipment_records.origin_location_id = inventory_locations.location_id or shipment_records.destination_location_id = inventory_locations.location_id)
join recycling_batches on returns.return_id = recycling_batches.batch_id
join condition_grades on condition_grades.grade_id = disposition_rules.condition_grade_id
    and condition_grades.grade_id = inventory_states.current_condition_grade_id
    and condition_grades.grade_id = return_items.inspected_grade_id
;