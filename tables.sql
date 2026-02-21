CREATE TABLE dim_customer (
    customer_sk INT IDENTITY PRIMARY KEY,
    customer_id NVARCHAR(50),
    customer_name NVARCHAR(100),
    segment NVARCHAR(50),
    country NVARCHAR(50),
    city NVARCHAR(50),
    state NVARCHAR(50),
    postal_code NVARCHAR(20),
    region NVARCHAR(50),
    customer_status NVARCHAR(50),
    repeat_status NVARCHAR(50),
    new_customer NVARCHAR(50),
    customer_segment NVARCHAR(50)
);

INSERT INTO dim_customer
SELECT DISTINCT
    LTRIM(RTRIM(customer_id)) AS customer_id,
    customer_name,
    segment,
    country,
    city,
    state,
    postal_code,
    region,
    customer_status,
    repeat_status,
    new_customer,
    customer_segment
FROM dbo.sales
WHERE customer_id IS NOT NULL;

----------------------------
CREATE TABLE dim_product (
    product_sk INT IDENTITY PRIMARY KEY,
    product_id NVARCHAR(50),
    category NVARCHAR(50),
    subcategory NVARCHAR(50),
    product NVARCHAR(MAX)
);

INSERT INTO dim_product
SELECT DISTINCT
    LTRIM(RTRIM(product_id)) AS product_id,
    category,
    subcategory,
    product
FROM dbo.sales
WHERE product_id IS NOT NULL;

-----------------------------------

CREATE TABLE dim_order (
    order_sk INT IDENTITY PRIMARY KEY,
    order_id NVARCHAR(50),
    order_date DATE,
    ship_date DATE,
    ship_mode NVARCHAR(50)
);

INSERT INTO dim_order
SELECT DISTINCT
    LTRIM(RTRIM(order_id)) AS order_id,
    order_date,
    ship_date,
    ship_mode
FROM dbo.sales
WHERE order_id IS NOT NULL;

------------------------------
CREATE TABLE dim_date (
    date_sk INT IDENTITY PRIMARY KEY,
    full_date DATE,
    year INT,
    month INT
);

INSERT INTO dim_date
SELECT DISTINCT
    order_date AS full_date,
    YEAR(order_date) AS year,
    MONTH(order_date) AS month
FROM dbo.sales
WHERE order_date IS NOT NULL;

----------------------------
CREATE TABLE fact_sales (
    fact_id INT IDENTITY PRIMARY KEY,
    customer_sk INT,
    product_sk INT,
    order_sk INT,

    order_date_sk INT,    
    ship_date_sk INT,     
    sales FLOAT,
    quantity INT,
    discount FLOAT,
    profit FLOAT,
    Recency INT,
    Frequency INT,
    Monetary FLOAT,
    Recency_score INT,
    Frequency_score INT,
    Monetary_score INT,
    rfm_score INT,
    churn_status NVARCHAR(20)
);

INSERT INTO fact_sales (
    customer_sk, product_sk, order_sk,
    order_date_sk, ship_date_sk,
    sales, quantity, discount, profit,
    Recency, Frequency, Monetary,
    Recency_score, Frequency_score, Monetary_score,
    rfm_score, churn_status
)
SELECT
    c.customer_sk,
    p.product_sk,
    o.order_sk,
    d_order.date_sk AS order_date_sk, 
    d_ship.date_sk AS ship_date_sk,   
    s.sales,
    s.quantity,
    s.discount,
    s.profit,
    s.Recency,
    s.Frequency,
    s.Monetary,
    s.Recency_score,
    s.Frequency_score,
    s.Monetary_score,
    s.rfm_score,
    s.churn_status
FROM dbo.sales s
JOIN dim_customer c 
    ON LTRIM(RTRIM(s.customer_id)) = LTRIM(RTRIM(c.customer_id))
JOIN dim_product p 
    ON LTRIM(RTRIM(s.product_id)) = LTRIM(RTRIM(p.product_id))
JOIN dim_order o 
    ON LTRIM(RTRIM(s.order_id)) = LTRIM(RTRIM(o.order_id))
JOIN dim_date d_order 
    ON s.order_date = d_order.full_date    
JOIN dim_date d_ship 
    ON s.ship_date = d_ship.full_date;     

ALTER TABLE fact_sales
ADD CONSTRAINT fk_fact_customer
FOREIGN KEY (customer_sk) REFERENCES dim_customer(customer_sk);

ALTER TABLE fact_sales
ADD CONSTRAINT fk_fact_product
FOREIGN KEY (product_sk) REFERENCES dim_product(product_sk);

ALTER TABLE fact_sales
ADD CONSTRAINT fk_fact_order
FOREIGN KEY (order_sk) REFERENCES dim_order(order_sk);

ALTER TABLE fact_sales
ADD CONSTRAINT fk_fact_order_date
FOREIGN KEY (order_date_sk) REFERENCES dim_date(date_sk);

ALTER TABLE fact_sales
ADD CONSTRAINT fk_fact_ship_date
FOREIGN KEY (ship_date_sk) REFERENCES dim_date(date_sk);