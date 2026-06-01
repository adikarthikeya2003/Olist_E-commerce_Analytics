-- Q5: Overall repeat purchase rate.
-- Answers: Do customers come back?
-- IMPORTANT: groups by customer_unique_id (true person), not customer_id (per-order surrogate).

WITH cust AS (
  SELECT c.customer_unique_id,
         COUNT(DISTINCT o.order_id) AS order_count
  FROM orders o
  JOIN customers c ON o.customer_id = c.customer_id
  GROUP BY 1
)
SELECT
  COUNT(*)                                                            AS total_customers,
  COUNT(*) FILTER (WHERE order_count > 1)                             AS repeat_customers,
  ROUND(100.0 * COUNT(*) FILTER (WHERE order_count > 1) / COUNT(*), 2) AS repeat_rate_pct
FROM cust;
