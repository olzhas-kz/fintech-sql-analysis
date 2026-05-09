# olist e-commerce sql analysis

## about the project

I was looking for a real dataset to practice sql on something with multiple related tables and enough rows to ask meaningful business questions. I found the olist dataset on kaggle, which contains 100 000+ real orders from a brazilian e-commerce platform collected between 2016 and 2018.

The goal was to go beyond simple select queries and actually analyze the business, revenue trends, best selling categories, seller performance, customer geography, payment behavior, and delivery operations. These are the same types of questions a data analyst would work on at an e-commerce or fintech company.

All analysis was done in sql server using ssms. No python, no excel — just sql from start to finish.

---

## dataset

Source: [olist brazilian e-commerce public dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) on kaggle.

The dataset has 7 tables that connect to each other through order and product ids:

| table | rows | what it contains |
|-------|------|-----------------|
| orders | 99,441 | one row per order with status and timestamps |
| order_items | 112,650 | individual items within each order, with price and seller |
| customers | 99,441 | customer location — city and state |
| sellers | 3,095 | seller location — city and state |
| products | 32,951 | product catalog with category names |
| order_payments | 103,886 | payment method and value per order |
| product_category_translation | 71 | portuguese to english category names |

To use this project yourself, download the csv files from kaggle, place them in c:\database, and run schema_and_import.sql first. Then open analysis.sql and run each query section by section.

---

## business questions and findings

### 1. how did revenue grow over time?

I grouped completed orders by month and calculated total revenue and order count per month.

The business started very small — september 2016 had just 1 order and $135 in revenue. By january 2017 it reached 750 orders and $111,000. By may 2017 already 3,500 orders and $489,000. Revenue crossed $1 million per month in early 2018 and kept growing. This is a classic startup growth curve — slow start, then rapid acceleration once product-market fit is found.

### 2. which product categories sell the most?

I joined order_items to products and the category translation table to get english category names, then grouped by category and sorted by total revenue.

Top categories by revenue: health and beauty, watches and gifts, bed/bath/table, sports and leisure, computers and accessories. Electronics categories tend to have higher average prices but fewer orders. Mass-market categories like health and beauty win on volume.

### 3. who are the top sellers?

I joined order_items to sellers and grouped by seller, sorting by total revenue.

The top seller generated $196,882 across 1,772 orders. Almost all top sellers are based in são paulo state (SP), which makes sense given SP is brazil's economic center. Revenue is fairly concentrated — the top 10 sellers account for a significant share of total platform revenue.

### 4. where do customers come from?

I joined customers to orders and order_items, then grouped by customer state.

São paulo (SP) dominates with 40,494 delivered orders — roughly 40% of the entire platform. The next states are rio de janeiro (RJ), minas gerais (MG), rio grande do sul (RS), and paraná (PR). This maps almost exactly to brazil's population distribution.

### 5. how do customers pay?

I aggregated the order_payments table by payment type.

| payment type | share of transactions | avg value |
|-------------|----------------------|-----------|
| credit card | 73.9% | $163 |
| boleto | 19.0% | $145 |
| voucher | 5.6% | $66 |
| debit card | 1.5% | $143 |

Credit card dominates heavily. Boleto is a brazilian payment method (bank slip) popular with people who don't have credit cards — its 19% share reflects how important financial inclusion is in the brazilian market.

### 6. how fast are deliveries?

I calculated the average number of days between order placement and actual delivery, grouped by customer state. I also calculated how many days early or late deliveries were compared to the estimated date.

São paulo (SP) averages 8.7 days — fastest in the country. Remote states like mato grosso do sul and rio grande do sul average 15+ days. Every single state receives orders earlier than the estimated delivery date by 11-13 days on average. The platform systematically under-promises on delivery time and over-delivers, which is a deliberate strategy to improve customer satisfaction.

### 7. what is the overall order completion rate?

97% of all orders have status "delivered". Only about 1% are cancelled and less than 1% fall into other statuses. This is a strong operational reliability metric.

---

## sql concepts used in this project

| concept | where it appears |
|---------|-----------------|
| inner join | connecting orders to items, customers, sellers |
| left join | product category translation — keeps products without english name |
| group by + sum / count / avg | all aggregation queries |
| cte (with clause) | month-over-month growth calculation |
| lag() window function | comparing each month to the previous one |
| sum() over() | calculating percentage of total |
| cast() | converting varchar price columns to decimal for math |
| datefromparts() | grouping dates by month |
| nullif() | avoiding division by zero in growth percentage |
| isnull() | handling missing category translations |
| top n | limiting results to top 10 sellers and categories |

---

## files in this repository

**schema_and_import.sql** — creates the olistanalysis database, defines all 8 tables, and loads the csv data using bulk insert. Run this first. Requires the csv files to be placed in c:\database on your local machine.

**analysis.sql** — contains all 8 analysis queries. Each query has a comment explaining what business question it answers and what the logic is. Queries are written in lowercase sql with no unnecessary formatting.

---

## tools

- sql server 2025 express
- sql server management studio (ssms)
- dataset source: kaggle
