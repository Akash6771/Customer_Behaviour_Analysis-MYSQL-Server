
CREATE TABLE sales (
    customer_id VARCHAR(1),
    order_date DATE,
    product_id INTEGER
);

INSERT INTO sales
	(customer_id, order_date, product_id)
VALUES
	('A', '2021-01-01', 1),
	('A', '2021-01-01', 2),
	('A', '2021-01-07', 2),
	('A', '2021-01-10', 3),
	('A', '2021-01-11', 3),
	('A', '2021-01-11', 3),
	('B', '2021-01-01', 2),
	('B', '2021-01-02', 2),
	('B', '2021-01-04', 1),
	('B', '2021-01-11', 1),
	('B', '2021-01-16', 3),
	('B', '2021-02-01', 3),
	('C', '2021-01-01', 3),
	('C', '2021-01-01', 3),
	('C', '2021-01-07', 3);


CREATE TABLE menu (
    product_id INTEGER,
    product_name VARCHAR(5),
    price INTEGER
);

INSERT INTO menu
	(product_id, product_name, price)
VALUES
	(1, 'sushi', 10),
    (2, 'curry', 15),
    (3, 'ramen', 12);

CREATE TABLE members (
    customer_id VARCHAR(1),
    join_date DATE
);


INSERT INTO members
	(customer_id, join_date)
VALUES
	('A', '2021-01-07'),
    ('B', '2021-01-09');

SELECT 
    s.customer_id, SUM(price) AS Total_Spent
FROM
    sales AS s
        INNER JOIN
    menu AS m ON s.product_id = m.product_id
GROUP BY s.customer_id;

##Q.2 How many days has each customer visited the restaurant##
Select customer_id, Count(Distinct order_date) from sales
Group by customer_id

##Q.3 What was the first item from the menu purchased by each customer?##
use Products
Select * from  menu 
Select * from sales

With customer_first_Purchase AS( 
Select s.customer_id, MIN(s.order_date) as First_purchase_date 
from sales s
Group by s.customer_id
)
Select cfp.customer_id,cfp.First_purchase_date, m.product_name
From customer_first_Purchase cfp
inner join sales s on s.customer_id = cfp.customer_id 
AND cfp.First_purchase_date = s.order_date
inner join menu m on m.product_id = s.product_id

##4. What is the most purchased item on the menu and how many times was it purchased by all customers?##
Select m.product_name, COUNT(*) AS Total_purchase
from sales s
join menu m on
s.product_id = m.product_id
group by m.product_name
order by Total_purchase desc

## 5. Which item was the most popular for each customer?##

WITH Popular_customer AS (
Select s.customer_id, m.product_name, Count(*) As Purchase_count,
Row_Number() OVER(Partition by s.customer_id order by Count(*) desc) AS Total_Rank
from sales s
Inner join menu m on
s.product_id = m.product_id
group by s.customer_id, m.product_name
)
Select customer_id, product_name, purchase_count
from Popular_customer pc
Where Total_Rank = 1

##Q.6 Which item was purchased first by the customer after they became a member?##

WITH MEMBERSHIP As
(Select s.customer_id, MIN(s.order_date) As First_Purchase_Date
from sales s
join members ms on
s.customer_id = ms.customer_id
Where s.order_date >= ms.join_date
group by s.customer_id
)
Select msb.customer_id, m.product_name
from MEMBERSHIP msb
join sales s 
on  msb.customer_id = s.customer_id
AND msb.First_Purchase_Date = s.order_date
join menu m on s.product_id = m.product_id

select * from menu
## 7. Which item was purchased just before the customer became a member?##

WITH BEFORE_MEMBERSHIP As
(Select s.customer_id, MAX(s.order_date) As Last_Purchase_Date
from sales s
join members ms on
s.customer_id = ms.customer_id
Where s.order_date < ms.join_date
group by s.customer_id
)
Select bms.customer_id, m.product_name
from BEFORE_MEMBERSHIP bms
join sales s 
on  bms.customer_id = s.customer_id
AND bms.Last_Purchase_Date = s.order_date
join menu m on s.product_id = m.product_id

##8. What is the total items and amount spent for each member before they became a member?##

SELECT s.customer_id, COUNT(*) as total_items, SUM(m.price) AS total_spent
FROM sales s
JOIN menu m ON s.product_id = m.product_id
JOIN members mb ON s.customer_id = mb.customer_id
WHERE s.order_date < mb.join_date
GROUP BY s.customer_id;

##9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier – how many points would each customer have?##

Select s.customer_id,
SUM(CASE when m.product_name = 'sushi' then m.price*20
ELSE m.price*10 END) As TOtal_Point 
from sales s
Join menu m on s.product_id = m.product_id
group by s.customer_id

## 10. In the first week after a customer joins the program (including their join date) 
## they earn 2x points on all items, not just sushi. How many points do customer A and B have at the end of January?##

SELECT 
    s.customer_id,
    SUM(CASE
        WHEN s.order_date BETWEEN mb.join_date AND DATE_ADD('2021-01-31', interval 7 day) THEN m.price*20
        WHEN m.product_name = 'sushi' THEN m.price*20
        ELSE m.price*10
    END) AS total_points
FROM sales s
        JOIN menu m ON s.product_id = m.product_id
        LEFT JOIN members mb ON s.customer_id = mb.customer_id
WHERE s.customer_id IN ('A' , 'B') AND s.order_date <= '2021-01-31'
GROUP BY s.customer_id
order by customer_id

