# 🛒 Retail Sales Analytics Pipeline (SQL Project)

![SQL](https://img.shields.io/badge/SQL-Data%20Analysis-blue)
![Project Level](https://img.shields.io/badge/Level-Beginner--to--Intermediate-green)
![Status](https://img.shields.io/badge/Status-Completed-brightgreen)

---

## 🚀 Project Overview

This project demonstrates an **end-to-end data analytics pipeline using SQL**, covering database design, data cleaning, exploratory data analysis (EDA), and business insight generation.

The goal is to simulate real-world responsibilities of a **Data Analyst**, transforming raw retail sales data into meaningful insights that support business decisions.

---

## 🎯 Problem Statement

Retail businesses generate large volumes of transactional data, but without proper analysis, valuable insights remain hidden.

👉 This project answers key business questions such as:

* Which product categories generate the most revenue?
* Who are the top customers?
* When do sales peak?
* How does customer behavior vary?

---

## 🏗️ Tech Stack

* **SQL (PostgreSQL / MySQL compatible)**
* Data Analysis using:

  * Aggregations (`SUM`, `AVG`, `COUNT`)
  * Window Functions (`RANK()`)
  * CTEs (Common Table Expressions)
* Data Cleaning using:

  * NULL handling
  * Filtering

---

## 🗂️ Project Structure

```
sales-data-analytics-pipeline/
│
├── data/
│   └── retail_sales.csv
│
├── sql/
│   ├── database_setup.sql
│   ├── data_cleaning.sql
│   └── analysis_queries.sql
│
├── outputs/
│   └── insights.md
│
└── README.md
```

---

## ⚙️ Database Schema

```sql
CREATE DATABASE p1_retail_db;

CREATE TABLE retail_sales (
    transactions_id INT PRIMARY KEY,
    sale_date DATE,
    sale_time TIME,
    customer_id INT,
    gender VARCHAR(10),
    age INT,
    category VARCHAR(35),
    quantity INT,
    price_per_unit FLOAT,
    cogs FLOAT,
    total_sale FLOAT
);
```

---

## 🧹 Data Cleaning

* Removed records with NULL values
* Ensured consistency across all columns
* Verified dataset integrity

```sql
DELETE FROM retail_sales
WHERE 
    sale_date IS NULL OR sale_time IS NULL OR customer_id IS NULL OR 
    gender IS NULL OR age IS NULL OR category IS NULL OR 
    quantity IS NULL OR price_per_unit IS NULL OR cogs IS NULL;
```

---

## 📊 Exploratory Data Analysis

* Total number of transactions
* Unique customers
* Product category distribution

```sql
SELECT COUNT(*) FROM retail_sales;
SELECT COUNT(DISTINCT customer_id) FROM retail_sales;
SELECT DISTINCT category FROM retail_sales;
```

---

## 📈 Business Insights (Key Queries)

### 🔹 Top 5 Customers by Sales

```sql
SELECT 
    customer_id,
    SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY customer_id
ORDER BY total_sales DESC
LIMIT 5;
```

---

### 🔹 Best Selling Month (Per Year)

```sql
SELECT 
    year,
    month,
    avg_sale
FROM (
    SELECT 
        EXTRACT(YEAR FROM sale_date) AS year,
        EXTRACT(MONTH FROM sale_date) AS month,
        AVG(total_sale) AS avg_sale,
        RANK() OVER (
            PARTITION BY EXTRACT(YEAR FROM sale_date)
            ORDER BY AVG(total_sale) DESC
        ) AS rank
    FROM retail_sales
    GROUP BY 1,2
) t
WHERE rank = 1;
```

---

### 🔹 Sales by Time Shift

```sql
WITH hourly_sale AS (
SELECT *,
    CASE
        WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
        WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS shift
FROM retail_sales
)
SELECT 
    shift,
    COUNT(*) AS total_orders
FROM hourly_sale
GROUP BY shift;
```

---

## 💡 Key Insights

* 📌 Certain categories consistently generate higher revenue
* 💰 High-value transactions (>1000) indicate premium customer segments
* 📈 Sales peak during specific months (seasonality trends)
* 👥 Top customers contribute disproportionately to revenue
* ⏰ Afternoon & evening shifts show higher sales volume

---

## 🧠 What I Learned

* Writing optimized SQL queries
* Translating business problems into analytical queries
* Using window functions for advanced analysis
* Structuring a real-world analytics project

---

## 📌 Future Improvements

* 📊 Build Power BI / Tableau dashboard
* 🧱 Add ER Diagram
* ☁️ Deploy using cloud (AWS / GCP)
* 🔄 Automate pipeline using Python

---

## 👨‍💻 Author

**Vivek Poddar**
📧 [vivekpoddar.work@gmail.com](mailto:vivekpoddar.work@gmail.com)
🔗 https://www.linkedin.com/in/vivekpoddar-work

---

## ⭐ If you found this helpful

Give this repo a ⭐ and feel free to connect!

---
