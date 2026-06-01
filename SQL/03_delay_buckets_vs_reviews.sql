-- Q3: Delivery delay bucketed against review score.
-- Answers: Does late delivery hurt customer satisfaction?
-- Hero query of the project.

WITH d AS (
  SELECT
    o.order_id,
    (o.order_delivered_customer_date::date
     - o.order_estimated_delivery_date::date) AS delay_days,
    r.review_score
  FROM orders o
  JOIN order_reviews r ON o.order_id = r.order_id
  WHERE o.order_status = 'delivered'
    AND o.order_delivered_customer_date IS NOT NULL
    AND o.order_estimated_delivery_date IS NOT NULL
)
SELECT
  CASE
    WHEN delay_days <= 0            THEN 'on time / early'
    WHEN delay_days BETWEEN 1 AND 3 THEN '1-3 days late'
    WHEN delay_days BETWEEN 4 AND 7 THEN '4-7 days late'
    ELSE '8+ days late'
  END                                                                  AS delivery_bucket,
  COUNT(*)                                                             AS orders,
  ROUND(AVG(review_score), 2)                                          AS avg_review,
  ROUND(100.0 * AVG(CASE WHEN review_score <= 2 THEN 1 ELSE 0 END), 1) AS pct_bad_reviews
FROM d
GROUP BY 1
ORDER BY MIN(delay_days);
