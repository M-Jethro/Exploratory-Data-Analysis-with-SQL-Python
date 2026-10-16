# Exploratory Data Analysis with SQL and Python

A data exploration project that loads a paintings dataset into MySQL with Python, then uses SQL to investigate collection coverage, data quality, museum operations, artists, artwork pricing, and painting styles.

## Project overview

The project combines a Python data-loading script with an annotated SQL analysis file. The loader uses **pandas** and **SQLAlchemy** to import eight CSV files into a MySQL database named `paintings`. The `EDA.sql` file explores the resulting relational tables.

## Tools and technologies

- **Python** — ingestion workflow
- **pandas** — reading and preparing CSV data
- **SQLAlchemy** — database connection and table loading
- **MySQL** — relational storage and querying
- **SQL** — joins, aggregation, subqueries, CTEs, window functions, and data-quality checks

## Analysis covered

- **Collection coverage:** artworks without an assigned museum and museums with no recorded paintings.
- **Pricing checks:** sale prices above regular prices, unusually deep discounts, and the most/least expensive recorded works.
- **Data quality:** museum records with missing or numeric-only city values, and invalid or incomplete museum opening hours.
- **Museum operations:** museums open on selected days, museums open all seven days, and the museum with the longest total opening hours.
- **Artists and artworks:** frequently represented artists, painting subjects, popular styles, and artists whose works are represented across multiple countries.
- **Ranking and advanced analysis:** less common canvas sizes, ranked countries by painting count, and CTE/window-function queries involving museum and style rankings.

## Repository files

- `EDA.sql` — SQL queries for exploration and analysis.
- `load_paintings_data.py` — Python script that loads the CSV files into MySQL.
- `archive/` — expected location of the source CSV files (the data files are not necessarily included in the repository).

The loader expects eight files: `artist.csv`, `canvas_size.csv`, `image_link.csv`, `museum_hours.csv`, `museum.csv`, `product_size.csv`, `subject.csv`, and `work.csv`.

## Getting started

### Prerequisites

- Python 3.9 or newer
- MySQL Server
- The paintings dataset CSV files
- A SQL client such as MySQL Workbench

### 1. Install dependencies

From the repository directory, run:

```bash
pip install pandas sqlalchemy pymysql
```

### 2. Create the database

Create the database in MySQL before loading the data:

```sql
CREATE DATABASE paintings;
```

Use a dedicated database user with only the privileges required for this project. The loader replaces tables with matching names, so do not point it at a database containing data you need to preserve.

### 3. Configure the environment

The loader reads connection details from environment variables, not from hard-coded credentials in the Python file.

**Windows PowerShell:**

```powershell
$env:PAINTINGS_DB_USER = "your_mysql_user"
$env:PAINTINGS_DB_PASSWORD = "your_mysql_password"
$env:PAINTINGS_DB_HOST = "localhost"
$env:PAINTINGS_DB_PORT = "3306"
$env:PAINTINGS_DB_NAME = "paintings"
$env:PAINTINGS_DATA_DIR = "C:\path\to\archive"
```

**macOS/Linux shell:**

```bash
export PAINTINGS_DB_USER="your_mysql_user"
export PAINTINGS_DB_PASSWORD="your_mysql_password"
export PAINTINGS_DB_HOST="localhost"
export PAINTINGS_DB_PORT="3306"
export PAINTINGS_DB_NAME="paintings"
export PAINTINGS_DATA_DIR="/path/to/archive"
```

Set `PAINTINGS_DATA_DIR` to the directory that contains all eight CSV files. If you place them in an `archive` directory next to the script, you can omit that variable.

### 4. Load the data

```bash
python load_paintings_data.py
```

The script validates required credentials and input files before connecting. It writes each CSV to a table with the same name and reports the number of rows loaded. It uses `if_exists="replace"`, which replaces an existing table each time it runs.

### 5. Run the analysis

Open `EDA.sql` in your SQL client and execute the queries against the `paintings` database.

## Notes and limitations

- The SQL uses MySQL-compatible syntax, including functions such as `REGEXP`, `TIME_TO_SEC`, `GROUP_CONCAT`, and `LIMIT`.
- `EDA.sql` contains a `DELETE` statement for invalid museum-hours rows. Review destructive statements and back up data before executing them.
- Some queries rely on assumptions about the source data. Review joins and field meanings before using results for decisions.
- The source CSV files are required to reproduce the analysis; obtain them separately if they are not committed to this repository.

## What this project demonstrates

A practical workflow from CSV ingestion to relational analysis: preparing tables, exploring business questions, checking data quality, joining related entities, and using aggregation and ranking to derive insights.

## Repository

[View the source code on GitHub](https://github.com/M-Jethro/Exploratory-Data-Analysis-with-SQL-Python)
