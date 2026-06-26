-- 1. Total number of customers.
SELECT COUNT(*) AS total_customers
FROM customers;

-- 2. Total number of orders.
SELECT COUNT(*) AS total_orders
FROM orders;

-- 3. Total successful payment amount.
SELECT ROUND(SUM(payment_amount), 2) AS total_successful_payment_amount
FROM payments
WHERE payment_status = 'Successful';

-- 4. Revenue by product category.
SELECT p.category,
       ROUND(SUM(oi.quantity * oi.unit_price), 2) AS revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.category
ORDER BY revenue DESC;

-- 5. Revenue by region.
SELECT c.region,
       ROUND(SUM(CASE WHEN pay.payment_status = 'Successful' THEN oi.quantity * oi.unit_price ELSE 0 END), 2) AS revenue
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN payments pay ON o.order_id = pay.order_id
GROUP BY c.region
ORDER BY revenue DESC;

-- 6. Revenue by customer segment.
SELECT c.segment,
       ROUND(SUM(CASE WHEN pay.payment_status = 'Successful' THEN oi.quantity * oi.unit_price ELSE 0 END), 2) AS revenue
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN payments pay ON o.order_id = pay.order_id
GROUP BY c.segment
ORDER BY revenue DESC;

-- 7. Average order value.
SELECT ROUND(AVG(order_value), 2) AS average_order_value
FROM (
    SELECT o.order_id,
           SUM(oi.quantity * oi.unit_price) AS order_value
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY o.order_id
) t;

-- 8. Average order value by city.
SELECT o.delivery_city AS city,
       ROUND(AVG(order_value), 2) AS average_order_value
FROM (
    SELECT o.order_id,
           o.delivery_city,
           SUM(oi.quantity * oi.unit_price) AS order_value
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY o.order_id, o.delivery_city
) AS t
JOIN orders o ON o.order_id = t.order_id
GROUP BY o.delivery_city
ORDER BY average_order_value DESC;

-- 9. Number of orders by payment method.
SELECT payment_method,
       COUNT(*) AS number_of_orders
FROM payments
GROUP BY payment_method
ORDER BY number_of_orders DESC, payment_method;

-- 10. Gross profit by product category.
SELECT p.category,
       ROUND(SUM(oi.quantity * (oi.unit_price - p.cost_price)), 2) AS gross_profit
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.category
ORDER BY gross_profit DESC;

-- 11. Top 5 products by quantity sold.
SELECT p.product_id,
       p.product_name,
       SUM(oi.quantity) AS total_quantity_sold
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_quantity_sold DESC, p.product_name
LIMIT 5;

-- 12. Product categories having revenue above a chosen threshold using HAVING.
SELECT p.category,
       ROUND(SUM(oi.quantity * oi.unit_price), 2) AS revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.category
HAVING SUM(oi.quantity * oi.unit_price) > 30000
ORDER BY revenue DESC;
