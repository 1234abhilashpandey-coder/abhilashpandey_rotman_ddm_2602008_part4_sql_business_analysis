-- 1. Orders with customer names.
SELECT o.order_id,
       o.order_date,
       o.order_status,
       c.first_name || ' ' || c.last_name AS customer_name,
       o.delivery_city
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
ORDER BY o.order_date;

-- 2. Orders with payment details.
SELECT o.order_id,
       o.order_status,
       pay.payment_method,
       pay.payment_status,
       pay.payment_amount,
       pay.payment_date
FROM orders o
JOIN payments pay ON o.order_id = pay.order_id
ORDER BY o.order_id;

-- 3. Order items with product names and categories.
SELECT oi.order_item_id,
       oi.order_id,
       p.product_name,
       p.category,
       oi.quantity,
       oi.unit_price
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
ORDER BY oi.order_id, oi.order_item_id;

-- 4. Full order detail with customer, product, and payment information.
SELECT o.order_id,
       o.order_date,
       c.first_name || ' ' || c.last_name AS customer_name,
       p.product_name,
       p.category,
       oi.quantity,
       oi.unit_price,
       pay.payment_method,
       pay.payment_status
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
JOIN payments pay ON o.order_id = pay.order_id
ORDER BY o.order_id, oi.order_item_id;

-- 5. Revenue by customer.
SELECT c.customer_id,
       c.first_name || ' ' || c.last_name AS customer_name,
       ROUND(SUM(CASE WHEN pay.payment_status = 'Successful' THEN oi.quantity * oi.unit_price ELSE 0 END), 2) AS revenue
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
LEFT JOIN order_items oi ON o.order_id = oi.order_id
LEFT JOIN payments pay ON o.order_id = pay.order_id
GROUP BY c.customer_id, customer_name
ORDER BY revenue DESC, customer_name;

-- 6. Revenue by city.
SELECT o.delivery_city AS city,
       ROUND(SUM(CASE WHEN pay.payment_status = 'Successful' THEN oi.quantity * oi.unit_price ELSE 0 END), 2) AS revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN payments pay ON o.order_id = pay.order_id
GROUP BY o.delivery_city
ORDER BY revenue DESC;

-- 7. Revenue by product category.
SELECT p.category,
       ROUND(SUM(CASE WHEN pay.payment_status = 'Successful' THEN oi.quantity * oi.unit_price ELSE 0 END), 2) AS revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN payments pay ON oi.order_id = pay.order_id
GROUP BY p.category
ORDER BY revenue DESC;

-- 8. Customers who have not placed any orders.
SELECT c.customer_id,
       c.first_name,
       c.last_name,
       c.city,
       c.region
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL
ORDER BY c.customer_id;

-- 9. Orders that have payment failures.
SELECT o.order_id,
       o.order_date,
       o.order_status,
       pay.payment_status,
       pay.payment_method
FROM orders o
JOIN payments pay ON o.order_id = pay.order_id
WHERE pay.payment_status = 'Failed'
ORDER BY o.order_id;

-- 10. Customers with completed orders only.
SELECT c.customer_id,
       c.first_name || ' ' || c.last_name AS customer_name
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, customer_name
HAVING SUM(CASE WHEN o.order_status <> 'Completed' THEN 1 ELSE 0 END) = 0;

-- 11. Products that were never ordered.
SELECT p.product_id,
       p.product_name,
       p.category
FROM products p
LEFT JOIN order_items oi ON p.product_id = oi.product_id
WHERE oi.product_id IS NULL
ORDER BY p.product_id;

-- 12. Top 5 customers by total successful payment amount.
SELECT c.customer_id,
       c.first_name || ' ' || c.last_name AS customer_name,
       ROUND(SUM(CASE WHEN pay.payment_status = 'Successful' THEN pay.payment_amount ELSE 0 END), 2) AS total_successful_payment_amount
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN payments pay ON o.order_id = pay.order_id
GROUP BY c.customer_id, customer_name
ORDER BY total_successful_payment_amount DESC, customer_name
LIMIT 5;
