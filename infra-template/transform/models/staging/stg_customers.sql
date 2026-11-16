with source as (

    select * from {{ ref('example_customers') }}

),

renamed as (

    select
        customer_id,
        first_name,
        last_name,
        first_name || ' ' || last_name as full_name,
        state,
        signup_date

    from source

)

select * from renamed
