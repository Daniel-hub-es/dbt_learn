{# 

With config as ephemeral model is interpolated as a cte in the upsteam model



{{
    config(
        materialized='incremental',
        on_schema_change='append_new_columns'
    )
}}

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
            cast(coalesce(order_payments.amount, 0) as integer) as order_amount --change on dtype for v2
        from orders
        left join order_payments
        on order_payments.order_id = orders.order_id
    )

select * from final
{% if is_incremental() %}
    -- this filter will only be applied on an incremental run
    where order_date > (select max(order_date) from {{ this }}) 
{% endif %}
order by order_date desc