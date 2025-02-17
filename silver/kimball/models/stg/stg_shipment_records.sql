{{ config(materialized='table') }}

with shipment_records as (
    select distinct
        shipment_id,
        tracking_number,
        origin_location_id,
        destination_location_id,
        pickup_date,
        delivery_date,
        status,
        freight_cost,
        created_at,
        updated_at
    from {{ source('raw', 'shipment_records') }}
)

select
    shipment_id,
    tracking_number,
    origin_location_id,
    destination_location_id,
    pickup_date,
    delivery_date,
    status,
    freight_cost,
    created_at,
    updated_at
from shipment_records;