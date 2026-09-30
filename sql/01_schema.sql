-- Raw table. Loaded straight from data/retail_sales.csv with no transformation,
-- so the cleaning step can be audited against what was actually received.
CREATE OR REPLACE TABLE retail_sales_raw (
    transaction_id  INTEGER,
    sale_date       DATE,
    sale_time       TIME,
    customer_id     INTEGER,
    gender          VARCHAR,
    age             INTEGER,
    category        VARCHAR,
    quantity        INTEGER,
    price_per_unit  DOUBLE,
    cogs            DOUBLE,
    total_sale      DOUBLE
);

INSERT INTO retail_sales_raw
SELECT * FROM read_csv('data/retail_sales.csv', header = true);
