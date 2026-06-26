-- 1. This query identifies which customer segment generates the highest successful revenue.
SELECT c.segment,
       ROUND(SUM(CASE WHEN pay.payment_status = 'Successful' THEN oi.quantity * oi.unit_price ELSE 0 END), 2) AS total_revenue
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN payments pay ON o.order_id = pay.order_id
GROUP BY c.segment
ORDER BY total_revenue DESC
LIMIT 1;

-- 2. This query identifies which region has the highest successful payment amount.
SELECT c.region,
       ROUND(SUM(CASE WHEN pay.payment_status = 'Successful' THEN pay.payment_amount ELSE 0 END), 2) AS successful_payment_amount
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN payments pay ON o.order_id = pay.order_id
GROUP BY c.region
ORDER BY successful_payment_amount DESC
LIMIT 1;

-- 3. This query identifies which product category has the highest gross profit.
SELECT p.category,
       ROUND(SUM(oi.quantity * (oi.unit_price - p.cost_price)), 2) AS gross_profit
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.category
ORDER BY gross_profit DESC
LIMIT 1;

-- 4. This query identifies which city has the highest number of cancelled orders.
SELECT delivery_city,
       COUNT(*) AS cancelled_orders
FROM orders
WHERE order_status = 'Cancelled'
GROUP BY delivery_city
ORDER BY cancelled_orders DESC, delivery_city
LIMIT 1;

-- 5. This query identifies which payment method has the highest failure rate.
SELECT payment_method,
       COUNT(CASE WHEN payment_status = 'Failed' THEN 1 END) AS failed_payments,
       COUNT(*) AS total_payments,
       ROUND(100.0 * COUNT(CASE WHEN payment_status = 'Failed' THEN 1 END) / COUNT(*), 2) AS failure_rate_percent
FROM payments
GROUP BY payment_method
ORDER BY failure_rate_percent DESC, payment_method
LIMIT 1;

-- 6. This query finds customers who are high value but have not ordered recently.
-- Recency rule: a customer is 'not recent' if their latest order date is before 2024-05-15.
-- High value rule: successful payment amount greater than the average successful spend per active customer.
SELECT c.customer_id,
       c.first_name || ' ' || c.last_name AS customer_name,
       ROUND(SUM(CASE WHEN pay.payment_status = 'Successful' THEN pay.payment_amount ELSE 0 END), 2) AS successful_spend,
       MAX(o.order_date) AS last_order_date
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN payments pay ON o.order_id = pay.order_id
GROUP BY c.customer_id, customer_name
HAVING successful_spend > (
           SELECT AVG(customer_spend)
           FROM (
               SELECT SUM(CASE WHEN pay2.payment_status = 'Successful' THEN pay2.payment_amount ELSE 0 END) AS customer_spend
               FROM orders o2
               JOIN payments pay2 ON o2.order_id = pay2.order_id
               GROUP BY o2.customer_id
           ) t
       )
   AND MAX(o.order_date) < '2024-05-15'
ORDER BY successful_spend DESC;

-- 7. This query identifies products that sell frequently but generate low profit.
-- Frequent means total quantity sold is above the average quantity sold per product.
-- Low profit means total gross profit is below the average gross profit per sold product.
SELECT product_id,
       product_name,
       total_quantity_sold,
       ROUND(total_gross_profit, 2) AS total_gross_profit
FROM (
    SELECT p.product_id,
           p.product_name,
           SUM(oi.quantity) AS total_quantity_sold,
           SUM(oi.quantity * (oi.unit_price - p.cost_price)) AS total_gross_profit
    FROM products p
    JOIN order_items oi ON p.product_id = oi.product_id
    GROUP BY p.product_id, p.product_name
) t
WHERE total_quantity_sold > (
          SELECT AVG(qty_sold)
          FROM (
              SELECT SUM(quantity) AS qty_sold
              FROM order_items
              GROUP BY product_id
          ) q
      )
  AND total_gross_profit < (
          SELECT AVG(gross_profit)
          FROM (
              SELECT SUM(oi2.quantity * (oi2.unit_price - p2.cost_price)) AS gross_profit
              FROM order_items oi2
              JOIN products p2 ON oi2.product_id = p2.product_id
              GROUP BY p2.product_id
          ) gp
      )
ORDER BY total_quantity_sold DESC, total_gross_profit ASC;

-- 8. This query identifies products that generate high profit but low quantity sold.
-- High profit means total gross profit is above average.
-- Low quantity means total quantity sold is below average.
SELECT product_id,
       product_name,
       total_quantity_sold,
       ROUND(total_gross_profit, 2) AS total_gross_profit
FROM (
    SELECT p.product_id,
           p.product_name,
           SUM(oi.quantity) AS total_quantity_sold,
           SUM(oi.quantity * (oi.unit_price - p.cost_price)) AS total_gross_profit
    FROM products p
    JOIN order_items oi ON p.product_id = oi.product_id
    GROUP BY p.product_id, p.product_name
) t
WHERE total_gross_profit > (
          SELECT AVG(gross_profit)
          FROM (
              SELECT SUM(oi2.quantity * (oi2.unit_price - p2.cost_price)) AS gross_profit
              FROM order_items oi2
              JOIN products p2 ON oi2.product_id = p2.product_id
              GROUP BY p2.product_id
          ) gp
      )
  AND total_quantity_sold < (
          SELECT AVG(qty_sold)
          FROM (
              SELECT SUM(quantity) AS qty_sold
              FROM order_items
              GROUP BY product_id
          ) q
      )
ORDER BY total_gross_profit DESC, total_quantity_sold ASC;

-- 9. This query identifies which customer segment has the highest average order value.
SELECT c.segment,
       ROUND(AVG(order_value), 2) AS average_order_value
FROM (
    SELECT o.order_id,
           o.customer_id,
           SUM(oi.quantity * oi.unit_price) AS order_value
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY o.order_id, o.customer_id
) ov
JOIN customers c ON ov.customer_id = c.customer_id
GROUP BY c.segment
ORDER BY average_order_value DESC
LIMIT 1;

-- 10. This query returns 5 actionable business insights for the business as text output.
WITH segment_leader AS (
    SELECT c.segment AS insight_value,
           ROUND(SUM(CASE WHEN pay.payment_status = 'Successful' THEN oi.quantity * oi.unit_price ELSE 0 END), 2) AS metric
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN payments pay ON o.order_id = pay.order_id
    GROUP BY c.segment
    ORDER BY metric DESC
    LIMIT 1
),
category_profit AS (
    SELECT p.category AS insight_value,
           ROUND(SUM(oi.quantity * (oi.unit_price - p.cost_price)), 2) AS metric
    FROM order_items oi
    JOIN products p ON oi.product_id = p.product_id
    GROUP BY p.category
    ORDER BY metric DESC
    LIMIT 1
),
payment_risk AS (
    SELECT payment_method AS insight_value,
           ROUND(100.0 * COUNT(CASE WHEN payment_status = 'Failed' THEN 1 END) / COUNT(*), 2) AS metric
    FROM payments
    GROUP BY payment_method
    ORDER BY metric DESC, payment_method
    LIMIT 1
),
no_order_customers AS (
    SELECT COUNT(*) AS metric
    FROM customers c
    LEFT JOIN orders o ON c.customer_id = o.customer_id
    WHERE o.order_id IS NULL
),
never_ordered_products AS (
    SELECT COUNT(*) AS metric
    FROM products p
    LEFT JOIN order_items oi ON p.product_id = oi.product_id
    WHERE oi.product_id IS NULL
)
SELECT '1. Prioritize the ' || insight_value || ' segment because it generates the highest revenue (' || metric || ').' AS actionable_insight FROM segment_leader
UNION ALL
SELECT '2. Expand ' || insight_value || ' inventory because it has the highest gross profit (' || metric || ').' FROM category_profit
UNION ALL
SELECT '3. Review ' || insight_value || ' checkout flow because it has the highest payment failure rate (' || metric || '%).' FROM payment_risk
UNION ALL
SELECT '4. Launch reactivation campaigns for ' || metric || ' customers who signed up but never placed an order.' FROM no_order_customers
UNION ALL
SELECT '5. Reassess or promote ' || metric || ' products that were never ordered to reduce dead stock.' FROM never_ordered_products;
