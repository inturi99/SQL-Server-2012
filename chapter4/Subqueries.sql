--Subqueries:
--------------------------------------------------------------
--Self-Contained Subqueries
--1.Self-Contained Scalar Subquery Examples
DECLARE @maxid AS INT =(SELECT MAX(orderid) from Sales.Orders);
SELECT orderid,orderdate,empid,custid from Sales.Orders WHERE orderid = @maxid;

SELECT orderid,orderdate,empid,custid from Sales.Orders WHERE orderid = (SELECT MAX(o.orderid) from Sales.Orders AS o);


SELECT orderid from Sales.Orders where empid =(SELECT E.empid from HR.Employees AS E WHERE E.lastname like N'B%');

SELECT orderid from Sales.Orders where empid =(SELECT E.empid from HR.Employees AS E WHERE E.empid=5);

SELECT orderid from Sales.Orders where empid =(SELECT E.empid from HR.Employees AS E WHERE E.lastname like N'D%');
--ERROR
/*
Subquery returned more than 1 value. This is not permitted when the subquery follows =, !=, <, <= , >, >= or when the subquery is used as an expression.
*/
--2.Self-Contained Multivalued Subquery Examples

SELECT orderid from Sales.Orders where empid IN (SELECT E.empid from HR.Employees AS E WHERE E.lastname like N'D%');

SELECT O.orderid from HR.Employees AS E JOIN Sales.Orders AS O ON E.empid=O.empid WHERE E.lastname like N'D%';

SELECT custid,orderid,orderdate,empid from Sales.Orders where custid IN (SELECT C.custid from Sales.Customers AS C WHERE c.country=N'USA');

SELECT custid,companyname from Sales.Customers where custid  NOT IN (SELECT O.custid from Sales.Orders AS O);


SELECT n from dbo.Nums WHERE n BETWEEN (SELECT MIN(O.orderid) from dbo.Orders AS O) AND (SELECT  MAX(O.Orderid) from dbo.Orders AS O)
AND n NOT IN (SELECT O.orderid from dbo.Orders AS O)
-------------------------------------------------------------
-- Correlated Subqueries
-------------------------------------------------------------
SELECT custid, orderid, orderdate, empid FROM Sales.Orders AS O1
WHERE orderid = (SELECT MAX(O2.orderid) FROM Sales.Orders AS O2 WHERE O2.custid = O1.custid) order by O1.custid ;

SELECT orderid, custid, val, CAST(100. * val / (SELECT SUM(O2.val) FROM Sales.OrderValues AS O2 WHERE O2.custid = O1.custid) AS NUMERIC(5,2)) AS pct
FROM Sales.OrderValues AS O1 ORDER BY custid, orderid;

--The EXISTS Predicate

SELECT C.custid,C.companyname,C.country from Sales.Customers AS C WHERE C.country=N'Spain'
AND EXISTS (SELECT * from Sales.Orders AS O WHERE O.custid=C.custid)  

SELECT C.custid,C.companyname,C.country from Sales.Customers AS C WHERE C.country=N'Spain'
AND NOT EXISTS (SELECT * from Sales.Orders AS O WHERE O.custid=C.custid)

------------------------------------------------------------------
-- Beyond the Fundamentals of Subqueries
------------------------------------------------------------------
-- Returning Previous or Next Values

SELECT orderid, orderdate, empid, custid, (SELECT MAX(O2.orderid) FROM Sales.Orders AS O2 WHERE O2.orderid < O1.orderid) AS prevorderid
FROM Sales.Orders AS O1;

SELECT orderid, orderdate, empid, custid, (SELECT MIN(O2.orderid) FROM Sales.Orders AS O2 WHERE O2.orderid > O1.orderid) AS prevorderid
FROM Sales.Orders AS O1;

-- Using Running Aggregates
SELECT orderyear, qty
FROM Sales.OrderTotalsByYear;

SELECT orderyear, qty, (SELECT SUM(O2.qty) FROM Sales.OrderTotalsByYear AS O2 WHERE O2.orderyear <= O1.orderyear) AS runqty
FROM Sales.OrderTotalsByYear AS O1 ORDER BY orderyear;

--Dealing with Misbehaving Subqueries

SELECT custid, companyname FROM Sales.Customers WHERE custid NOT IN(SELECT O.custid FROM Sales.Orders AS O);
-- Return Result 2 Records

INSERT INTO Sales.Orders (custid, empid, orderdate, requireddate, shippeddate, shipperid,
freight, shipname, shipaddress, shipcity, shipregion, shippostalcode, shipcountry)
VALUES(NULL, 1, '20090212', '20090212',
'20090212', 1, 123.00, N'abc', N'abc', N'abc',
N'abc', N'abc', N'abc');

SELECT custid, companyname FROM Sales.Customers WHERE custid NOT IN(SELECT O.custid FROM Sales.Orders AS O);
-- THIS time return result empty
SELECT custid, companyname FROM Sales.Customers WHERE custid NOT IN(SELECT O.custid FROM Sales.Orders AS O WHERE O.custid IS NOT NULL);
--OR
SELECT custid, companyname FROM Sales.Customers AS C WHERE  NOT EXISTS(SELECT O.custid FROM Sales.Orders AS O WHERE O.custid=C.custid);

DELETE FROM Sales.Orders WHERE custid IS NULL;

SELECT shipper_id,companyname from Sales.MyShippers where shipper_id IN (SELECT O.shipper_id from Sales.Orders AS O where O.custid=43);
-- Invalid column name 'shipper_id'.
SELECT shipper_id,companyname from Sales.MyShippers where shipper_id IN (SELECT O.shipperid from Sales.Orders AS O where O.custid=43);

-------------------
--Exercises
-------------------
--1.
SELECT orderid,orderdate,custid,empid from Sales.Orders where orderdate = (SELECT MAX(O.orderdate)from  Sales.Orders AS O);

--2
SELECT custid, orderid, orderdate, empid FROM Sales.Orders WHERE custid IN (SELECT TOP (1) WITH TIES O.custid
FROM Sales.Orders AS O GROUP BY O.custid ORDER BY COUNT(*) DESC);

--3
SELECT empid, FirstName, lastname FROM HR.Employees WHERE empid NOT IN
(SELECT O.empid FROM Sales.Orders AS O WHERE O.orderdate >= '20080501');

--4
SELECT DISTINCT country FROM Sales.Customers WHERE country NOT IN
(SELECT E.country FROM HR.Employees AS E);

--5
SELECT custid, orderid, orderdate, empid FROM Sales.Orders AS O1
WHERE orderdate = (SELECT MAX(O2.orderdate) FROM Sales.Orders AS O2 WHERE O2.custid = O1.custid)
ORDER BY custid;

--6
SELECT custid, companyname FROM Sales.Customers AS C WHERE EXISTS
(SELECT * FROM Sales.Orders AS O WHERE O.custid = C.custid AND O.orderdate >= '20070101' AND O.orderdate < '20080101')
AND NOT EXISTS
(SELECT * FROM Sales.Orders AS O WHERE O.custid = C.custid AND O.orderdate >= '20080101' AND O.orderdate < '20090101');

--7
SELECT custid, companyname FROM Sales.Customers AS C WHERE EXISTS
(SELECT * FROM Sales.Orders AS O WHERE O.custid = C.custid AND EXISTS
(SELECT * FROM Sales.OrderDetails AS OD WHERE OD.orderid = O.orderid AND OD.ProductID = 12));

-- 8
SELECT custid, ordermonth, qty, (SELECT SUM(O2.qty) FROM Sales.CustOrders AS O2 WHERE O2.custid = O1.custid
AND O2.ordermonth <= O1.ordermonth) AS runqty FROM Sales.CustOrders AS O1 ORDER BY custid, ordermonth;