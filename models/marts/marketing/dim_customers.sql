{#

- Config macro: {{config(materialized='table','view')}} - by default as view if config is not provided.

- Materialization can be configured also in dbt_project.yml file

- dbt run (run all models)

- dbt run --select _model_name_ (run specific model)

{{config(required_tests=None)}} -- to override the project.yml test configuration. 

#}

-- Adding info line for pr of change run states

{{
    config(
        materialized='table'
    )
}}

with 

    customers as (
        select
            *
        from {{ ref('stg_jaffle_shop__customers') }}
    ),

    orders as(
        select
            *
        from {{ ref('fct_orders', v=1) }}
    ),

    customer_orders as(
        select
            customer_id,
            min(order_date) as first_order_date,
            max(order_date) as most_recent_order_date,
            count(order_id) as number_of_orders,
            sum(amount) as lifetime_value
        from orders
        group by 1 -- ref. to first column in select
    ),

    final as (
        select
            customers.customer_id,
            customers.givenname as first_name,
            customers.surname as last_name,
            customer_orders.most_recent_order_date,
            coalesce(customer_orders.number_of_orders, 0) as number_of_orders,
            customer_orders.lifetime_value
        from customers
        left join customer_orders
        on customers.customer_id = customer_orders.customer_id
    )

select * from final