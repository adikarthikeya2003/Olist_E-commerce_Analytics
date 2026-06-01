-- Q4: Binary late vs on-time, headline number.
-- Answers: Single-number summary of the delivery problem.

SELECT
  CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date
       THEN 'late' ELSE 'on time' END    AS delivery_status,
  COUNT(*)                               AS orders,
  ROUND(AVG(r.review_score), 2)          AS avg_review,
  ROUND(100.0 * AVG(CASE WHEN r.review_score <= 2 THEN 1 ELSE 0 END), 1) AS pct_bad_reviews
FROM orders o
JOIN order_reviews r ON o.order_id = r.order_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
GROUP BY 1;
