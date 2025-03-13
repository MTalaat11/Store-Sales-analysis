select * from Products;
select * from Customers;
select * from Orders;


SELECT 
    COLUMN_NAME, 
    DATA_TYPE
FROM 
    INFORMATION_SCHEMA.COLUMNS
WHERE 
    TABLE_NAME = 'Customers';


SELECT 
    COLUMN_NAME, 
    DATA_TYPE
FROM 
    INFORMATION_SCHEMA.COLUMNS
WHERE 
    TABLE_NAME = 'Orders';


	SELECT 
    COLUMN_NAME, 
    DATA_TYPE
FROM 
    INFORMATION_SCHEMA.COLUMNS
WHERE 
    TABLE_NAME = 'Products';

--1.What are the total sales over different time periods (quarterly & yearly)?
--quarterly
SELECT 
    YEAR(O."Order_Date") AS Year,
    DATEPART(QUARTER,O."Order_Date") AS Quarter,
    SUM(P.Sales) AS TotalSales
FROM Orders O
JOIN Products P ON O."Order_ID" = P."Order_ID"
GROUP BY YEAR(O."Order_Date"), DATEPART(QUARTER,O."Order_Date")
ORDER BY Year, Quarter;
--yearly--
SELECT 
    YEAR(O."Order_Date") AS Year,
    SUM(P.Sales) AS TotalSales
FROM Orders O
JOIN Products P ON O."Order_ID" = P."Order_ID"
GROUP BY YEAR(O."Order_Date")
ORDER BY Year;

--2.How do sales vary across different regions, states, and cities?
--regions
SELECT 
    C."Region",
    ROUND(SUM(P.Sales), 2) AS TotalSales
FROM Orders O
JOIN Products P ON O."Order_ID" = P."Order_ID"
JOIN Customers C ON O."Order_ID" = C."Order_ID"
GROUP BY C."Region"
ORDER BY TotalSales DESC;
--States--
SELECT 
    C."State",
    ROUND(SUM(P.Sales), 2) AS TotalSales
FROM Orders O
JOIN Products P ON O."Order_ID" = P."Order_ID"
JOIN Customers C ON O."Order_ID" = C."Order_ID"
GROUP BY C."State"
ORDER BY TotalSales DESC;
--Cities--
SELECT 
    C."City",
    ROUND(SUM(P.Sales), 2) AS TotalSales
FROM Orders O
JOIN Products P ON O."Order_ID" = P."Order_ID"
JOIN Customers C ON O."Order_ID" = C."Order_ID"
GROUP BY C."City"
ORDER BY TotalSales DESC;

--3.What is the top-performing and worst-performing products in terms of sales?
--top-performing
SELECT TOP 10
    P."Product_Name",
    ROUND(SUM(P.Sales), 2) AS TotalSales
FROM Products P
GROUP BY P."Product_Name"
ORDER BY TotalSales DESC;


--worst-performing
SELECT TOP 10
    P."Product_Name",
    ROUND(SUM(P.Sales), 2) AS TotalSales
FROM Products P
GROUP BY P."Product_Name"
ORDER BY TotalSales ASC;

-- 4.How does the sales performance differ between different customer segments (Consumer, Corporate, Home Office)?
SELECT 
    C."Segment",
    ROUND(SUM(P.Sales), 2) AS TotalSales
FROM Orders O
JOIN Products P ON O."Order_ID" = P."Order_ID"
JOIN Customers C ON O."Order_ID" = C."Order_ID"
GROUP BY C."Segment"
ORDER BY TotalSales DESC;

-- 5. Which shipping mode generates the highest sales revenue?
SELECT 
    O."Ship_Mode",
    ROUND(SUM(P.Sales), 2) AS TotalSales
FROM Orders O
JOIN Products P ON O."Order_ID" = P."Order_ID"
GROUP BY O."Ship_Mode"
ORDER BY TotalSales DESC;

-- 6. What is the average sales value per customer?
SELECT 
    C."Customer_Name",
    ROUND(AVG(P.Sales), 2) AS AverageSales
FROM Orders O
JOIN Products P ON O."Order_ID" = P."Order_ID"
JOIN Customers C ON O."Order_ID" = C."Order_ID"
GROUP BY C."Customer_Name"
ORDER BY AverageSales DESC;

--7. Who are the top Spenders? 
SELECT TOP 10
    C."Customer_Name",
    ROUND(SUM(P.Sales), 2) AS TotalSpend
FROM Orders O
JOIN Products P ON O."Order_ID" = P."Order_ID"
JOIN Customers C ON O."Order_ID" = C."Order_ID"
GROUP BY C."Customer_Name"
ORDER BY TotalSpend DESC;

-- 8.	Who are the most loyal customers? Count to CST ID with order ID 
SELECT TOP 10
    C."Customer_ID",
    C."Customer_Name",
    COUNT(O."Order_ID") AS 'Orders Made'
FROM Customers C
JOIN Orders O ON C."Order_ID" = O."Order_ID"
GROUP BY C."Customer_ID", C."Customer_Name"
ORDER BY 'Orders Made' DESC;


-- 9. What are the buying patterns of customers over time? (e.g., seasonal trends)
-- Months
SELECT 
    YEAR(O."Order_Date") AS Year,
    MONTH(O."Order_Date") AS Month,
    SUM(P.Sales) AS TotalSales
FROM Orders O
JOIN Products P ON O."Order_ID" = P."Order_ID"
GROUP BY YEAR(O."Order_Date"), MONTH(O."Order_Date")
ORDER BY Year, Month;

--seasonal
WITH SalesBySeason AS (
    SELECT 
        YEAR(O."Order_Date") AS Year,
        CASE 
            WHEN MONTH(O."Order_Date") IN (1, 2, 3) THEN 'Winter'
            WHEN MONTH(O."Order_Date") IN (4, 5, 6) THEN 'Spring'
            WHEN MONTH(O."Order_Date") IN (7, 8, 9) THEN 'Summer'
            WHEN MONTH(O."Order_Date") IN (10, 11, 12) THEN 'Fall'
        END AS Season,
        ROUND(SUM(P.Sales), 2) AS "Total Sales"
    FROM Orders O
    JOIN Products P ON O."Order_ID" = P."Order_ID"
    GROUP BY 
        YEAR(O."Order_Date"),
        CASE 
            WHEN MONTH(O."Order_Date") IN (1, 2, 3) THEN 'Winter'
            WHEN MONTH(O."Order_Date") IN (4, 5, 6) THEN 'Spring'
            WHEN MONTH(O."Order_Date") IN (7, 8, 9) THEN 'Summer'
            WHEN MONTH(O."Order_Date") IN (10, 11, 12) THEN 'Fall'
        END
)
SELECT * FROM SalesBySeason
ORDER BY 
    Year, 
    CASE 
        WHEN Season = 'Winter' THEN 1
        WHEN Season = 'Spring' THEN 2
        WHEN Season = 'Summer' THEN 3
        WHEN Season = 'Fall' THEN 4
    END;

-- 10.How does each product category (Furniture, Office Supplies, Technology) perform in terms of sales?
SELECT 
    P.Category,
    ROUND(SUM(P.Sales), 2) AS TotalSales
FROM Products P
GROUP BY P.Category
ORDER BY TotalSales DESC;

--11.Which sub-category has the highest and lowest sales?
SELECT  Sub_Category, TotalSales
FROM (
    SELECT 
        Sub_Category,
        ROUND(SUM(Sales), 2) AS TotalSales,
        RANK() OVER (ORDER BY SUM(Sales) DESC) AS SalesRank
    FROM Products
    GROUP BY Sub_Category
) RankedSales
WHERE SalesRank <= 5

SELECT Sub_Category, TotalSales
FROM (
    SELECT 
        Sub_Category,
        ROUND(SUM(Sales), 2) AS TotalSales,
        RANK() OVER (ORDER BY SUM(Sales) ASC) AS SalesRank
    FROM Products
    GROUP BY Sub_Category
) RankedSales
WHERE SalesRank <= 5
ORDER BY  TotalSales DESC;

--12.What Are the products with the highest demand?

SELECT top 5
    Product_Name,

    COUNT(Order_ID) AS OrderCount
FROM Products
GROUP BY Product_Name
ORDER BY  OrderCount desc ;


--13.Which states and cities have the highest and lowest sales?

SELECT State, TotalSales
FROM (
    SELECT 
        State,
        ROUND(SUM(P.Sales), 2) AS TotalSales,
        RANK() OVER (ORDER BY SUM(P.Sales) DESC) AS SalesRank
    FROM Products P
       JOIN Customers C ON P.Order_ID = C.Order_ID
    GROUP BY State
) RankedSales
WHERE SalesRank <= 5


SELECT  State, TotalSales
FROM (
    SELECT 
        State,
        ROUND(SUM(P.Sales), 2) AS TotalSales,
        RANK() OVER (ORDER BY SUM(P.Sales) ASC) AS SalesRank
    FROM Products P
     JOIN Customers C ON P.Order_ID = C.Order_ID
    GROUP BY State
) RankedSales
WHERE SalesRank <= 5

ORDER BY  TotalSales DESC;

--14.How many times was each shipping mode used? 
SELECT "Ship_Mode", COUNT(*) AS 'Usage Count'
FROM Orders
GROUP BY "Ship_Mode"
ORDER BY 'Usage Count' DESC;


--How does the shipping mode affect customer purchase behavior?
SELECT 
    O."Ship_Mode", 
    ROUND(SUM(P.Sales), 2) AS TotalSales
FROM Orders O
JOIN Products P ON O."Order_ID" = P."Order_ID"
GROUP BY O."Ship_Mode"
ORDER BY TotalSales DESC;




SELECT 
    MONTH(O.Order_Date) AS Month,
    ROUND(SUM(P.Sales), 2) AS TotalSales,
    COUNT(O.Order_ID) AS TotalOrders
FROM Orders O
JOIN Products P ON O.Order_ID = P.Order_ID
GROUP BY MONTH(O.Order_Date)
ORDER BY TotalSales DESC;

--17.	Are there specific seasons when sales peak or drop?
SELECT Year, Season, TotalSales,
       CASE 
           WHEN SalesRankHigh = 1 THEN 'Highest Sales'
           WHEN SalesRankLow = 1 THEN 'Lowest Sales'
       END AS SalesType
FROM (
    SELECT 
        YEAR(O.Order_Date) AS Year,
        CASE 
            WHEN MONTH(O.Order_Date) IN (12, 1, 2) THEN 'Winter'
            WHEN MONTH(O.Order_Date) IN (3, 4, 5) THEN 'Spring'
            WHEN MONTH(O.Order_Date) IN (6, 7, 8) THEN 'Summer'
            WHEN MONTH(O.Order_Date) IN (9, 10, 11) THEN 'Fall'
        END AS Season,
        ROUND(SUM(P.Sales), 2) AS TotalSales,
        RANK() OVER (PARTITION BY YEAR(O.Order_Date) ORDER BY SUM(P.Sales) DESC) AS SalesRankHigh,
        RANK() OVER (PARTITION BY YEAR(O.Order_Date) ORDER BY SUM(P.Sales) ASC) AS SalesRankLow
    FROM Orders O
    JOIN Products P ON O.Order_ID = P.Order_ID
    GROUP BY YEAR(O.Order_Date), 
             CASE 
                WHEN MONTH(O.Order_Date) IN (12, 1, 2) THEN 'Winter'
                WHEN MONTH(O.Order_Date) IN (3, 4, 5) THEN 'Spring'
                WHEN MONTH(O.Order_Date) IN (6, 7, 8) THEN 'Summer'
                WHEN MONTH(O.Order_Date) IN (9, 10, 11) THEN 'Fall'
             END
) RankedSales
WHERE SalesRankHigh = 1 OR SalesRankLow = 1
ORDER BY Year, TotalSales DESC;

--18.	How have sales trends evolved over the years?
SELECT 
    YEAR(O.Order_Date) AS Year,
     ROUND(SUM(P.Sales), 2) AS TotalSales,
    (SELECT SUM(P2.Sales) 
     FROM Orders O2 
     JOIN Products P2 ON O2.Order_ID = P2.Order_ID
     WHERE YEAR(O2.Order_Date) = YEAR(O.Order_Date) - 1) AS PreviousYearSales,
    ((SUM(P.Sales) - 
      (SELECT SUM(P2.Sales) 
       FROM Orders O2 
       JOIN Products P2 ON O2.Order_ID = P2.Order_ID
       WHERE YEAR(O2.Order_Date) = YEAR(O.Order_Date) - 1))
      / 
      (SELECT SUM(P2.Sales) 
       FROM Orders O2 
       JOIN Products P2 ON O2.Order_ID = P2.Order_ID
       WHERE YEAR(O2.Order_Date) = YEAR(O.Order_Date) - 1) * 100) 
      AS SalesGrowthRate
FROM Orders O
JOIN Products P ON O.Order_ID = P.Order_ID
GROUP BY YEAR(O.Order_Date)
ORDER BY Year;

--19.Can we predict future sales based on past trends?
SELECT 
    YEAR(O.Order_Date) AS Year,
    ROUND(SUM(P.Sales), 2) AS TotalSales
FROM Orders O
JOIN Products P ON O.Order_ID = P.Order_ID
GROUP BY YEAR(O.Order_Date)
ORDER BY Year;



--20.Which factors contribute the most to high sales performance?
(
    SELECT 'Top Category' AS FactorType, Factor, TotalSales
    FROM (
        SELECT TOP 1 Category AS Factor, 
		ROUND(SUM(Sales), 2) AS TotalSales
        FROM Products
        GROUP BY Category
        ORDER BY TotalSales DESC
    ) AS Subquery
)
UNION ALL
(
    SELECT 'Top State' AS FactorType, Factor, TotalSales
    FROM (
        SELECT TOP 1 C.State AS Factor, ROUND(SUM(P.Sales), 2) AS TotalSales
        FROM Customers C
        JOIN Orders O ON C.Order_ID = O.Order_ID
        JOIN Products P ON O.Order_ID = P.Order_ID
        GROUP BY C.State
        ORDER BY TotalSales DESC
    ) AS Subquery
)
UNION ALL
(
    SELECT 'Top Shipping Mode' AS FactorType, Factor, TotalSales
    FROM (
        SELECT TOP 1 O.Ship_Mode AS Factor, ROUND(SUM(P.Sales), 2) AS TotalSales
        FROM Orders O
        JOIN Products P ON O.Order_ID = P.Order_ID
        GROUP BY O.Ship_Mode
        ORDER BY TotalSales DESC
    ) AS Subquery
)
UNION ALL
(
    SELECT 'Top Customer Segment' AS FactorType, Factor, TotalSales
    FROM (
        SELECT TOP 1 C.Segment AS Factor, ROUND(SUM(P.Sales), 2) AS TotalSales
        FROM Customers C
        JOIN Orders O ON C.Order_ID = O.Order_ID
        JOIN Products P ON O.Order_ID = P.Order_ID
        GROUP BY C.Segment
        ORDER BY TotalSales DESC
    ) AS Subquery
)
ORDER BY TotalSales DESC;


