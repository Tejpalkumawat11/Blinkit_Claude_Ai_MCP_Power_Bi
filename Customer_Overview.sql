use blinkit


                                                  --  Customer Overview --

select 
count (*) as C
from blinkit_customers 


/* Customer Count and Revenue by Year */

SELECT 
    YEAR(o.order_date) AS year,
    COUNT(DISTINCT o.customer_id) AS Customer_Count,
    ROUND(SUM(itm.total_price), 0) AS Revenue
FROM blinkit_orders AS o
LEFT JOIN blinkit_order_items AS itm
       ON o.order_id = itm.order_id
WHERE YEAR(o.order_date) IN (2024, 2025)
GROUP BY YEAR(o.order_date)
ORDER BY year;



/* New, Lost and Active Customer Count */




	WITH active AS (
    SELECT DISTINCT customer_id
    FROM blinkit_orders
    WHERE YEAR(order_date) = YEAR(GETDATE())
),
prev_active AS (
    SELECT DISTINCT customer_id
    FROM blinkit_orders
    WHERE YEAR(order_date) = YEAR(GETDATE()) - 1
)
SELECT
    (SELECT COUNT(*) 
     FROM blinkit_customers 
     WHERE YEAR(registration_date) = YEAR(GETDATE())) AS new_customers,

    (SELECT COUNT(DISTINCT customer_id) 
     FROM active) AS active_customers,

    (SELECT COUNT(*) 
     FROM prev_active 
     WHERE customer_id NOT IN (SELECT customer_id FROM active)) AS lost_customers;


/* New Customer Sale*/



SELECT 
    ROUND(SUM(itm.total_price), 0) AS new_sales
FROM blinkit_customers AS c
LEFT JOIN blinkit_orders AS o
    ON c.customer_id = o.customer_id
LEFT JOIN blinkit_order_items AS itm
    ON o.order_id = itm.order_id
WHERE 
    YEAR(c.registration_date) = YEAR(GETDATE());



/* Lost Customer Sale*/

	 WITH last_year_customers AS (
    SELECT DISTINCT customer_id
    FROM blinkit_orders
    WHERE YEAR(order_date) = YEAR(GETDATE()) - 1
),
this_year_customers AS (
    SELECT DISTINCT customer_id
    FROM blinkit_orders
    WHERE YEAR(order_date) = YEAR(GETDATE())
),
lost_customers AS (
    SELECT customer_id
    FROM last_year_customers
    WHERE customer_id NOT IN (SELECT customer_id FROM this_year_customers)
)
SELECT 
    ROUND(SUM(itm.total_price), 0) AS lost_sales
FROM blinkit_orders AS o
JOIN blinkit_order_items AS itm
    ON o.order_id = itm.order_id
WHERE 
    YEAR(o.order_date) = YEAR(GETDATE()) - 1
    AND o.customer_id IN (SELECT customer_id FROM lost_customers);


/* Customer Count by Year and Month*/


SELECT 
    YEAR(registration_date) AS Year,
    DATENAME(MONTH, registration_date) AS Month,
    COUNT(customer_id) AS Customer
FROM blinkit_customers
GROUP BY 
    YEAR(registration_date),
    DATENAME(MONTH, registration_date),
    MONTH(registration_date)
ORDER BY 
    Year,
    MONTH(registration_date);



/* Category wise Custome Count and Revenue*/


SELECT 
    p.category AS Category,
    COUNT(o.customer_id) AS Customer,
    ROUND(SUM(itm.total_price), 0) AS Revenue
FROM blinkit_products AS p
JOIN blinkit_order_items AS itm
    ON p.product_id = itm.product_id
JOIN blinkit_orders AS o
    ON itm.order_id = o.order_id
GROUP BY 
    p.category
ORDER BY 
    Customer DESC,
    Revenue DESC;
