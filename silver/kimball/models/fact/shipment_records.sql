{{ config(materialized='table') }}

with base as (
    select
         shipment_id as shipment_key,
         trim(tracking_number) as tracking_number,
         origin_location_id,
         destination_location_id,
         cast(pickup_date as date) as pickup_date,
         cast(delivery_date as date) as delivery_date,
         upper(trim(status)) as status,
         cast(freight_cost as decimal) as freight_cost,
         cast(created_at as date) as created_at,
         cast(updated_at as date) as updated_at
    from {{ ref('stg_shipment_records') }}
    where freight_cost >= 0
)

select
    b.shipment_key,
    b.tracking_number,
    b.origin_location_id,
    b.destination_location_id,
    b.pickup_date,
    b.delivery_date,
    b.status,
    b.freight_cost,
    b.created_at,
    b.updated_at
from base b
inner join {{ ref('stg_inventory_locations') }} as orig on b.origin_location_id = orig.location_id
inner join {{ ref('stg_inventory_locations') }} as dest on b.destination_location_id = dest.location_id
