
-- Tan's Approach for rearranging tables 

ALTER TABLE products ADD COLUMN StockCode TEXT;
UPDATE products p 
INNER JOIN stock s ON p.index = s.index
SET p.StockCode = s.StockCode;

CREATE TABLE purchases (
ASIN TEXT
price REAL
total_sale REAL
)
UPDATE purchases pr 
INNER JOIN invoices i ON pr.index = i.index
SET pr.ASIN = i.ASIN AND pr.Price = i.price AND pr.total_sale = i.total_sale

-- Killian and Virginia's Solution for rearranging tables 
ALTER TABLE products ADD COLUMN StockCode TEXT;
ALTER TABLE products RENAME COLUMN 'index' TO index_col;

ALTER TABLE stock
RENAME COLUMN 'index' TO index_col;

UPDATE products 
SET StockCode = (SELECT StockCode FROM stock WHERE stock.index_col = products.index_col);

-- WINDOW FUNCTION example 
-- What are the top 3 products in each product segment according to rating and review_count? 



-- What are the average ratings for each product type?
ALTER TABLE assessment
RENAME COLUMN 'index' TO index_col;

SELECT product_type, AVG(rating) as avg_rating 
FROM products p 
INNER JOIN assessment a ON p.index_col = a.index_col
GROUP BY product_type;

--What are the 5 items generating the maximum sales revenue?
SELECT i.ASIN, title, SUM(total_sale) as sales_revenue
FROM invoices i
JOIN products p ON i.ASIN = p.ASIN
GROUP BY i.ASIN 
ORDER BY sales_revenue DESC
LIMIT 5

--What are the 5 countries generating the max sales revenue, excluding the host country?
ALTER TABLE invoices  RENAME COLUMN 'index' TO index_col;

ALTER TABLE customers RENAME COLUMN 'index' TO index_col;

SELECT SUM(i.total_sale) as sales_revenue, c.Country
FROM invoices i 
JOIN customers c ON i.index_col = c.index_col
GROUP BY c.Country
ORDER BY sales_revenue DESC
LIMIT 5


-- SELECT SUM(i.total_sale) as sales_revenue, c.Country
-- FROM invoices i 
-- JOIN customers c ON i.CustomerID = c.CustomerID
-- GROUP BY c.Country
-- ORDER BY sales_revenue DESC
-- LIMIT 5

--What are the 3 products in each product segment with the highest customer rating? (Hint: check partition function)
SELECT *
FROM (
	SELECT a.ASIN, product_type, title, rating, RANK() OVER (PARTITION BY product_type ORDER BY rating DESC) AS product_rank
	FROM assessment a
	JOIN products p ON a.ASIN = p.ASIN
	GROUP BY a.ASIN	)
WHERE product_rank<=3

--Are they the 3 most reviewed products as well?
SELECT *
FROM (
	SELECT a.ASIN, product_type, title, review_count, RANK() OVER (PARTITION BY product_type ORDER BY review_count DESC) AS product_rank
	FROM assessment a
	JOIN products p ON a.ASIN = p.ASIN
	GROUP BY a.ASIN)
WHERE product_rank<=3

--What are the 3 best-sellers products in each product segment? (Quantity wise) (Hint: partition function again)
SELECT *
FROM (
	SELECT a.ASIN, product_type, title, Quantity, RANK() OVER (PARTITION BY product_type ORDER BY Quantity DESC) AS product_rank
	FROM invoices a
	JOIN products p ON a.ASIN = p.ASIN
	GROUP BY a.ASIN)
WHERE product_rank<=3

--What are the first and second worst-selling products in every category? (Quantity wise)
SELECT *
FROM (
	SELECT a.ASIN, product_type, title, Quantity, RANK() OVER (PARTITION BY product_type ORDER BY Quantity ASC) AS product_rank
	FROM invoices a
	JOIN products p ON a.ASIN = p.ASIN
	GROUP BY a.ASIN)
WHERE product_rank<=2

--Unique customers per month for the year 2019. 
--There's a catch here: contrary other 'heavier' RDBMS, SQLite does not 
--support the functions YEAR() or MONTH() to extract the year or the month in a date. 
--You will have to create two new columns: yr and mnth.
ALTER TABLE invoices ADD COLUMN Year INT;
ALTER TABLE invoices ADD COLUMN Month INT;

SELECT strftime('%m', invoice_date)AS Month,
strftime('%Y', invoice_date) AS Year
FROM invoices a
WHERE Year=2019
GROUP BY Month






