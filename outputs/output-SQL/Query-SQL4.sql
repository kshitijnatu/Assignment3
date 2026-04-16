-- Query 4
SELECT 
    customer,
    AVG(amount) AS avg_order_value
FROM orders_db.processed
GROUP BY customer
ORDER BY avg_order_value DESC;