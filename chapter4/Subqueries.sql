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

