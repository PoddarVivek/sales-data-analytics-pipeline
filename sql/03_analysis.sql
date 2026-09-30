-- Each query is preceded by "-- name: <id>" so pipeline.py can run and export it.

-- name: q01_sales_on_2022_11_05
SELECT * FROM retail_sales WHERE sale_date = DATE '2022-11-05' ORDER BY sale_time;

-- name: q02_clothing_bulk_orders_nov_2022
SELECT * FROM retail_sales
WHERE category = 'Clothing'
  AND strftime(sale_date, '%Y-%m') = '2022-11'
  AND quantity >= 4
ORDER BY sale_date, sale_time;

-- name: q03_revenue_profit_by_category
SELECT category,
       COUNT(*)                                        AS orders,
       SUM(total_sale)                                 AS revenue,
       SUM(profit)                                     AS profit,
       ROUND(100.0 * SUM(profit) / SUM(total_sale), 1) AS margin_pct
FROM retail_sales
GROUP BY category
ORDER BY revenue DESC;

-- name: q04_avg_age_beauty_buyers
SELECT ROUND(AVG(age), 1) AS avg_age FROM retail_sales WHERE category = 'Beauty';

-- name: q05_high_value_transactions
SELECT category,
       COUNT(*)        AS transactions_over_1000,
       SUM(total_sale) AS revenue
FROM retail_sales
WHERE total_sale > 1000
GROUP BY category
ORDER BY revenue DESC;

-- name: q06_orders_by_gender_and_category
SELECT category, gender, COUNT(*) AS orders
FROM retail_sales
GROUP BY category, gender
ORDER BY category, gender;

-- name: q07_monthly_revenue
SELECT date_trunc('month', sale_date)::DATE AS month,
       SUM(total_sale)                      AS revenue,
       ROUND(AVG(total_sale), 1)            AS avg_order_value
FROM retail_sales
GROUP BY 1
ORDER BY 1;

-- name: q08_best_month_each_year_by_avg_order
SELECT year, month, avg_order_value
FROM (
    SELECT EXTRACT(year FROM sale_date)  AS year,
           EXTRACT(month FROM sale_date) AS month,
           ROUND(AVG(total_sale), 1)     AS avg_order_value,
           RANK() OVER (PARTITION BY EXTRACT(year FROM sale_date)
                        ORDER BY AVG(total_sale) DESC) AS rnk
    FROM retail_sales
    GROUP BY 1, 2
) t
WHERE rnk = 1
ORDER BY year;

-- name: q09_top_5_customers
SELECT customer_id,
       COUNT(*)        AS orders,
       SUM(total_sale) AS revenue
FROM retail_sales
GROUP BY customer_id
ORDER BY revenue DESC
LIMIT 5;

-- name: q10_unique_customers_by_category
SELECT category, COUNT(DISTINCT customer_id) AS unique_customers
FROM retail_sales
GROUP BY category
ORDER BY unique_customers DESC;

-- name: q11_orders_by_shift
SELECT CASE WHEN EXTRACT(hour FROM sale_time) < 12 THEN 'Morning (before 12)'
            WHEN EXTRACT(hour FROM sale_time) < 17 THEN 'Afternoon (12 to 16)'
            ELSE 'Evening (17 and later)' END AS shift,
       COUNT(*)        AS orders,
       SUM(total_sale) AS revenue
FROM retail_sales
GROUP BY 1
ORDER BY MIN(EXTRACT(hour FROM sale_time));

-- name: q12_customer_concentration
-- Share of revenue from the top 10% of customers, ranked by revenue.
WITH per_customer AS (
    SELECT customer_id, SUM(total_sale) AS revenue FROM retail_sales GROUP BY customer_id
), ranked AS (
    SELECT revenue, NTILE(10) OVER (ORDER BY revenue DESC) AS decile FROM per_customer
)
SELECT ROUND(100.0 * SUM(revenue) FILTER (WHERE decile = 1) / SUM(revenue), 1) AS top_10pct_revenue_share,
       COUNT(*) AS customers
FROM ranked;

-- name: q13_revenue_by_age_band
SELECT CASE WHEN age < 25 THEN '18-24' WHEN age < 35 THEN '25-34'
            WHEN age < 45 THEN '35-44' WHEN age < 55 THEN '45-54'
            ELSE '55+' END AS age_band,
       COUNT(*)                  AS orders,
       SUM(total_sale)           AS revenue,
       ROUND(AVG(total_sale), 1) AS avg_order_value
FROM retail_sales
WHERE age IS NOT NULL
GROUP BY 1
ORDER BY MIN(age);
