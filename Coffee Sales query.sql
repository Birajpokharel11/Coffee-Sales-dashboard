USE coffeeSales
select * from coffeeSales

-- Query for total number of sales based on month on month 
with monthly_order AS (
	SELECT MONTH(transaction_date) AS month,
	 count(transaction_id) total_order
	from coffeeSales
	where MONTH(transaction_date) in (4,5)
	GROUP by 
	month(transaction_date)
)


-- Query on total number of order based on month on month

WITH monthly_order AS (
	SELECT 
		MONTH(transaction_date) AS month,
		COUNT(transaction_id) AS total_order
	FROM coffeeSales
	WHERE MONTH(transaction_date) IN (4,5)
	GROUP BY MONTH(transaction_date)
)
SELECT 
	month,
	ROUND(total_order, 1) AS totalOrder,
	CAST(((total_order - LAG(total_order, 1) OVER (ORDER BY month)) * 100.0 / LAG(total_order, 1) OVER (ORDER BY month)) AS DECIMAL(10,4)) AS month_on_month_increase_percentage
FROM monthly_order
ORDER BY month;

-- Query for total quantity sold based on month on month

WITH monthly_quantity_sold AS (
	SELECT 
		MONTH(transaction_date) AS month,
		SUM(transaction_qty) AS total_quantity
	FROM coffeeSales
	WHERE MONTH(transaction_date) IN (4,5)
	GROUP BY MONTH(transaction_date)
)
SELECT 
	month,
	ROUND(total_quantity, 1) AS totalOrder,
	CAST(((total_quantity - LAG(total_quantity, 1) OVER (ORDER BY month)) * 100.0 / LAG(total_quantity, 1) OVER (ORDER BY month)) AS DECIMAL(10,4)) AS month_on_month_increase_percentage
FROM monthly_quantity_sold
ORDER BY month;


-- Total quantity , total order, totalsales based on date monthly and daily 
select * from coffeeSales;
SELECT
    concat(cast(round(sum(unit_price * transaction_qty) / 1000.0, 1) AS decimal(10,1)), 'k') AS Total_sales,
    concat(cast(round(sum(transaction_qty) / 1000.0, 1) AS decimal(10,1)), 'k') AS Total_qty_sold,
    concat(cast(round(count(transaction_id) / 1000.0, 1) AS decimal(10,1)), 'k') AS Total_orders
FROM coffeeSales
WHERE transaction_date = '2023-03-27';

-- getting  Total quantity , total order, totalsales based on date monthly and daily  based on weekends and weekdays
SELECT 
    CASE 
        WHEN DATEPART(WEEKDAY, transaction_date) IN (1, 7) THEN 'Weekends'
        ELSE 'Weekdays'
    END AS day_type,
    CONCAT(ROUND(SUM(unit_price * transaction_qty) / 1000, 1), 'k') AS total_sales
FROM coffeeSales
WHERE MONTH(transaction_date) = 2
GROUP BY 
    CASE 
        WHEN  
        ELSE 'Weekdays'
    END;

-- sales analysis by store location

select * from coffeeSales;

SELECT store_location,
		concat(round(sum(unit_price * transaction_qty)/1000,2), 'K') as Total_Sales
from coffeeSales
where month(transaction_date) = 5
group by store_location
order by sum(unit_price * transaction_qty) desc

/*--  used sub query here because we have to find the average of month 5 not all the dataset 
where there is 6 months 
so if we want to find out average monthly sales then we should first summarise the table data to monthly data only then we can preform average function
*/
-- To calculate the average sales for a month, we need the daily sales totals (one value per day).
-- That's why we use a subquery with GROUP BY to generate total sales for each individual day.
-- This gives us 30 (or 31) values, one for each day in the month.
-- The AVG() function then uses these 30 values to calculate the monthly average by dividing 
-- the sum of daily totals by the number of days.
-- Without the GROUP BY, the subquery would return just one total for the entire month,
-- and the AVG() function would return this total sum as the "average," which is incorrect.

select round(AVG(total_sales),1) as AVG_Sales
from 
(
select sum(transaction_qty * unit_price) as total_sales
from coffeeSales
where month(transaction_date) = 5
group by transaction_date
) as Internal_quer
-- each and every day what are the sales

select  day(transaction_date) as day,sum(transaction_qty * unit_price) as daily_total_sales
from coffeeSales where month(transaction_date) = 2
group by transaction_date
order by transaction_date ASC

select * from coffeeSales;
-- Checking weather monthly day to day sales is above averaage or beow average
with totaal as (
 SELECT 
        DAY(transaction_date) AS day_of_month,
        SUM(unit_price * transaction_qty) AS total_sales,
        AVG(SUM(unit_price * transaction_qty)) OVER () AS avg_sales
    FROM 
        coffeeSales
    WHERE 
        MONTH(transaction_date) = 5  -- Filter for May
    GROUP BY 
        DAY(transaction_date) 
)
SELECT 
    day_of_month,
    CASE 
        WHEN total_sales > avg_sales THEN 'Above Average'
        WHEN total_sales < avg_sales THEN 'Below Average'
        ELSE 'Average'
    END AS sales_status,
    total_sales
FROM totaal 
ORDER BY 
    day_of_month;


-- total sales by product category
select product_category, sum(unit_price  * transaction_qty) as total_sales
from   coffeeSales where
month(transaction_date) = 5
Group by product_category
order by sum(unit_price  * transaction_qty) DESC

-- query for total sales, total quaantity sold, total orders
-- based on date day and time(hourly)
SELECT 
    SUM(unit_price * transaction_qty) AS Total_Sales,
    SUM(transaction_qty) AS Total_qty_sold,
    COUNT(*) AS Total_Orders
FROM coffeeSales
WHERE MONTH(transaction_date) = 5
AND DATEPART(WEEKDAY, transaction_date) = 1  -- Equivalent to Monday
AND DATEPART(HOUR, transaction_time) = 14;
-- query for total sales based on hours on a particular montjh

select 
DATEPART(HOUR, transaction_time) as Hour,
SUM(unit_price * transaction_qty) AS Total_Sales
from coffeeSales
where month(transaction_date) = 5
group by DATEPART(HOUR, transaction_time)
order by
DATEPART(HOUR, transaction_time) ASC

-- weekly sales analysis
SELECT 
    DATENAME(WEEKDAY, transaction_date) AS Day_of_Week,
    ROUND(SUM(unit_price * transaction_qty), 0) AS Total_Sales,
   
FROM 
    coffeeSales
WHERE 
    MONTH(transaction_date) = 5 -- Filter for May
GROUP BY 
    DATENAME(WEEKDAY, transaction_date),
    DATEPART(WEEKDAY, transaction_date)
ORDER BY 
    CASE 
        -- SQL Server's DATEFIRST function can affect the order; you may need to adjust the values here
        WHEN DATEPART(WEEKDAY, transaction_date) = 1 THEN 7 -- Sunday should come last
        ELSE DATEPART(WEEKDAY, transaction_date) - 1 -- Monday to Saturday come in order
    END;
