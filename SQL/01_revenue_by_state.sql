-- Q1: Revenue and average order value by Brazilian state.
-- Answers: Where does revenue come from geographically?
-- Filter: delivered orders only (revenue recognition).

SELECT
  c.customer_state,
  COUNT(DISTINCT o.order_id)                                   AS orders,
  ROUND(SUM(orv.order_total), 2)                              AS revenue,
  ROUND(SUM(orv.order_total) / COUNT(DISTINCT o.order_id), 2) AS aov
FROM orders o
JOIN customers c       ON o.customer_id = c.customer_id
JOIN order_revenue orv ON o.order_id    = orv.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY revenue DESC;
