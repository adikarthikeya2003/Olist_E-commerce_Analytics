-- Foundation view: aggregates order_items to one row per order.
-- Prevents revenue double-counting when joining orders to items downstream.

CREATE VIEW order_revenue AS
SELECT
  oi.order_id,
  SUM(oi.price)                    AS product_revenue,
  SUM(oi.freight_value)            AS freight_revenue,
  SUM(oi.price + oi.freight_value) AS order_total,
  COUNT(*)                         AS item_count
FROM order_items oi
GROUP BY oi.order_id;
