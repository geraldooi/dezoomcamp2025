{{
    config(
        materialized='table'
    )
}}

with trips_data_filter as (
    select *
    from {{ ref('fact_trips') }}
    where fare_amount >= 0 and trip_distance >= 0 and payment_type_description in ('Cash', 'Credit Card')
),
trips_data_filter_percentile as (
    select
        service_type,
        pickup_year,
        pickup_month,
        percentile_cont(fare_amount, 0.97) over(partition by service_type, pickup_year, pickup_month) fare_amount_p97,
        percentile_cont(fare_amount, 0.95) over(partition by service_type, pickup_year, pickup_month) fare_amount_p95,
        percentile_cont(fare_amount, 0.90) over(partition by service_type, pickup_year, pickup_month) fare_amount_p90,
    from trips_data_filter
)

select *
from trips_data_filter_percentile
group by all