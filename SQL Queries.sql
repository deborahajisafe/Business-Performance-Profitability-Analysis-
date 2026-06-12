USE superstore_project;
-- Verify the imported dataset
SELECT COUNT(*) AS total_rows 
FROM dbo.Superstore_cleaned;

--Preview the data
SELECT TOP 5 * 
FROM dbo.Superstore_cleaned;

--Check All Columns and Data Types
SELECT COLUMN_NAME, DATA_TYPE 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'Superstore_cleaned'
ORDER BY ORDINAL_POSITION;

-- SQL Analysis
-- Query 1 — Total Revenue, Total Profit and Overall Profit Margin
-- Q1: What is the total revenue, total profit and overall profit margin?
SELECT 
    ROUND(SUM(sales), 2) AS total_revenue,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND((SUM(profit) / SUM(sales)) * 100, 2) AS overall_profit_margin_pct
FROM dbo.Superstore_cleaned;

-- Query 2 — Yearly Revenue and Profit Trend
-- Is the business actually growing year over year?
-- Q2: What is the yearly revenue and profit trend?
SELECT 
    YEAR(order_date) AS order_year,
    ROUND(SUM(sales), 2) AS total_revenue,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND((SUM(profit) / SUM(sales)) * 100, 2) AS profit_margin_pct,
    COUNT(DISTINCT order_id) AS total_orders
FROM dbo.Superstore_cleaned
GROUP BY YEAR(order_date)
ORDER BY order_year;

-- Query 3 — Monthly Sales Trend
-- Q3: Which months historically generate the highest sales?
SELECT 
    MONTH(order_date) AS month_number,
    DATENAME(MONTH, order_date) AS month_name,
    ROUND(SUM(sales), 2) AS total_revenue,
    ROUND(SUM(profit), 2) AS total_profit,
    COUNT(DISTINCT order_id) AS total_orders
FROM dbo.Superstore_cleaned
GROUP BY MONTH(order_date), DATENAME(MONTH, order_date)
ORDER BY month_number;

-- Query 4 — Top 10 and Bottom 10 Products by Profit
-- Q4a: Top 10 most profitable products
SELECT TOP 10
    product_name,
    category,
    sub_category,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND((SUM(profit) / SUM(sales)) * 100, 2) AS profit_margin_pct
FROM dbo.Superstore_cleaned
GROUP BY product_name, category, sub_category
ORDER BY total_profit DESC;
-- Q4b: Bottom 10 least profitable products
SELECT TOP 10
    product_name,
    category,
    sub_category,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND((SUM(profit) / SUM(sales)) * 100, 2) AS profit_margin_pct
FROM dbo.Superstore_cleaned
GROUP BY product_name, category, sub_category
ORDER BY total_profit ASC;

-- Query 5 — Category Performance
-- Q5: Total sales, profit and margin by Category
SELECT 
    category,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND((SUM(profit) / SUM(sales)) * 100, 2) AS profit_margin_pct,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(sales) / COUNT(DISTINCT order_id), 2) AS avg_order_value
FROM dbo.Superstore_cleaned
GROUP BY category
ORDER BY total_profit DESC;

-- Query 6 — Loss-Making Sub-Categories
-- Q6: Which sub-categories are loss-making?
SELECT 
    category,
    sub_category,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND((SUM(profit) / SUM(sales)) * 100, 2) AS profit_margin_pct,
    COUNT(DISTINCT order_id) AS total_orders
FROM dbo.Superstore_cleaned
GROUP BY category, sub_category
HAVING SUM(profit) < 0
ORDER BY total_profit ASC;

-- Query 7 — Furniture Deep Dive
--Let's see the full picture across ALL Furniture sub-categories to understand 
which ones are saving and which are sinking the category.
-- Q7: Full breakdown of Furniture sub-categories
SELECT 
    sub_category,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND((SUM(profit) / SUM(sales)) * 100, 2) AS profit_margin_pct,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(AVG(discount), 2) AS avg_discount
FROM dbo.Superstore_cleaned
WHERE category = 'Furniture'
GROUP BY sub_category
ORDER BY total_profit DESC;

-- Query 8 — High Sales but Low Profit Margin Sub-Categories
-- This query finds the dangerous "vanity revenue" sub-categories 
-- ones that look good on the top line but are quietly underperforming on profit.
-- Q8: High sales but low profit margin sub-categories
SELECT 
    category,
    sub_category,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND((SUM(profit) / SUM(sales)) * 100, 2) AS profit_margin_pct,
    ROUND(AVG(discount), 2) AS avg_discount
FROM dbo.Superstore_cleaned
GROUP BY category, sub_category
ORDER BY total_sales DESC;

-- Query 9 — Regional Performance
-- Now let's shift to geography. Which regions are driving profit
-- and which are underperforming?
-- Q9: Sales, profit and margin by Region
SELECT 
    region,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND((SUM(profit) / SUM(sales)) * 100, 2) AS profit_margin_pct,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(AVG(discount), 2) AS avg_discount
FROM dbo.Superstore_cleaned
GROUP BY region
ORDER BY total_profit DESC;

-- Query 10 — Top 5 and Bottom 5 States by Profit
-- Q10a: Top 5 states by profit
SELECT TOP 5
    state,
    region,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND((SUM(profit) / SUM(sales)) * 100, 2) AS profit_margin_pct,
    COUNT(DISTINCT order_id) AS total_orders
FROM dbo.Superstore_cleaned
GROUP BY state, region
ORDER BY total_profit DESC;
-- Q10b: Bottom 5 states by profit
SELECT TOP 5
    state,
    region,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND((SUM(profit) / SUM(sales)) * 100, 2) AS profit_margin_pct,
    COUNT(DISTINCT order_id) AS total_orders
FROM dbo.Superstore_cleaned
GROUP BY state, region
ORDER BY total_profit ASC;

-- Query 11 — All Loss-Making States
-- Q11: All states where total profit is negative
SELECT 
    state,
    region,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND((SUM(profit) / SUM(sales)) * 100, 2) AS profit_margin_pct,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(AVG(discount), 2) AS avg_discount
FROM dbo.Superstore_cleaned
GROUP BY state, region
HAVING SUM(profit) < 0
ORDER BY total_profit ASC;

-- Query 12 — Average Discount by Region
-- Q12: Average discount by region and its relationship to profit
SELECT 
    region,
    ROUND(AVG(discount), 2) AS avg_discount,
    ROUND(MIN(discount), 2) AS min_discount,
    ROUND(MAX(discount), 2) AS max_discount,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND((SUM(profit) / SUM(sales)) * 100, 2) AS profit_margin_pct,
    COUNT(CASE WHEN discount > 0.5 THEN 1 END) AS high_discount_orders
FROM dbo.Superstore_cleaned
GROUP BY region
ORDER BY avg_discount DESC;

-- Query 13 — Customer Segment Analysis
-- Let's now understand which customer type — Consumer, Corporate 
-- or Home Office — is most valuable to the business.
-- Q13: Sales, profit and orders by Customer Segment
SELECT 
    segment,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND((SUM(profit) / SUM(sales)) * 100, 2) AS profit_margin_pct,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(AVG(sales), 2) AS avg_order_value,
    ROUND(AVG(discount), 2) AS avg_discount
FROM dbo.Superstore_cleaned
GROUP BY segment
ORDER BY total_profit DESC;

--Query 14 — Segment Profit Margin Deep Dive
-- Q14: Profit margin by Segment and Category
SELECT 
    segment,
    category,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND((SUM(profit) / SUM(sales)) * 100, 2) AS profit_margin_pct,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(AVG(discount), 2) AS avg_discount
FROM dbo.Superstore_cleaned
GROUP BY segment, category
ORDER BY segment, profit_margin_pct DESC;

-- Query 15 — Discount Analysis by Segment
-- Q15: Discount distribution by segment
SELECT 
    segment,
    ROUND(AVG(discount), 2) AS avg_discount,
    COUNT(CASE WHEN discount = 0 THEN 1 END) AS no_discount_orders,
    COUNT(CASE WHEN discount > 0 AND discount <= 0.2 THEN 1 END) AS low_discount_orders,
    COUNT(CASE WHEN discount > 0.2 AND discount <= 0.5 THEN 1 END) AS medium_discount_orders,
    COUNT(CASE WHEN discount > 0.5 THEN 1 END) AS high_discount_orders,
    ROUND(SUM(CASE WHEN discount > 0.5 THEN profit ELSE 0 END), 2) AS profit_from_high_discount
FROM dbo.Superstore_cleaned
GROUP BY segment
ORDER BY avg_discount DESC;

-- Query 16 — Shipping Analysis
--Let's now look at operational efficiency — how long does shipping take and which
ship mode is most used?
-- Q16: Average days to ship by Ship Mode
SELECT 
    ship_mode,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(AVG(days_to_ship), 1) AS avg_days_to_ship,
    MIN(days_to_ship) AS min_days,
    MAX(days_to_ship) AS max_days,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND((SUM(profit) / SUM(sales)) * 100, 2) AS profit_margin_pct
FROM dbo.Superstore_cleaned
GROUP BY ship_mode
ORDER BY avg_days_to_ship;

-- Query 17 — Negative Shipping Days Check
-- Q17: Check for any negative days to ship
SELECT 
    COUNT(*) AS negative_shipping_rows,
    MIN(days_to_ship) AS min_days_to_ship
FROM dbo.Superstore_cleaned
WHERE days_to_ship < 0;

-- Query 18 — Discount Bands vs Profit
-- Q18: How do discount bands impact average profit?
SELECT 
    CASE 
        WHEN discount = 0 THEN '1. No Discount (0%)'
        WHEN discount > 0 AND discount <= 0.2 THEN '2. Low Discount (1-20%)'
        WHEN discount > 0.2 AND discount <= 0.5 THEN '3. Medium Discount (21-50%)'
        WHEN discount > 0.5 THEN '4. High Discount (51%+)'
    END AS discount_band,
    COUNT(*) AS total_orders,
    ROUND(AVG(discount) * 100, 1) AS avg_discount_pct,
    ROUND(AVG(profit), 2) AS avg_profit_per_order,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(AVG(profit_margin), 2) AS avg_profit_margin_pct,
    ROUND(SUM(sales), 2) AS total_sales
FROM dbo.Superstore_cleaned
GROUP BY 
    CASE 
        WHEN discount = 0 THEN '1. No Discount (0%)'
        WHEN discount > 0 AND discount <= 0.2 THEN '2. Low Discount (1-20%)'
        WHEN discount > 0.2 AND discount <= 0.5 THEN '3. Medium Discount (21-50%)'
        WHEN discount > 0.5 THEN '4. High Discount (51%+)'
    END
ORDER BY discount_band;