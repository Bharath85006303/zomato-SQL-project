#1 .what is total amount each customer spent on zomato ?
select s.userid,sum(p.price) as total_price
from sales s
join product p
on s.product_id=p.product_id
group by userid;

#2.How many days has each customer visited zomato?
select userid,count(distinct created_date) as days_visited
from sales
group by userid;


#3.what was the first product purchased by each customer?
with cte1 as ( 
select *,dense_rank() over(partition by userid order by created_date ) as rnk 
from sales )  

select * from cte1 where rnk=1	;

#4.what is most purchased item on menu & how many times was it purchased by all customers ?
with cte1 as (
select product_id,count(product_id) as cnt_prdt from sales
group by product_id
order by cnt_prdt desc)

select userid,count(product_id) from sales
where product_id=2
group by userid;

#5.which item was most popular for each customer
select userid,product_id,count(product_id) as cnt from sales 
group by userid,product_id
order by userid;

# 6.which item was purchased first by customer after they become a member ?
with cte1 as (
select s.userid,s.created_date ,s.product_id,g.gold_signup_date,rank() over(partition by userid order by created_date) rnk
 from  sales s 
join goldusers_signup g 
on s.userid=g.userid
and created_date>=gold_signup_date)

select * from cte1 where rnk=1;


#7. which item was purchased just before the customer became a member?
with cte1 as (
select s.userid,s.created_date ,s.product_id,g.gold_signup_date,rank() over(partition by userid order by created_date desc) rnk
 from  sales s 
join goldusers_signup g 
on s.userid=g.userid
and created_date<gold_signup_date)

select * from cte1 where rnk=1;

#8. what is total orders and amount spent for each member before they become a member?
select s.userid,created_date,g.gold_signup_date,s.product_id,product_name,price,sum(price) as sum 
from sales s 
join product p 
on s.product_id=p.product_id
join goldusers_signup g 
on s.userid=g.userid
where created_date<=gold_signup_date
group by userid;


#9. If buying each product generates points for eg 5rs=2 zomato point 
 # and each product has different purchasing points for eg for p1 5rs=1 
 #zomato point,for p2 10rs=zomato point and p3 5rs=1 zomato point  2rs =1zomato point,
 #calculate points collected by each customer and for which product most points have been given till now.
 
with cte2 as (
with cte1 as(
select s.userid,p.product_id,product_name,sum(price) as amt,
case 
when s.product_id=1 then 5  
when s.product_id=2 then 2 
when s.product_id=3 then 5
end as points 
from sales s 
join product p 
on s.product_id=p.product_id
group by s.userid,product_id)

select *,round(amt/points,0)as pt_ans from cte1
)
select *,sum(pt_ans) as ind_pts from cte2 
group by userid;


#10. In the first year after a customer joins the gold program (including the join date )
#irrespective of what customer has purchased earn 5 zomato points for every 10rs spent
# who earned more more 1 or 3 what int earning in first yr ? 1zp = 2rs

select s.userid,s.created_date ,s.product_id,g.gold_signup_date
 from  sales s 
join goldusers_signup g 
on s.userid=g.userid
and created_date>=gold_signup_date 
and created_date>=adddate(gold_signup_date+ interval 1 year);

#  11. rnk all transaction of the customers
SELECT *,dense_rank() over(order by created_date asc) as rnk from sales;
  
#12. rank all transaction for each member whenever they are zomato gold member for every non gold member transaction mark as 0 
with cte1 as(
select s.userid,s.created_date,s.product_id,g.gold_signup_date from sales s
left join goldusers_signup g on s.userid=g.userid
and created_date>=gold_signup_date)

select *,case when s.gold_signup_date_ ='null' then 0 else rank() over(partition by userid order by created_date) end as rnk from cte1;



  

