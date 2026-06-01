-- Q8: Monthly order trend.
-- Answers: Is the business growing? Boundary months (Sept 2016, Oct 2018) are partial.

SELECT DATE_TRUNC('month', order_purchase_timestamp) AS month,
       COUNT(*) AS orders
FROM orders
GROUP BY 1
ORDER BY 1;
