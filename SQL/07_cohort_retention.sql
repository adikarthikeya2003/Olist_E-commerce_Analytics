-- Q7: Monthly cohort retention.
-- Cohort = month of customer's first purchase.
-- Tracks how many return in months 1, 2, 3 after first buy.
-- Sparse output expected given the low overall repeat rate.

WITH firsts AS (
  SELECT c.customer_unique_id,
         DATE_TRUNC('month', MIN(o.order_purchase_timestamp)) AS cohort_month
  FROM orders o
  JOIN customers c ON o.customer_id = c.customer_id
  GROUP BY 1
),
activity AS (
  SELECT c.customer_unique_id,
         DATE_TRUNC('month', o.order_purchase_timestamp) AS order_month
  FROM orders o
  JOIN customers c ON o.customer_id = c.customer_id
),
joined AS (
  SELECT f.cohort_month,
         a.customer_unique_id,
         (DATE_PART('year', a.order_month) - DATE_PART('year', f.cohort_month)) * 12
       + (DATE_PART('month', a.order_month) - DATE_PART('month', f.cohort_month)) AS month_offset
  FROM firsts f
  JOIN activity a ON f.customer_unique_id = a.customer_unique_id
)
SELECT cohort_month,
       COUNT(DISTINCT customer_unique_id) FILTER (WHERE month_offset = 0) AS cohort_size,
       COUNT(DISTINCT customer_unique_id) FILTER (WHERE month_offset = 1) AS month_1,
       COUNT(DISTINCT customer_unique_id) FILTER (WHERE month_offset = 2) AS month_2,
       COUNT(DISTINCT customer_unique_id) FILTER (WHERE month_offset = 3) AS month_3
FROM joined
GROUP BY cohort_month
ORDER BY cohort_month;
