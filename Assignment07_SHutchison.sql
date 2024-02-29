--*************************************************************************--
-- Title: Assignment07
-- Author: SidneyHutchison
-- Desc: This file demonstrates how to use Functions
-- Change Log: When,Who,What
-- 2017-01-01,RRoot,Created File
-- 2024-02-27,SidneyHutchison,Completed File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment07DB_SidneyHutchison')
	 Begin 
	  Alter Database [Assignment07DB_SidneyHutchison] set Single_user With Rollback Immediate;
	  Drop Database Assignment07DB_SidneyHutchison;
	 End
	Create Database Assignment07DB_SidneyHutchison;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment07DB_SidneyHutchison;

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
(InventoryDate, EmployeeID, ProductID, [Count], [ReorderLevel]) -- New column added this week
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock, ReorderLevel
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10, ReorderLevel -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, abs(UnitsInStock - 10), ReorderLevel -- Using this is to create a made up value
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
Print
'NOTES------------------------------------------------------------------------------------ 
 1) You must use the BASIC views for each table.
 2) Remember that Inventory Counts are Randomly Generated. So, your counts may not match mine
 3) To make sure the Dates are sorted correctly, you can use Functions in the Order By clause!
------------------------------------------------------------------------------------------'



-- Question 1 (5% of pts):
-- Show a list of Product names and the price of each product.
-- Use a function to format the price as US dollars.
-- Order the result by the product name.

/*
-- Showing my work. First attempt at formatting the UnitPrice into US Dollars. 
Select
	ProductName,
	UnitPrice = concat('$',UnitPrice)
From
	vProducts
Order By 
	ProductName
go
*/


-- Final code to answer Question 1.
Select
	ProductName,
	UnitPrice = Format(UnitPrice, 'C', 'en-us')
From
	vProducts
Order By 
	ProductName
go



-- Question 2 (10% of pts): 
-- Show a list of Category and Product names, and the price of each product.
-- Use a function to format the price as US dollars.
-- Order the result by the Category and Product.

Select
	c.CategoryName,
	p.ProductName,
	UnitPrice = Format(UnitPrice, 'C', 'en-us')
From
	vProducts as p
	INNER JOIN
	vCategories as c
	ON c.CategoryID = p.CategoryID
Order By 
	CategoryName, 
	ProductName
go



-- Question 3 (10% of pts): 
-- Use functions to show a list of Product names, each Inventory Date, and the Inventory Count.
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.


/*
-- Showing my work. This is the general code to answer the Question without the requested formatting of the InventoryDate column
Select
	ProductName,
	InventoryDate,
	InventoryCount = [Count]
From
	vProducts as p 
	INNER JOIN
	vInventories as i
	ON p.ProductID = i.ProductID
Order By
	ProductName,
	i.InventoryDate
go
*/


/*
-- Showing my work. Figuring out the components of how to format the InventoryDate column. I broke the requested format into 2 pieces (the written month, and the year), created a solution for getting each of those pieces, and then concatenated those two pieces together. 
Select
	[Month] = Case
				When RIGHT(InventoryDate,5) like '01%' Then 'January, '
				When RIGHT(InventoryDate,5) like '02%' Then 'February, '
				When RIGHT(InventoryDate,5) like '03%' Then 'March, '
				Else 'No Date Available'
				End
From
	vInventories

Select 
	[Year] = LEFT(InventoryDate,4)
From
	vInventories

Select
	[MonthYear] = concat(Case
							When RIGHT(InventoryDate,5) like '01%' Then 'January, '
							When RIGHT(InventoryDate,5) like '02%' Then 'February, '
							When RIGHT(InventoryDate,5) like '03%' Then 'March, '    -- Could add more similar lines for all 12 months of the year, but this data only includes dates from January through March so I only included cases for those 3 months.
							Else 'No Date Available'
							End,
							LEFT(InventoryDate,4))
From
	vInventories
-- As I worked through the rest of the questions, I figured out that this solution for formatting the InventoryDate column doesn't work nicely into the answer for Question 6. 
*/


/*
-- Showing my work. Next iteration of how I can format the InventoryDate column, in a way that will work better into future Questions' solutions. This solution also just looks cleaner and is less typing.

Select
	[MonthYear] = Format(InventoryDate, 'MMMM, yyyy')
From
	vInventories
*/


--Final code to answer Question 3.
Select
	ProductName,
	InventoryDate = Format(InventoryDate, 'MMMM, yyyy'),
	InventoryCount = [Count]
From
	vProducts as p 
	INNER JOIN
	vInventories as i
	ON p.ProductID = i.ProductID
Order By
	ProductName,
	Year(InventoryDate),        -- Could omit this line as this data currently only has dates from one year, but leaving this in here in case additional data from other years gets added in the future.
	Month(InventoryDate)
go



-- Question 4 (10% of pts): 
-- CREATE A VIEW called vProductInventories. 
-- Shows a list of Product names, each Inventory Date, and the Inventory Count. 
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

Create View vProductInventories
AS
	Select Top 100000
		ProductName,
		InventoryDate = Format(InventoryDate, 'MMMM, yyyy'),
		InventoryCount = [Count]
	From
		vProducts as p 
		INNER JOIN
		vInventories as i
		ON p.ProductID = i.ProductID
	Order By
		ProductName,
		Year(InventoryDate),
		Month(InventoryDate)
go

-- Check that it works: 
Select * From vProductInventories;
go



-- Question 5 (10% of pts): 
-- CREATE A VIEW called vCategoryInventories. 
-- Shows a list of Category names, Inventory Dates, and a TOTAL Inventory Count BY CATEGORY
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

Create View vCategoryInventories
AS
	Select Top 100000
		CategoryName,
		InventoryDate = Format(InventoryDate, 'MMMM, yyyy'),
		InventoryCountByCategory = Sum([Count])
	From
		vInventories as i
		INNER JOIN
		vProducts as p 
		ON i.ProductID = p.ProductID
		INNER JOIN
		vCategories as c
		ON p.CategoryID = c.CategoryID
	Group By 
		CategoryName, InventoryDate
	Order By
		CategoryName,
		Year(InventoryDate),
		Month(InventoryDate)
go

-- Check that it works: 
Select * From vCategoryInventories;
go



-- Question 6 (10% of pts): 
-- CREATE ANOTHER VIEW called vProductInventoriesWithPreviouMonthCounts. 
-- Show a list of Product names, Inventory Dates, Inventory Count, AND the Previous Month Count.
-- Use functions to set any January NULL counts to zero. 
-- Order the results by the Product and Date. 
-- This new view must use your vProductInventories view.

Create View vProductInventoriesWithPreviousMonthCounts
AS
	Select Top 100000
		vpi.ProductName,
		vpi.InventoryDate,
		vpi.InventoryCount,
		PreviousMonthCount = Lag(InventoryCount,1,0) Over(Order By month(InventoryCount))
	From
		vProductInventories as vpi
	Order By
		ProductName, 
		Year(InventoryDate),
		Month(InventoryDate)
go

-- Check that it works: 
Select * From vProductInventoriesWithPreviousMonthCounts;
go



-- Question 7 (15% of pts): 
-- CREATE a VIEW called vProductInventoriesWithPreviousMonthCountsWithKPIs.
-- Show columns for the Product names, Inventory Dates, Inventory Count, Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- Verify that the results are ordered by the Product and Date.
-- Important: This new view must use your vProductInventoriesWithPreviousMonthCounts view!

Create View vProductInventoriesWithPreviousMonthCountsWithKPIs
AS
	Select Top 100000
		vpiwpmc.ProductName,
		vpiwpmc.InventoryDate,
		vpiwpmc.InventoryCount,
		vpiwpmc.PreviousMonthCount,
		CountVsPreviousCountKPI = Case
				When InventoryCount > PreviousMonthCount Then 1
				When InventoryCount = PreviousMonthCount Then 0
				When InventoryCount < PreviousMonthCount Then -1
			End
	From
		vProductInventoriesWithPreviousMonthCounts as vpiwpmc
	Order By
		ProductName,
		Year(InventoryDate),
		Month(InventoryDate)
go

-- Check that it works: 
Select * From vProductInventoriesWithPreviousMonthCountsWithKPIs;
go



-- Question 8 (25% of pts): 
-- CREATE a User Defined Function (UDF) called fProductInventoriesWithPreviousMonthCountsWithKPIs.
-- Show columns for the Product names, Inventory Dates, Inventory Count, the Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- The function must use the ProductInventoriesWithPreviousMonthCountsWithKPIs view.
-- Verify that the results are ordered by the Product and Date.

Create Function fProductInventoriesWithPreviousMonthCountsWithKPIs(@KPI int)
Returns Table
AS
Return
	Select TOP 100000
		vpiwpmcwkpi.ProductName,
		vpiwpmcwkpi.InventoryDate,
		vpiwpmcwkpi.InventoryCount,
		vpiwpmcwkpi.PreviousMonthCount,
		vpiwpmcwkpi.CountVsPreviousCountKPI
	From 
		vProductInventoriesWithPreviousMonthCountsWithKPIs as vpiwpmcwkpi
	Where
		CountVsPreviousCountKPI = @KPI
	Order By
		ProductName,
		Year(InventoryDate),
		Month(InventoryDate)
go

-- Check that it works:
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(1);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(0);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(-1);
go

/***************************************************************************************/