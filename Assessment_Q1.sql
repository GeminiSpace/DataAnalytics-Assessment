-- Question 1: High-Value Customers with Multiple Products

with savings_cte as (
    select owner_id, count(*) as savings_count
    from plans_plan
    where is_regular_savings = 1 -- customer has an investment plan
    group by owner_id
),
investment_cte as (
    select owner_id, count(*) as investment_count
    from plans_plan
    where is_a_fund = 1 -- customer has a savings plan
    group by owner_id
),
deposits_cte as (
    select owner_id, sum(confirmed_amount) as total_deposits
    from savings_savingsaccount
    where confirmed_amount > 0 -- The customer have done a transaction or transaction is greater than 0
    group by owner_id
)

select 
    u.id as owner_id,
    concat(u.first_name, ' ', u.last_name) as name,
    ifnull(s.savings_count, 0) as savings_count,
    ifnull(i.investment_count, 0) as investment_count,
    round(ifnull(d.total_deposits / 100, 0), 2) as total_deposits  -- Convert from kobo
from users_customuser u
left join savings_cte s on u.id = s.owner_id
left join investment_cte i on u.id = i.owner_id
left join deposits_cte d on u.id = d.owner_id
where s.savings_count >= 1 and i.investment_count >= 1
order by total_deposits desc;
