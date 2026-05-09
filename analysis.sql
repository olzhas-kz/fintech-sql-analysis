-- olist e-commerce analysis
-- dataset: brazilian e-commerce public dataset by olist (kaggle)
-- tool: sql server 2025 / ssms

use olistanalysis;


-- analysis 1: monthly revenue trend
-- how did revenue grow month by month?
-- grain: one row per month
-- tables: orders, order_items
-- filter: delivered orders only

select
    datefromparts(year(o.order_purchase_timestamp),
                  month(o.order_purchase_timestamp), 1) as month_start,
    count(distinct o.order_id) as total_orders,
    round(sum(cast(oi.price as decimal(10,2))), 2) as total_revenue,
    round(avg(cast(oi.price as decimal(10,2))), 2) as avg_item_price
from orders o
join order_items oi 
    on o.order_id = oi.order_id
where o.order_status = 'delivered'
group by datefromparts(year(o.order_purchase_timestamp),
                       month(o.order_purchase_timestamp), 1)
order by month_start;


-- analysis 2: month-over-month revenue growth
-- wanted to see the growth rate between months

with monthly as (
    select
        datefromparts(year(o.order_purchase_timestamp),
                      month(o.order_purchase_timestamp), 1) as month_start,
        round(sum(cast(oi.price as decimal(10,2))), 2) as revenue
    from orders o
    join order_items oi 
        on o.order_id = oi.order_id
    where o.order_status = 'delivered'
    group by datefromparts(year(o.order_purchase_timestamp),
                           month(o.order_purchase_timestamp), 1)
)
select
    month_start,
    revenue,
    lag(revenue) over (order by month_start) as prev_month_revenue,
    round(
        100.0 * (revenue - lag(revenue) over (order by month_start))
        / nullif(lag(revenue) over (order by month_start), 0)
    , 1) as growth_pct
from monthly
order by month_start;


-- analysis 3: top product categories by revenue
-- which categories drive the most sales?
-- used left join on translation so categories without english name still show up

select top 10
    isnull(t.product_category_name_english,
           p.product_category_name) as category,
    count(distinct oi.order_id) as total_orders,
    round(sum(cast(oi.price as decimal(10,2))), 2) as total_revenue,
    round(avg(cast(oi.price as decimal(10,2))), 2) as avg_price
from order_items oi
join orders o on oi.order_id = o.order_id
join products p on oi.product_id = p.product_id
left join product_category_translation t
    on p.product_category_name = t.product_category_name
where o.order_status = 'delivered'
group by isnull(t.product_category_name_english,
                p.product_category_name)
order by total_revenue desc;


-- analysis 4: top 10 sellers by revenue
-- who are the best performing sellers and where are they based?

select top 10
    oi.seller_id,
    s.seller_city,
    s.seller_state,
    count(distinct oi.order_id) as total_orders,
    round(sum(cast(oi.price as decimal(10,2))), 2) as total_revenue
from order_items oi
join orders o on oi.order_id = o.order_id
join sellers s on oi.seller_id = s.seller_id
where o.order_status = 'delivered'
group by oi.seller_id, s.seller_city, s.seller_state
order by total_revenue desc;


-- analysis 5: revenue by customer state
-- which states generate the most orders and revenue?

select top 10
    c.customer_state,
    count(distinct o.order_id) as total_orders,
    round(sum(cast(oi.price as decimal(10,2))), 2) as total_revenue
from customers c
join orders o 
    on c.customer_id = o.customer_id
join order_items oi 
    on o.order_id = oi.order_id
where o.order_status = 'delivered'
group by c.customer_state
order by total_revenue desc;


-- analysis 6: payment method breakdown
-- how do customers pay and what is the average transaction value?

select
    payment_type,
    count(*) as total_transactions,
    round(sum(cast(payment_value as decimal(10,2))), 2) as total_value,
    round(avg(cast(payment_value as decimal(10,2))), 2) as avg_value,
    round(100.0 * count(*) / sum(count(*)) over(), 1) as pct_of_transactions
from order_payments
where payment_type != 'not_defined'
group by payment_type
order by total_transactions desc;


-- analysis 7: delivery performance by state
-- how long does delivery take and which states get faster service?
-- positive avg_days_early means delivered before the estimated date

select
    c.customer_state,
    count(distinct o.order_id) as delivered_orders,
    round(avg(
        cast(datediff(day,
            o.order_purchase_timestamp,
            o.order_delivered_customer_date
        ) as float)
    ), 1) as avg_delivery_days,
    round(avg(
        cast(datediff(day,
            o.order_delivered_customer_date,
            o.order_estimated_delivery_date
        ) as float)
    ), 1) as avg_days_early_vs_estimate
from orders o
join customers c on o.customer_id = c.customer_id
where o.order_status = 'delivered'
  and o.order_delivered_customer_date is not null
  and o.order_delivered_customer_date != ''
group by c.customer_state
order by avg_delivery_days asc;


-- analysis 8: order status summary
-- what share of orders are delivered, cancelled etc?

select
    order_status,
    count(*) as total_orders,
    round(100.0 * count(*) / sum(count(*)) over(), 1) as pct
from orders
group by order_status
order by total_orders desc;