-- 1. Select all customers.
SELECT * FROM customers;

-- 2. Select customer full names using concatenation.
SELECT customer_id,
       first_name || ' ' || last_name AS full_name,
       email,
       city,
       region,
       segment
FROM customers;

-- 3. Select product names with selling price, cost price, and profit per unit.
SELECT product_id,
       product_name,
       unit_price AS selling_price,
       cost_price,
       ROUND(unit_price - cost_price, 2) AS profit_per_unit
FROM products;

-- 4. Select unique cities.
SELECT DISTINCT city
FROM customers
ORDER BY city;

-- 5. Select unique product categories.
SELECT DISTINCT category
FROM products
ORDER BY category;

-- 6. Sort products by highest selling price.
SELECT product_id,
       product_name,
       category,
       unit_price
FROM products
ORDER BY unit_price DESC, product_name;

-- 7. Sort customers by signup date.
SELECT customer_id,
       first_name,
       last_name,
       signup_date
FROM customers
ORDER BY signup_date ASC;

-- 8. Show orders with readable aliases.
SELECT order_id AS order_number,
       customer_id AS customer_number,
       order_date AS placed_on,
       order_status AS status,
       delivery_city AS city
FROM orders
ORDER BY order_date;
