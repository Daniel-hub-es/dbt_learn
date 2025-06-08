with
    
    source as (
        select *
        from {{ source('stripe', 'payments') }} 
    ),

    payments as(
        select 
            ID as payment_id,
            ORDERID as order_id,
            PAYMENTMETHOD as payment_method,
            STATUS as payment_status,
            {{ cents_to_dollars('amount') }} as amount,
            round(amount/10.0, 2) as payment_amount,
            CREATED as created_at
        from source
    )

select * from payments