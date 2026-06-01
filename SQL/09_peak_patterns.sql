-- Q9: Order volume by weekday and hour-of-day.
-- Answers: When do customers buy? Operational signal for staffing and ad timing.
-- Note: timestamps are local Brazil time, no timezone column in source data.

-- By weekday
SELECT EXTRACT(DOW FROM order_purchase_timestamp) AS dow,
       TO_CHAR(order_purchase_timestamp, 'Day')   AS weekday,
       COUNT(*) AS orders
FROM orders
GROUP BY 1, 2
ORDER BY 1;

-- By hour
SELECT EXTRACT(HOUR FROM order_purchase_timestamp) AS hour,
       COUNT(*) AS orders
FROM orders
GROUP BY 1
ORDER BY 1;
