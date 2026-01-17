-- Customer Growth Classification
-- Classifies customers as Growing, Stable, or Declining based on yearly revenue change

WITH YearlyRevenue AS
(
    SELECT
        YEAR(OrderDate) AS Years,
        CustomerKey,
        SUM(SalesAmount) AS YearRevenue
    FROM AdventureWorksDW2025.dbo.FactInternetSales
    GROUP BY YEAR(OrderDate), CustomerKey
),
FirstLastYearRevenue AS
(
    SELECT
        CustomerKey,
        MIN(Years) AS FirstYear,
        MAX(Years) AS LastYear
    FROM YearlyRevenue
    GROUP BY CustomerKey
),
RevenueComparison AS
(
    SELECT
        y.CustomerKey,
        f.FirstYear,
        f.LastYear,
        SUM(CASE WHEN y.Years = f.FirstYear THEN y.YearRevenue END) AS FirstYearRevenue,
        SUM(CASE WHEN y.Years = f.LastYear THEN y.YearRevenue END) AS LastYearRevenue
    FROM YearlyRevenue y
    JOIN FirstLastYearRevenue f
        ON y.CustomerKey = f.CustomerKey
    GROUP BY y.CustomerKey, f.FirstYear, f.LastYear
)

SELECT
    CustomerKey,
    FirstYearRevenue,
    LastYearRevenue,
    CASE
        WHEN LastYearRevenue > FirstYearRevenue * 1.10 THEN 'Growing'
        WHEN LastYearRevenue < FirstYearRevenue * 0.90 THEN 'Declining'
        ELSE 'Stable'
    END AS CustomerSegment
FROM RevenueComparison;
