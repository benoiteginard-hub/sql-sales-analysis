USE DataWarehouseAnalytics;
GO

/*
================================================================================
SQL Portfolio Project - Sales Analysis
================================================================================

Objective
---------
Build reusable SQL views to analyze commercial performance over time and by product.
This script is designed as a portfolio-ready SQL project for a junior Data Analyst role.

Business questions
------------------
1. How did total sales, customers and quantity evolve between 2011 and 2013?
2. Which products and categories generated the most revenue?
3. Which products generated the highest margin?
4. Which products showed the strongest month-over-month growth?
5. How did Mountain Bikes perform over time?

Main SQL skills demonstrated
----------------------------
- Joins between fact and dimension tables
- Analytical views
- Aggregations
- Date truncation and time-based analysis
- Margin calculations
- Window functions: SUM OVER, LAG, RANK
- NULL-safe calculations with NULLIF

Assumptions
-----------
- The source model contains:
    gold.fact_sales
    gold.dim_products
- The analysis period is restricted to completed years from 2011 to 2013.
- SQL Server syntax is used.
================================================================================
*/

/*
================================================================================
1. Base analytical view
================================================================================
This view enriches the sales fact table with product attributes and margin metrics.
It is the central reusable dataset for the rest of the analysis.
*/

CREATE OR ALTER VIEW gold.vw_sales_enriched AS
SELECT
    s.order_date,
    YEAR(s.order_date) AS order_year,
    DATETRUNC(month, s.order_date) AS order_month,
    s.customer_key,
    s.product_key,
    p.product_name,
    p.category,
    p.subcategory,
    p.cost,
    s.quantity,
    s.price,
    s.sales_amount,
    s.quantity * p.cost AS total_cost,
    s.sales_amount - (s.quantity * p.cost) AS margin_amount,
    CAST(
        100.0 * (s.sales_amount - (s.quantity * p.cost))
        / NULLIF(s.sales_amount, 0)
        AS DECIMAL(10, 2)
    ) AS margin_rate_percent
FROM gold.fact_sales AS s
LEFT JOIN gold.dim_products AS p
    ON p.product_key = s.product_key
WHERE s.order_date >= '2011-01-01'
  AND s.order_date < '2014-01-01'
  AND s.order_date IS NOT NULL;
GO

/*
================================================================================
2. Yearly global sales performance
================================================================================
This view summarizes yearly revenue, customer count and quantity sold.
It also calculates cumulative totals over time.
*/

CREATE OR ALTER VIEW gold.vw_sales_yearly_summary AS
WITH yearly_sales AS (
    SELECT
        order_year,
        SUM(sales_amount) AS total_sales,
        COUNT(DISTINCT customer_key) AS total_customers,
        SUM(quantity) AS total_quantity,
        SUM(total_cost) AS total_cost,
        SUM(margin_amount) AS total_margin
    FROM gold.vw_sales_enriched
    GROUP BY order_year
)
SELECT
    order_year,
    total_sales,
    total_customers,
    total_quantity,
    total_cost,
    total_margin,
    CAST(100.0 * total_margin / NULLIF(total_sales, 0) AS DECIMAL(10, 2)) AS margin_rate_percent,
    SUM(total_sales) OVER (ORDER BY order_year) AS running_total_sales,
    SUM(total_customers) OVER (ORDER BY order_year) AS running_total_customers,
    SUM(total_quantity) OVER (ORDER BY order_year) AS running_total_quantity
FROM yearly_sales;
GO

/*
================================================================================
3. Monthly global sales performance
================================================================================
This view summarizes monthly sales performance and cumulative evolution.
*/

CREATE OR ALTER VIEW gold.vw_sales_monthly_summary AS
WITH monthly_sales AS (
    SELECT
        order_month,
        SUM(sales_amount) AS total_sales,
        COUNT(DISTINCT customer_key) AS total_customers,
        SUM(quantity) AS total_quantity,
        SUM(total_cost) AS total_cost,
        SUM(margin_amount) AS total_margin
    FROM gold.vw_sales_enriched
    GROUP BY order_month
)
SELECT
    order_month,
    total_sales,
    total_customers,
    total_quantity,
    total_cost,
    total_margin,
    CAST(100.0 * total_margin / NULLIF(total_sales, 0) AS DECIMAL(10, 2)) AS margin_rate_percent,
    SUM(total_sales) OVER (ORDER BY order_month) AS running_total_sales,
    SUM(total_customers) OVER (ORDER BY order_month) AS running_total_customers,
    SUM(total_quantity) OVER (ORDER BY order_month) AS running_total_quantity
FROM monthly_sales;
GO

/*
================================================================================
4. Product performance summary
================================================================================
This view ranks products by revenue, quantity sold and margin.
It is useful to identify best-selling and most profitable products.
*/

CREATE OR ALTER VIEW gold.vw_product_performance_summary AS
WITH product_performance AS (
    SELECT
        product_key,
        product_name,
        category,
        subcategory,
        cost,
        AVG(price) AS average_price,
        SUM(quantity) AS total_quantity_sold,
        SUM(total_cost) AS total_cost,
        SUM(sales_amount) AS total_revenue,
        SUM(margin_amount) AS total_margin
    FROM gold.vw_sales_enriched
    GROUP BY
        product_key,
        product_name,
        category,
        subcategory,
        cost
)
SELECT
    product_key,
    product_name,
    category,
    subcategory,
    cost,
    average_price,
    CAST(100.0 * (average_price - cost) / NULLIF(cost, 0) AS DECIMAL(10, 2)) AS average_margin_percent,
    total_quantity_sold,
    total_cost,
    total_revenue,
    total_margin,
    CAST(100.0 * total_margin / NULLIF(total_revenue, 0) AS DECIMAL(10, 2)) AS total_margin_rate_percent,
    RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank,
    RANK() OVER (ORDER BY total_margin DESC) AS margin_rank,
    RANK() OVER (ORDER BY total_quantity_sold DESC) AS quantity_rank
FROM product_performance;
GO

/*
================================================================================
5. Monthly product trends
================================================================================
This view tracks product performance month by month.
It calculates month-over-month changes and monthly product rankings.
*/

CREATE OR ALTER VIEW gold.vw_product_monthly_trend AS
WITH monthly_product_sales AS (
    SELECT
        order_month,
        product_key,
        product_name,
        category,
        subcategory,
        SUM(quantity) AS quantity_sold,
        SUM(sales_amount) AS total_revenue,
        SUM(margin_amount) AS total_margin
    FROM gold.vw_sales_enriched
    GROUP BY
        order_month,
        product_key,
        product_name,
        category,
        subcategory
),
monthly_with_lag AS (
    SELECT
        order_month,
        product_key,
        product_name,
        category,
        subcategory,
        quantity_sold,
        total_revenue,
        total_margin,
        LAG(quantity_sold) OVER (
            PARTITION BY product_key
            ORDER BY order_month
        ) AS previous_month_quantity,
        LAG(total_revenue) OVER (
            PARTITION BY product_key
            ORDER BY order_month
        ) AS previous_month_revenue
    FROM monthly_product_sales
)
SELECT
    order_month,
    product_key,
    product_name,
    category,
    subcategory,
    quantity_sold,
    previous_month_quantity,
    quantity_sold - previous_month_quantity AS mom_quantity_difference,
    CAST(
        100.0 * (quantity_sold - previous_month_quantity)
        / NULLIF(previous_month_quantity, 0)
        AS DECIMAL(10, 2)
    ) AS mom_quantity_growth_percent,
    total_revenue,
    previous_month_revenue,
    total_revenue - previous_month_revenue AS mom_revenue_difference,
    CAST(
        100.0 * (total_revenue - previous_month_revenue)
        / NULLIF(previous_month_revenue, 0)
        AS DECIMAL(10, 2)
    ) AS mom_revenue_growth_percent,
    total_margin,
    RANK() OVER (
        PARTITION BY order_month
        ORDER BY total_revenue DESC
    ) AS revenue_rank_in_month,
    RANK() OVER (
        PARTITION BY order_month
        ORDER BY quantity_sold DESC
    ) AS quantity_rank_in_month
FROM monthly_with_lag;
GO

/*
================================================================================
6. Portfolio analysis queries
================================================================================
These final SELECT statements can be used to export CSV outputs for GitHub.
Recommended exports:
- outputs/yearly_sales_summary.csv
- outputs/monthly_sales_summary.csv
- outputs/product_performance_summary.csv
- outputs/mountain_bikes_monthly_trends.csv
================================================================================
*/

-- 6.1 Global yearly sales performance
SELECT
    order_year,
    total_sales,
    total_customers,
    total_quantity,
    total_cost,
    total_margin,
    margin_rate_percent,
    running_total_sales,
    running_total_customers,
    running_total_quantity
FROM gold.vw_sales_yearly_summary
ORDER BY order_year;

-- 6.2 Global monthly sales evolution
SELECT
    order_month,
    total_sales,
    total_customers,
    total_quantity,
    total_cost,
    total_margin,
    margin_rate_percent,
    running_total_sales,
    running_total_customers,
    running_total_quantity
FROM gold.vw_sales_monthly_summary
ORDER BY order_month;

-- 6.3 Top products by revenue
SELECT TOP 20
    product_key,
    product_name,
    category,
    subcategory,
    total_quantity_sold,
    total_revenue,
    total_margin,
    total_margin_rate_percent,
    revenue_rank,
    margin_rank,
    quantity_rank
FROM gold.vw_product_performance_summary
ORDER BY revenue_rank;

-- 6.4 Top products by margin
SELECT TOP 20
    product_key,
    product_name,
    category,
    subcategory,
    total_quantity_sold,
    total_revenue,
    total_margin,
    total_margin_rate_percent,
    revenue_rank,
    margin_rank,
    quantity_rank
FROM gold.vw_product_performance_summary
ORDER BY margin_rank;

-- 6.5 Mountain Bikes monthly trend
SELECT
    order_month,
    product_name,
    quantity_sold,
    previous_month_quantity,
    mom_quantity_difference,
    mom_quantity_growth_percent,
    total_revenue,
    previous_month_revenue,
    mom_revenue_difference,
    mom_revenue_growth_percent,
    revenue_rank_in_month,
    quantity_rank_in_month
FROM gold.vw_product_monthly_trend
WHERE subcategory = 'Mountain Bikes'
ORDER BY order_month, quantity_rank_in_month, product_name;

-- 6.6 Category-level performance summary
SELECT
    category,
    subcategory,
    SUM(total_quantity_sold) AS total_quantity_sold,
    SUM(total_revenue) AS total_revenue,
    SUM(total_margin) AS total_margin,
    CAST(100.0 * SUM(total_margin) / NULLIF(SUM(total_revenue), 0) AS DECIMAL(10, 2)) AS margin_rate_percent
FROM gold.vw_product_performance_summary
GROUP BY category, subcategory
ORDER BY total_revenue DESC;
GO
