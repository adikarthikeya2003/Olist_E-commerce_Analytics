import os
import pandas as pd
from sqlalchemy import create_engine

# 1. Automatically detect your Mac username for Postgres.app
mac_username = os.getlogin()
engine = create_engine(f"postgresql+psycopg2://TonysJarvis@localhost:5432/olist")

# 2. Your master dictionary of queries (Now using triple quotes """ everywhere!)
queries = {
    "state": """
        SELECT c.customer_state, 
               COUNT(DISTINCT o.order_id) AS orders, 
               SUM(orv.order_total) AS revenue 
        FROM orders o 
        JOIN customers c ON o.customer_id=c.customer_id 
        JOIN order_revenue orv ON o.order_id=orv.order_id 
        WHERE o.order_status='delivered' 
        GROUP BY 1
    """,

    "category": """
        WITH cat AS (
          SELECT
            COALESCE(t.product_category_name_english, p.product_category_name, 'unknown') AS category,
            COUNT(DISTINCT oi.order_id) AS orders,
            ROUND(SUM(oi.price), 2)     AS revenue
          FROM order_items oi
          JOIN orders o    ON oi.order_id   = o.order_id
          JOIN products p  ON oi.product_id = p.product_id
          LEFT JOIN product_category_translation t ON p.product_category_name = t.product_category_name
          WHERE o.order_status = 'delivered'
          GROUP BY 1
        )
        SELECT
          category,
          orders,
          revenue,
          ROUND(100.0 * revenue / SUM(revenue) OVER (), 2) AS pct_of_revenue,
          ROUND(100.0 * SUM(revenue) OVER (ORDER BY revenue DESC) / SUM(revenue) OVER (), 2) AS cumulative_pct
        FROM cat
        ORDER BY revenue DESC
    """,

    "delay": """
        WITH d AS (
          SELECT
            o.order_id,
            (o.order_delivered_customer_date::date - o.order_estimated_delivery_date::date) AS delay_days,
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
        ORDER BY MIN(delay_days)
    """,

    "headline": """
        SELECT
          CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 'late' ELSE 'on time' END AS delivery_status,
          COUNT(*)                               AS orders,
          ROUND(AVG(r.review_score), 2)          AS avg_review,
          ROUND(100.0 * AVG(CASE WHEN r.review_score <= 2 THEN 1 ELSE 0 END), 1) AS pct_bad_reviews
        FROM orders o
        JOIN order_reviews r ON o.order_id = r.order_id
        WHERE o.order_status = 'delivered'
          AND o.order_delivered_customer_date IS NOT NULL
        GROUP BY 1;
    """,

    "repeat": """
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
    """,

    "monthly": """
        SELECT DATE_TRUNC('month', order_purchase_timestamp) AS month,
               COUNT(*) AS orders
        FROM orders
        GROUP BY 1
        ORDER BY 1;
    """,

    "hour": """
        SELECT EXTRACT(HOUR FROM order_purchase_timestamp) AS hour,
               COUNT(*) AS orders
        FROM orders
        GROUP BY 1
        ORDER BY 1;
    """
}

# 3. The Automation Loop
print("Starting data export pipeline...")
for name, sql in queries.items():
    try:
        df = pd.read_sql(sql, engine)
        df.to_csv(f"export_{name}.csv", index=False)
        print(f"✅ export_{name}.csv built successfully: {len(df)} rows")
    except Exception as e:
        print(f"❌ Error on {name}: {e}")