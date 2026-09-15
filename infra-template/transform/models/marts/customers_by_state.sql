with customers as (

    select * from {{ ref('stg_customers') }}

)

select
    state,
    count(*) as customer_count

from customers
group by state
