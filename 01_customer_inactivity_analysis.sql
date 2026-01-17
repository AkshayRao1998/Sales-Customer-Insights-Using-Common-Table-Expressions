-- Customer Inactivity Analysis
-- Identifies active vs inactive customers based on last purchase date

WITH LastOrder AS
(
    SELECT
        CustomerKey,
        MAX(CAST(OrderDate AS DATE)) AS LastPurchaseDate,
        CAST(GETDATE() AS DATE) AS CurrentDate
    FROM AdventureWorksDW2025.dbo.FactInternetSales
    GROUP BY CustomerKey
),
InactiveDaysCalc AS
(
    SELECT
        CustomerKey,
        LastPurchaseDate,
        CurrentDate,
        DATEDIFF(DAY, LastPurchaseDate, CurrentDate) AS InactiveDays
    FROM LastOrder
),
CustomerStatus AS
(
    SELECT
        CustomerKey,
        LastPurchaseDate,
        CurrentDate,
        InactiveDays,
        CASE
            WHEN InactiveDays > 365 THEN 'Inactive'
            ELSE 'Active'
        END AS ActivityStatus
    FROM InactiveDaysCalc
)

SELECT
    CustomerKey,
    LastPurchaseDate,
    CurrentDate,
    InactiveDays,
    ActivityStatus
FROM CustomerStatus;
