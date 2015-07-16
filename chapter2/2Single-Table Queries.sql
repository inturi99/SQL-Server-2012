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

SELECT orderid,empid,orderdate from Sales.Orders WHERE orderdate >= '20080101';

SELECT orderid,empid,orderdate from Sales.Orders WHERE orderdate >= '20080101'  AND empid in (1,3,5);

SELECT orderid,productid,qty,qty * unitprice * (1-discount) AS val from Sales.OrderDetails;

SELECT orderid,custid,empid,orderdate from Sales.Orders where custid=1 AND empid in (1,3,5) OR custid= 85 AND empid IN (2,4,6);
--Parentheses have the highest precedence, so they give you full control.
SELECT orderid,custid,empid,orderdate from Sales.Orders where (custid=1 AND empid in (1,3,5) OR custid= 85 AND empid IN (2,4,6));

------------------------------------------------------------------------------------------------------
-- CASE Expressions
------------------------------------------------------------------------------------------------------
/*
A CASE expression is a scalar expression that returns a value based on conditional logic.
*/
SELECT productid,productname,categoryid,
CASE categoryid
WHEN 1 THEN 'Beverages'
WHEN 2 THEN 'Condiments'
WHEN 3 THEN 'Confections'
WHEN 4 THEN 'Dairy Products'
WHEN 5 THEN 'Grains/Cereals'
WHEN 6 THEN 'Meat/Poultry'
WHEN 7 THEN 'Produce'
WHEN 8 THEN 'Seafood'
ELSE 'Unknown Category'
END AS categoryname
 from Production.Products


 SELECT orderid, custid, val,
CASE
WHEN val < 1000.00 THEN 'Less than 1000'
WHEN val BETWEEN 1000.00 AND 3000.00 THEN 'Between 1000 and 3000'
WHEN val > 3000.00 THEN 'More than 3000'
ELSE 'Unknown'
END AS valuecategory
FROM Sales.OrderValues;

---------------------------------------------------------------------------------
-- NULL Marks
---------------------------------------------------------------------------------
SELECT custid, country, region, city FROM Sales.Customers WHERE region = N'WA';

SELECT custid, country, region, city FROM Sales.Customers WHERE region <> N'WA';

SELECT custid, country, region, city FROM Sales.Customers WHERE region = NULL;

SELECT custid, country, region, city FROM Sales.Customers WHERE region IS NULL;

SELECT custid, country, region, city FROM Sales.Customers WHERE region <> N'WA' OR region IS NULL;

---------------------------------------------------------------------------------------------
-- Working with Character Data
---------------------------------------------------------------------------------------------
--case insensitive
SELECT empid, firstname, lastname FROM HR.Employees WHERE lastname = N'davis';
--case sensitive
SELECT empid, firstname, lastname FROM HR.Employees WHERE lastname COLLATE Latin1_General_CS_AS = N'davis';

---------------------------------------------------------------------------------------------
-- Operators and Functions
---------------------------------------------------------------------------------------------

SELECT empid, firstname + N' ' + lastname AS fullname FROM HR.Employees;
-- ‘a’, +  NULL, + ‘b’  returns the string ‘NULL’.
SELECT custid, country, region, city, country + N',' + region + N',' + city AS location FROM Sales.Customers;
--COALESCE(‘a’, NULL, ‘b’) returns the string ‘ab’.
SELECT custid, country, region, city, country + COALESCE( N',' + region, N'') + N',' + city AS location FROM Sales.Customers;
--CONCAT(‘a’, NULL, ‘b’) returns the string ‘ab’.
SELECT custid, country, region, city, CONCAT(country, N',' + region, N',' + city) AS location FROM Sales.Customers;
--The SUBSTRING Function
SELECT SUBSTRING('abcde', 1, 3);
--The LEFT and RIGHT Functions
SELECT LEFT('abcde', 3);
SELECT RIGHT('abcde', 3);

--The LEN and DATALENGTH Functions
SELECT LEN(N'abcde'); --5
--Each character requires two bytes of storage (in most cases, at least)
SELECT DATALENGTH(N'abcde'); --10

--CHARINDEX(substring, string[, start_pos])
SELECT CHARINDEX(' ','Itzik Ben-Gan');
--PATINDEX(pattern, string)
SELECT PATINDEX('%[0-9]%', 'abcd123efgh');
--REPLACE(string, substring1, substring2)
SELECT REPLACE('1-a 2-b', '-', ':');

SELECT empid, lastname, LEN(lastname) - LEN(REPLACE(lastname, 'e', '')) AS numoccur FROM HR.Employees;
--REPLICATE(string, n)
SELECT REPLICATE('abc', 3); --abcabcabc
--CAST:The value to convert to another datatype.
SELECT supplierid, RIGHT(REPLICATE('0', 9) + CAST(supplierid AS VARCHAR(10)), 10) AS strsupplierid FROM Production.Suppliers;
--STUFF(string, pos, delete_length, insertstring)
SELECT STUFF('xyz', 2, 1, 'abc'); --xabcz

SELECT UPPER('Itzik Ben-Gan');
SELECT LOWER('Itzik Ben-Gan');

SELECT RTRIM(LTRIM(' abc '));
-- FORMAT(input , format_string, culture)
SELECT FORMAT(20150506, '0000-00-00');

--The LIKE Predicate
SELECT empid, lastname FROM HR.Employees WHERE lastname LIKE N'D%';

SELECT empid, lastname FROM HR.Employees WHERE lastname LIKE N'_e%';
--first character in the last name is A, B, or C.
SELECT empid, lastname FROM HR.Employees WHERE lastname LIKE N'[ABC]%';

SELECT empid, lastname FROM HR.Employees WHERE lastname LIKE N'[A-E]%';

SELECT empid, lastname FROM HR.Employees WHERE lastname LIKE N'[^A-E]%';

-----------------------------------------------------------------------------
-- Working with Date and Time Data
-----------------------------------------------------------------------------

SELECT orderid, custid, empid, orderdate FROM Sales.Orders WHERE orderdate = '20070212';

sp_help 'Sales.Orders';

SELECT orderid, custid, empid, orderdate FROM Sales.Orders WHERE orderdate =CAST('20070212' AS datetime);

SELECT CONVERT(DATETIME, '07/15/2015', 101);

SELECT CONVERT(DATETIME, '15/07/2015', 103);

SELECT PARSE('07/15/2015' AS DateTime using 'en-US');

SELECT PARSE('15/07/2015' AS DateTime using 'en-GB');

--Working with Date and Time Separately

SELECT orderid,custid,empid,orderdate from Sales.Orders where orderdate='20070212';


SELECT orderid,custid,empid,orderdate from Sales.Orders where orderdate >='20070212' AND orderdate < '20070928';

SELECT CAST('12:30:15.123' AS DATETIME); -- 1900-01-01 12:30:15.123

--Filtering Date Ranges

SELECT orderid,custid,empid,orderdate from Sales.Orders where YEAR(orderdate) =2007

SELECT orderid,custid,empid,orderdate from Sales.Orders where orderdate >='20070212' AND orderdate < '20080101';


SELECT orderid,custid,empid,orderdate from Sales.Orders where YEAR(orderdate) =2007 AND MONTH(orderdate) =02;

-- Date and Time Functions

SELECT GETDATE() AS [GETDATE],
       CURRENT_TIMESTAMP AS [CURRENT_TIMESTAMP],
	   GETUTCDATE() AS [GETUTCDATE],
	   SYSDATETIME() AS [SYSDATETIME],
	   SYSUTCDATETIME() AS [SYSUTCDATE],
	   SYSDATETIMEOFFSET() AS [SYSDATETIMEOFFSET];

SELECT CAST(SYSDATETIME() AS date) AS [Current_Date],
       CAST(SYSDATETIME() AS time) AS [Current_time]

SELECT CAST('20090212' AS DATE); -- 2009-02-12

SELECT CAST(SYSDATETIME() AS DATE);

SELECT CAST(SYSDATETIME() AS TIME);

--CHAR(8) by using style 112 (‘YYYYMMDD’)
SELECT CONVERT(CHAR(8),CURRENT_TIMESTAMP,112) --20150716	 

SELECT CAST(CONVERT(CHAR(8),CURRENT_TIMESTAMP,112) AS DATETIME); -- 2015-07-16 00:00:00.000

SELECT CONVERT(CHAR(12),CURRENT_TIMESTAMP,114)  --11:36:51:423

SELECT CAST(CONVERT(CHAR(12),CURRENT_TIMESTAMP,114) AS DATETIME) -- 1900-01-01 11:53:10.540

SELECT SWITCHOFFSET(SYSDATETIMEOFFSET(),'-05:00')     -- 2015-07-16 01:27:05.5959159 -05:00

SELECT SWITCHOFFSET(SYSDATETIMEOFFSET(), '+00:00');   --2015-07-16 06:30:16.7462545 +00:00

SELECT DATEADD(year,1,'20090212')

SELECT DATEDIFF(day, '20080212', '20090212');

SELECT DATEADD( day, DATEDIFF(day, '20010101', CURRENT_TIMESTAMP), '20010101');
--First Day of  a Month
SELECT DATEADD( month, DATEDIFF(month, '20010101', CURRENT_TIMESTAMP), '20010101');
-- Last Day of a Month
SELECT DATEADD( month, DATEDIFF(month, '19991231', CURRENT_TIMESTAMP), '19991231');

SELECT DATEPART(month,'20090812')

SELECT DAY('20090822') AS theday,
       MONTH('20090822') As themonth,
	   YEAR('20090822') AS theyear

SELECT DATENAME(month,'20090822')

SELECT DATENAME(year,'20090822')

SELECT ISDATE('20090822') --  return 1

SELECT ISDATE('20090231') --  return 0

SELECT
DATEFROMPARTS(2012, 02, 12),--2012-02-12
DATETIME2FROMPARTS(2012, 02, 12, 13, 30, 5, 1, 7), --2012-02-12 13:30:05.0000001
DATETIMEFROMPARTS(2012, 02, 12, 13, 30, 5, 997), --2012-02-12 13:30:05.997
DATETIMEOFFSETFROMPARTS(2012, 02, 12, 13, 30, 5, 1, -8, 0, 7),--2012-02-12 13:30:05.0000001 -08:00
SMALLDATETIMEFROMPARTS(2012, 02, 12, 13, 30),--2012-02-12 13:30:00
TIMEFROMPARTS(13, 30, 5, 1, 7); --13:30:05.0000001
-- end-of-month date
SELECT EOMONTH(SYSDATETIME()); --2015-07-31

SELECT orderid, orderdate, custid, empid FROM Sales.Orders WHERE orderdate = EOMONTH(orderdate);

-------------------------------------------------------------------------------------
-- Querying Metadata
-------------------------------------------------------------------------------------

SELECT SCHEMA_NAME(schema_id) AS table_schema_name,name AS table_name from sys.tables

SELECT name AS column_name, TYPE_NAME(system_type_id) AS column_type, max_length, collation_name, is_nullable
FROM sys.columns WHERE object_id = OBJECT_ID(N'Sales.Orders');

SELECT TABLE_SCHEMA, TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = N'BASE TABLE';

--System Stored Procedures and Functions

EXEC sys.sp_tables;

EXEC sys.sp_help @objname = N'Sales.Orders';

EXEC sys.sp_columns
@table_name = N'Orders',
@table_owner = N'Sales';

EXEC sys.sp_helpconstraint @objname = N'Sales.Orders';


SELECT
SERVERPROPERTY('ProductLevel'); --RTM

