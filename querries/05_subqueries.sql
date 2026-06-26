-- 1. Customers whose total spend is above the average customer spend.
SELECT c.customer_id,
       c.first_name || ' ' || c.last_name AS customer_name,
       ROUND(SUM(pay.payment_amount), 2) AS total_spend
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN payments pay ON o.order_id = pay.order_id
WHERE pay.payment_status = 'Successful'
GROUP BY c.customer_id, customer_name
HAVING SUM(pay.payment_amount) > (
    SELECT AVG(customer_spend)
    FROM (
        SELECT SUM(pay2.payment_amount) AS customer_spend
        FROM orders o2
        JOIN payments pay2 ON o2.order_id = pay2.order_id
        WHERE pay2.payment_status = 'Successful'
        GROUP BY o2.customer_id
    ) s
)
ORDER BY total_spend DESC;

-- 2. Products priced above the average product price.
SELECT product_id,
       product_name,
       unit_price
FROM products
WHERE unit_price > (SELECT AVG(unit_price) FROM products)
ORDER BY unit_price DESC;

-- 3. Orders with value above the average order value.
SELECT order_id,
       ROUND(order_value, 2) AS order_value
FROM (
    SELECT o.order_id,
           SUM(oi.quantity * oi.unit_price) AS order_value
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY o.order_id
) t
WHERE order_value > (
    SELECT AVG(order_value)
    FROM (
        SELECT SUM(oi.quantity * oi.unit_price) AS order_value
        FROM order_items oi
        GROUP BY oi.order_id
    ) a
)
ORDER BY order_value DESC;

-- 4. Customers who placed at least one completed order.
SELECT *
FROM customers c
WHERE EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.customer_id = c.customer_id
      AND o.order_status = 'Completed'
)
ORDER BY c.customer_id;

-- 5. Customers who never placed an order.
SELECT *
FROM customers c
WHERE NOT EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.customer_id = c.customer_id
)
ORDER BY c.customer_id;

-- 6. Product categories with revenue above the average category revenue.
SELECT category,
       ROUND(revenue, 2) AS revenue
FROM (
    SELECT p.category,
           SUM(oi.quantity * oi.unit_price) AS revenue
    FROM order_items oi
    JOIN products p ON oi.product_id = p.product_id
    GROUP BY p.category
) cat_rev
WHERE revenue > (
    SELECT AVG(revenue)
    FROM (
        SELECT SUM(oi2.quantity * oi2.unit_price) AS revenue
        FROM order_items oi2
        JOIN products p2 ON oi2.product_id = p2.product_id
        GROUP BY p2.category
    ) avg_cat
)
ORDER BY revenue DESC;

-- 7. Products that generated revenue above the average product revenue.
SELECT product_id,
       product_name,
       ROUND(revenue, 2) AS revenue
FROM (
    SELECT p.product_id,
           p.product_name,
           SUM(oi.quantity * oi.unit_price) AS revenue
    FROM products p
    JOIN order_items oi ON p.product_id = oi.product_id
    GROUP BY p.product_id, p.product_name
) prod_rev
WHERE revenue > (
    SELECT AVG(revenue)
    FROM (
        SELECT SUM(oi2.quantity * oi2.unit_price) AS revenue
        FROM order_items oi2
        GROUP BY oi2.product_id
    ) avg_prod
)
ORDER BY revenue DESC;

-- 8. Orders that contain more than one product.
SELECT order_id,
       product_count
FROM (
    SELECT order_id,
           COUNT(DISTINCT product_id) AS product_count
    FROM order_items
    GROUP BY order_id
) t
WHERE product_count > 1
ORDER BY order_id;

-- 9. Customers who purchased from more than one category.
SELECT customer_id,
       customer_name,
       category_count
FROM (
    SELECT c.customer_id,
           c.first_name || ' ' || c.last_name AS customer_name,
           COUNT(DISTINCT p.category) AS category_count
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN payments pay ON o.order_id = pay.order_id
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products p ON oi.product_id = p.product_id
    WHERE pay.payment_status = 'Successful'
    GROUP BY c.customer_id, customer_name
) t
WHERE category_count > 1
ORDER BY category_count DESC, customer_name;

-- 10. Cities whose revenue is above the average city revenue.
SELECT city,
       ROUND(revenue, 2) AS revenue
FROM (
    SELECT o.delivery_city AS city,
           SUM(CASE WHEN pay.payment_status = 'Successful' THEN oi.quantity * oi.unit_price ELSE 0 END) AS revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN payments pay ON o.order_id = pay.order_id
    GROUP BY o.delivery_city
) city_rev
WHERE revenue > (
    SELECT AVG(revenue)
    FROM (
        SELECT SUM(CASE WHEN pay2.payment_status = 'Successful' THEN oi2.quantity * oi2.unit_price ELSE 0 END) AS revenue
        FROM orders o2
        JOIN order_items oi2 ON o2.order_id = oi2.order_id
        JOIN payments pay2 ON o2.order_id = pay2.order_id
        GROUP BY o2.delivery_city
    ) avg_city
)
ORDER BY revenue DESC;
