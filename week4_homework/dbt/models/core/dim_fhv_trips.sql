{{
    config(
        materialized='table'
    )
}}

with fhv_tripdata as (
    select * from {{ ref('stg_fhv_tripdata') }}
),
dim_zones as (
    select * from {{ ref('dim_zones') }} where borough != 'Unknown'
)

select
    dispatching_base_num,
    pickup_datetime,
    extract(YEAR from pickup_datetime) as pickup_year,
    extract(MONTH from pickup_datetime) as pickup_month,
    dropoff_datetime,
    pulocationid,
    pickup_zone.borough as pickup_borough, 
    pickup_zone.zone as pickup_zone, 
    dolocationid,
    dropoff_zone.borough as dropoff_borough, 
    dropoff_zone.zone as dropoff_zone,
    sr_flag,
    affiliated_base_number
from fhv_tripdata
inner join dim_zones as pickup_zone
on fhv_tripdata.pulocationid = pickup_zone.locationid
inner join dim_zones as dropoff_zone
on fhv_tripdata.dolocationid = dropoff_zone.locationid