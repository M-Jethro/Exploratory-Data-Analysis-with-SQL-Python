# Exploratory Data Analysis with SQL and Python

A data exploration project using Python to load a paintings dataset into MySQL and SQL to investigate data quality, museum collections, artists, artwork pricing, opening hours, and painting styles.

## Project overview

This project combines a Python ingestion script with SQL queries. The Python script uses **pandas** and **SQLAlchemy** to load eight CSV tables into a MySQL database named `paintings`. The `EDA.sql` file explores the relational data to answer questions about the collection and identify potential data-quality issues.

## Tools and technologies

- **Python**
- **pandas** — read CSV files into DataFrames
- **SQLAlchemy** — connect to MySQL and write tables
- **MySQL** — store and query the relational dataset
- **SQL** — joins, aggregation, subqueries, common table expressions (CTEs), window functions, and data-quality checks

## Analysis covered

- **Collection coverage:** artworks without an assigned museum and museums with no recorded paintings.
- **Pricing checks:** artworks whose sale price exceeds the regular price, deep discounts, and the most/least expensive recorded works.
- **Data quality:** museum records with missing or numeric-only city values, and invalid or incomplete museum opening hours.
- **Museum operations:** museums open on selected days, museums open all seven days, and the museum with the longest total opening hours.
- **Artists and artworks:** frequently represented artists, painting subjects, popular styles, and artists whose works are represented across multiple countries.
- **Ranking and advanced analysis:** least-used canvas sizes, ranked countries by painting count, and CTE/window-function queries to identify leading combinations of style and museum.

## Repository files

- `EDA.sql` — annotated SQL queries for exploration and analysis.
- `creatin tables and loading data into sql.py` — Python script that reads eight CSV files and loads them into MySQL.

The loading script expects the following CSV files: `artist`, `canvas_size`, `image_link`, `museum_hours`, `museum`, `product_size`, `subject`, and `work`.

## Getting started

### Prerequisites

- Python 3
- MySQL Server
- The paintings dataset CSV files
- A SQL client such as MySQL Workbench

### 1. Install dependencies

```bash
pip install pandas sqlalchemy pymysql
```

### 2. Create the database

```sql
CREATE DATABASE paintings;
```

### 3. Configure the loader

Before running the Python script, update the connection URL and CSV file paths for your environment. The current script uses local Windows paths and contains a local database username/password. Replace these values with your own, and do not commit credentials to source control.

A connection URL will generally look like this:

```python
from sqlalchemy import create_engine

# Example placeholder only; use environment variables for credentials.
engine = create_engine("mysql+pymysql://<user>:<password>@localhost:3306/paintings")
```

Ensure the expected CSV files are available at the paths configured in the script.

### 4. Load the data

```bash
python "creatin tables and loading data into sql.py"
```

The script writes each CSV to a table with the same name. It uses `if_exists="replace"`, so existing tables with those names will be replaced whenever the script runs.

### 5. Run the analysis

Open `EDA.sql` in your SQL client and execute the queries against the `paintings` database.

## Notes and limitations

- The SQL uses MySQL-compatible syntax, including functions such as `REGEXP`, `TIME_TO_SEC`, `GROUP_CONCAT`, and `LIMIT`.
- The SQL file includes a `DELETE` statement for invalid museum-hours rows. Review destructive statements and back up your data before executing them.
- Some queries rely on assumptions about the source data. Review the joins and field meanings before using results for decision-making.
- The loader's local file paths and database settings must be adapted before use.

## What this project demonstrates

A practical workflow from CSV ingestion to relational analysis: preparing tables, exploring business questions, checking data quality, joining related entities, and using aggregation and ranking to derive insights.

## Repository

[View the source code on GitHub](https://github.com/M-Jethro/Exploratory-Data-Analysis-with-SQL-Python)
