# SQL Sales Analysis Project & Power BI Dashboard 

## Overview and Project Update

This project was initially built as a SQL-only sales analysis project. It has since been extended with a Power BI reporting layer based on the exported SQL analytical views.

Recent improvements include:

* Added a Power BI dashboard with two report pages:

  * Sales Performance Overview
  * Product Performance Analysis
* Added a product model-level analytical view to aggregate SKU variants such as size and color into broader commercial product models.
* Updated CSV outputs with explicit column headers for easier BI import.
* Added product model ranking, category revenue concentration and bike product range analysis.
* Added dashboard screenshots and the `.pbix` report file to the repository.

---

## Business Questions

The analysis answers four main questions:

1. How did sales, customers and quantity sold evolve over time between 2011 and 2013?
2. Which product models generated the most revenue?
3. Which product models generated the highest margin?
4. How did product performance evolve month over month across products and categories?

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
├── outputs/
│   ├── yearly_sales_summary.csv
│   ├── monthly_sales_summary.csv
│   ├── product_performance_summary.csv
│   ├── product_model_performance_summary.csv
│   └── product_monthly_trends.csv
│   
│
└── powerbi/
    ├── sales_performance_dashboard.pbix
    └── screenshots/
        ├── Sales_Performance_Overview.png
        └── Product_Performance_Analysis.png
``` 

## Analytical Views

The SQL script creates six reusable analytical views:

| View                                        | Purpose                                                              |
| ------------------------------------------- | -------------------------------------------------------------------- |
| `gold.vw_sales_enriched`                    | Central view combining sales, customer and product data              |
| `gold.vw_sales_yearly_summary`              | Yearly sales, quantity, customers and margin KPIs                    |
| `gold.vw_sales_monthly_summary`             | Monthly sales, customer, quantity and margin evolution               |
| `gold.vw_product_performance_summary`       | SKU-level product ranking by revenue, margin and quantity            |
| `gold.vw_product_model_performance_summary` | Product model-level performance, aggregating size and color variants |
| `gold.vw_product_monthly_trend`             | Month-over-month product performance analysis                        |

## Outputs

The final SQL queries are exported as CSV files in the `outputs/` folder.

| File                                    | Description                                                                  |
| --------------------------------------- | ---------------------------------------------------------------------------- |
| `yearly_sales_summary.csv`              | Yearly business performance KPIs                                             |
| `monthly_sales_summary.csv`             | Monthly revenue, margin, customer and quantity evolution                     |
| `product_performance_summary.csv`       | SKU-level product revenue, margin, quantity and ranking                      |
| `product_model_performance_summary.csv` | Product model-level ranking, aggregating SKU variants such as size and color |
| `product_monthly_trends.csv`            | Monthly product trend analysis with month-over-month indicators              |


Each CSV output includes explicit column headers and can be imported directly into Power BI or another BI tool.

## Power BI Dashboard

A Power BI dashboard was created from the exported SQL analytical views to provide a business-oriented reporting layer.

The report contains two pages:

### 1. Sales Performance Overview

This page provides a high-level view of business performance over time, including:

* total revenue
* total margin
* margin rate
* quantity sold
* monthly revenue and margin trends
* monthly customer and quantity trends
* year-based filtering
* key business insights

### 2. Product Performance Analysis

This page focuses on product and category performance, including:

* revenue vs margin by product model
* top product models by revenue
* product model ranking
* revenue concentration by category
* bike product range comparison by subcategory
* business insights on revenue concentration and product portfolio structure

### Dashboard Preview

![Sales Performance Overview](powerbi/screenshots/Sales_Performance_Overview.png)

![Product Performance Analysis](powerbi/screenshots/Product_Performance_Analysis.png)

The Power BI report file is available in the `powerbi/` folder:

```text
powerbi/sales_performance_dashboard.pbix
```


## Example Insights

The analysis helps identify:

- strong revenue growth in 2013 after a weaker 2012
- revenue and margin concentration in the Bikes category
- leading product models by revenue and margin
- differences between SKU-level and product model-level performance
- how Road Bikes and Mountain Bikes contribute differently to total revenue
- monthly product performance trends and month-over-month changes

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

## Possible Future Improvements

Possible future improvements include:

- connecting Power BI directly to SQL Server instead of CSV exports
- adding an automated refresh workflow
- adding a dedicated category-level report page
- improving the product model grouping logic with a dedicated mapping table