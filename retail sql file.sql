CREATE TABLE retail (
    InvoiceNo TEXT,
    StockCode TEXT,
    Description TEXT,
    Quantity INTEGER,
    InvoiceDate TIMESTAMP,
    UnitPrice NUMERIC(10, 2),
    CustomerID NUMERIC,
    Country TEXT
);
SELECT COUNT(*)
FROM retail;

SELECT COUNT(DISTINCT Country)
FROM retail;

SELECT Country,
SUM(Quantity * UnitPrice) AS total_sales
FROM retail
GROUP BY Country
ORDER BY total_sales DESC;

SELECT StockCode, Description,
SUM(Quantity * UnitPrice) AS total_sales
FROM retail
GROUP BY StockCode, Description
ORDER BY total_sales DESC
LIMIT 10;

SELECT StockCode,
Description,
SUM(Sales) AS total_sales
FROM retail
GROUP BY StockCode, Description
ORDER BY total_sales DESC
LIMIT 10;

SELECT Country,
SUM(Sales) AS total_sales
FROM retail
GROUP BY Country
HAVING SUM(Sales) > 100000
ORDER BY total_sales DESC;

SELECT
DATE_TRUNC('month', InvoiceDate) AS month,
SUM(Sales) AS total_sales
FROM retail
GROUP BY DATE_TRUNC('month', InvoiceDate)
ORDER BY month;

SELECT
Country,
SUM(Sales) AS negative_sales
FROM retail
WHERE Quantity < 0
GROUP BY Country
ORDER BY negative_sales ASC;

SELECT
CustomerID,
SUM(Sales) AS total_sales
FROM retail
WHERE CustomerID IS NOT NULL
GROUP BY CustomerID
ORDER BY total_sales DESC
LIMIT 10;

SELECT StockCode,
Description,
SUM(Sales) AS total_sales,
ROUND(SUM(Sales) * 100.0 /(SELECT SUM(Sales) FROM retail),2) AS sales_percentage
FROM retail
GROUP BY StockCode, Description
ORDER BY total_sales DESC
LIMIT 10;

SELECT
    CustomerID,
    COUNT(DISTINCT InvoiceNo) AS order_count
FROM retail
WHERE CustomerID IS NOT NULL
GROUP BY CustomerID
HAVING COUNT(DISTINCT InvoiceNo) > 5
ORDER BY order_count DESC;

SELECT ROUND(SUM(Sales) / COUNT(DISTINCT InvoiceNo), 2 ) AS average_order_value
FROM retail
WHERE Quantity > 0;
WITH monthly_sales AS (
SELECT
DATE_TRUNC('month', InvoiceDate) AS month,
SUM(Sales) AS total_sales
FROM retail
GROUP BY DATE_TRUNC('month', InvoiceDate))
SELECT
month,
total_sales,
LAG(total_sales) OVER (ORDER BY month) AS previous_month_sales
FROM monthly_sales
ORDER BY month;

WITH monthly_sales AS (SELECT
DATE_TRUNC('month', InvoiceDate) AS month,
SUM(Sales) AS total_sales FROM retail
GROUP BY DATE_TRUNC('month', InvoiceDate)),monthly_comparison AS (SELECT month,
total_sales,
LAG(total_sales) OVER (ORDER BY month) AS previous_month_sales
FROM monthly_sales)
SELECT
month,
total_sales,
previous_month_sales,
ROUND((total_sales - previous_month_sales)
* 100.0 / NULLIF(previous_month_sales, 0), 2) AS growth_percentage
FROM monthly_comparison
ORDER BY month;

WITH product_country_sales AS (
    SELECT
        Country,
        StockCode,
        Description,
        SUM(Sales) AS total_sales
    FROM retail
    GROUP BY Country, StockCode, Description
),

ranked_products AS (
    SELECT
        Country,
        StockCode,
        Description,
        total_sales,
        RANK() OVER (
            PARTITION BY Country
            ORDER BY total_sales DESC
        ) AS product_rank
    FROM product_country_sales
)

SELECT
    Country,
    StockCode,
    Description,
    total_sales,
    product_rank
FROM ranked_products
WHERE product_rank <= 3
ORDER BY Country, product_rank;

SELECT
    CustomerID,
    MIN(InvoiceDate) AS first_purchase_date
FROM retail
WHERE CustomerID IS NOT NULL
  AND Quantity > 0
GROUP BY CustomerID
ORDER BY first_purchase_date;


SELECT
    Country,
    COUNT(DISTINCT CASE
        WHEN InvoiceNo LIKE 'C%' THEN InvoiceNo
    END) AS cancelled_orders,

    COUNT(DISTINCT InvoiceNo) AS total_orders,

    ROUND(
        COUNT(DISTINCT CASE
            WHEN InvoiceNo LIKE 'C%' THEN InvoiceNo
        END) * 100.0
        / NULLIF(COUNT(DISTINCT InvoiceNo), 0),
        2
    ) AS cancellation_rate
FROM retail
GROUP BY Country
ORDER BY cancellation_rate DESC;


WITH customer_sales AS (
    SELECT
        CustomerID,
        SUM(Sales) AS total_sales
    FROM retail
    WHERE CustomerID IS NOT NULL
    GROUP BY CustomerId )

SELECT
CustomerID,
total_sales,
RANK() OVER (
ORDER BY total_sales DESC
) AS customer_rank
FROM customer_sales
ORDER BY customer_rank;


WITH monthly_sales AS (
SELECT
DATE_TRUNC('month', InvoiceDate) AS month,
SUM(Sales) AS monthly_sales
FROM retail
GROUP BY DATE_TRUNC('month', InvoiceDate))
SELECT month,monthly_sales,
SUM(monthly_sales) OVER (ORDER BY month
ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_sales
FROM monthly_sales
ORDER BY month;