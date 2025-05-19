-- Question 4: Customer Lifetime Value (CLV) Estimation


with customer_tenure as (
    select 
        id as customer_id,
        concat(first_name, ' ', last_name) as name,
        timestampdiff(month, date_joined, current_date()) as tenure_months  -- getting the time difference from the signup date to the current date and filtering by month
    from users_customuser
),

txn_summary as (
    select 
        owner_id as customer_id,
        count(*) as total_transactions,
        sum(confirmed_amount) / 100 as total_amount_naira  -- Convert from kobo
    from savings_savingsaccount
    group by owner_id
),

clv_calc as (
    select 
        t.customer_id,
        c.name,
        c.tenure_months,
        t.total_transactions,
        (t.total_amount_naira * 0.001) / nullif(t.total_transactions, 0) as avg_profit_per_transaction  -- Calculation for average profit per transaction
    from txn_summary t
    join customer_tenure c on t.customer_id = c.customer_id
)

select 
    customer_id,
    name,
    tenure_months,
    total_transactions,
    round((total_transactions / nullif(tenure_months, 0)) * 12 * avg_profit_per_transaction, 2) as estimated_clv -- calculation for estimated clv from the formula given
from clv_calc
order by estimated_clv desc;
