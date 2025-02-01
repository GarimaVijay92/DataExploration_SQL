create DATABASE pizza;

create table orders (
order_id int not null, 
order_date date not null, 
order_time time not null, 
primary key (order_id));

create table order_details (
order_details_id int not null,
order_id int not null, 
pizza_id text not null, pizza_types
quantity int not null, 
primary key (order_details_id));

-- Total number of orders placed
SELECT 
    COUNT(order_id) AS total_orders
FROM
    orders;

-- Total revenue generated from pizza sales
SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS total_sales
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id;

-- Identify the highest-priced pizza.
SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;

-- Most common pizza size ordered 
SELECT 
    pizzas.size,
    COUNT(order_details.order_details_id) AS number_of_orders
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY number_of_orders DESC;

-- top 5 most ordered pizza types along with their quantities

SELECT 
    pizza_types.name,
    SUM(order_details.quantity) AS total_quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY total_quantity DESC
LIMIT 5;

-- find the total quantity of each pizza category ordered
SELECT 
    pizza_types.category,
    SUM(order_details.quantity) AS total_quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY total_quantity DESC;

-- the distribution of orders by hour of the day
SELECT 
    HOUR(order_time) AS order_hour, COUNT(order_id)
FROM
    orders
GROUP BY order_hour;

-- the category-wise distribution of pizzas

SELECT 
    category, COUNT(name) AS no_of_pizzas
FROM
    pizza_types
GROUP BY category;

-- the average number of pizzas ordered per day

SELECT 
    ROUND(AVG(quantity), 0) as average_orders
FROM
    (SELECT 
        orders.order_date, SUM(order_details.quantity) AS quantity
    FROM
        orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY orders.order_date) AS order_quantity;

-- top 3 most ordered pizza types based on revenue

SELECT 
    pizza_types.name,
    SUM(pizzas.price * order_details.quantity) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.name
ORDER BY revenue DESC
LIMIT 3;


-- percentage contribution of each pizza type to total revenue

SELECT 
    pizza_types.category,
    ROUND((SUM(pizzas.price * order_details.quantity) / (SELECT 
                    SUM(order_details.quantity * pizzas.price)
                FROM
                    order_details
                        JOIN
                    pizzas ON order_details.pizza_id = pizzas.pizza_id)) * 100,
            2) AS revenue_contribution
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.category
ORDER BY revenue_contribution DESC;


-- cumulative revenue generated over time

select order_date, 
sum(revenue) over (order by order_date) as cum_revenue
from
(select orders.order_date, 
round(sum(order_details.quantity*pizzas.price),2) as revenue
from order_details join pizzas
on order_details.pizza_id = pizzas.pizza_id
join orders
on orders.order_id = order_details.order_id
group by orders.order_date) as revenue_table;



-- top 3 most ordered pizza types based on revenue for each pizza category

select category, name, round(revenue,1) 
from
(select category, name, revenue, 
rank() over(partition by category order by revenue desc) as rn
from
(select pizza_types.category, pizza_types.name,
sum((order_details.quantity)*pizzas.price) as revenue
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on pizzas.pizza_id = order_details.pizza_id
group by pizza_types.category, pizza_types.name) as a) as b
where rn<=3;

