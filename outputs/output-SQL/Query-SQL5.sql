-- Query 5
SELECT 
    orderid,
    customer,
    orderdate,
    amount
FROM orders_db.processed
WHERE CAST(orderdate AS DATE) >= DATE '2025-02-01'
  AND CAST(orderdate AS DATE) < DATE '2025-03-01'
ORDER BY amount DESC
LIMIT 10;