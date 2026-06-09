# Sales Data Analysis

End-to-end analysis of e-commerce sales data covering database design, SQL querying, exploratory data analysis, and customer segmentation. The dataset spans **December 2018 – December 2019** and contains ~554,000 transaction records for an electronics retailer based in Germany.

---

## Project Structure

| File | Description |
|---|---|
| `EDA_sales_data.ipynb` | Loads raw Excel data, performs data wrangling and EDA, outputs cleaned dataset |
| `excel_db_fileconvert.ipynb` | Converts cleaned Excel file to SQLite `.db` and loads into PostgreSQL |
| `Querying_sales_data.sql` | SQL queries against the SQLite database (DB Browser for SQLite) |
| `Querying_sales_data_pg.sql` | Equivalent queries adapted for PostgreSQL syntax |
| `Clustering_sales_data.ipynb` | RFM analysis and KMeans customer segmentation |

---

## Dataset

The source data (`sales_original.xlsx`) contains five relational sheets:

| Table | Columns | Rows |
|---|---|---|
| `products` | ASIN, title, product_type | 554,417 |
| `stock` | StockCode | 554,417 |
| `assessment` | rating, review_count | 554,417 |
| `invoices` | InvoiceNo, Quantity, price, total_sale, invoice_date, invoice_time, CustomerID | 554,417 |
| `customers` | CustomerID, Country | 554,417 |

Product categories include DSLR cameras, smartphones, monitors, and related electronics accessories. Customers span 35+ countries.

---

## Workflow

### 1. Data Wrangling & EDA (`EDA_sales_data.ipynb`)
- Merges the five tables into a single `df_sales` dataframe
- Handles missing values (drops rows with null ASIN or CustomerID, ~145k rows removed)
- Engineers date features: Year, Month, Day of the Week
- Outputs `sales_clean.xlsx` for use in subsequent steps

**EDA visualisations:**
- Total units sold per product category
- Total revenue by month (seasonal spike in Oct–Nov ahead of holidays)
- Sales by day of the week (peak on Sundays)
- Top 10 countries by order volume (excluding Germany as host country)
- Top 10 customers by quantity ordered
- Customer country distribution on a world map (via GeoPandas + Geopy)

**KPIs computed:**
- Average Order Value over time
- Repeat Purchase Rate over time
- Purchase Frequency (orders per customer per month)

### 2. Database Loading (`excel_db_fileconvert.ipynb`)
- Loads cleaned data into **SQLite** via `sqlite3` (for use in DB Browser for SQLite)
- Loads original multi-sheet Excel into **PostgreSQL** via `SQLAlchemy` + `psycopg2`

### 3. SQL Analysis (`Querying_sales_data.sql` / `_pg.sql`)
Queries cover:
- Average customer rating per product type
- Top 5 items by sales revenue
- Top 5 countries by sales revenue (excluding Germany)
- Top 3 highest-rated products per category (window function `RANK() OVER PARTITION BY`)
- Top 3 most-reviewed products per category
- Top 3 best-sellers and bottom 2 worst-sellers per category (by quantity)
- Unique customers per month for 2019

### 4. Customer Segmentation (`Clustering_sales_data.ipynb`)
RFM (Recency, Frequency, Monetary) features are computed per customer:
- **Recency**: days since last purchase
- **Frequency**: number of transactions
- **Monetary**: total spend

Outliers are removed using IQR bounds, features are standardised with `StandardScaler`, and **KMeans** clustering is applied. The optimal number of clusters is selected using the elbow method (inertia) and silhouette score, with k=3 identified as optimal.

---

## Technologies

**Python libraries:** `pandas`, `numpy`, `matplotlib`, `seaborn`, `scikit-learn`, `scipy`, `geopandas`, `geopy`, `pycountry`, `sqlite3`, `SQLAlchemy`, `psycopg2`

**Databases:** DB Browser for SQLite, PostgreSQL

---

## Setup

```bash
pip install pandas numpy matplotlib seaborn scikit-learn scipy geopandas geopy pycountry sqlalchemy psycopg2 openpyxl
```

Place `sales_original.xlsx` in the project root, then run the notebooks in order:
1. `EDA_sales_data.ipynb`
2. `excel_db_fileconvert.ipynb`
3. `Clustering_sales_data.ipynb`

Load the generated `.db` file into DB Browser for SQLite (or connect to PostgreSQL) to run the `.sql` scripts.
