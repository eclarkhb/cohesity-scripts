/*
  ============================================================================
  Cohesity backup/recovery lab: sample database for the nested MS SQL instance
  ----------------------------------------------------------------------------
  Creates database "ContosoSales" with 4 related tables and ~20,500 rows of
  fake data. Recognizable table names and visible row counts make the
  destroy/recover part of the demo obvious to the audience.

  Safe to drop and recreate. Fictional data only.

  HOW TO RUN
    Option 1 (SSMS): open this file, connect to the instance, hit Execute (F5).
    Option 2 (command line, run from the VM):
       sqlcmd -S localhost -E -i create-demo-db.sql
  ============================================================================
*/

------------------------------------------------------------------------------
-- 1. Drop if it already exists, then create
------------------------------------------------------------------------------
IF DB_ID('ContosoSales') IS NOT NULL
BEGIN
    ALTER DATABASE ContosoSales SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE ContosoSales;
END
GO

CREATE DATABASE ContosoSales;
GO

-- FULL recovery lets you demo transaction-log backups / point-in-time recovery.
-- Switch to SIMPLE if you only want full/incremental and no log management.
ALTER DATABASE ContosoSales SET RECOVERY FULL;
GO

USE ContosoSales;
GO

------------------------------------------------------------------------------
-- 2. Schema
------------------------------------------------------------------------------
CREATE TABLE dbo.Customers (
    CustomerID   INT IDENTITY(1,1) PRIMARY KEY,
    CompanyName  NVARCHAR(100) NOT NULL,
    City         NVARCHAR(60),
    State        NVARCHAR(2),
    CreatedDate  DATETIME2 DEFAULT SYSUTCDATETIME()
);

CREATE TABLE dbo.Products (
    ProductID    INT IDENTITY(1,1) PRIMARY KEY,
    ProductName  NVARCHAR(100) NOT NULL,
    UnitPrice    DECIMAL(10,2) NOT NULL
);

CREATE TABLE dbo.Orders (
    OrderID      INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID   INT NOT NULL REFERENCES dbo.Customers(CustomerID),
    OrderDate    DATE NOT NULL,
    Status       NVARCHAR(20) NOT NULL
);

CREATE TABLE dbo.OrderLines (
    OrderLineID  INT IDENTITY(1,1) PRIMARY KEY,
    OrderID      INT NOT NULL REFERENCES dbo.Orders(OrderID),
    ProductID    INT NOT NULL REFERENCES dbo.Products(ProductID),
    Quantity     INT NOT NULL
);
GO

------------------------------------------------------------------------------
-- 3. Populate
------------------------------------------------------------------------------
-- 500 customers
;WITH n AS (
    SELECT TOP (500) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS i
    FROM sys.all_objects a CROSS JOIN sys.all_objects b
)
INSERT INTO dbo.Customers (CompanyName, City, State)
SELECT
    CONCAT('Customer ', i, ' LLC'),
    CHOOSE(1 + (i % 8),
        'Phoenix','Tucson','Mesa','Scottsdale','Tempe','Chandler','Gilbert','Glendale'),
    'AZ'
FROM n;
GO

-- 50 products
;WITH n AS (
    SELECT TOP (50) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS i
    FROM sys.all_objects
)
INSERT INTO dbo.Products (ProductName, UnitPrice)
SELECT
    CONCAT('Product SKU-', 1000 + i),
    CAST(10 + (ABS(CHECKSUM(NEWID())) % 490) AS DECIMAL(10,2)) + 0.99
FROM n;
GO

-- 5,000 orders (random customer, random date in the last year, random status)
;WITH n AS (
    SELECT TOP (5000) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS i
    FROM sys.all_objects a CROSS JOIN sys.all_objects b
)
INSERT INTO dbo.Orders (CustomerID, OrderDate, Status)
SELECT
    1 + ABS(CHECKSUM(NEWID())) % 500,
    DATEADD(DAY, -(ABS(CHECKSUM(NEWID())) % 365), CAST(GETDATE() AS DATE)),
    CHOOSE(1 + ABS(CHECKSUM(NEWID())) % 3, 'Shipped','Pending','Cancelled')
FROM n;
GO

-- 15,000 order lines (random order, random product, random qty)
;WITH n AS (
    SELECT TOP (15000) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS i
    FROM sys.all_objects a CROSS JOIN sys.all_objects b
)
INSERT INTO dbo.OrderLines (OrderID, ProductID, Quantity)
SELECT
    1 + ABS(CHECKSUM(NEWID())) % 5000,
    1 + ABS(CHECKSUM(NEWID())) % 50,
    1 + ABS(CHECKSUM(NEWID())) % 10
FROM n;
GO

------------------------------------------------------------------------------
-- 4. Verify (run this before AND after the destroy step in the demo)
------------------------------------------------------------------------------
USE ContosoSales;
GO
SELECT 'Customers'  AS TableName, COUNT(*) AS [RowCount] FROM dbo.Customers
UNION ALL SELECT 'Products',   COUNT(*) FROM dbo.Products
UNION ALL SELECT 'Orders',     COUNT(*) FROM dbo.Orders
UNION ALL SELECT 'OrderLines', COUNT(*) FROM dbo.OrderLines;
GO
