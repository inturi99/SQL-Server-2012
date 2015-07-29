--Set Operators
---------------------------------------------
--1. The UNION Operator
--The UNION ALL Multiset Operator

SELECT country,region,city FROM Hr.Employees
UNION ALL
SELECT country,region,city FROM Sales.Customers

-- m+n
--The UNION Distinct Set Operator
SELECT country,region,city FROM Hr.Employees
UNION
SELECT country,region,city FROM Sales.Customers
---------------------------
--2.The INTERSECT Operator
---------------------------

--The INTERSECT Distinct Set Operator
SELECT country,region,city FROM Hr.Employees 
INTERSECT
SELECT country,region,city FROM Sales.Customers 

--The INTERSECT ALL Multiset Operator
-- NOT AT COVER IN THIS TOPIC ON THIS Chapter

------------------------
--3.The EXCEPT Operator
------------------------
--The EXCEPT Distinct Set Operator

SELECT country,region,city FROM Hr.Employees 
EXCEPT
SELECT country,region,city FROM Sales.Customers 

SELECT country,region,city FROM Sales.Customers
EXCEPT
SELECT country,region,city from Hr.Employees


-- Precedence
SELECT country, region, city FROM Production.Suppliers
EXCEPT
SELECT country, region, city FROM HR.Employees
INTERSECT
SELECT country, region, city FROM Sales.Customers;
 

 (SELECT country, region, city FROM Production.Suppliers
EXCEPT
SELECT country, region, city FROM HR.Employees)
INTERSECT
SELECT country, region, city FROM Sales.Customers;

-- Circumventing Unsupported Logical Phases
SELECT country, COUNT(*) AS numlocations
FROM (SELECT country, region, city FROM HR.Employees
UNION
SELECT country, region, city FROM Sales.Customers) AS U
GROUP BY country;
-------------------------

SELECT empid, orderid, orderdate
FROM (SELECT TOP (2) empid, orderid, orderdate
FROM Sales.Orders
WHERE empid = 3
ORDER BY orderdate DESC, orderid DESC) AS D1
UNION ALL
SELECT empid, orderid, orderdate
FROM (SELECT TOP (2) empid, orderid, orderdate
FROM Sales.Orders
WHERE empid = 5
ORDER BY orderdate DESC, orderid DESC) AS D2;
---------------------------- OR
SELECT empid, orderid, orderdate
FROM (SELECT empid, orderid, orderdate
FROM Sales.Orders
WHERE empid = 3
ORDER BY orderdate DESC, orderid DESC
OFFSET 0 ROWS FETCH FIRST 2 ROWS ONLY) AS D1
UNION ALL
SELECT empid, orderid, orderdate
FROM (SELECT empid, orderid, orderdate
FROM Sales.Orders
WHERE empid = 5
ORDER BY orderdate DESC, orderid DESC
OFFSET 0 ROWS FETCH FIRST 2 ROWS ONLY) AS D2;


--Exercises
--1
SELECT 1 AS n
UNION ALL SELECT 2
UNION ALL SELECT 3
UNION ALL SELECT 4
UNION ALL SELECT 5
UNION ALL SELECT 6
UNION ALL SELECT 7
UNION ALL SELECT 8
UNION ALL SELECT 9
UNION ALL SELECT 10;

--2
SELECT custid, empid
FROM Sales.Orders
WHERE orderdate >= '20080101' AND orderdate < '20080201'
EXCEPT
SELECT custid, empid
FROM Sales.Orders
WHERE orderdate >= '20080201' AND orderdate < '20080301';

--3

SELECT custid, empid
FROM Sales.Orders
WHERE orderdate >= '20080101' AND orderdate < '20080201'
INTERSECT
SELECT custid, empid
FROM Sales.Orders
WHERE orderdate >= '20080201' AND orderdate < '20080301';

--4
SELECT custid, empid
FROM Sales.Orders
WHERE orderdate >= '20080101' AND orderdate < '20080201'
INTERSECT
SELECT custid, empid
FROM Sales.Orders
WHERE orderdate >= '20080201' AND orderdate < '20080301'
EXCEPT
SELECT custid, empid
FROM Sales.Orders
WHERE orderdate >= '20070101' AND orderdate < '20080101';
------
(SELECT custid, empid
FROM Sales.Orders
WHERE orderdate >= '20080101' AND orderdate < '20080201'
INTERSECT
SELECT custid, empid
FROM Sales.Orders
WHERE orderdate >= '20080201' AND orderdate < '20080301')
EXCEPT
SELECT custid, empid
FROM Sales.Orders
WHERE orderdate >= '20070101' AND orderdate < '20080101';

--5
SELECT country, region, city
FROM (SELECT 1 AS sortcol, country, region, city
FROM HR.Employees
UNION ALL
SELECT 2, country, region, city
FROM Production.Suppliers) AS D
ORDER BY sortcol, country, region, city;