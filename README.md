# SQL Sales Analysis Project

## Overview

This project is a SQL-based sales analysis built to demonstrate core Data Analyst skills: data modeling, analytical views, business KPI calculation, product performance analysis, and month-over-month trends.

The project focuses on SQL only. A Power BI dashboard may be added later using the same outputs.

---

## Business Questions

The analysis answers four main questions:

1. How did sales, customers and quantity sold evolve over time between 2011 and 2013??
2. Which products generated the most revenue?
3. Which products generated the highest margin?
4. How did product performance evolve month over month, especially for Mountain Bikes?

---

## Dataset

The project uses a sales data warehouse structure with:

- `gold.fact_sales`
- `gold.dim_products`

Raw flat files are available in:

```text
datasets/flat-files/
``` 

The analysis is based on sales transactions and product attributes such as product name, category, subcategory, cost, price, quantity and sales amount.

## SQL Skills Demonstrated

This project demonstrates:

- SQL view creation
- Joins between fact and dimension tables
- Aggregations with `SUM`, `AVG`, and `COUNT DISTINCT`
- Date-based analysis by year and month
- Revenue, cost, margin and margin rate calculations
- Common Table Expressions
- Window functions:
  - `SUM() OVER`
  - `LAG()`
  - `RANK()`
- Month-over-month analysis
- Product ranking by revenue, margin and quantity

## Project Structure

```text
sql-sales-analysis/
│
├── README.md
│
├── datasets/
│   └── flat-files/
│
├── scripts/
│   └── product_report.sql
│
└── outputs/
    ├── yearly_sales_summary.csv
    ├── monthly_sales_summary.csv
    ├── product_performance_summary.csv
    └── mountain_bikes_monthly_trends.csv
``` 

## Analytical Views

The SQL script creates five reusable analytical views:

| View                                  | Purpose                                           |
| ------------------------------------- | ------------------------------------------------- |
| `gold.vw_sales_enriched`              | Central view combining sales and product data     |
| `gold.vw_sales_yearly_summary`        | Yearly sales, quantity, customers and margin KPIs |
| `gold.vw_sales_monthly_summary`       | Monthly sales and margin evolution                |
| `gold.vw_product_performance_summary` | Product ranking by revenue, margin and quantity   |
| `gold.vw_product_monthly_trend`       | Month-over-month product performance analysis     |

## Outputs
The final SQL queries are exported as CSV files in the outputs/ folder:

| File                                | Description                               |
| ----------------------------------- | ----------------------------------------- |
| `yearly_sales_summary.csv`          | Yearly business performance               |
| `monthly_sales_summary.csv`         | Monthly revenue and margin evolution      |
| `product_performance_summary.csv`   | Product-level revenue, margin and ranking |
| `mountain_bikes_monthly_trends.csv` | Monthly trend analysis for Mountain Bikes |

These outputs can be used directly for reporting or future dashboard creation.

## Example Insights

The analysis helps identify:

- yearly and monthly sales evolution
- top revenue-generating products
- highest-margin products
- products with strong month-over-month growth
- performance trends within the Mountain Bikes subcategory

## Technical Notes

This project uses SQL Server syntax.

The script uses:

```sql
DATETRUNC(month, order_date)
```

This function requires SQL Server 2022 or later.
For older SQL Server versions, it can be replaced with:

```sql
DATEFROMPARTS(YEAR(order_date), MONTH(order_date), 1)
```

The cumulative customer metric represents a cumulative sum of active customers by period, not a fully deduplicated historical customer count.


## How to Run

1. Open the SQL script in SQL Server Management Studio or Azure Data Studio.
2. Load the dataset into the expected `gold` schema.
3. Run `scripts/product_report.sql`.
4. Export the final query results into the `outputs/` folder.
5. Use the CSV outputs for review, reporting or dashboard creation.

## What This Project Demonstrates

This project shows the ability to:

- prepare reusable SQL views
- calculate business KPIs
- analyze sales performance over time
- rank products by business value
- perform month-over-month analysis
- prepare clean outputs for BI or reporting

## Next Step

The next planned step is to build a Power BI dashboard using the exported SQL outputs, focusing on:

- revenue evolution
- margin analysis
- product ranking
- category performance
- monthly trends