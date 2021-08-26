--*************************************************************************--
-- Title: Assignment07
-- Author: Erin Leggett
-- Description: This file demonstrates how to use functions.
-- GitHub Documentation: https://github.com/emleggett/DBFoundations-Module07
-- Change Log: 2021-08-26,Wrote and validated SQL code
-- 2021-08-21,ELeggett,Established database and began testing functions
-- 2021-08-19,ELeggett,Created SQL file
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment07DB_ErinLeggett')
	 Begin 
	  Alter Database [Assignment07DB_ErinLeggett] set Single_user With Rollback Immediate;
	  Drop Database Assignment07DB_ErinLeggett;
	 End
	Create Database Assignment07DB_ErinLeggett;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment07DB_ErinLeggett;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [money] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL
,[ProductID] [int] NOT NULL
,[ReorderLevel] int NOT NULL -- New Column 
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, ReorderLevel, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, ReorderLevel, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, ReorderLevel, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, ReorderLevel, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Order By 1, 2
go

-- Adding Views (Module 06) -- 
Create View vCategories With SchemaBinding
 AS
  Select CategoryID, CategoryName From dbo.Categories;
go
Create View vProducts With SchemaBinding
 AS
  Select ProductID, ProductName, CategoryID, UnitPrice From dbo.Products;
go
Create View vEmployees With SchemaBinding
 AS
  Select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID From dbo.Employees;
go
Create View vInventories With SchemaBinding 
 AS
  Select InventoryID, InventoryDate, EmployeeID, ProductID, ReorderLevel, [Count] From dbo.Inventories;
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From vCategories;
go
Select * From vProducts;
go
Select * From vEmployees;
go
Select * From vInventories;
go

/********************************* Questions and Answers *********************************/
--NOTES------------------------------------------------------------------------------------ 
--1) You must use the BASIC views for each table.
--2) Remember that Inventory Counts are Randomly Generated. So, your counts may not match mine
--3) To make sure the Dates are sorted correctly, you can use Functions in the Order By clause!
------------------------------------------------------------------------------------------
-- Question 1 (5% of pts):
-- show a list of Product names and the price of each product
-- Use a function to format the price as US dollars?
-- Order the result by the product name.

--Step 1: Preview raw data.
-- GO
-- SELECT *
-- FROM vProducts
-- ;
-- GO

--Step 2: Narrow view to select only product names and prices.
-- GO
-- SELECT
-- 	ProductName
-- 	,UnitPrice
-- FROM vProducts
-- ;
-- GO

--Step 3: Format product prices as USD using the FORMAT function.
-- GO
-- SELECT
-- 	ProductName
-- 	,FORMAT(
-- 		UnitPrice
-- 		,'C'
-- 		,'en-us'
-- 	)
-- FROM vProducts
-- ;
-- GO

--Step 4: Order results by product name.
GO
SELECT
	ProductName
	,FORMAT(
		UnitPrice
		,'C'
		,'en-us'
	)
	AS [UnitPrice]
FROM vProducts
ORDER BY ProductName
;
GO

-- Question 2 (10% of pts): 
-- Show a list of Category and Product names, and the price of each product
-- Format the price as US dollars.
-- Order the result by the Category and Product.

--Step 1: Preview raw data.
-- GO
-- SELECT *
-- 	FROM vCategories
-- ;
-- GO

-- GO
-- SELECT *
-- FROM vProducts
-- ;
-- GO

--Step 2: Join views by CategoryID.
-- GO
-- SELECT *
-- FROM vProducts
-- JOIN vCategories
-- 	ON vCategories.CategoryID=vProducts.CategoryID
-- ;
-- GO

--Step 3: Narrow view to select only product names, categories, and prices.
-- GO
-- SELECT
-- 	CategoryName
-- 	,ProductName
-- 	,UnitPrice
-- FROM vProducts
-- JOIN vCategories
-- 	ON vCategories.CategoryID=vProducts.CategoryID
-- ;
-- GO

--Step 4: Format product prices as USD using the FORMAT function.
-- GO
-- SELECT
-- 	CategoryName
-- 	,ProductName
-- 	,FORMAT(
-- 		UnitPrice
-- 		,'C'
-- 		,'en-us'
-- 	)
-- 	AS [UnitPrice]
-- FROM vProducts
-- JOIN vCategories
-- 	ON vCategories.CategoryID=vProducts.CategoryID
-- ;
-- GO

--Step 5: Order results by category name and product name.
GO
SELECT
	CategoryName
	,ProductName
	,FORMAT(
		UnitPrice
		,'C'
		,'en-us'
	)
	AS [UnitPrice]
FROM vProducts
JOIN vCategories
	ON vCategories.CategoryID=vProducts.CategoryID
ORDER BY
	CategoryName,
	ProductName
;
GO

-- Question 3 (10% of pts): 
-- Use functions to show a list of Product names, each Inventory Date, and the Inventory Count
-- Format the date like 'January, 2017'.
-- Order the results by the Product, Date, and Count.

--Step 1: Preview raw data.
-- GO
-- SELECT *
-- FROM vProducts
-- ;
-- GO

-- GO
-- SELECT * 
-- FROM vInventories
-- ;
-- GO

--Step 2: Join views by ProductID.
-- GO
-- SELECT *
-- FROM vProducts
-- JOIN vInventories
-- 	ON vProducts.ProductID=vInventories.ProductID
-- ;
-- GO

--Step 3: Narrow view to select only product names, inventory dates, and inventory counts.
-- GO
-- SELECT
-- 	ProductName
-- 	,InventoryDate
-- 	,[Count] AS InventoryCount
-- FROM vProducts
-- JOIN vInventories
-- 	ON vProducts.ProductID=vInventories.ProductID
-- ;
-- GO

--Step 4: Format inventory date in specified format using the DATENAME function.
-- GO
-- SELECT
-- 	ProductName
-- 	,DATENAME(
-- 		mm
-- 		,InventoryDate
-- 	)
-- 	+', '
-- 	+DATENAME(
-- 		yy
-- 		,InventoryDate
-- 	)
-- 	AS [InventoryDate]
-- 	,[Count] AS InventoryCount
-- FROM vProducts
-- JOIN vInventories
-- 	ON vProducts.ProductID=vInventories.ProductID
-- ;
-- GO

--Step 5: Order results by product name, inventory date, and inventory count. Note: this is a basic query
--meant to answer the business question posed, though it was built to theoretically handle multi-year
--data. That said, in the case of a very large data set a more sophisticated ORDER BY clause may be more efficient.
GO
SELECT
	ProductName
	,DATENAME(
		mm
		,InventoryDate
	)
	+', '
	+DATENAME(
		yy
		,InventoryDate
	)
	AS [InventoryDate]
	,[Count] AS InventoryCount
FROM vProducts
JOIN vInventories
	ON vProducts.ProductID=vInventories.ProductID
ORDER BY
	ProductName
	,YEAR(InventoryDate)
	,MONTH(InventoryDate)
	,[Count]
;
GO

-- Question 4 (10% of pts): 
-- CREATE A VIEW called vProductInventories 
-- Shows a list of Product names, each Inventory Date, and the Inventory Count, 
-- Format the date like 'January, 2017'.
-- Order the results by the Product, Date, and Count!

--Step 1: Preview raw data.
-- GO
-- SELECT *
-- FROM vProducts
-- ;
-- GO

-- GO
-- SELECT * 
-- FROM vInventories
-- ;
-- GO

--Step 2: Join views by ProductID.
-- GO
-- SELECT *
-- FROM vProducts
-- JOIN vInventories
-- 	ON vProducts.ProductID=vInventories.ProductID
-- ;
-- GO

--Step 3: Narrow view to select only product names, inventory dates, and inventory counts.
-- GO
-- SELECT
-- 	ProductName
-- 	,InventoryDate
-- 	,[Count] AS InventoryCount
-- FROM vProducts
-- JOIN vInventories
-- 	ON vProducts.ProductID=vInventories.ProductID
-- ;
-- GO

--Step 4: Display inventory date in specified format using the DATENAME function.
-- GO
-- SELECT
-- 	ProductName
-- 	,DATENAME(mm,InventoryDate)+', '+DATENAME(yy,InventoryDate) AS [InventoryDate]
-- 	AS [InventoryDate]
-- 	,[Count] AS InventoryCount
-- FROM vProducts
-- JOIN vInventories
-- 	ON vProducts.ProductID=vInventories.ProductID
-- ;
-- GO

--Step 5: Order results by product name, inventory date, and inventory count. Note: this is a basic view
--meant to answer the business question posed, though it was built to theoretically handle multi-year
--data. That said, in the case of a very large data set a more sophisticated ORDER BY clause may be more efficient.
-- GO
-- SELECT
-- 	ProductName
-- 	,DATENAME(mm,InventoryDate)+', '+DATENAME(yy,InventoryDate) AS [InventoryDate]
-- 	,[Count] AS InventoryCount
-- FROM vProducts
-- JOIN vInventories
-- 	ON vProducts.ProductID=vInventories.ProductID
-- ORDER BY
-- 	ProductName
-- 	,YEAR(InventoryDate)
-- 	,MONTH(InventoryDate)
-- 	,[Count]
-- ;
-- GO

--Step 6: Create view from previous SQL query.
GO
CREATE VIEW vProductInventories
	AS
		SELECT TOP 10000
			ProductName
			,DATENAME(mm,InventoryDate)+', '+DATENAME(yy,InventoryDate) AS [InventoryDate]
			,[Count] AS InventoryCount
		FROM vProducts
		JOIN vInventories
			ON vProducts.ProductID=vInventories.ProductID
		ORDER BY
			ProductName
			,YEAR(InventoryDate)
			,MONTH(InventoryDate)
			,[Count]
;
GO

-- Check that it works:
-- SELECT * 
-- FROM vProductInventories
-- ;
-- GO

-- Question 5 (10% of pts): 
-- CREATE A VIEW called vCategoryInventories. 
-- Shows a list of Category names, Inventory Dates, and a TOTAL Inventory Count BY CATEGORY
-- Format the date like 'January, 2017'.

--Step 1: Preview raw data.
-- GO
-- SELECT *
-- FROM vCategories
-- ;
-- GO

-- GO
-- SELECT *
-- FROM vProducts
-- ;
-- GO

-- GO
-- SELECT * 
-- FROM vInventories
-- ;
-- GO

--Step 2: Join views by ProductID and CategoryID.
-- GO
-- SELECT *
-- FROM vCategories
-- JOIN vProducts
-- 	ON vCategories.CategoryID=vProducts.CategoryID
-- JOIN vInventories
-- 	ON vProducts.ProductID=vInventories.ProductID
-- ;
-- GO

--Step 3: Narrow view to select only category names, inventory dates, and inventory counts.
-- GO
-- SELECT
-- 	CategoryName
-- 	,InventoryDate
-- 	,[Count]
-- FROM vCategories
-- JOIN vProducts
-- 	ON vCategories.CategoryID=vProducts.CategoryID
-- JOIN vInventories
-- 	ON vProducts.ProductID=vInventories.ProductID
-- ;
-- GO

--Step 4: Aggregate inventory counts and group by category and inventory date.
-- GO
-- SELECT
-- 	CategoryName
-- 	,InventoryDate
-- 	,SUM([Count]) AS [InventoryCountbyCategory]
-- FROM vCategories
-- JOIN vProducts
-- 	ON vCategories.CategoryID=vProducts.CategoryID
-- JOIN vInventories
-- 	ON vProducts.ProductID=vInventories.ProductID
-- GROUP BY
-- 	CategoryName
-- 	,InventoryDate
-- ;
-- GO

--Step 5: Order results by category name and inventory date.
-- GO
-- SELECT
-- 	CategoryName
-- 	,InventoryDate
-- 	,SUM([Count]) AS [InventoryCountbyCategory]
-- FROM vCategories
-- JOIN vProducts
-- 	ON vCategories.CategoryID=vProducts.CategoryID
-- JOIN vInventories
-- 	ON vProducts.ProductID=vInventories.ProductID
-- GROUP BY
-- 	CategoryName
-- 	,InventoryDate
-- ORDER BY
-- 	CategoryName
-- 	,InventoryDate	
-- ;
-- GO

--Step 6: Display inventory date in specified format using the DATENAME function and
--reformat ORDER BY to return result in chronological order. Note: this is a basic view
--meant to answer the business question posed, though it was built to theoretically handle multi-year
--data. That said, in the case of a very large data set a more sophisticated ORDER BY clause may be more efficient.
-- GO
-- SELECT
-- 	CategoryName
-- 	,DATENAME(mm,InventoryDate)+', '+DATENAME(yy,InventoryDate) AS [InventoryDate]
-- 	,SUM([Count]) AS [InventoryCountbyCategory]
-- FROM vCategories
-- JOIN vProducts
-- 	ON vCategories.CategoryID=vProducts.CategoryID
-- JOIN vInventories
-- 	ON vProducts.ProductID=vInventories.ProductID
-- GROUP BY
-- 	CategoryName
-- 	,InventoryDate
-- ORDER BY
-- 	CategoryName
-- ,YEAR(InventoryDate)
-- ,MONTH(InventoryDate)
-- ;
-- GO

--Step 7: Create view from previous SQL query.
GO
CREATE VIEW vCategoryInventories
	AS
		SELECT TOP 10000
			CategoryName
			,DATENAME(mm,InventoryDate)+', '+DATENAME(yy,InventoryDate) AS [InventoryDate]
			,SUM([Count]) AS [InventoryCountbyCategory]
		FROM vCategories
		JOIN vProducts
			ON vCategories.CategoryID=vProducts.CategoryID
		JOIN vInventories
			ON vProducts.ProductID=vInventories.ProductID
		GROUP BY
			CategoryName
			,InventoryDate
		ORDER BY
			CategoryName
			,YEAR(InventoryDate)
			,MONTH(InventoryDate)
;
GO

--Check that it works:
-- SELECT * 
-- FROM vCategoryInventories
-- ;
-- GO

-- Question 6 (10% of pts): 
-- CREATE ANOTHER VIEW called vProductInventoriesWithPreviouMonthCounts 
-- Show a list of Product names, Inventory Dates, Inventory Count, AND the Previous Month Count.
-- Use functions to set any January NULL counts to zero. 
-- Order the results by the Product, Date, and Count. 
-- This new view must use your vProductInventories view!

--Step 1: Preview raw data.
-- GO
-- SELECT * 
-- FROM vProductInventories
-- ;
-- GO

--Step 2: List out category name, inventory date, and inventory count columns.
-- GO
-- SELECT
-- 	ProductName
-- 	,InventoryDate
-- 	,InventoryCount
-- FROM vProductInventories
-- ;
-- GO

--Step 3: Define PreviousMonthCount column by returning the changes in the InventoryCount column
--using the LAG function and partitioning the data by product. Note that the ORDER BY clause from
--the previous view carries into this new view and therefore does not need to be repeated, 
--from a functional perspective.
-- GO
-- SELECT
-- 	ProductName
-- 	,InventoryDate
-- 	,InventoryCount AS InventoryCount
-- 	,LAG(InventoryCount,1) OVER(PARTITION BY ProductName ORDER BY(MONTH(InventoryDate))) AS PreviousMonthCount
-- FROM vProductInventories
-- ;
-- GO

--Step 4: Assign an integer value of zero to null entries in the PreviousMonthCount column.
-- GO
-- SELECT
-- 	ProductName
-- 	,InventoryDate
-- 	,InventoryCount AS InventoryCount
-- 	,ISNULL(LAG(InventoryCount,1) OVER(PARTITION BY ProductName ORDER BY(MONTH(InventoryDate))),0) AS PreviousMonthCount
-- FROM vProductInventories
-- ;
-- GO

--Step 5: Create view from previous SQL query.
GO
CREATE VIEW vProductInventoriesWithPreviousMonthCounts
	AS
		SELECT
			ProductName
			,InventoryDate
			,InventoryCount AS InventoryCount
			,ISNULL(LAG(InventoryCount,1) OVER(PARTITION BY ProductName ORDER BY(MONTH(InventoryDate))),0) AS PreviousMonthCount
		FROM vProductInventories
;
GO

-- Check that it works:
-- SELECT * 
-- FROM vProductInventoriesWithPreviousMonthCounts
-- ;
-- GO

-- Question 7 (15% of pts): 
-- CREATE a VIEW called vProductInventoriesWithPreviousMonthCountsWithKPIs
-- Show columns for the Product names, Inventory Dates, Inventory Count, Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- Order the results by the Product, Date, and Count!
-- Important: This new view must use your vProductInventoriesWithPreviousMonthCounts view!

--Step 1: Preview raw data.
-- GO
-- SELECT *
-- FROM vProductInventoriesWithPreviousMonthCounts
-- ;
-- GO

--Step 2: List out category name, inventory date, inventory count, and previous month count columns.
-- GO
-- SELECT
-- 	ProductName
-- 	,InventoryDate
-- 	,InventoryCount
-- 	,PreviousMonthCount
-- FROM vProductInventoriesWithPreviousMonthCounts
-- ;
-- GO

--Step 3: Define CountVsPreviousCountKPI column using the CASE function.
-- GO
-- SELECT
-- 	ProductName
-- 	,InventoryDate
-- 	,InventoryCount
-- 	,PreviousMonthCount
-- 	,CASE
-- 		WHEN PreviousMonthCount<InventoryCount THEN 1
-- 		WHEN PreviousMonthCount=InventoryCount THEN 0
-- 		WHEN PreviousMonthCount>InventoryCount THEN -1
-- 	END	AS CountVsPreviousCountKPI
-- FROM vProductInventoriesWithPreviousMonthCounts
-- ;
-- GO

--Step 5: Create view from previous SQL query. Note that the ORDER BY clause from the previous view
--carries into this new view and therefore does not need to be repeated, from a functional perspective.
GO
CREATE VIEW vProductInventoriesWithPreviousMonthCountsWithKPIs
	AS
		SELECT
		ProductName
		,InventoryDate
		,InventoryCount
		,PreviousMonthCount
		,CASE
			WHEN PreviousMonthCount<InventoryCount THEN 1
			WHEN PreviousMonthCount=InventoryCount THEN 0
			WHEN PreviousMonthCount>InventoryCount THEN -1
		END	AS CountVsPreviousCountKPI
FROM vProductInventoriesWithPreviousMonthCounts
;
GO

--Check that it works:
-- SELECT * 
-- FROM vProductInventoriesWithPreviousMonthCountsWithKPIs
-- ;
-- GO

-- Question 8 (25% of pts): 
-- CREATE a User Defined Function (UDF) called fProductInventoriesWithPreviousMonthCountsWithKPIs.
-- Show columns for the Product names, Inventory Dates, Inventory Count, the Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- The function must use the ProductInventoriesWithPreviousMonthCountsWithKPIs view!
-- Include an Order By clause in the function using this code: 
-- Year(Cast(v1.InventoryDate as Date))
-- and note what effect it has on the results.

--Note: Unlike the previous questions - and due to the syntax of UDFs, which cannot be created in actionalbe 
--parts as in the case with views - this function was written ad hoc. Furthermore, to conform to the formatting
--specified in the prompt, the alias v1 was utilized for the resulting table and the ORDER BY clause was
--called into the final function code.
GO
CREATE FUNCTION	dbo.fProductInventoriesWithPreviousMonthCountsWithKPIs(@KPI INT)
RETURNS TABLE
	AS RETURN(
		SELECT TOP 10000
			v1.ProductName
			,v1.InventoryDate
			,v1.InventoryCount
			,v1.PreviousMonthCount
			,v1.CountVsPreviousCountKPI
		FROM vProductInventoriesWithPreviousMonthCountsWithKPIs AS v1
		WHERE CountVsPreviousCountKPI=@KPI
		ORDER BY
			v1.ProductName
			,YEAR(CAST(v1.InventoryDate AS DATE))
		)
;
GO

-- In testing, the following function returned the same results without the use of aliases or ORDER BY:
-- GO
-- ALTER FUNCTION dbo.fProductInventoriesWithPreviousMonthCountsWithKPIs(@KPI INT)
-- RETURNS TABLE
-- 	AS RETURN(
-- 		SELECT
-- 			ProductName
-- 			,InventoryDate
-- 			,InventoryCount
-- 			,PreviousMonthCount
-- 			,CountVsPreviousCountKPI
-- 		FROM vProductInventoriesWithPreviousMonthCountsWithKPIs
-- 		WHERE CountVsPreviousCountKPI=@KPI
-- 		)
-- ;
-- GO

--Check that it works:
-- SELECT * 
-- FROM fProductInventoriesWithPreviousMonthCountsWithKPIs(1)
-- ;
-- GO

-- SELECT * 
-- FROM fProductInventoriesWithPreviousMonthCountsWithKPIs(0)
-- ;
-- GO

-- SELECT * 
-- FROM fProductInventoriesWithPreviousMonthCountsWithKPIs(-1)
-- ;
-- GO
/***************************************************************************************/