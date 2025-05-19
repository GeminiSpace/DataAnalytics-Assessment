-- Question 2: Transaction Frequency Analysis


with txn_per_customer_month as (
    select 
        owner_id,
        date_format(transaction_date, '%Y-%m') as txn_month, -- formating the transaction date to year-month  i.e '2016-08-28 21:56:43' will become '2016-08'
        count(*) as monthly_txns
    from savings_savingsaccount
    group by owner_id, date_format(transaction_date, '%Y-%m')
),

avg_txn_rate as (
    select 
        owner_id,
        avg(monthly_txns) as avg_txn_per_month
    from txn_per_customer_month
    group by owner_id
),

-- categorizing the transaction frequency into buckets
frequency_categorized as (
    select 
        case 
            when avg_txn_per_month >= 10 then 'High Frequency'
            when avg_txn_per_month between 3 and 9 then 'Medium Frequency'
            else 'Low Frequency'  
        end as frequency_category,
        owner_id,
        avg_txn_per_month
    from avg_txn_rate
)

select 
    frequency_category,
    count(distinct owner_id) as customer_count,
    round(avg(avg_txn_per_month), 2) as avg_transactions_per_month
from frequency_categorized
group by frequency_category
order by 
    case 
        when frequency_category = 'High Frequency' then 1
        when frequency_category = 'Medium Frequency' then 2
        else 3  -- ordering by frequency category
    end;
