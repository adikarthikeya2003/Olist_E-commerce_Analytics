-- Q2: Category revenue with Pareto cumulative percentage.
-- Answers: Which categories carry the business (80/20 view)?
-- Uses window functions for total share and running cumulative.

WITH cat AS (
  SELECT
    COALESCE(t.product_category_name_english, p.product_category_name, 'unknown') AS category,
    COUNT(DISTINCT oi.order_id) AS orders,
    ROUND(SUM(oi.price), 2)     AS revenue
  FROM order_items oi
  JOIN orders o   ON oi.order_id   = o.order_id
  JOIN products p ON oi.product_id = p.product_id
  LEFT JOIN product_category_translation t ON p.product_category_name = t.product_category_name
  WHERE o.order_status = 'delivered'
  GROUP BY 1
)
SELECT
  category, orders, revenue,
  ROUND(100.0 * revenue / SUM(revenue) OVER (), 2)                                  AS pct_of_revenue,
  ROUND(100.0 * SUM(revenue) OVER (ORDER BY revenue DESC) / SUM(revenue) OVER (), 2) AS cumulative_pct
FROM cat
ORDER BY revenue DESC;
