use blinkit

                                                           --  Marketing Overview --
/* Feedback Category Wise Sentiment */


SELECT
    feedback_category,
    sentiment
FROM blinkit_customer_feedback
GROUP BY 
    feedback_category,
    sentiment;


/* Feedback by Customer Sentiment */


SELECT
    COUNT(order_id) as Customer,
    sentiment
FROM blinkit_customer_feedback
GROUP BY 
    sentiment;


/* Feedback by Customer Segment */

SELECT 
    COUNT(customer_id) AS Customer,
    customer_segment
FROM blinkit_customers
GROUP BY customer_segment;



/* Customer Delivery Status */


SELECT
    COUNT(order_id) AS Orders,
    delivery_status
FROM blinkit_delivery_performance
GROUP BY delivery_status;


/* Customer Reasons of Delayed */

SELECT
    COUNT(order_id) AS Orders,
    reasons_if_delayed
FROM blinkit_delivery_performance
GROUP BY reasons_if_delayed;


/* Campaign by Audience */
SELECT 
    target_audience,
    COUNT(campaign_id) AS Campaign
FROM blinkit_marketing_performance
GROUP BY target_audience
ORDER BY Campaign DESC;


/* Campaign by Channel */

SELECT 
    channel,
    COUNT(campaign_id) AS Campaign
FROM blinkit_marketing_performance
GROUP BY channel
ORDER BY Campaign DESC;



/* KPI'S */

SELECT 
    SUM(impressions) AS Impressions,
    SUM(clicks) AS Clicks,
    SUM(conversions) AS Conversions,
    SUM(spend) AS Spend,
    SUM(revenue_generated) AS Revenue
FROM blinkit_marketing_performance;




