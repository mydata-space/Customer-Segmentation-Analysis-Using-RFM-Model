/*
    =========================================================
    Data Exploration
    =========================================================
*/

SELECT * FROM sales_table;
SELECT count(*) FROM sales_table WHERE ORDERNUMBER IS NULL AND ORDERNUMBER = '';
SELECT COUNT(*) FROM sales_table; -- 2823 RECORDS 
SELECT MIN(ORDERDATE), MAX(ORDERDATE) FROM sales_table; -- 2003 TO 2005( APRIL)

-- Unique value
SELECT DISTINCT STATUS FROM sales_table;
SELECT DISTINCT YEAR_ID FROM sales_table;
SELECT DISTINCT PRODUCTLINE FROM sales_table;
SELECT DISTINCT COUNTRY FROM sales_table;
SELECT DISTINCT DEALSIZE FROM sales_table;
SELECT DISTINCT TERRITORY FROM sales_table;

-- Sales by product line 
SELECT PRODUCTLINE,ROUND(SUM(SALES),2) Revenue 
FROM sales_table
GROUP BY PRODUCTLINE 
ORDER BY 2 DESC; -- Classic Cars and Vintage Cars are best selling

-- Sales by year
SELECT YEAR_ID ,ROUND(SUM(SALES),2) Revenue 
FROM sales_table
GROUP BY YEAR_ID
ORDER BY 2 DESC; -- 2004 is best year followed by the year 2003. 

SELECT DISTINCT MONTH_ID FROM sales_table 
WHERE YEAR_ID = 2005 ORDER BY MONTH_ID -- 2005 has only 5 months of operation 

-- Sales by dealsize
SELECT DEALSIZE,ROUND(SUM(SALES),2) Revenue 
FROM sales_table
GROUP BY DEALSIZE
ORDER BY 2 DESC; -- medium and small size have the biggets revenue. 

-- Sales by month and the frequency of order for each month 
SELECT MONTH_ID,ROUND(SUM(SALES),2) Revenue, COUNT(ORDERNUMBER) frequency 
FROM sales_table
WHERE YEAR_ID = 2004 --  november is the best month  
GROUP BY MONTH_ID
ORDER BY 2 DESC; 

-- 
SELECT MONTH_ID, PRODUCTLINE,ROUND(SUM(SALES),2) Revenue, COUNT(ORDERNUMBER) frequency 
FROM sales_table
WHERE YEAR_ID = 2004 --  november is the best month  
GROUP BY MONTH_ID, PRODUCTLINE
ORDER BY 3 DESC; --  best selling product in november is classic cars 


/*
    =========================================================
    Recency Frequency Monetory 
    =========================================================
*/

-- who is the best customer ?

DROP TABLE IF EXISTS #rfm; -- put the rfm into temp_table

WITH rfm AS
(
    SELECT
        CUSTOMERNAME,
        ROUND(SUM(SALES),2) monetary_value,
        COUNT(ORDERNUMBER) frequency,
        -- customer last orderdate and the last orderdate of the whole table
        MAX(ORDERDATE) last_order_date,
        (SELECT MAX(ORDERDATE) FROM sales_table) max_orderdate_table,
        DATEDIFF(DAY,MAX(ORDERDATE),(SELECT MAX(ORDERDATE) FROM sales_table)) recency
    FROM sales_table 
    GROUP BY CUSTOMERNAME 
), rfm_calc AS
(
    SELECT r.*,
        -- divide the customers into 4 groups
        NTILE(4) OVER(ORDER BY recency DESC) rfm_recency,
        NTILE(4) OVER(ORDER BY frequency) rfm_frequency,
        NTILE(4) OVER(ORDER BY monetary_value) rfm_monetary_value
    FROM rfm r 
)
SELECT c.*,(rfm_recency + rfm_frequency + rfm_monetary_value) rfm_cell,
CAST(rfm_recency AS VARCHAR) + CAST(rfm_frequency AS VARCHAR) + 
CAST(rfm_monetary_value AS VARCHAR) rfm_concat
INTO #rfm
FROM rfm_calc c;

SELECT *
FROM #rfm; 

-- RFM segmentation 

SELECT 
     CUSTOMERNAME, rfm_concat,
     rfm_recency, rfm_frequency, rfm_monetary_value,rfm_cell,
     CASE
        WHEN rfm_cell >= 9 THEN 'VIP' 
        WHEN rfm_cell >= 7 AND rfm_cell <9 THEN 'Loyal'
        WHEN rfm_cell >= 5 AND rfm_cell <7 THEN 'Occasional'
        ELSE 'Risk'
     END rfm_segmentation
FROM #rfm  



FROM sales_table; -- VERY LOW CUSTOMER BASE( 92 CUSTOMERS) 
