# DataAnalytics-Assessment

## Question 1: High-Value Customers with Multiple Products

### Approach:
To identify high-value customers for cross-selling opportunities, i used CTEs (Common Table Expressions) to break down the problem into clear and concise steps:

- `savings_cte`: filtered for customers with at least one regular savings plan (`is_regular_savings =1`)
- `investment_cte`: filtered for customers with at least one investment plan (`is_a_fund = 1`)
- `deposits_cte`: aggregated the total confirmed deposits from `savings_savingsaccount`, converting from kobo to naira by dividing by 100

I then joined all three CTEs with the main user table, filtered to keep only those with both savings and investment plans, and sorted the result by total deposits in descending order.

#### Challenge:
Originally, I tried filtering `plans_plan` using `confirmed_amount`, but it caused an error since that column exists only in `savings_savingsaccount`. Switching to CTEs made the query more readable and easier to debug.

##

## Question 2: Transaction Frequency Analysis

#### Approach:
- I first aggregated the number of transactions per user per month using the `savings_savingsaccount` table.
- Then, I computed each user’s **average monthly transaction rate** across all months they were active.
- Based on this average, I bucketed users into three frequency segments:
  - High Frequency (≥10 txns/month)
  - Medium Frequency (3–9 txns/month)
  - Low Frequency (≤2 txns/month)
- Finally, I grouped the data by frequency category to count customers and compute average transactions per category.

#### Challenge:
Ensuring monthly forwardness in the transaction count and handling users with inconsistent transaction patterns required precise grouping using `date_format`. Using CTEs made it easier to debug and modularize the logic.

#

## Question 3: Account Inactivity Alert

#### Approach:
- I first selected all active plans from the `plans_plan` table, tagging each as a “Savings” or “Investment” based on their type fields.
- Then I joined with `savings_savingsaccount` to get the last recorded transaction per `plan_id`.
- Using `DATEDIFF`, I calculated how long it’s been since each account's last inflow.
- Finally, I filtered out accounts that have been inactive for over 365 days i.e more than a year.

#### Challenge:
The schema stores transaction activity separately, so I had to join the plan data with the transaction stream and correctly aggregate by `plan_id` to detect inactivity.

#

## Question 4: Customer Lifetime Value (CLV) Estimation

#### Approach:
- I calculated tenure in months for each customer using `timestampdiff` between their signup date and the current date.
- Then I counted their total transactions and computed the total transaction amount from the `savings_savingsaccount` table (converted from kobo to naira).
- Profit per transaction was assumed to be 0.1% of the total transaction value.
- I plugged everything into the provided formula to compute an annualized CLV.
- Used `nullif()` to handle divide-by-zero cases for customers with zero months or zero transactions.

#### Challenge:
Handling divide-by-zero edge cases was crucial to avoid SQL errors, especially for new customers with low or no activity. Also, converting from kobo to naira was important for a realistic financial estimate.
