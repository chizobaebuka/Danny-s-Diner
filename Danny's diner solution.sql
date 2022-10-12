/* -------Case Study Questions-------*/

-- 1. What is the total amount each customer spent at the restaurant?
-- 2. How many days has each customer visited the restaurant?
-- 3. What was the first item from the menu purchased by each customer?
-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
-- 5. Which item was the most popular for each customer?
-- 6. Which item was purchased first by the customer after they became a member?
-- 7. Which item was purchased just before the customer became a member?
-- 8. What is the total items and amount spent for each member before they became a member?
-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

-- 1. What is the total amount each customer spent at the restaurant?
select customer_id, sum(price) as total_price
From sales as s JOIN menu as m 
ON s.product_id = m.product_id
Group by customer_id
Order by customer_id;

-- 2. How many days has each customer visited the restaurant?? 
select customer_id, count(DISTINCT order_date) as days_visited
From sales
Group by customer_id
Order by customer_id;

-- 3. What was the first item from the menu purchased by each customer?
select customer_id, product_name
from sales as s join menu as m on s.product_id = m.product_id
where order_date >= '2021-01-01'
group by customer_id; 

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
select product_name, count(s.product_id) as no_of_items_sold
from sales as s join menu as m on s.product_id = m.product_id
group by m.product_id; 

-- 5. Which item was the most popular for each customer?
select s.customer_id, m.product_name, count(s.product_id) as times_purchased
from sales as s join menu as m on s.product_id = m.product_id
group by s.customer_id, s.product_id
Order by times_purchased;

-- 6. Which item was purchased first by the customer after they became a member?
select me.customer_id, m.product_name
from members as me
join sales as s on me.customer_id = s.customer_id 
join menu as m on s.product_id = m.product_id
where join_date IS NOT NULL and order_date>join_date
group by customer_id;

-- 7. Which item was purchased just before the customer became a member?
select me.customer_id, m.product_name
from members as me
join sales as s on me.customer_id = s.customer_id 
join menu as m on s.product_id = m.product_id
where join_date IS NOT NULL and order_date<join_date
group by customer_id;

-- 8. What is the total items and amount spent for each member before they became a member?
select s.customer_id, sum(m.price) as total_amount_spent, count(m.product_id) as no_of_items_purchased
from sales as s JOIN menu as m on s.product_id = m.product_id
JOIN members as me on me.customer_id = s.customer_id
WHERE me.customer_id IS NOT NULL and order_date < join_date 
group by customer_id; 

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
With CTE AS (
		select s.customer_id, 
	CASE 
		When s.product_id = 1 then (count(s.product_id)*20*m.price)
		else (count(s.product_id)*10*m.price)
	END AS points
From sales as s 
Join menu as m on s.product_id = m.product_id 
group by s.customer_id, s.product_id
)
select customer_id, sum(points) as points_per_product
from cte
group by customer_id;

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
WITH new_table as (	
		SELECT sales.customer_id,menu.price,sales.order_date,members.join_date, date_add(members.join_date, INTERVAL 6 DAY) AS one_week
				FROM sales
                JOIN menu ON sales.product_id=menu.product_id
                JOIN members ON sales.customer_id =members.customer_id),
cte as (
	SELECT customer_id, order_date, 
	CASE WHEN order_date BETWEEN join_date AND one_week THEN price*20
     ELSE price*10
	END AS points
	FROM new_table)
SELECT customer_id, SUM(points) as loyalty_points 
FROM cte
WHERE order_date <"2021-02-01"
GROUP BY customer_id;