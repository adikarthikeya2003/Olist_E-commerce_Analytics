-- Setup: create tables, load CSVs, add foreign keys
-- Run inside the olist database via psql

CREATE TABLE customers (
  customer_id              VARCHAR PRIMARY KEY,
  customer_unique_id       VARCHAR,
  customer_zip_code_prefix INT,
  customer_city            VARCHAR,
  customer_state           CHAR(2)
);

CREATE TABLE orders (
  order_id                      VARCHAR PRIMARY KEY,
  customer_id                   VARCHAR,
  order_status                  VARCHAR,
  order_purchase_timestamp      TIMESTAMP,
  order_approved_at             TIMESTAMP,
  order_delivered_carrier_date  TIMESTAMP,
  order_delivered_customer_date TIMESTAMP,
  order_estimated_delivery_date TIMESTAMP
);

CREATE TABLE order_items (
  order_id            VARCHAR,
  order_item_id       INT,
  product_id          VARCHAR,
  seller_id           VARCHAR,
  shipping_limit_date TIMESTAMP,
  price               NUMERIC(10,2),
  freight_value       NUMERIC(10,2),
  PRIMARY KEY (order_id, order_item_id)
);

CREATE TABLE order_payments (
  order_id             VARCHAR,
  payment_sequential   INT,
  payment_type         VARCHAR,
  payment_installments INT,
  payment_value        NUMERIC(10,2),
  PRIMARY KEY (order_id, payment_sequential)
);

CREATE TABLE order_reviews (
  review_id              VARCHAR,
  order_id               VARCHAR,
  review_score           INT,
  review_comment_title   VARCHAR,
  review_comment_message TEXT,
  review_creation_date   TIMESTAMP,
  review_answer_timestamp TIMESTAMP
);

CREATE TABLE products (
  product_id                 VARCHAR PRIMARY KEY,
  product_category_name      VARCHAR,
  product_name_length        INT,
  product_description_length INT,
  product_photos_qty         INT,
  product_weight_g           INT,
  product_length_cm          INT,
  product_height_cm          INT,
  product_width_cm           INT
);

CREATE TABLE product_category_translation (
  product_category_name         VARCHAR,
  product_category_name_english VARCHAR
);

-- Load CSVs (replace PATH with your local Kaggle unzip directory)
-- \copy customers FROM 'PATH/olist_customers_dataset.csv' WITH (FORMAT csv, HEADER true);
-- \copy orders FROM 'PATH/olist_orders_dataset.csv' WITH (FORMAT csv, HEADER true);
-- \copy order_items FROM 'PATH/olist_order_items_dataset.csv' WITH (FORMAT csv, HEADER true);
-- \copy order_payments FROM 'PATH/olist_order_payments_dataset.csv' WITH (FORMAT csv, HEADER true);
-- \copy order_reviews FROM 'PATH/olist_order_reviews_dataset.csv' WITH (FORMAT csv, HEADER true);
-- \copy products FROM 'PATH/olist_products_dataset.csv' WITH (FORMAT csv, HEADER true);
-- \copy product_category_translation FROM 'PATH/product_category_name_translation.csv' WITH (FORMAT csv, HEADER true);

-- Foreign keys
ALTER TABLE orders          ADD FOREIGN KEY (customer_id) REFERENCES customers(customer_id);
ALTER TABLE order_items     ADD FOREIGN KEY (order_id)    REFERENCES orders(order_id);
ALTER TABLE order_items     ADD FOREIGN KEY (product_id)  REFERENCES products(product_id);
ALTER TABLE order_payments  ADD FOREIGN KEY (order_id)    REFERENCES orders(order_id);
ALTER TABLE order_reviews   ADD FOREIGN KEY (order_id)    REFERENCES orders(order_id);
