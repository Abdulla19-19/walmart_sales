# walmart_sales
![walmart_project-piplelines](https://github.com/user-attachments/assets/b09dd3bb-12e8-4c9f-943a-2ca6de39ac7d)

## Project Objective
This report analyzes sales data from Walmart retail outlets to uncover insights into
transaction patterns, customer preferences, and operational performance across branches,
cities, and product categories. The dataset, walmart_table, contains historical sales
records, including payment methods, quantities sold, ratings, and profit margins. The
analysis includes exploratory queries, grouped aggregations, time-based insights, and
revenue calculations to support strategic decisions in inventory management, marketing,
and branch operations.

# Dataset Description
 **Table Name**: walmart_table
 **Description**: Contains historical sales records for products sold across Walmart
outlets, including payment methods, branch details, product categories, quantities,
ratings, and financial metrics.

## Exploratory Analysis
**-- View all data**

 ```SELECT * FROM walmart_table;```


 **-- Total number of records**

``` SELECT COUNT(*) AS total_records FROM walmart_table;```



 **-- Count payment methods and transactions by payment method**

 
 ``` SELECT DISTINCT payment_method, COUNT(*) AS transaction_count
 FROM walmart_table
 GROUP BY payment_method;
```


 **-- Count distinct branches**
 
 ``` SELECT COUNT(DISTINCT branch) AS branches FROM walmart_table;```



**-- Minimum quantity sold**


 ```SELECT MIN(quantity) AS min_quantity FROM walmart_table;```

--***Business Problems***
--**Q1: Find different payment methods, number of transactions, and quantity sold by payment method**

```
select 
    payment_method,
    count(*) as no_payments,
    sum(quantity) as no_qty_sold
from walmart_table
group by payment_method;
```
--***Project Question #2: Identify the highest-rated category in each branch
-- Display the branch, category, and avg rating***

```
select branch, category, avg_rating
from(select branch,category,
       avg(rating) as avg_rating,
        rank() over(partition by branch order by avg(rating) desc) as rank
    from walmart_table
    group by branch, category
) as ranked
where rank = 1;
```
-- **Q3: Identify the busiest day for each branch based on the number of transactions**

```
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
```


-- **Q4: Calculate the total quantity of items sold per payment method**

```
select 
    payment_method,
    sum(quantity) as no_qty_sold
from walmart_table
group by payment_method;
```

-- **Q5: Determine the average, minimum, and maximum rating of categories for each city**

```
select 
    city,
    category,
    min(rating) as min_rating,
    max(rating) as max_rating,
    avg(rating) as avg_rating
from walmart_table
group by city, category;
```

-- **Q6: Calculate the total profit for each category**

```
select 
    category,
    sum(unit_price * quantity * datepart(minute, profit_margin)) as total_profit
from walmart_table
group by category
order by total_profit desc;
```


-- **Q7: Determine the most common payment method for each branch**

```
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
```

-- **Q8: Categorize sales into Morning, Afternoon, and Evening shifts**

```
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
```

-- **Q9: Total Sales per Category with Profit Margin Above 0.4**

```
select 
    category,
    count(*) as total_transactions,
    round(sum(unit_price * quantity), 2) as total_sales
from walmart_table
where profit_margin > 0.4
group by category
order by total_sales desc;
 ```

 --**Q10. Top 5 Cities by Total Revenue**


 ```
 select 
    City,
    round(sum(unit_price * quantity), 2) as total_revenue
from walmart_table
group by City
order by total_revenue desc
OFFSET 0 rows fetch next 5 rows ONLY;
```

 --**Q11. Top 5 Cities by Revenue from 'Electronic accessories'**
 
```
 select top 5 city,
    round(sum(cast(replace(unit_price, '$', '') as float) * quantity), 2) as revenue
from walmart_table
where category = 'Electronic accessories'
group by city
order by revenue desc
```

### Results and Insights

This section will include your analysis findings:

**Sales Insights**: Key categories, branches with highest sales, and preferred payment methods.

**Profitability**: Insights into the most profitable product categories and locations.
Customer Behavior: Trends in ratings, payment preferences, and peak shopping hours.

## Acknowledgments

**Data Source**: Kaggle’s Walmart Sales Dataset

**Inspiration**: Walmart’s business case studies on sales and supply chain optimization.


