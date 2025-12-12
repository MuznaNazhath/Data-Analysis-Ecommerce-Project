
-- 1. Create cleaned table (remove invalid rows)

IF OBJECT_ID('ecom_clean', 'U') IS NOT NULL
    DROP TABLE ecom_clean;

SELECT *
INTO ecom_clean
FROM staging_ecom
WHERE Quantity IS NOT NULL
  AND InvoiceDate IS NOT NULL
  AND Quantity <> 0;


-- 4. Monthly revenue view

IF OBJECT_ID('monthly_revenue', 'V') IS NOT NULL
    DROP VIEW monthly_revenue;

CREATE VIEW monthly_revenue AS
SELECT 
    FORMAT(InvoiceDate, 'yyyy-MM-01') AS month_start,
    SUM(TotalPrice) AS revenue,
    COUNT(DISTINCT CustomerID) AS unique_customers
FROM ecom_clean
GROUP BY FORMAT(InvoiceDate, 'yyyy-MM-01');

-- 5. Top products by quantity

IF OBJECT_ID('top_products', 'V') IS NOT NULL
    DROP VIEW top_products;

CREATE VIEW top_products AS
SELECT TOP 20
    Description,
    SUM(Quantity) AS total_qty,
    SUM(TotalPrice) AS total_revenue
FROM ecom_clean
GROUP BY Description
ORDER BY total_qty DESC;

--  6. Customer RFM view

IF OBJECT_ID('customer_rfm', 'V') IS NOT NULL
    DROP VIEW customer_rfm;

CREATE VIEW customer_rfm AS
SELECT 
    CustomerID,
    MAX(InvoiceDate) AS last_purchase,
    DATEDIFF(DAY, MAX(InvoiceDate), GETDATE()) AS recency_days,
    COUNT(DISTINCT InvoiceNo) AS frequency,
    SUM(TotalPrice) AS monetary
FROM ecom_clean
GROUP BY CustomerID;