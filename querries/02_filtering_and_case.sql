-- 1. Customers from a selected region.
SELECT *
FROM customers
WHERE region = 'West';

-- 2. Products above a selected price.
SELECT *
FROM products
WHERE unit_price > 3000
ORDER BY unit_price DESC;

-- 3. Orders between two dates.
SELECT *
FROM orders
WHERE order_date BETWEEN '2024-02-01' AND '2024-04-30'
ORDER BY order_date;

-- 4. Customers with Gmail addresses.
SELECT customer_id,
       first_name,
       last_name,
       email
FROM customers
WHERE email LIKE '%@gmail.com';

-- 5. Orders with cancelled or returned status.
SELECT *
FROM orders
WHERE order_status IN ('Cancelled', 'Returned')
ORDER BY order_date;

-- 6. Payments with failed status.
SELECT *
FROM payments
WHERE payment_status = 'Failed'
ORDER BY payment_date;

-- 7. Products where selling price is less than cost price.
SELECT *
FROM products
WHERE unit_price < cost_price;

-- 8. Create an order value category using CASE.
SELECT o.order_id,
       ROUND(SUM(oi.quantity * oi.unit_price), 2) AS order_value,
       CASE
           WHEN SUM(oi.quantity * oi.unit_price) >= 15000 THEN 'High Value'
           WHEN SUM(oi.quantity * oi.unit_price) >= 7000 THEN 'Medium Value'
           ELSE 'Low Value'
       END AS order_value_category
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY o.order_id
ORDER BY order_value DESC;

-- 9. Create a customer segment label using CASE.
SELECT customer_id,
       first_name,
       last_name,
       segment,
       CASE
           WHEN segment = 'Corporate' THEN 'B2B'
           WHEN segment = 'Small Business' THEN 'Growing Business'
           WHEN segment = 'Home Office' THEN 'Professional Individual'
           ELSE 'Retail Consumer'
       END AS segment_label
FROM customers;

-- 10. Filter orders from a selected month.
SELECT *
FROM orders
WHERE strftime('%m', order_date) = '03'
ORDER BY order_date;
