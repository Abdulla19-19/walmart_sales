-- Walmart Project Queries 
select * from walmart_table

-- Count total records
select count(*) from walmart_table

-- Count payment methods and number of transactions by payment method
select distinct payment_method,count(*)
from walmart_table
group by payment_method

-- Count distinct branches
select count(distinct branch) as branches from walmart_table

-- Find the minimum quantity sold
select min(quantity)as min_quantity from walmart_table

-- Business Problem 
--Q1: Find different payment methods, number of transactions, and quantity sold by payment method
select 
    payment_method,
    count(*) as no_payments,
    sum(quantity) as no_qty_sold
from walmart_table
group by payment_method;

-- Project Question #2: Identify the highest-rated category in each branch
-- Display the branch, category, and avg rating
select branch, category, avg_rating
from(select branch,category,
       avg(rating) as avg_rating,
        rank() over(partition by branch order by avg(rating) desc) as rank
    from walmart_table
    group by branch, category
) as ranked
where rank = 1;

-- Q3: Identify the busiest day for each branch based on the number of transactions
select branch, day_name, no_transactions
from (
    select 
        branch,
        datename(weekday, try_convert(DATE, date, 103)) as day_name,
        count(*) as no_transactions,
        rank() over (partition by branch order by count(*) desc) as rank
    from walmart_table
    group by branch, datename(weekday, try_convert(DATE, date, 103))
) AS ranked
where rank = 1;



-- Q4: Calculate the total quantity of items sold per payment method
select 
    payment_method,
    sum(quantity) as no_qty_sold
from walmart_table
group by payment_method;

-- Q5: Determine the average, minimum, and maximum rating of categories for each city
select 
    city,
    category,
    min(rating) as min_rating,
    max(rating) as max_rating,
    avg(rating) as avg_rating
from walmart_table
group by city, category;

-- Q6: Calculate the total profit for each category
select 
    category,
    sum(unit_price * quantity * datepart(minute, profit_margin)) as total_profit
from walmart_table
group by category
order by total_profit desc;



-- Q7: Determine the most common payment method for each branch
with cte as (
    select 
        branch,
        payment_method,
        count(*) as total_trans,
        rank() over(partition by branch order by count(*) desc) as rank
    from walmart_table
    group by branch, payment_method
)
select branch, payment_method as preferred_payment_method
from cte
where rank = 1;

-- Q8: Categorize sales into Morning, Afternoon, and Evening shifts
select
    branch,
    case 
        when datepart(HOUR, time) < 12 then 'Morning'
        when datepart(HOUR, time) between 12 and 17 then 'Afternoon'
        else 'Evening'
    end as shift,
    count(*) as num_invoices
from walmart_table
group by branch,
         case 
            when datepart(HOUR, time) < 12 then 'Morning'
            when datepart(HOUR, time) between 12 and 17 then 'Afternoon'
           else 'Evening'
         end
order by branch, num_invoices desc;
-- Q9: Total Sales per Category with Profit Margin Above 0.4
select 
    category,
    count(*) as total_transactions,
    round(sum(unit_price * quantity), 2) as total_sales
from walmart_table
where profit_margin > 0.4
group by category
order by total_sales desc;
 
 --Q10. Top 5 Cities by Total Revenue
 select 
    City,
    round(sum(unit_price * quantity), 2) as total_revenue
from walmart_table
group by City
order by total_revenue desc
OFFSET 0 rows fetch next 5 rows ONLY;

 --Q11. Top 5 Cities by Revenue from 'Electronic accessories'

 select top 5 city,
    round(sum(cast(replace(unit_price, '$', '') as float) * quantity), 2) as revenue
from walmart_table
where category = 'Electronic accessories'
group by city
order by revenue desc


