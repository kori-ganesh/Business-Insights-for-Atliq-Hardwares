-- task 1
-- Provide the list of markets in which customer "Atliq Exclusive" operates its
-- business in the APAC region.
select 
distinct market from dim_customer 
where customer="Atliq Exclusive" and region="APAC"
group by market order by market;

-- task 2
-- What is the percentage of unique product increase in 2021 vs. 2020? The
-- final output contains these fields,
-- unique_products_2020
-- unique_products_2021
-- percentage_chg
with cte1 as(
select 
count(distinct(p.product_code)) as uniq_products_2020 
from dim_product p join fact_actual_estimate f 
using(product_code) 
where f.fiscal_year=2020),
cte2 as (
select 
count(distinct(p.product_code)) as uniq_products_2021
from dim_product p join fact_actual_estimate f 
using(product_code) 
where f.fiscal_year=2021
)
select uniq_products_2020,uniq_products_2021,
round((uniq_products_2021-uniq_products_2020)*100/uniq_products_2020,2) as percentage_chnge
from cte1 join cte2;

-- task 3
-- Provide a report with all the unique product counts for each segment and
-- sort them in descending order of product counts. The final output contains
-- 2 fields,
-- segment
-- product_count
select 
segment,
count(distinct product_code) as product_count 
from dim_product
group by segment order by product_count desc;


-- task 4
-- Follow-up: Which segment had the most increase in unique products in
-- 2021 vs 2020? The final output contains these fields,
-- segment
-- product_count_2020
-- product_count_2021
-- difference
with product_21 as (
select 
segment,
count(distinct(p.product_code)) uniq_products_2021
from dim_product p join fact_actual_estimate f 
using(product_code) 
where f.fiscal_year=2021 group by segment
),
product_20 as (
select segment,
count(distinct(p.product_code)) uniq_products_2020
from dim_product p join fact_actual_estimate f
using(product_code) 
where f.fiscal_year=2020 group by segment
) 
select *,
(uniq_products_2021-uniq_products_2020) as product_difference
from product_20  join product_21 
using(segment) order by product_difference desc;

-- task 5
-- Get the products that have the highest and lowest manufacturing costs.
-- The final output should contain these fields,
-- product_code
-- product
-- manufacturing_cost
select
product_code,product,
round(manufacturing_cost,3) as manufacturing_cost
from dim_product join fact_manufacturing_cost
using(product_code)
where manufacturing_cost in 
((select max(manufacturing_cost) from  fact_manufacturing_cost
),(select min(manufacturing_cost) from  fact_manufacturing_cost
));

-- task 6
-- Generate a report which contains the top 5 customers who received an
-- average high pre_invoice_discount_pct for the fiscal year 2021 and in the
-- Indian market. The final output contains these fields,
-- customer_code
-- customer
-- average_discount_percentage
select customer_code,customer,
round(avg(pre_invoice_discount_pct),4) as avg_discount_pct
from dim_customer join fact_pre_invoice_deductions 
using(customer_code)
where fiscal_year=2021 and market="india"
group by customer_code,customer
order by avg_discount_pct desc limit 5;

-- task 7
-- Get the complete report of the Gross sales amount for the customer “Atliq
-- Exclusive” for each month. This analysis helps to get an idea of low and
-- high-performing months and take strategic decisions.
-- The final report contains these columns:
-- Month
-- Year
-- Gross sales Amount
select monthname(date) as month, 
fiscal_year,sum(gross_sales_total) as gross_sales_amount
from gross_sales where customer="Atliq Exclusive" and fiscal_year in (2020,2021)
group by date, month,fiscal_year
order by fiscal_year;


-- task 8
 -- In which quarter of 2020, got the maximum total_sold_quantity? The final
-- output contains these fields sorted by the total_sold_quantity,
-- Quarter
-- total_sold_quantity

select 
case when month(date) in (9,10,11) then "Q1"
	 when month(date) in (12,1,2) then "Q2"
     when month(date) in (3,4,5) then "Q3"
     else "Q4" end as quarter,
sum(sold_quantity) as total_sold_quantity
from fact_actual_estimate where fiscal_year=2020
group by quarter order by total_sold_quantity desc;

# or you can create a function for getting fiscal_quarter and run this query
select 
get_fiscal_quarter(date) as quarter,
sum(sold_quantity) as total_sold_quantity
from fact_actual_estimate where fiscal_year=2020
group by quarter order by total_sold_quantity desc;

-- task 9
-- Which channel helped to bring more gross sales in the fiscal year 2021
-- and the percentage of contribution? The final output contains these fields,
-- channel
-- gross_sales_mln
-- percentage
with gross_sales_channel as(
select c.channel,
sum(g.gross_sales_total) as gross_sales_amount
from gross_sales g join dim_customer c 
on g.customer_code=c.customer_code and 
g.market=c.market where fiscal_year=2021
group by c.channel
)
select channel, 
gross_sales_amount as gross_sales_mln,
round(gross_sales_amount*100/sum(gross_sales_amount)
over(),2) as percentage_contribution
from gross_sales_channel order by gross_sales_mln desc;

-- task 10
-- Get the Top 3 products in each division that have a high
-- total_sold_quantity in the fiscal_year 2021? The final output contains these
-- fields,
-- division
-- product_code
-- product
-- total_sold_quantity
-- rank_order

with cte as (
select 
division,product_code,product,
sum(sold_quantity) as total_quantity,
dense_rank() 
over(partition by division order by sum(sold_quantity) desc) as rank_order
from fact_actual_estimate join dim_product 
using(product_code) 
where fiscal_year=2021 
group by division,product_code
)
select * from cte where rank_order<=3;















