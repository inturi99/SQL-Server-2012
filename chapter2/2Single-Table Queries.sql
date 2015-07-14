/*
1.FROM
2.WHERE
3.GROUP BY
4.HAVING
5.SELECT
6.ORDER BY﻿
*/


----------------------------------------------------------------------
-- 1. FROM
----------------------------------------------------------------------
/*
To return All rows from table with no special  manipulation
*/
SELECT orderid, empid, orderdate, freight FROM Sales.Orders;

-------------------------------------------------------------------------
-- 2. where
-------------------------------------------------------------------------
/*
 In the WHERE clause, you specify a predicate or logical expression to filter the rows returned by
the FROM phase.
*/ 
SELECT orderid, empid, orderdate, freight FROM Sales.Orders WHERE custid = 71;
--------------------------------------------------------------------------------------------
--3. GROUP BY
--------------------------------------------------------------------------------------------
/*
The GROUP BY phase allows you to arrange the rows returned by the previous logical query processing
phase in groups
*/
SELECT empid, YEAR(orderdate) AS orderyear FROM Sales.Orders WHERE custid = 71 GROUP BY empid, YEAR(orderdate);
/*
Elements that do not participate in the GROUP BY list are allowed only as inputs to an aggregate
function such as COUNT, SUM, AVG, MIN, or MAX.
*/
SELECT empid,YEAR(orderdate) AS orderyear, SUM(freight) AS totalfreight, COUNT(*) AS numorders FROM Sales.Orders WHERE custid = 71 GROUP BY empid, YEAR(orderdate);

SELECT empid, YEAR(orderdate) AS orderyear, freight FROM Sales.Orders WHERE custid = 71 GROUP BY empid, YEAR(orderdate);
/*
SQL Server produces the following error.
Msg 8120, Level 16, State 1, Line 1
Column 'Sales.Orders.freight' is invalid in the select list because it is not contained in
either an aggregate function or the GROUP BY clause.
*/

/*
The DISTINCT keyword can be used to return only distinct (different) values.
SQL provides the means to guarantee uniqueness in the result of a SELECT statement in the form
of a DISTINCT clause that removes duplicate rows,
*/

SELECT empid,YEAR(orderdate) AS orderyear, COUNT(DISTINCT custid) AS numcusts FROM Sales.Orders GROUP BY empid, YEAR(orderdate);
------------------------------------------------------------------------------------
-- 4.HAVING
------------------------------------------------------------------------------------
SELECT empid, YEAR(orderdate) AS orderyear FROM Sales.Orders WHERE custid = 71 GROUP BY empid, YEAR(orderdate)
HAVING COUNT(*) > 1;
-------------------------------------------------------------------------------------
--5.SELECT
-------------------------------------------------------------------------------------
/*
The SELECT clause is where you specify the attributes (columns) that you want to return in the result
table of the query.
*/
SELECT empid,orderid  FROM Sales.Orders;

 
select empid,YEAR(orderdate) AS orderyear,COUNT(*) as Numorders from sales.Orders where custid=71 GROUP BY empid,YEAR(orderdate) HAVING count(*) > 1


SELECT orderid, YEAR(orderdate) AS orderyear
FROM Sales.Orders
WHERE orderyear > 2006;

SELECT orderid, YEAR(orderdate) AS orderyear
FROM Sales.Orders
WHERE YEAR(orderdate) > 2006;

SELECT empid, YEAR(orderdate) AS orderyear, COUNT(*) AS numorders
FROM Sales.Orders
WHERE custid = 71
GROUP BY empid, YEAR(orderdate)
HAVING numorders > 1;


SELECT DISTINCT empid, YEAR(orderdate) AS orderyear
FROM Sales.Orders
WHERE custid = 71;

SELECT orderid,
YEAR(orderdate) AS orderyear,
orderyear + 1 AS nextyear
FROM Sales.Orders;

SELECT orderid,
YEAR(orderdate) AS orderyear,
YEAR(orderdate) + 1 AS nextyear
FROM Sales.Orders;

---------------------------------------------------------------------------------------
--6.ORDER BY﻿:
---------------------------------------------------------------------------------------
/*
The ORDER BY clause allows you to sort the rows in the output for presentation purposes. In terms of
logical query processing, ORDER BY is the very last clause to be processed.
*/


select empid,YEAR(orderdate) AS orderyear,COUNT(*) as Numorders from sales.Orders where custid=71 GROUP BY empid,YEAR(orderdate) HAVING count(*) > 1
ORDER BY  empid,orderyear
------------------------------------------------------------------------------------------------------
-- The TOP and OFFSET-FETCH Filters
------------------------------------------------------------------------------------------------------
--1 The TOP

select TOP(5)orderid,orderdate,custid,empid from SAles.Orders ORDER BY orderdate DESC,orderid DESC

/*
SQL Server first returned
the TOP (5) rows based on orderdate DESC ordering, and also all other rows from the table that had
the same orderdate value as in the last of the five rows that was accessed.
*/
select TOP(5) WITH TIES orderid,orderdate,custid,empid from Sales.Orders ORDER BY orderdate DESC

--2. OFFSET-FETCH Filters

select orderid,orderdate,custid,empid from Sales.Orders ORDER BY orderdate,orderid
OFFSET 820 ROWS FETCH NEXT 25 ROWS ONLY
/*
the OFFSET clause skips the first 820 rows, and the FETCH clause filters the next 25 rows only.
*/
--------------------------------------------------------------------------------------------------
-- A Quick Look at Window Functions:
--------------------------------------------------------------------------------------------------

select orderid,custid,val,ROW_NUMBER() OVER(PARTITION By custid ORDER BY val) AS rownum from Sales.OrderValues ORDER BY custid,val;

--------------------------------------------------------------------------------------------------
-- Predicates and Operators
--------------------------------------------------------------------------------------------------
SELECT orderid, empid, orderdate FROM Sales.Orders WHERE orderid IN(10248, 10249, 10250);

SELECT orderid, empid, orderdate FROM Sales.Orders WHERE orderid BETWEEN 10300 AND 10310;

SELECT empid, firstname, lastname FROM HR.Employees WHERE lastname LIKE N'D%';