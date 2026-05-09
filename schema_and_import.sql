-- olist e-commerce schema and import
-- run this first before analysis.sql
-- requires csv files in c:\database folder
-- download dataset from: kaggle.com/datasets/olistbr/brazilian-ecommerce

create database olistanalysis;
go

use olistanalysis;
go


-- create tables

create table customers (
    customer_id varchar(100),
    customer_unique_id varchar(100),
    customer_zip_code_prefix varchar(20),
    customer_city varchar(200),
    customer_state varchar(50)
);

create table sellers (
    seller_id varchar(100),
    seller_zip_code_prefix varchar(20),
    seller_city varchar(200),
    seller_state varchar(50)
);

create table products (
    product_id varchar(100),
    product_category_name varchar(200),
    product_name_length varchar(20),
    product_description_length varchar(20),
    product_photos_qty varchar(20),
    product_weight_g varchar(20),
    product_length_cm varchar(20),
    product_height_cm varchar(20),
    product_width_cm varchar(20)
);

create table product_category_translation (
    product_category_name varchar(200),
    product_category_name_english varchar(200)
);

create table orders (
    order_id varchar(100),
    customer_id varchar(100),
    order_status varchar(50),
    order_purchase_timestamp varchar(50),
    order_approved_at varchar(50),
    order_delivered_carrier_date varchar(50),
    order_delivered_customer_date varchar(50),
    order_estimated_delivery_date varchar(50)
);

create table order_items (
    order_id varchar(100),
    order_item_id varchar(20),
    product_id varchar(100),
    seller_id varchar(100),
    shipping_limit_date varchar(50),
    price varchar(20),
    freight_value varchar(20)
);

create table order_payments (
    order_id varchar(100),
    payment_sequential varchar(20),
    payment_type varchar(50),
    payment_installments varchar(20),
    payment_value varchar(20)
);

create table order_reviews (
    review_id varchar(100),
    order_id varchar(100),
    review_score varchar(10),
    review_comment_title varchar(500),
    review_comment_message varchar(max),
    review_creation_date varchar(50),
    review_answer_timestamp varchar(50)
);


-- import data from csv files

bulk insert customers
from 'c:\database\olist_customers_dataset.csv'
with (firstrow = 2, fieldterminator = ',', rowterminator = '0x0a', codepage = '65001');

bulk insert sellers
from 'c:\database\olist_sellers_dataset.csv'
with (firstrow = 2, fieldterminator = ',', rowterminator = '0x0a', codepage = '65001', maxerrors = 10);

bulk insert products
from 'c:\database\olist_products_dataset.csv'
with (firstrow = 2, fieldterminator = ',', rowterminator = '0x0a', codepage = '65001');

bulk insert product_category_translation
from 'c:\database\product_category_name_translation.csv'
with (firstrow = 2, fieldterminator = ',', rowterminator = '0x0a', codepage = '65001');

bulk insert orders
from 'c:\database\olist_orders_dataset.csv'
with (firstrow = 2, fieldterminator = ',', rowterminator = '0x0a', codepage = '65001');

bulk insert order_items
from 'c:\database\olist_order_items_dataset.csv'
with (firstrow = 2, fieldterminator = ',', rowterminator = '0x0a', codepage = '65001');

bulk insert order_payments
from 'c:\database\olist_order_payments_dataset.csv'
with (firstrow = 2, fieldterminator = ',', rowterminator = '0x0a', codepage = '65001');