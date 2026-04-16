-- Query 3
SELECT 
    status,
    COUNT(orderid) AS total_orders,
    SUM(amount) AS total_revenue
FROM orders_db.processed
WHERE status IN ('shipped', 'confirmed')
GROUP BY status;