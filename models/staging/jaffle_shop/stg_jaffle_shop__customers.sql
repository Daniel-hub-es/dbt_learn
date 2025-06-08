with

    source as(
        select *
        from {{ source('jaffle_shop', 'customers') }}
    ),

    customers as (
        select
            ID as customer_id,
            LAST_NAME as surname,
            FIRST_NAME as givenname, 
            FIRST_NAME || ' ' || LAST_NAME as full_name
        from source
    )

select * from customers