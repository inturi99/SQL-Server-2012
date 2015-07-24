-- Table Expressions
---------------------------------------------------
--Derived Tables
SELECT * from (SELECT custid,companyname,country from Sales.Customers where country = N'USA') AS USACusts

--Assigning Column Aliases
SELECT YEAR(orderdate) AS orderyear,COUNT(DISTINCT custid) AS numcusts from Sales.Orders GROUP BY orderyear;
--error: Invalid column name 'orderyear'.

SELECT  month, orderyear,COUNT(DISTINCT custid) AS numcusts from (SELECT MONTH(orderdate) AS month,YEAR(orderdate) AS orderyear,custid from Sales.Orders) AS D GROUP BY orderyear,month ORDER BY orderyear;
--OR
SELECT MONTH(orderdate) AS month,YEAR(orderdate) AS orderyear,COUNT(DISTINCT custid) AS numcusts from Sales.Orders GROUP BY MONTH(orderdate),YEAR(orderdate) order by orderyear;

SELECT  orderyear,COUNT(DISTINCT custid) AS numcusts from (SELECT YEAR(orderdate),custid from Sales.Orders) AS D(orderyear,custid) GROUP BY orderyear ORDER BY orderyear;

-------------------------------------------
--Using Arguments
------------------------------------------

DECLARE @empid AS INT = 3;
SELECT orderyear,COUNT(DISTINCT custid) AS numcusts from (SELECT YEAR(orderdate) AS orderyear,custid from Sales.Orders where empid =@empid) AS D GROUP BY orderyear ORDER BY orderyear;


------------------------------------------
-- Nesting
------------------------------------------

SELECT orderyear, numcusts FROM (SELECT orderyear, COUNT(DISTINCT custid) AS numcusts 
FROM (SELECT YEAR(orderdate) AS orderyear, custid
FROM Sales.Orders) AS D1 GROUP BY orderyear) AS D2 WHERE numcusts > 70;

SELECT YEAR(orderdate) AS orderyear, COUNT(DISTINCT custid) AS numcusts FROM Sales.Orders GROUP BY YEAR(orderdate)
HAVING COUNT(DISTINCT custid) > 70;

Select MONTH(orderdate) AS month,YEAR(orderdate) AS year,COUNT(DISTINCT custid) AS custcount from  Sales.Orders GROUP BY MONTH(orderdate),YEAR(orderdate)  Order by custcount DESC;

WITH MaxPerUser AS
(
SELECT  YEAR(orderdate) AS year,custid,Count(orderid) AS ordercount,ROW_NUMBER() OVER(PARTITION BY Count(orderid) ORDER BY custid ASC) AS 'RowNumber' from Sales.Orders  GROUP BY YEAR(orderdate),custid 
)
SELECT year, custid, ordercount 
FROM MaxPerUser
WHERE RowNumber = 1 order by ordercount desc;

----------------------------
-- Multiple References
----------------------------
SELECT Cur.orderyear, Cur.numcusts AS curnumcusts, Prv.numcusts AS prvnumcusts, Cur.numcusts - Prv.numcusts AS growth
FROM (SELECT YEAR(orderdate) AS orderyear, COUNT(DISTINCT custid) AS numcusts
FROM Sales.Orders GROUP BY YEAR(orderdate)) AS Cur LEFT OUTER JOIN (SELECT YEAR(orderdate) AS orderyear,
COUNT(DISTINCT custid) AS numcusts FROM Sales.Orders GROUP BY YEAR(orderdate)) AS Prv ON Cur.orderyear = Prv.orderyear + 1;
----------------------------
--Common Table Expressions
----------------------------
WITH USACusts AS
(
SELECT custid, companyname
FROM Sales.Customers
WHERE country = N'USA'
)
SELECT * FROM USACusts;
--------------
--Assigning Column Aliases in CTEs
---
WITH C AS
(
SELECT YEAR(orderdate) AS orderyear, custid
FROM Sales.Orders
)
SELECT orderyear, COUNT(DISTINCT custid) AS numcusts
FROM C
GROUP BY orderyear;

--OR---
WITH C(orderyear, custid) AS
(
SELECT YEAR(orderdate), custid
FROM Sales.Orders
)
SELECT orderyear, COUNT(DISTINCT custid) AS numcusts
FROM C
GROUP BY orderyear;
---------
--Using Arguments in CTEs
-------
DECLARE @empid AS INT = 3;
WITH C AS
(
SELECT YEAR(orderdate) AS orderyear, custid
FROM Sales.Orders
WHERE empid = @empid
)
SELECT orderyear, COUNT(DISTINCT custid) AS numcusts
FROM C
GROUP BY orderyear;

---------------------------
-- Defining Multiple CTEs
--------------------------
WITH C1 AS
(
SELECT YEAR(orderdate) AS orderyear, custid
FROM Sales.Orders
),
C2 AS
(
SELECT orderyear, COUNT(DISTINCT custid) AS numcusts
FROM C1
GROUP BY orderyear
)
SELECT orderyear, numcusts
FROM C2
WHERE numcusts > 70;

-------------------------------
-- Multiple References in CTEs
-------------------------------
WITH YearlyCount AS
(
SELECT YEAR(orderdate) AS orderyear,
COUNT(DISTINCT custid) AS numcusts
FROM Sales.Orders
GROUP BY YEAR(orderdate)
)
SELECT Cur.orderyear,
Cur.numcusts AS curnumcusts, Prv.numcusts AS prvnumcusts,
Cur.numcusts - Prv.numcusts AS growth
FROM YearlyCount AS Cur
LEFT OUTER JOIN YearlyCount AS Prv
ON Cur.orderyear = Prv.orderyear + 1;

--------------------
--Recursive CTEs
--------------------
WITH EmpsCTE AS
(
SELECT empid, mgrid, firstname, lastname
FROM HR.Employees
WHERE empid = 2
UNION ALL
SELECT C.empid, C.mgrid, C.firstname, C.lastname
FROM EmpsCTE AS P
JOIN HR.Employees AS C
ON C.mgrid = P.empid
)
SELECT empid, mgrid, firstname, lastname
FROM EmpsCTE;


---------------------------------------------------
-- Views
-------------------------------------------------

IF OBJECT_ID('Sales.USACusts') IS NOT NULL
DROP VIEW Sales.USACusts;
GO

CREATE VIEW Sales.USACusts
AS
SELECT
custid, companyname, contactname, contacttitle, address,
city, region, postalcode, country, phone, fax
FROM Sales.Customers
WHERE country = N'USA';
GO
-------------------------------
--Views and the ORDER BY Clause
----------------------------------
Select custid,companyname from Sales.USACusts;

Select custid,companyname,region from Sales.USACusts Order by region;

---
ALTER VIEW Sales.USACusts
AS
SELECT
custid, companyname, contactname, contacttitle, address,
city, region, postalcode, country, phone, fax
FROM Sales.Customers
WHERE country = N'USA'
ORDER BY region;
GO

-- ERROR 
/* This attempt fails, and you get the following error.
Msg 1033, Level 15, State 1, Procedure USACusts, Line 9
The ORDER BY clause is invalid in views, inline functions, derived tables, subqueries, and
common table expressions, unless TOP, OFFSET or FOR XML is also specified.
*/
/*
The error message indicates that SQL Server allows the ORDER BY clause in three exceptional
cases—when the TOP, OFFSET-FETCH, or FOR XML option is used.
*/


ALTER VIEW Sales.USACusts
AS
SELECT TOP(100) PERCENT
custid, companyname, contactname, contacttitle, address,
city, region, postalcode, country, phone, fax
FROM Sales.Customers
WHERE country = N'USA'
ORDER BY region;
GO

----
SELECT custid, companyname, region
FROM Sales.USACusts;

--Here is the output from one of my executions showing that the rows are not sorted by region.


ALTER VIEW Sales.USACusts
AS
SELECT 
custid, companyname, contactname, contacttitle, address,
city, region, postalcode, country, phone, fax
FROM Sales.Customers
WHERE country = N'USA'
ORDER BY region OFFSET 0 Rows;
GO
-----
SELECT custid, companyname, region
FROM Sales.USACusts;


-----------------
--View Options
-----------------
--The ENCRYPTION Option
------------------------

ALTER VIEW Sales.USACusts
AS
SELECT
custid, companyname, contactname, contacttitle, address,
city, region, postalcode, country, phone, fax
FROM Sales.Customers
WHERE country = N'USA';
GO
-----------------------------------------------------------
SELECT OBJECT_DEFINITION(OBJECT_ID('Sales.USACusts'));
---------------------------------------------
ALTER VIEW Sales.USACusts WITH ENCRYPTION
AS
SELECT
custid, companyname, contactname, contacttitle, address,
city, region, postalcode, country, phone, fax
FROM Sales.Customers
WHERE country = N'USA';
GO
------------------
SELECT OBJECT_DEFINITION(OBJECT_ID('Sales.USACusts'));
-----------------------
EXEC sp_helptext 'Sales.USACusts';

----------------------------
--The SCHEMABINDING Option
----------------------------
ALTER VIEW Sales.USACusts WITH SCHEMABINDING
AS
SELECT
custid, companyname, contactname, contacttitle, address,
city, region, postalcode, country, phone, fax
FROM Sales.Customers
WHERE country = N'USA';
GO

ALTER TABLE Sales.Customers DROP COLUMN address;
-- ERROR: ALTER TABLE DROP COLUMN address failed because one or more objects access this column.

------------------------
-- The CHECK OPTION Option
----------------------------

INSERT INTO Sales.USACusts(
companyname, contactname, contacttitle, address,
city, region, postalcode, country, phone, fax)
VALUES(
N'Customer ABCDE', N'Contact ABCDE', N'Title ABCDE', N'Address ABCDE',
N'London', NULL, N'12345', N'UK', N'012-3456789', N'012-3456789');
---------------------------------------------
SELECT custid, companyname, country
FROM Sales.USACusts
WHERE companyname = N'Customer ABCDE';
-------------------------------
SELECT custid, companyname, country
FROM Sales.Customers
WHERE companyname = N'Customer ABCDE';
-----------------------------------------
ALTER VIEW Sales.USACusts WITH SCHEMABINDING
AS
SELECT
custid, companyname, contactname, contacttitle, address,
city, region, postalcode, country, phone, fax
FROM Sales.Customers
WHERE country = N'USA'
WITH CHECK OPTION;
GO
-------------------------------------------------------

INSERT INTO Sales.USACusts(
companyname, contactname, contacttitle, address,
city, region, postalcode, country, phone, fax)
VALUES(
N'Customer FGHIJ', N'Contact FGHIJ', N'Title FGHIJ', N'Address FGHIJ',
N'London', NULL, N'12345', N'UK', N'012-3456789', N'012-3456789');

-- ERROR :The attempted insert or update failed because the target view either specifies WITH CHECK OPTION or spans a view that specifies WITH CHECK OPTION and one or more rows resulting from the operation did not qualify under the CHECK OPTION constraint.
-- The statement has been terminated.
--------------------------------------------------

DELETE FROM Sales.Customers
WHERE custid > 91;
IF OBJECT_ID('Sales.USACusts') IS NOT NULL DROP VIEW Sales.USACusts;

-------------------------------------------------------------------------------
-- Inline Table-Valued Functions
------------------------------------
IF OBJECT_ID('dbo.GetCustOrders') IS NOT NULL
DROP FUNCTION dbo.GetCustOrders;
GO
CREATE FUNCTION dbo.GetCustOrders
(@cid AS INT) RETURNS TABLE
AS
RETURN
SELECT orderid, custid, empid, orderdate, requireddate,
shippeddate, shipperid, freight, shipname, shipaddress, shipcity,
shipregion, shippostalcode, shipcountry
FROM Sales.Orders
WHERE custid = @cid;
GO

-------------------------------
SELECT orderid, custid
FROM dbo.GetCustOrders(1) AS O
-------------------------------------------------
SELECT O.orderid, O.custid, OD.productid, OD.qty
FROM dbo.GetCustOrders(1) AS O
JOIN Sales.OrderDetails AS OD
ON O.orderid = OD.orderid ORDER BY OD.qty;
------------------------------------------------
IF OBJECT_ID('dbo.GetCustOrders') IS NOT NULL
DROP FUNCTION dbo.GetCustOrders;
----------------------------------------------------

-- The APPLY Operator
------------------------------------------------------------

SELECT S.shipperid, E.empid
FROM Sales.Shippers AS S
CROSS JOIN HR.Employees AS E;
-----Same
SELECT S.shipperid, E.empid
FROM Sales.Shippers AS S
CROSS APPLY HR.Employees AS E;
-----------------------------------------

SELECT C.custid, A.orderid, A.orderdate
FROM Sales.Customers AS C
CROSS APPLY
(SELECT TOP (3) orderid, empid, orderdate, requireddate
FROM Sales.Orders AS O
WHERE O.custid = C.custid
ORDER BY orderdate DESC, orderid DESC) AS A;

------------------------------------Same
SELECT C.custid, A.orderid, A.orderdate
FROM Sales.Customers AS C
CROSS APPLY
(SELECT orderid, empid, orderdate, requireddate
FROM Sales.Orders AS O
WHERE O.custid = C.custid
ORDER BY orderdate DESC, orderid DESC
OFFSET 0 ROWS FETCH FIRST 3 ROWS ONLY) AS A;


--------------------------------------------------------
SELECT C.custid, A.orderid, A.orderdate
FROM Sales.Customers AS C
OUTER APPLY
(SELECT TOP (3) orderid, empid, orderdate, requireddate
FROM Sales.Orders AS O
WHERE O.custid = C.custid
ORDER BY orderdate DESC, orderid DESC) AS A;
----- SAME
SELECT C.custid, A.orderid, A.orderdate
FROM Sales.Customers AS C
OUTER APPLY
(SELECT orderid, empid, orderdate, requireddate
FROM Sales.Orders AS O
WHERE O.custid = C.custid
ORDER BY orderdate DESC, orderid DESC
OFFSET 0 ROWS FETCH FIRST 3 ROWS ONLY) AS A;

---------------------------------------------

IF OBJECT_ID('dbo.TopOrders') IS NOT NULL
DROP FUNCTION dbo.TopOrders;
GO
CREATE FUNCTION dbo.TopOrders
(@custid AS INT, @n AS INT)
RETURNS TABLE
AS
RETURN
SELECT orderid, empid, orderdate, requireddate
FROM Sales.Orders
WHERE custid = @custid
ORDER BY orderdate DESC, orderid DESC
OFFSET 0 ROWS FETCH FIRST @n ROWS ONLY;
GO
-------------------------------
SELECT
C.custid, C.companyname,
A.orderid, A.empid, A.orderdate, A.requireddate
FROM Sales.Customers AS C
CROSS APPLY dbo.TopOrders(C.custid, 3) AS A;

----------------------------------------------------------
--Exercises
----------------------------------------------------------
--1
SELECT empid, MAX(orderdate) AS maxorderdate FROM Sales.Orders GROUP BY empid;
--2
SELECT O.empid, O.orderdate, O.orderid, O.custid FROM Sales.Orders AS O JOIN (SELECT empid, MAX(orderdate) AS maxorderdate
FROM Sales.Orders GROUP BY empid) AS D ON O.empid = D.empid AND O.orderdate = D.maxorderdate;
--3
SELECT orderid, orderdate, custid, empid, ROW_NUMBER() OVER(ORDER BY orderdate, orderid) AS rownum FROM Sales.Orders;

--4
WITH OrdersRN AS
(
SELECT orderid, orderdate, custid, empid,
ROW_NUMBER() OVER(ORDER BY orderdate, orderid) AS rownum
FROM Sales.Orders
)
SELECT * FROM OrdersRN WHERE rownum BETWEEN 11 AND 20;
---------------------------
--3

WITH EmpsCTE AS
(
SELECT empid, mgrid, firstname, lastname
FROM HR.Employees
WHERE empid = 9
UNION ALL
SELECT P.empid, P.mgrid, P.firstname, P.lastname
FROM EmpsCTE AS C
JOIN HR.Employees AS P
ON C.mgrid = P.empid
)
SELECT empid, mgrid, firstname, lastname
FROM EmpsCTE;

--4
USE TSQL2012;
IF OBJECT_ID('Sales.VEmpOrders') IS NOT NULL
DROP VIEW Sales.VEmpOrders;
GO
CREATE VIEW Sales.VEmpOrders
AS
SELECT
empid,
YEAR(orderdate) AS orderyear,
SUM(qty) AS qty
FROM Sales.Orders AS O
JOIN Sales.OrderDetails AS OD
ON O.orderid = OD.orderid
GROUP BY
empid,
YEAR(orderdate);
GO
--5
SELECT empid, orderyear, qty, (SELECT SUM(qty) FROM Sales.VEmpOrders AS V2 WHERE V2.empid = V1.empid
AND V2.orderyear <= V1.orderyear) AS runqty FROM Sales.VEmpOrders AS V1 ORDER BY empid, orderyear;
--6
USE TSQL2012;
IF OBJECT_ID('Production.TopProducts') IS NOT NULL
DROP FUNCTION Production.TopProducts;
GO
CREATE FUNCTION Production.TopProducts
(@supid AS INT, @n AS INT)
RETURNS TABLE
AS
RETURN
SELECT TOP (@n) productid, productname, unitprice
FROM Production.Products
WHERE supplierid = @supid
ORDER BY unitprice DESC;
GO
-- 7
SELECT S.supplierid, S.companyname, P.productid, P.productname, P.unitprice
FROM Production.Suppliers AS S
CROSS APPLY Production.TopProducts(S.supplierid, 2) AS P;

-- TABREZ SIR TASKS

SELECT c.contactname,o.custid,COUNT(orderid) AS ordercount from Sales.Orders AS o INNER JOIN Sales.Customers AS c ON o.custid = c.custid GROUP BY c.contactname,o.custid order by ordercount DESC;

Select YEAR(orderdate) AS year,COUNT(orderid) AS ordercount from  Sales.Orders GROUP BY YEAR(orderdate)  Order by ordercount DESC;

SELECT c.contactname,o.custid, YEAR(orderdate) AS year,COUNT(orderid) AS ordercount from Sales.Orders AS o INNER JOIN Sales.Customers AS c ON o.custid = c.custid GROUP BY c.contactname,o.custid,YEAR(orderdate) order by ordercount DESC;

SELECT  YEAR(orderdate) AS year,custid,Count(orderid) AS ordercount from Sales.Orders  GROUP BY YEAR(orderdate),custid order by ordercount DESC;



WITH maxorder AS(
SELECT  YEAR(orderdate) AS year,custid,Count(orderid) AS ordercount ,ROW_NUMBER() OVER(ORDER BY YEAR(orderdate), custid) AS rownum from Sales.Orders  GROUP BY YEAR(orderdate),custid 
)
SELECT * FROM maxorder  order by ordercount DESC ;


USE TSQL2012;
IF OBJECT_ID('Sales.TopOrders') IS NOT NULL
DROP FUNCTION Sales.TopOrders;
GO
CREATE FUNCTION Sales.TopOrders
(@custid AS INT, @n AS INT)
RETURNS TABLE
AS
RETURN
SELECT TOP (@n) custid, orderdate ,freight,orderid 
FROM Sales.Orders 
WHERE custid = @custid 
ORDER BY freight DESC;
GO

SELECT SC.custid ,YEAR(SC.orderdate) AS year,COUNT(SC.orderid) AS ordercount
FROM Sales.Orders AS O 
CROSS APPLY Sales.TopOrders(O.custid, 1) AS SC GROUP BY YEAR(SC.orderdate),SC.custid ORDER BY ordercount DESC;