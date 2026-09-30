-- Cleaning policy
--   1. A row is unusable for revenue analysis if quantity, price_per_unit, cogs or
--      total_sale is missing, so those rows are dropped.
--   2. A missing age is kept: age matters for two questions only, and AVG ignores NULLs.
--   3. Every removal is counted in data_quality_log so nothing disappears silently.

CREATE OR REPLACE TABLE retail_sales AS
SELECT *,
       total_sale - cogs                                    AS profit,
       ROUND(100.0 * (total_sale - cogs) / total_sale, 2)   AS margin_pct
FROM retail_sales_raw
WHERE quantity IS NOT NULL
  AND price_per_unit IS NOT NULL
  AND cogs IS NOT NULL
  AND total_sale IS NOT NULL;

CREATE OR REPLACE TABLE data_quality_log AS
SELECT 'rows received' AS check_name, COUNT(*) AS value FROM retail_sales_raw
UNION ALL
SELECT 'rows dropped (missing quantity, price, cogs or total)',
       (SELECT COUNT(*) FROM retail_sales_raw) - (SELECT COUNT(*) FROM retail_sales)
UNION ALL
SELECT 'rows kept', COUNT(*) FROM retail_sales
UNION ALL
SELECT 'kept rows with missing age', COUNT(*) FROM retail_sales WHERE age IS NULL
UNION ALL
SELECT 'duplicate transaction_id', COUNT(*) - COUNT(DISTINCT transaction_id) FROM retail_sales
UNION ALL
SELECT 'rows where total_sale differs from quantity x price', COUNT(*) FROM retail_sales
WHERE ABS(total_sale - quantity * price_per_unit) > 0.01;
