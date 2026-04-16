-- Query 1
SELECT 
    customer,
    SUM(amount) AS total_sales
FROM orders_db.processed
GROUP BY customer
ORDER BY total_sales DESC;