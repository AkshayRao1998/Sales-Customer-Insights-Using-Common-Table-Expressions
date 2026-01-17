-- Customer Lifecycle Segmentation
-- Segments customers based on revenue contribution and activity level

WITH CustomerMetrics AS
(
    SELECT
        CustomerKey,
        SUM(SalesAmount) AS TotalSales,
        COUNT(SalesOrderNumber) AS TotalOrders,
        MAX(CAST(OrderDate AS DATE)) AS LastOrderDate,
        DATEDIFF(DAY, MAX(CAST(OrderDate AS DATE)), GETDATE()) AS InactiveDays
    FROM AdventureWorksDW2025.dbo.FactInternetSales
    GROUP BY CustomerKey
),
RevenueBuckets AS
(
    SELECT
        *,
        NTILE(2) OVER (ORDER BY TotalSales DESC) AS RevenueBucket
    FROM CustomerMetrics
),
CustomerSegmentation AS
(
    SELECT
        CustomerKey,
        TotalSales,
        TotalOrders,
        LastOrderDate,
        InactiveDays,
        RevenueBucket,
        CASE
            WHEN RevenueBucket = 1 AND InactiveDays <= 30 THEN 'Champion'
            WHEN RevenueBucket = 1 AND InactiveDays > 30 THEN 'At Risk'
            WHEN RevenueBucket = 2 AND InactiveDays <= 30 THEN 'Potential'
            ELSE 'Lost'
        END AS CustomerSegment
    FROM RevenueBuckets
)

SELECT *
FROM CustomerSegmentation;
