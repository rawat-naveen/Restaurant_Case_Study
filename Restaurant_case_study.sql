														-- Swiggy Case Study

USE zoho;

SELECT * FROM orders;
SELECT * FROM order_details;
SELECT * FROM menu;
SELECT * FROM food;
SELECT * FROM restaurants;
SELECT * FROM users;


-- 1. Find customers who never ordered ?

SELECT name 
FROM users 
WHERE user_id NOT IN (SELECT user_id FROM orders);


-- 2. Average Price of each Dish

SELECT * FROM menu;
SELECT * FROM food;

SELECT t1.f_id AS 'Id',t2.f_name AS 'Food Name', AVG(price) AS 'Average Price' 
FROM menu AS t1
JOIN food AS t2
ON t1.f_id = t2.f_id
GROUP BY t1.f_id,t2.f_name;


-- 3. Find Top Restaurant in terms of number of orders for a given month

SELECT * FROM restaurants;
SELECT * FROM orders;

-- June Month
SELECT t2.r_name, t1.r_id, COUNT(*) AS 'Orders'
FROM orders AS t1
JOIN restaurants AS t2
ON t1.r_id = t2.r_id
WHERE monthname(date) LIKE 'June'
GROUP BY t1.r_id, t2.r_name
ORDER BY COUNT(*) DESC LIMIT 1;

-- May Month
SELECT t1.r_id, t2.r_name, COUNT(*) AS 'Orders'
FROM orders AS t1
JOIN restaurants AS t2
ON t1.r_id = t2.r_id
WHERE monthname(date) LIKE 'May'
GROUP BY t1.r_id, t2.r_name
ORDER BY COUNT(*) DESC LIMIT 1;


-- 4. Resturants with monthly sales > x for 

-- June monthly sales > 500
SELECT * FROM orders;
SELECT * FROM restaurants;
SELECT t2.r_name, t1.r_id, SUM(amount) AS 'Revenue' FROM orders AS t1
JOIN restaurants t2
ON t1.r_id = t2.r_id
WHERE monthname(date) like 'June'
GROUP BY t1.r_id, t2.r_name
HAVING Revenue > 500;

-- May monthly sales > 600
SELECT * FROM orders;
SELECT * FROM restaurants;
SELECT t2.r_name, t1.r_id, SUM(amount) AS 'Revenue' FROM orders AS t1
JOIN restaurants t2
ON t1.r_id = t2.r_id
WHERE monthname(date) like 'May'
GROUP BY t1.r_id, t2.r_name
HAVING Revenue > 600;


-- 5.Show all orders with order details for a particular customer in a particular date range
SELECT * FROM users;
SELECT * FROM orders;
SELECT * FROM users WHERE name LIKE 'Ankit';
SELECT * FROM restaurants;
SELECT * FROM order_details;

-- We are takinh Ankit named customer and showing order date between 2022-06-10 to 2022-07-10
SELECT t1.order_id, t2.r_name, t4.f_name
FROM orders AS t1
JOIN restaurants AS t2
ON t1.r_id = t2.r_id
JOIN order_details AS t3
ON t1.order_id = t3.order_id
JOIN food t4
ON t4.f_id = t3.f_id
WHERE user_id = ( SELECT  user_id FROM users WHERE name LIKE 'Ankit')
AND date > '2022-06-10' AND date < '2022-07-10';


-- 6. Find restaurants with max repeated customers

-- It count how many times the customers visits.
 -- SELECT r_id, user_id, COUNT(*) AS 'visit'
--  FROM orders
--  GROUP BY r_id, user_id
--  HAVING visit > 1;


SELECT t2.r_name,t1.r_id , COUNT(*)  AS 'loyal_customers'
FROM 
(
 SELECT r_id, user_id, COUNT(*) AS 'visit'
 FROM orders
 GROUP BY r_id, user_id
 HAVING visit > 1
) AS t1
JOIN restaurants AS t2
ON t1.r_id = t2.r_id
GROUP BY t1.r_id, t2.r_name
ORDER BY loyal_customers DESC LIMIT 1;


-- 7. Month over month revenue growth of swiggy
SELECT month, ((revenue - prev)/prev) * 100 FROM (
WITH sales AS (
SELECT
 monthname(date) AS 'month',
 SUM(amount) AS 'revenue'
 FROM orders
GROUP BY month
) 
SELECT month, revenue, 
LAG(revenue,1) OVER(ORDER BY revenue) AS 'prev'
FROM sales
) AS t;



-- 8. Customer -> Favourite Food

SELECT * FROM users;
SELECT * FROM orders;
SELECT * FROM order_details;
SELECT * FROM food;

WITH food AS (
SELECT t1.name AS 'name',t4.f_name AS 'f_name',COUNT(f_name) AS 'total'
FROM users AS t1
JOIN orders AS t2
ON t1.user_id = t2.user_id
JOIN order_details AS t3
ON t2.order_id = t3.order_id
JOIN food t4
ON t3.f_id = t4.f_id
GROUP BY name, f_name
)
SELECT * FROM  food AS f1
WHERE f1.total = (SELECT MAX(total) FROM food f2 WHERE f1.name = f2.name);


-- 9. Month Over Month Revenue growth of a restaurant
-- Lets Assume restaurant be kfc
SELECT month, ((revenue - prev)/prev) * 100 AS 'MOM Rev'
FROM(
WITH sales AS (
SELECT t1.r_name AS 'name'
, monthname(date) AS 'month', SUM(amount) AS 'revenue'
FROM restaurants AS t1
JOIN orders AS t2
ON t1.r_id = t2.r_id
GROUP BY name, month
HAVING t1.r_name = 'kfc'
)
SELECT month, revenue,
LAG(revenue,1) OVER(ORDER BY revenue) AS 'prev'
FROM sales
) AS t;


-- 10. Find most loyal customers for all restaurant

select * from users;
SELECT * FROM orders;

SELECT t1.r_id, t2.r_name, t3.name, COUNT(*) AS 'visit'
FROM orders as t1
JOIN restaurants AS t2
ON t1.r_id = t2.r_id
JOIN users AS t3
ON t1.user_id = t3.user_id
GROUP BY t1.r_id, t2.r_name, t3.name
HAVING visit > 1
ORDER BY r_id;
