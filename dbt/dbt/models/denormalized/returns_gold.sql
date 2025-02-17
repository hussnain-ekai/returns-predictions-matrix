with base_data as (
    select 
        id,
        order_date,
        product_id,
        return_reason,
        -- Natural feature extraction: derive day of week from order_date
        extract(dow from order_date) as order_dow,
        extract(month from order_date) as order_month,
        -- Privacy preserving transformation: convert date_of_birth into an age bracket
        case 
            when floor(extract(year from age(current_date, date_of_birth))) < 30 then 'young'
            when floor(extract(year from age(current_date, date_of_birth))) between 30 and 60 then 'middle'
            else 'senior'
        end as age_bracket,
        other_feature,
        -- Derived feature for additional analysis; compute customer age without exposing raw PII
        floor(extract(year from age(current_date, date_of_birth))) as customer_age
    from {{ source('source_data', 'returns') }}
)

select 
    id,
    order_date,
    product_id,
    return_reason,
    order_dow,
    order_month,
    age_bracket,
    other_feature,
    customer_age,
    -- Binary label: flag returns with reasons 'Damaged' or 'Defective' as 1, else 0
    case when return_reason in ('Damaged', 'Defective') then 1 else 0 end as label
from base_data;