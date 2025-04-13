select * from Products;
select * from Customers;
select * from Orders;
select * from OrderDetails;

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

	SELECT 
    COLUMN_NAME, 
    DATA_TYPE
FROM 
    INFORMATION_SCHEMA.COLUMNS
WHERE 
    TABLE_NAME = 'OrderDetails';

--1.What are the total sales over different time periods (quarterly & yearly)?
--quarterly

SELECT 
    YEAR(O.Order_Date) AS Year,
    DATEPART(QUARTER, O.Order_Date) AS Quarter,
    SUM(OD.Sales) AS TotalSales
FROM Orders O
JOIN OrderDetails OD ON O.Order_ID = OD.Order_ID
JOIN Products P ON OD.Product_ID = P.Product_ID
GROUP BY YEAR(O.Order_Date), DATEPART(QUARTER, O.Order_Date)
ORDER BY Year, Quarter;

--yearly--
SELECT 
    YEAR(O.Order_Date) AS Year,
    SUM(OD.Sales) AS TotalSales
FROM Orders O
JOIN OrderDetails OD ON O.Order_ID = OD.Order_ID
JOIN Products P ON OD.Product_ID = P.Product_ID
GROUP BY YEAR(O.Order_Date)
ORDER BY Year;

--2.How do sales vary across different regions, states, and cities?
--regions

SELECT 
    O.Region,
    ROUND(SUM(OD.Sales), 2) AS TotalSales
FROM Orders O
JOIN OrderDetails OD ON O.Order_ID = OD.Order_ID
JOIN Products P ON OD.Product_ID = P.Product_ID
GROUP BY O.Region
ORDER BY TotalSales DESC;

--States--
SELECT 
    O.State,
    ROUND(SUM(OD.Sales), 2) AS TotalSales
FROM Orders O
JOIN OrderDetails OD ON O.Order_ID = OD.Order_ID
JOIN Products P ON OD.Product_ID = P.Product_ID
GROUP BY O.State
ORDER BY TotalSales DESC;

--Cities--

SELECT 
    O.City,
    ROUND(SUM(OD.Sales), 2) AS TotalSales
FROM Orders O
JOIN OrderDetails OD ON O.Order_ID = OD.Order_ID
JOIN Products P ON OD.Product_ID = P.Product_ID
GROUP BY O.City
ORDER BY TotalSales DESC;

--3.What is the top-performing and worst-performing products in terms of sales?
--top-performing

SELECT TOP 10
    P.Product_Name,
    ROUND(SUM(OD.Sales), 2) AS TotalSales
FROM OrderDetails OD
JOIN Products P ON OD.Product_ID = P.Product_ID
GROUP BY P.Product_Name
ORDER BY TotalSales DESC;


--worst-performing
SELECT TOP 10
    P.Product_Name,
    ROUND(SUM(OD.Sales), 2) AS TotalSales
FROM OrderDetails OD
JOIN Products P ON OD.Product_ID = P.Product_ID
GROUP BY P.Product_Name
ORDER BY TotalSales ASC;

-- 4.How does the sales performance differ between different customer segments (Consumer, Corporate, Home Office)?
SELECT 
    C.Segment,
    ROUND(SUM(OD.Sales), 2) AS TotalSales
FROM Orders O
JOIN Customers C ON O.Customer_ID = C.Customer_ID
JOIN OrderDetails OD ON O.Order_ID = OD.Order_ID
JOIN Products P ON OD.Product_ID = P.Product_ID
GROUP BY C.Segment
ORDER BY TotalSales DESC;

-- 5. Which shipping mode generates the highest sales revenue?
SELECT 
    O.Ship_Mode,
    ROUND(SUM(OD.Sales), 2) AS TotalSales
FROM Orders O
JOIN OrderDetails OD ON O.Order_ID = OD.Order_ID
JOIN Products P ON OD.Product_ID = P.Product_ID
GROUP BY O.Ship_Mode
ORDER BY TotalSales DESC;

-- 6. What is the average sales value per customer?
SELECT 
    C.Customer_Name,
    ROUND(AVG(OD.Sales), 2) AS AverageSales
FROM Orders O
JOIN Customers C ON O.Customer_ID = C.Customer_ID
JOIN OrderDetails OD ON O.Order_ID = OD.Order_ID
JOIN Products P ON OD.Product_ID = P.Product_ID
GROUP BY C.Customer_Name
ORDER BY AverageSales DESC;

-- 6. What is the average sales value per customer?
-- السؤال دة تم تعديلة علشان يبقي ماشي مع البايثون في النتيجة

SELECT 
    ROUND(AVG(CustomerSales.TotalSales), 2) AS AverageSalesPerCustomer
FROM (
    SELECT 
        C.Customer_Name,
        SUM(OD.Sales) AS TotalSales
    FROM Orders O
    JOIN Customers C ON O.Customer_ID = C.Customer_ID
    JOIN OrderDetails OD ON O.Order_ID = OD.Order_ID
    JOIN Products P ON OD.Product_ID = P.Product_ID
    GROUP BY C.Customer_Name
) AS CustomerSales;

--7. Who are the top Spenders? 
SELECT TOP 10
    C.Customer_Name,
    ROUND(SUM(OD.Sales), 2) AS TotalSpend
FROM Orders O
JOIN Customers C ON O.Customer_ID = C.Customer_ID
JOIN OrderDetails OD ON O.Order_ID = OD.Order_ID
JOIN Products P ON OD.Product_ID = P.Product_ID
GROUP BY C.Customer_Name
ORDER BY TotalSpend DESC;

-- 8.	Who are the most loyal customers? Count to CST ID with order ID 
SELECT TOP 10
    --C.Customer_ID,
    C.Customer_Name,
    COUNT(O.Order_ID) AS OrdersMade
FROM Customers C
JOIN Orders O ON C.Customer_ID = O.Customer_ID
GROUP BY C.Customer_ID, C.Customer_Name
ORDER BY OrdersMade DESC;

-- 9. What are the buying patterns of customers over time? (e.g., seasonal trends)
-- Months
SELECT 
    YEAR(O.Order_Date) AS Year,
    MONTH(O.Order_Date) AS Month,
    ROUND(SUM(OD.Sales), 2) AS TotalSales
FROM Orders O
JOIN OrderDetails OD ON O.Order_ID = OD.Order_ID
JOIN Products P ON OD.Product_ID = P.Product_ID
GROUP BY YEAR(O.Order_Date), MONTH(O.Order_Date)
ORDER BY Year, Month;

--seasonal
WITH SalesBySeason AS (
    SELECT 
        YEAR(O.Order_Date) AS Year,
        CASE 
            WHEN MONTH(O.Order_Date) IN (1, 2, 3) THEN 'Winter'
            WHEN MONTH(O.Order_Date) IN (4, 5, 6) THEN 'Spring'
            WHEN MONTH(O.Order_Date) IN (7, 8, 9) THEN 'Summer'
            WHEN MONTH(O.Order_Date) IN (10, 11, 12) THEN 'Fall'
        END AS Season,
        ROUND(SUM(OD.Sales), 2) AS TotalSales
    FROM Orders O
    JOIN OrderDetails OD ON O.Order_ID = OD.Order_ID
    JOIN Products P ON OD.Product_ID = P.Product_ID
    GROUP BY 
        YEAR(O.Order_Date),
        CASE 
            WHEN MONTH(O.Order_Date) IN (1, 2, 3) THEN 'Winter'
            WHEN MONTH(O.Order_Date) IN (4, 5, 6) THEN 'Spring'
            WHEN MONTH(O.Order_Date) IN (7, 8, 9) THEN 'Summer'
            WHEN MONTH(O.Order_Date) IN (10, 11, 12) THEN 'Fall'
        END
)
SELECT * 
FROM SalesBySeason
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
    ROUND(SUM(OD.Sales), 2) AS TotalSales
FROM Products P
JOIN OrderDetails OD ON P.Product_ID = OD.Product_ID
GROUP BY P.Category
ORDER BY TotalSales DESC;

--11.Which sub-category has the highest and lowest sales?
SELECT Sub_Category, TotalSales
FROM (
    SELECT 
        P.Sub_Category,
        ROUND(SUM(OD.Sales), 2) AS TotalSales,
        RANK() OVER (ORDER BY SUM(OD.Sales) DESC) AS SalesRank
    FROM Products P
    JOIN OrderDetails OD ON P.Product_ID = OD.Product_ID
    GROUP BY P.Sub_Category
) RankedSales
WHERE SalesRank <= 10;
--Lowest--
SELECT Sub_Category, TotalSales
FROM (
    SELECT 
        P.Sub_Category,
        ROUND(SUM(OD.Sales), 2) AS TotalSales,
        RANK() OVER (ORDER BY SUM(OD.Sales) ASC) AS SalesRank
    FROM Products P
    JOIN OrderDetails OD ON P.Product_ID = OD.Product_ID
    GROUP BY P.Sub_Category
) RankedSales
WHERE SalesRank <= 10
ORDER BY TotalSales DESC;


--12.What Are the products with the highest demand?
SELECT TOP 10
    P.Product_Name,
    COUNT(OD.Order_ID) AS OrderCount
FROM Products P
JOIN OrderDetails OD ON P.Product_ID = OD.Product_ID
GROUP BY P.Product_Name
ORDER BY OrderCount DESC;

--13.Which states and cities have the highest and lowest sales?

-- Top 5 States by Sales (with TotalSales)
SELECT State, TotalSales
FROM (
    SELECT 
        O.State,
        ROUND(SUM(OD.Sales), 2) AS TotalSales,
        RANK() OVER (ORDER BY SUM(OD.Sales) DESC) AS SalesRank
    FROM Orders O
    JOIN Customers C ON O.Customer_ID = C.Customer_ID
    JOIN OrderDetails OD ON O.Order_ID = OD.Order_ID
    GROUP BY O.State
) RankedStates
WHERE SalesRank <= 10
ORDER BY TotalSales DESC;

-- Bottom 5 States by Sales (with TotalSales)
SELECT State, TotalSales
FROM (
    SELECT 
        O.State,
        ROUND(SUM(OD.Sales), 2) AS TotalSales,
        RANK() OVER (ORDER BY SUM(OD.Sales) ASC) AS SalesRank
    FROM Orders O
    JOIN Customers C ON O.Customer_ID = C.Customer_ID
    JOIN OrderDetails OD ON O.Order_ID = OD.Order_ID
    GROUP BY O.State
) RankedStates
WHERE SalesRank <= 10
ORDER BY TotalSales DESC;

-- Top 5 Cities by Sales
SELECT O.City, ROUND(SUM(OD.Sales), 2) AS TotalSales
FROM dbo.Orders O
JOIN dbo.OrderDetails OD ON O.Order_ID = OD.Order_ID
GROUP BY O.City
ORDER BY TotalSales DESC
OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY;

-- Bottom 5 Cities by Sales
SELECT O.City, ROUND(SUM(OD.Sales), 2) AS TotalSales
FROM dbo.Orders O
JOIN dbo.OrderDetails OD ON O.Order_ID = OD.Order_ID
GROUP BY O.City
ORDER BY TotalSales ASC
OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY;

--14.How many times was each shipping mode used? 
SELECT "Ship_Mode", COUNT(*) AS "Usage Count"
FROM Orders
GROUP BY "Ship_Mode"
ORDER BY "Usage Count" DESC;

--15.How does the shipping mode affect customer purchase behavior?
SELECT 
    O.Ship_Mode, 
    ROUND(SUM(OD.Sales), 2) AS TotalSales
FROM Orders O
JOIN OrderDetails OD ON O.Order_ID = OD.Order_ID
JOIN Products P ON OD.Product_ID = P.Product_ID
GROUP BY O.Ship_Mode
ORDER BY TotalSales DESC;

--16.Are there specific seasons when sales peak or drop?
SELECT 
    Year, 
    Season, 
    TotalSales,
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
        ROUND(SUM(OD.Sales), 2) AS TotalSales,
        RANK() OVER (PARTITION BY YEAR(O.Order_Date) ORDER BY SUM(OD.Sales) DESC) AS SalesRankHigh,
        RANK() OVER (PARTITION BY YEAR(O.Order_Date) ORDER BY SUM(OD.Sales) ASC) AS SalesRankLow
    FROM Orders O
    JOIN OrderDetails OD ON O.Order_ID = OD.Order_ID
    JOIN Products P ON OD.Product_ID = P.Product_ID
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


--17.How have sales trends evolved over the years?
WITH SalesByYear AS (
    SELECT 
        YEAR(O.Order_Date) AS Year,
        SUM(OD.Sales) AS TotalSales
    FROM Orders O
    JOIN OrderDetails OD ON O.Order_ID = OD.Order_ID
    WHERE YEAR(O.Order_Date) BETWEEN 2015 AND 2018
    GROUP BY YEAR(O.Order_Date)
)
SELECT 
    S1.Year,
    ROUND(S1.TotalSales, 2) AS TotalSales,
    ROUND(ISNULL(S2.TotalSales, 0), 2) AS PreviousYearSales,
    ROUND(
        CASE 
            WHEN S2.TotalSales IS NULL OR S2.TotalSales = 0 THEN 0
            ELSE ((S1.TotalSales - S2.TotalSales) / S2.TotalSales) * 100
        END,
        2
    ) AS SalesGrowthRate
FROM SalesByYear S1
LEFT JOIN SalesByYear S2 ON S1.Year = S2.Year + 1
ORDER BY S1.Year;


--18.Can we predict future sales based on past trends?
WITH SalesByYear AS (
    SELECT 
        YEAR(O.Order_Date) AS Year,
        ROUND(SUM(OD.Sales), 2) AS TotalSales
    FROM Orders O
    JOIN OrderDetails OD ON O.Order_ID = OD.Order_ID
    JOIN Products P ON OD.Product_ID = P.Product_ID
    WHERE YEAR(O.Order_Date) BETWEEN 2015 AND 2018
    GROUP BY YEAR(O.Order_Date)
),
YearlyGrowth AS (
    SELECT 
        A.Year,
        A.TotalSales,
        (A.TotalSales - B.TotalSales) / B.TotalSales * 100 AS GrowthRate
    FROM SalesByYear A
    JOIN SalesByYear B ON A.Year = B.Year + 1
)
SELECT 
    '2019' AS Year,
    ROUND(
        (SELECT TotalSales FROM SalesByYear WHERE Year = 2018) * 
        (1 + (AVG(GrowthRate) / 100)), 
        2
    ) AS PredictedSalesFor2019
FROM YearlyGrowth;

--19.Which factors contribute the most to high sales performance?

(
    SELECT 'Top Category' AS FactorType, Factor, TotalSales
    FROM (
        SELECT TOP 1 Category AS Factor, 
        ROUND(SUM(OD.Sales), 2) AS TotalSales
        FROM Products P
        JOIN OrderDetails OD ON P.Product_ID = OD.Product_ID
        GROUP BY Category
        ORDER BY TotalSales DESC
    ) AS Subquery
)
UNION ALL
(
    SELECT 'Top State' AS FactorType, Factor, TotalSales
    FROM (
        SELECT TOP 1 O.State AS Factor, ROUND(SUM(OD.Sales), 2) AS TotalSales
        FROM Orders O
        JOIN OrderDetails OD ON O.Order_ID = OD.Order_ID
        JOIN Products P ON OD.Product_ID = P.Product_ID
        GROUP BY O.State
        ORDER BY TotalSales DESC
    ) AS Subquery
)
UNION ALL
(
    SELECT 'Top Shipping Mode' AS FactorType, Factor, TotalSales
    FROM (
        SELECT TOP 1 O.Ship_Mode AS Factor, ROUND(SUM(OD.Sales), 2) AS TotalSales
        FROM Orders O
        JOIN OrderDetails OD ON O.Order_ID = OD.Order_ID
        JOIN Products P ON OD.Product_ID = P.Product_ID
        GROUP BY O.Ship_Mode
        ORDER BY TotalSales DESC
    ) AS Subquery
)
UNION ALL
(
    SELECT 'Top Customer Segment' AS FactorType, Factor, TotalSales
    FROM (
        SELECT TOP 1 C.Segment AS Factor, ROUND(SUM(OD.Sales), 2) AS TotalSales
        FROM Customers C
        JOIN Orders O ON C.Customer_ID = O.Customer_ID
        JOIN OrderDetails OD ON O.Order_ID = OD.Order_ID
        JOIN Products P ON OD.Product_ID = P.Product_ID
        GROUP BY C.Segment
        ORDER BY TotalSales DESC
    ) AS Subquery
)
ORDER BY TotalSales DESC;
