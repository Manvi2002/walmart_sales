select *from walmart;

select count(*) from walmart;

select 
     count(distinct branch)
from walmart;
select max(quantity)from walmart;

--find the diff. payment method and number of transactions,number of qty sold
select 
     payment_method,
	 count(*) as no_payments,
	 sum(quantity) as no_qty_sold
from walmart
group by payment_method

--identify the highest-rated category in each branch, displaying the branch, category
-- average rating
select *
from
(select
     branch,
	 category,
	 avg(rating) as avg_rating,
	 rank() over(partition by branch order by avg(rating) desc) as rank
from walmart
group by 1,2
)
where rank=1

-- identify the busiest day for each branch based on the number of transactions
select *
from
   (select
    branch,
	to_char(to_date(date,'dd/mm/yy'),'day') as day_name,
	count(*) as no_transactions,
	rank() over(partition by branch order by count(*) desc) as rank
  from walmart
  group by 1,2
  )
where rank=1

--calculate the total quantity of items sold as per payment method. List payment_method and total_quantity.
select
     payment_method,
	 count(*)
from walmart
group by payment_method

--determine th average, minimum and maximum rating of category for each city
--list the city, average_rating, min_rating, and max_rating
select
     city,
	 category,
	 min(rating) as min_rating,
	 max(rating) as max_rating,
	 avg(rating) as avg_rating
from walmart
group by 1,2

--calculate the total profit for each category by considering total_profit as
--(unit_price * quantity * profit_margin).
--list category and total_profit, ordered from highest to lowest profit.
select
    category,
	sum(total) as total_revenue,
	sum(total * profit_margin) as profit
from walmart
group by 1
	
-- determine the most common payment method for each branch
--display branch and the preferred_payment_method
with cte
as
(select 
     branch,
	 payment_method,
	 count(*) as total_trans,
	 rank() over(partition by branch order by count(*) desc) as rank
from walmart
group by 1,2
)
select *
from cte
where rank = 1

--categorize sales into 3 group morning, afternoon, evening
--find out each of the shift and number of invoices
select
     branch,
  case
     when extract(hour from(time::time))<12 then 'morning'
	 when extract(hour from(time::time)) between 12 and 17 then 'afternoon'
	 else 'evening'
  end day_time,
  count(*)
from walmart
group by 1,2
order by 1,3 desc

--identify 5 branch with highest decrease ratio in
--revenue compare to last year(current year and last year)
select *,
extract(year from to_date(date, 'dd/mm/yy')) as formatted_date
from walmart

with revenue_2022
as
(select 
    branch,
	sum(total) as revenue
from walmart
where extract(year from to_date(date, 'dd/mm/yy'))=2022
group by 1
),
revenue_2023
as
(
  select 
    branch,
	sum(total) as revenue
from walmart
where extract(year from to_date(date, 'dd/mm/yy'))=2023
group by 1
)

select
     ls.branch,
	 ls.revenue as last_year_revenue,
	 cs.revenue as cr_year_revenue,
	 round(
	 (ls.revenue - cs.revenue)::numeric/
	 ls.revenue::numeric * 100,
	 2) as rev_dec_ratio
from revenue_2022 as ls
join
revenue_2023 as cs
on ls.branch = cs.branch
where ls.revenue > cs.revenue
order by 4 desc 
limit 5