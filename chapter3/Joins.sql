--JOINS
-------------------------------------
-- Cross Joins
/*
The SQL CROSS JOIN produces a result set which is the number of rows in the first table multiplied by the number of rows in the second table
*/
SELECT C.custid, E.empid FROM Sales.Customers AS C CROSS JOIN HR.Employees AS E;

SELECT C.custid, E.empid FROM Sales.Customers AS C, HR.Employees AS E;

-- Self Cross Joins
SELECT E1.empid, E1.firstname, E1.lastname, E2.empid, E2.firstname, E2.lastname
FROM HR.Employees AS E1 CROSS JOIN HR.Employees AS E2;

IF OBJECT_ID('dbo.Digits', 'U') IS NOT NULL DROP TABLE dbo.Digits;
CREATE TABLE dbo.Digits(digit INT NOT NULL PRIMARY KEY);
INSERT INTO dbo.Digits(digit)
VALUES (0),(1),(2),(3),(4),(5),(6),(7),(8),(9);
SELECT digit FROM dbo.Digits;

select D3.digit * 100 + D2.digit * 10 +D1.digit + 1 AS n from dbo.Digits AS D1 
   CROSS JOIN dbo.Digits AS D2
   CROSS JOIN dbo.Digits AS D3 ORDER by n;

---------------------------------------------------------------------------------
-- Inner Joins
---------------------------------------------------------------------------------
select * from Hr.Employees
SELECT * from Sales.Orders

SELECT E.empid,E.firstname,E.lastname,o.orderid FROM HR.Employees AS E JOIN Sales.Orders AS O ON E.empid=O.empid ORDER BY O.orderid;
--OR
SELECT E.empid,E.firstname,E.lastname,o.orderid FROM HR.Employees AS E,Sales.Orders AS O WHERE E.empid=O.empid ORDER BY O.orderid;


-- Composite Joins
SELECT OD.orderid,OD.productid,OD.qty,ODA.dt,ODA.loginname,ODA.oldval,ODA.newval from Sales.OrderDetails OD JOIN Sales.OrderDetailsAudit AS ODA ON OD.orderid=ODA.orderid AND OD.productid=ODA.productid
WHERE ODA.columnname=N'qty'


-- Non-Equi Join
SELECT E1.empid,E1.firstname,E1.lastname,E2.empid,E2.firstname,E2.lastname from HR.Employees AS E1 JOIN HR.Employees AS E2 ON E1.empid < E2.empid

-- Multi-Join Queries
SELECT C.custid, C.companyname, O.orderid,OD.productid, OD.qty FROM Sales.Customers AS C
JOIN Sales.Orders AS O ON C.custid = O.custid
JOIN Sales.OrderDetails AS OD ON O.orderid = OD.orderid;

--Outer Joins
--1 .INNER OUTER JOIN
SELECT C.custid, C.companyname, O.orderid FROM Sales.Customers AS C
INNER  JOIN Sales.Orders AS O ON C.custid = O.custid;

--2 .LEFT OUTER JOIN
SELECT C.custid, C.companyname, O.orderid FROM Sales.Customers AS C
LEFT OUTER JOIN Sales.Orders AS O ON C.custid = O.custid;
--3 .RIGHT OUTER JOIN
SELECT C.custid, C.companyname, O.orderid FROM Sales.Customers AS C
RIGHT OUTER JOIN Sales.Orders AS O ON C.custid = O.custid;

--4 .FULL OUTER JOIN
SELECT C.custid, C.companyname, O.orderid FROM Sales.Customers AS C
FULL JOIN Sales.Orders AS O ON C.custid = O.custid;

SELECT C.custid, C.companyname FROM Sales.Customers AS C
LEFT OUTER JOIN Sales.Orders AS O ON C.custid = O.custid WHERE O.orderid IS NULL;

SELECT DATEADD(day, n-1, '20060101') AS orderdate FROM dbo.Nums
WHERE n <= DATEDIFF(day, '20060101', '20081231') + 1 ORDER BY orderdate;

SELECT DATEADD(day, Nums.n - 1, '20060101') AS orderdate,O.orderid, O.custid, O.empid FROM dbo.Nums
LEFT OUTER JOIN Sales.Orders AS O ON DATEADD(day, Nums.n - 1, '20060101') = O.orderdate
WHERE Nums.n <= DATEDIFF(day, '20060101', '20081231') + 1 ORDER BY orderdate;

SELECT C.custid, C.companyname, O.orderid, O.orderdate FROM Sales.Customers AS C LEFT OUTER JOIN Sales.Orders AS O
ON C.custid = O.custid WHERE O.orderdate >= '20070101';

SELECT C.custid, O.orderid, OD.productid, OD.qty FROM Sales.Customers AS C
LEFT OUTER JOIN Sales.Orders AS O ON C.custid = O.custid
JOIN Sales.OrderDetails AS OD ON O.orderid = OD.orderid;

SELECT C.custid, O.orderid, OD.productid, OD.qty FROM Sales.Customers AS C
LEFT OUTER JOIN Sales.Orders AS O ON C.custid = O.custid
LEFT OUTER JOIN Sales.OrderDetails AS OD ON O.orderid = OD.orderid;

SELECT C.custid, O.orderid, OD.productid, OD.qty FROM Sales.Orders AS O
JOIN Sales.OrderDetails AS OD ON O.orderid = OD.orderid
RIGHT OUTER JOIN Sales.Customers AS C ON O.custid = C.custid;

SELECT C.custid, O.orderid, OD.productid, OD.qty FROM Sales.Customers AS C
LEFT OUTER JOIN (Sales.Orders AS O
JOIN Sales.OrderDetails AS OD ON O.orderid = OD.orderid) ON C.custid = O.custid;

SELECT C.custid, COUNT(*) AS numorders FROM Sales.Customers AS C LEFT OUTER JOIN Sales.Orders AS O
ON C.custid = O.custid GROUP BY C.custid;


-------------------------------------------
-- Exercises
-------------------------------------------
--1
SELECT E.empid, E.firstname, E.lastname, N.n FROM HR.Employees AS E
CROSS JOIN dbo.Nums AS N WHERE N.n <= 5 ORDER BY n, empid;

--2
SELECT C.custid, COUNT(DISTINCT O.orderid) AS numorders, SUM(OD.qty) AS totalqty
FROM Sales.Customers AS C JOIN Sales.Orders AS O ON O.custid = C.custid
JOIN Sales.OrderDetails AS OD ON OD.orderid = O.orderid WHERE C.country = N'USA' GROUP BY C.custid;

--3
SELECT C.custid, C.companyname, O.orderid, O.orderdate FROM Sales.Customers AS C
LEFT OUTER JOIN Sales.Orders AS O ON O.custid = C.custid;

--4
SELECT C.custid, C.companyname FROM Sales.Customers AS C LEFT OUTER JOIN Sales.Orders AS O
ON O.custid = C.custid WHERE O.orderid IS NULL;

--5
SELECT C.custid, C.companyname, O.orderid, O.orderdate FROM Sales.Customers AS C
JOIN Sales.Orders AS O ON O.custid = C.custid WHERE O.orderdate = '20070212';

--6
SELECT C.custid, C.companyname, O.orderid, O.orderdate FROM Sales.Customers AS C
LEFT OUTER JOIN Sales.Orders AS O ON O.custid = C.custid AND O.orderdate = '20070212';

--7
SELECT DISTINCT C.custid, C.companyname,
CASE WHEN O.orderid IS NOT NULL THEN 'Yes' ELSE 'No' END AS [HasOrderOn20070212] FROM Sales.Customers AS C
LEFT OUTER JOIN Sales.Orders AS O ON O.custid = C.custid AND O.orderdate = '20070212';


