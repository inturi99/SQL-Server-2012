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

--Tabrez sir Task
SELECT c.contactname,o.custid,COUNT(orderid) AS ordercount from Sales.Orders AS o INNER JOIN Sales.Customers AS c ON o.custid = c.custid GROUP BY c.contactname,o.custid order by ordercount DESC;

Select YEAR(orderdate) AS year,COUNT(orderid) AS ordercount from  Sales.Orders GROUP BY YEAR(orderdate)  Order by ordercount DESC;

SELECT c.contactname,o.custid, YEAR(orderdate) AS year,COUNT(orderid) AS ordercount from Sales.Orders AS o INNER JOIN Sales.Customers AS c ON o.custid = c.custid GROUP BY c.contactname,o.custid,YEAR(orderdate) order by ordercount DESC;

SELECT  YEAR(orderdate) AS year,custid,Count(orderid) AS ordercount from Sales.Orders  GROUP BY YEAR(orderdate),custid order by ordercount DESC;



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






