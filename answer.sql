--Basic:
--Q.1 Retrieve the total number of orders placed.
SELECT COUNT (order_id) AS total_orders
FROM orders;
--Q.2 Calculate the total revenue generate from pizza sales.
SELECT SUM (order_details.quantity * pizzas.price) AS revenue
FROM order_details
    JOIN pizzas ON order_details.pizza_id = pizzas.pizza_id;
--Q.3 Identify the highest price pizza.
SELECT pizzas.price,
    pizza_types.name
FROM pizzas
    JOIN pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
ORDER BY price DESC
LIMIT 1;
--Q.4 Identify the most common pizza size ordered.
SELECT pizzas.size,
    COUNT (order_details.order_details_id) AS order_count
FROM pizzas
    JOIN order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY order_count DESC;
--Q.5 List the top 5 most ordered pizza types along with their quantities.
SELECT pizza_types.name,
    SUM (order_details.quantity) AS quantity
FROM pizza_types
    JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
    JOIN order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY quantity DESC
LIMIT 5;
--Intermediate:
-- Q.1 Join the necessary tables to find the total quantity of each pizza category.
-- tables pizza_types, order_details, pizzas
SELECT pizza_types.category,
    SUM (order_details.quantity) AS quantity
FROM pizza_types
    JOIN pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
    JOIN order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY quantity DESC;
--Q.2 Determine the distribution of orders by hour of the day.
SELECT EXTRACT(
        HOUR
        FROM time
    ) AS time,
    COUNT (order_id) AS order
FROM orders
GROUP BY time
ORDER BY COUNT (order_id) DESC;
-- Different Way
SELECT HOUR (time) AS time,
    COUNT (order_id) AS order_count
FROM orders
GROUP BY HOUR (time);
--Q.3 Join relevant tables to find the category wise distribution of pizzas.
SELECT category,
    COUNT (name)
FROM pizza_types
GROUP BY category;
--Q.4 Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT round (avg(quantity))
FROM (
        SELECT orders.date,
            SUM (order_details.quantity) AS quantity
        FROM orders
            JOIN order_details ON order_details.order_id = orders.order_id
        GROUP BY orders.date
    ) AS order_quantity;
--Q.5 Determine the top 3 most ordered pizza types based on revenue.
SELECT pizza_types.name,
    SUM(order_details.quantity * pizzas.price) AS revenue
FROM pizza_types
    JOIN pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
    JOIN order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY revenue DESC
LIMIT 3;
--Advanced:
--Q.1 Calculate the percentage contribution of each pizza type to total revenue.
SELECT pizza_types.category,
    ROUND (
        SUM (order_details.quantity * pizzas.price) / (
            SELECT SUM(order_details.quantity * pizzas.price) AS total_sales
            FROM order_details
                JOIN pizzas ON order_details.pizza_id = pizzas.pizza_id
        ) * 100,
        2
    ) AS revenue
FROM pizza_types
    JOIN pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
    JOIN order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY revenue DESC;
--Q.2 Analyze the cumulative revenue generated over time.
SELECT date,
    SUM (revenue) OVER(
        ORDER BY date
    ) as cumulative_revenue
FROM (
        SELECT orders.date,
            SUM (order_details.quantity * pizzas.price) AS revenue
        FROM order_details
            JOIN pizzas ON order_details.pizza_id = pizzas.pizza_id
            JOIN orders ON order_details.order_id = orders.order_id
        GROUP BY orders.date
    ) AS sales;
--Q.3 Determine the top 3 most ordered pizza types base on revenue fro each pizza category.
-- pizza_types, order_details, pizzas
SELECT category,
    name,
    revenue,
    RANK() OVER (
        partition by category
        ORDER BY revenue DESC
    ) AS rank
FROM (
        SELECT pizza_types.category,
            pizza_types.name,
            SUM(order_details.quantity * pizzas.price) AS revenue
        FROM pizza_types
            JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
            JOIN order_details ON order_details.pizza_id = pizzas.pizza_id
        GROUP BY pizza_types.category,
            pizza_types.name
    ) AS revenue;