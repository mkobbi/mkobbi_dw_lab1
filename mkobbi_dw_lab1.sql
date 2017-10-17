-- Question 1.3.1
select country, count(customer_id) from customers group by country;
-- Question 1.3.2
SELECT orders.SHIP_COUNTRY AS SHIP_COUNTRY, orders.SHIP_CITY AS SHIP_CITY, COUNT(*) AS NBORDERS
from orders
GROUP BY orders.SHIP_COUNTRY, ROLLUP(orders.SHIP_CITY);
-- Question 1.3.3
select c.country as c_country, s.country as s_country, sum(od.quantity) as quantity, count(o.order_id) as nborder 
	from customers c , orders o , order_details od, suppliers s, products p 
	where c.customer_id = o.customer_id 
		and o.order_id = od.order_id  
		and od.product_id = p.product_id 
		and p.supplier_id = s.supplier_id 
	group by c.country, s.country
	order by c.country, s.country;

-- Question 1.3.4
select c.country as c_country, s.country as s_country, sum(od.quantity) as quantity, count(o.order_id) as nborder 
	from customers c , orders o , order_details od, suppliers s, products p  
	where c.customer_id = o.customer_id 
		and o.order_id = od.order_id  
		and od.product_id = p.product_id 
		and p.supplier_id = s.supplier_id 
		group by rollup(c.country, s.country) 
	order by c.country, s.country;
-- Question 1.3.5
-- First method
select o.ship_country, o.ship_region, o.ship_city, sum(od.unit_price * od.quantity)
	from orders o , order_details od, suppliers s, products p
	where  od.order_id = o.order_id
		and od.product_id = p.product_id
		and p.supplier_id = s.supplier_id
		and lower(s.country) = 'france'
	group by o.ship_country, rollup (o.ship_region, o.ship_city);

-- Second method
select o.ship_country, o.ship_region, o.ship_city, sum(od.unit_price * od.quantity)
	from orders o , order_details od, suppliers s, products p
	where  od.order_id = o.order_id
		and od.product_id = p.product_id
		and p.supplier_id = s.supplier_id
		and lower(s.country) = 'france'
	group by o.ship_country, cube (o.ship_region, o.ship_city);
-- Question 1.3.6
SELECT orders.SHIP_COUNTRY AS SHIP_COUNTRY, DECODE(GROUPING(orders.ship_city),0,TO_CHAR(orders.ship_city),'whole country') AS SHIP_CITY, COUNT(*) AS NBORDERS
	from orders
	GROUP BY orders.SHIP_COUNTRY, ROLLUP(orders.SHIP_CITY);
-- Question 1.4.1
select ship_country, ship_city, count(order_id) as nborders, sum(count(order_id)) over (partition by ship_country) as nbordcity, max(count(order_id)) over (partition by ship_country) as nbormaxcty
from orders
group by ship_country, ship_city 
order by ship_country, ship_city;
-- Question 1.4.2
select ship_country, ship_city, count(order_id) as nborders, dense_rank() over(partition by ship_country order by count(order_id)) as rank
from orders
group by ship_country, ship_city 
order by ship_country;
-- Question 1.4.3
select ship_country, ship_city, count(order_id) as nborders, dense_rank() over(partition by ship_country order by count(order_id)) as rank, cast(count(order_id) / sum(count(order_id))over(partition by ship_country )  as numeric (12,2))  as percentg
from orders
group by ship_country, ship_city 
order by ship_country;
-- Question 1.4.4
create table temp1 as select  dense_rank() OVER (ORDER BY order_id) as rang, order_id, sum(unit_price*quantity) as price from order_details group by order_id;
select t1.order_id, t1.price from temp1 t1, temp1 t2  where t1.price <= 1.1 * t2.price and t2.Rang = t1.Rang -1;
drop table temp1;
-- Question 1.4.5
-- Initialization
create table temp1 as select  od.order_id as order_id, od.product_id as product_id, od.quantity as quantity, extract (year from o.order_date) as year, p.product_name as product_name from  order_details od, orders o, products p where p.product_id = od.product_id and o.order_id = od.order_id;
-- First Method
select distinct year, product_name, sum(quantity) over (partition by year, product_id) as qtty 
from temp1
order by product_name, year;
-- Second Method
select distinct year, product_name, sum(quantity) as qtty from temp1 group by product_name, year order by product_name, year;
-- Dropping of temporary table
drop temp1;
