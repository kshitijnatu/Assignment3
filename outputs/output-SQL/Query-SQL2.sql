-- Query 2
SELECT 
    DATE_TRUNC('month', CAST(orderdate AS DATE)) AS order_month,
    COUNT(orderid) AS total_orders,
    SUM(amount) AS total_revenue
FROM orders_db.processed
GROUP BY DATE_TRUNC('month', CAST(orderdate AS DATE))
ORDER BY order_month;