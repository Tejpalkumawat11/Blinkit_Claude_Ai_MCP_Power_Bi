use blinkit



                                       --  Sales Overview --


/* Category Wise Sales base on yearly and monthly */

SELECT 
    p.category,
    YEAR(o.order_date) AS sales_year,
    DATENAME(MONTH, o.order_date) AS sales_month,
    ROUND(SUM(itm.total_price),0 ) AS Total_Sales
FROM blinkit_products AS p
left JOIN blinkit_order_items AS itm
    ON p.product_id = itm.product_id
left JOIN blinkit_orders AS o
    ON itm.order_id = o.order_id
WHERE YEAR(o.order_date) IN (2023, 2024, 2025)
GROUP BY 
    p.category,
    YEAR(o.order_date),
    DATENAME(MONTH, o.order_date),
    MONTH(o.order_date)  -- required for proper ordering
ORDER BY 
    sales_year,
    MONTH(o.order_date),  -- keeps months in correct order (Jan → Dec)
    Total_Sales;


/*Current Year Sale */

SELECT
    ROUND(
        SUM(
            CASE 
                WHEN YEAR(o.order_date) = YEAR(GETDATE())  
                THEN itm.total_price 
            END
        ), 0
    ) AS current_year_sale
FROM blinkit_order_items AS itm
LEFT JOIN blinkit_orders AS o
    ON itm.order_id = o.order_id;



/*Previous Year Sale */


SELECT
    ROUND(
        SUM(
            CASE 
                WHEN YEAR(o.order_date) = YEAR(GETDATE()) - 1 
                THEN itm.total_price 
            END
        ), 0
    ) AS previous_year_sale
FROM blinkit_order_items AS itm
LEFT JOIN blinkit_orders AS o
    ON itm.order_id = o.order_id;


/* YOY Growth % Sales */

WITH yearly_sales AS (
    SELECT
        YEAR(o.order_date) AS sales_year,
        ROUND(SUM(itm.total_price),0) AS current_year_sales
    FROM blinkit_order_items AS itm
    LEFT JOIN blinkit_orders AS o
        ON itm.order_id = o.order_id
    GROUP BY YEAR(o.order_date)
),
with_prev AS (
    SELECT
        sales_year,
        current_year_sales,
        LAG(current_year_sales, 1) 
            OVER (ORDER BY sales_year) AS previous_year_sales
    FROM yearly_sales
)
SELECT
    sales_year AS year,
    current_year_sales AS Current_sales,
    previous_year_sales AS Previous_sales,
    ROUND(
        ((current_year_sales - previous_year_sales) 
            / NULLIF(previous_year_sales, 0)) * 100,
        2
    ) AS Growth_Percent
FROM with_prev
ORDER BY sales_year;

/* YOY Growth % By Month Sales */

WITH monthly_sales AS (
    SELECT
        YEAR(o.order_date) AS sales_year,
        MONTH(o.order_date) AS month_num,
        FORMAT(o.order_date, 'MMM') AS month_name,
        SUM(itm.total_price) AS current_sales
    FROM blinkit_order_items itm
    LEFT JOIN blinkit_orders o
        ON itm.order_id = o.order_id
    GROUP BY
        YEAR(o.order_date),
        MONTH(o.order_date),
        FORMAT(o.order_date, 'MMM')
),
with_prev AS (
    SELECT
        sales_year,
        month_num,
        month_name,
        current_sales,
        LAG(current_sales, 1) OVER (
            PARTITION BY month_num
            ORDER BY sales_year
        ) AS previous_sales
    FROM monthly_sales
)
SELECT
    sales_year AS year,
    month_name AS month,
    current_sales,
    previous_sales,
    ROUND(
        ((current_sales - previous_sales) / NULLIF(previous_sales, 0)) * 100,
        2
    ) AS growth_percent
FROM with_prev
ORDER BY sales_year, month_num;



/* Top 10 Product Sales */

SELECT top 10
    p.product_name,
    ROUND(SUM(itm.total_price),0) AS total_sale
FROM blinkit_products AS p
LEFT JOIN blinkit_order_items AS itm
    ON p.product_id = itm.product_id
GROUP BY 
    p.product_name
ORDER BY 
    total_sale DESC



/* Top 10 Product Sales 2024 and 2025 */


WITH yearly_sales AS (
SELECT
        YEAR(o.order_date) AS sales_year,
        p.product_name,
        ROUND(SUM(itm.total_price),0) AS total_sale,
        RANK() OVER (
            PARTITION BY YEAR(o.order_date)
            ORDER BY SUM(itm.total_price) DESC
        ) AS rn
    FROM blinkit_products AS p
    LEFT JOIN blinkit_order_items AS itm
        ON p.product_id = itm.product_id
    LEFT JOIN blinkit_orders AS o
        ON o.order_id = itm.order_id
    WHERE YEAR(o.order_date) IN (2024, 2025)
    GROUP BY 
        YEAR(o.order_date),
        p.product_name
)
SELECT
    sales_year,
    product_name,
    total_sale
FROM yearly_sales
WHERE rn <= 10
ORDER BY 
    sales_year,
    total_sale DESC;

/* Top 10 Area Wise Sales */

SELECT top 10
    c.area AS Area,
    ROUND(SUM(itm.total_price),0) AS Total_Sale
FROM blinkit_customers AS c
LEFT JOIN blinkit_orders AS o
    ON c.customer_id = o.customer_id
LEFT JOIN blinkit_order_items AS itm
    ON o.order_id = itm.order_id
GROUP BY 
    c.area
ORDER BY 
    Total_Sale DESC;



/* Category Wise Total Sales */

SELECT
    p.category,
    ROUND(SUM(itm.total_price), 0) AS Total_sale
FROM blinkit_products AS p
LEFT JOIN blinkit_order_items AS itm
    ON p.product_id = itm.product_id
GROUP BY 
    p.category
ORDER BY 
    Total_Sale DESC;


/* Category Wise Sales 2025 and March Month */

SELECT
    p.category,
    ROUND(SUM(itm.total_price), 0) AS Total_Sale
FROM blinkit_products AS p
LEFT JOIN blinkit_order_items AS itm
    ON p.product_id = itm.product_id
LEFT JOIN blinkit_orders AS o
    ON itm.order_id = o.order_id
WHERE 
    YEAR(o.order_date) = 2025
    AND MONTH(o.order_date) = 3
GROUP BY 
    p.category
ORDER BY 
    Total_Sale DESC;


/* Segment Wise Total Sales */

SELECT 
    c.customer_segment AS Segment,
    ROUND(SUM(itm.total_price),0) AS Total_Sale
FROM blinkit_customers AS c
LEFT JOIN blinkit_orders AS o
    ON c.customer_id = o.customer_id
LEFT JOIN blinkit_order_items AS itm
    ON o.order_id = itm.order_id
GROUP BY 
    c.customer_segment
ORDER BY 
    Total_Sale DESC;



/* Payment Method Wise Total Sales */


SELECT 
    o.payment_method AS Payment_method,
    ROUND(SUM(itm.total_price),0) AS Total_Sale
FROM blinkit_orders AS o
LEFT JOIN blinkit_order_items AS itm
    ON o.order_id = itm.order_id
GROUP BY 
    o.payment_method
ORDER BY 
    Total_Sale DESC;



