{# 

With config as ephemeral model is interpolated as a cte in the upsteam model

#}

{{
    config(
        materialized='table' 
    )
}}


with
    -- load staging models
    orders as(
        select *
        from {{ ref('stg_jaffle_shop__orders') }}
    ),

    payments as(
        select *
        from {{ ref('stg_stripe__payments') }}
    ),

    -- operate for fact dimensinal model (this can be an intermediate one)
    order_payments as(
        select
            order_id,
            sum(
                case
                    when payment_status = 'success'
                    then amount
                end
            ) as amount
        from payments
        group by order_id
    ),

    -- final cte to select from 
    final as(
        select
            orders.order_id,
            orders.customer_id,
            orders.order_date,
            cast(coalesce(order_payments.amount, 0) as NUMERIC) as amount        from orders
        left join order_payments
        on order_payments.order_id = orders.order_id
    )

select * from final