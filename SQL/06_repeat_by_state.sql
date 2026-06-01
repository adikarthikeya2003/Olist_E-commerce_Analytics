-- Q6: Repeat rate broken down by state.
-- HAVING > 500 filters small states to control sample noise.

WITH cust AS (
  SELECT c.customer_unique_id, c.customer_state,
         COUNT(DISTINCT o.order_id) AS order_count
  FROM orders o
  JOIN customers c ON o.customer_id = c.customer_id
  GROUP BY 1, 2
)
SELECT customer_state,
       COUNT(*)                                                            AS customers,
       ROUND(100.0 * COUNT(*) FILTER (WHERE order_count > 1) / COUNT(*), 2) AS repeat_rate_pct
FROM cust
GROUP BY 1
HAVING COUNT(*) > 500
ORDER BY repeat_rate_pct DESC;
