{{
    config(
        materialized='table'
    )
}}

with fhv_tripdata as (
    select 
        *,
        timestamp_diff(dropoff_datetime, pickup_datetime, SECOND) trip_duration
    from {{ ref('dim_fhv_trips') }}
),
fhv_tripdata_p90 as (
    select
        pickup_year,
        pickup_month,
        pickup_zone,
        dropoff_zone,
        percentile_cont(trip_duration, 0.9) over(partition by pickup_year, pickup_month, pickup_zone, dropoff_zone) trip_duration_p90
    from fhv_tripdata
)

select * from fhv_tripdata_p90 group by all