{{ config(materialized='table') }}

with trips_data as (
    select * 
    from {{ ref('fact_trips') }}
),
trips_quarterly_revenue as (
    select
        -- service and quarter grouping
        service_type,
        pickup_year_quarter,

        -- revenue calculation
        sum(total_amount) as revenue_quarterly_total_amount
    from trips_data
    group by 1, 2
),
trips_quarterly_revenue_prev_year as (
    select
        service_type,
        pickup_year_quarter,
        revenue_quarterly_total_amount,
        LAG(revenue_quarterly_total_amount, 4) over(partition by service_type order by pickup_year_quarter) as revenue_quarterly_total_amount_prev_year
    from trips_quarterly_revenue
)

select
    service_type,
    pickup_year_quarter,
    revenue_quarterly_total_amount,
    revenue_quarterly_total_amount_prev_year,
    (safe_divide(revenue_quarterly_total_amount, revenue_quarterly_total_amount_prev_year)-1)*100 revenue_quarterly_total_amount_growth_yoy
from trips_quarterly_revenue_prev_year
