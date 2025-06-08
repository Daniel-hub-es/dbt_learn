with
    source as (
        select *
        from {{ source('jaffle_shop', 'orders') }}
    ),

    orders as (
        select
            ID as order_id,
            USER_ID as customer_id,
            ORDER_DATE as order_date,
            STATUS as order_status,
            case
                when STATUS not in ('returned', 'return_pending')
                then ORDER_DATE
            end as valid_order_date,
            row_number() over (
                partition by USER_ID
                order by ORDER_DATE, ID
                ) as user_order_seq
        from source
    ),

    filtered_orders as(
        select * 
        from orders
        {{ limit_data_in_dev('order_date', days=10) }}
    )

select *
from filtered_orders