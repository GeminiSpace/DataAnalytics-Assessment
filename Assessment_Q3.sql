-- Question 3: Account Inactivity Alert

-- for customers with savings plan or investment plan
with active_plans as (
    select 
        id as plan_id,
        owner_id,
        case 
            when is_regular_savings = 1 then 'Savings'
            when is_a_fund = 1 then 'Investment'
            else 'Other'
        end as type
    from plans_plan
    where is_regular_savings = 1 or is_a_fund = 1
),

last_txn as (
    select 
        plan_id,
        max(transaction_date) as last_transaction_date
    from savings_savingsaccount
    group by plan_id
),

-- Putting the filtered customers and their last transaction inside one table
combined as (
    select 
        ap.plan_id,
        ap.owner_id,
        ap.type,
        lt.last_transaction_date,
        datediff(current_date(), lt.last_transaction_date) as inactivity_days  -- subtracting the last transaction date from the current date to get the inactive days
    from active_plans ap
    left join last_txn lt on ap.plan_id = lt.plan_id
)

select *
from combined
where inactivity_days > 365 -- Customers with no transaction in the last 1 year
order by inactivity_days desc;
