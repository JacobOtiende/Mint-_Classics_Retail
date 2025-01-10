USE mintclassics;

####
SELECT warehouseCode, productLine, COUNT(productLine) AS productLineCount, SUM(quantityInStock) As totalQuantityInStock
FROM products
GROUP BY 1, 2;
###

###
WITH TotalStock AS (
    SELECT productLine,  COUNT(productLine) AS totalProductLineCount, SUM(quantityInStock) AS totalQuantityInStock
    FROM products
    GROUP BY productLine, warehouseCode
)
SELECT P.productLine, P.warehouseCode, W.warehouseName, TS.totalProductLineCount, SUM(OD.quantityOrdered) AS totalQuantityOrdered, 
TS.totalQuantityInStock, ROUND(AVG(DATEDIFF(O.shippedDate, O.orderDate)),0) AS AvgTimespent,
ROUND((AVG(DATEDIFF(O.shippedDate, O.orderDate)) / 3.764 * 100),2) AS pctAvgTimeSpent
FROM orders O 
JOIN orderdetails OD ON O.orderNumber = OD.orderNumber
JOIN products P ON OD.productCode = P.productCode

JOIN warehouses W ON W.warehouseCode = P.warehouseCode
JOIN TotalStock TS ON P.productLine = TS.productLine
GROUP BY P.productLine, P.warehouseCode, W.warehouseName, TS.totalProductLineCount, TS.totalQuantityInStock
ORDER BY P.productLine;
###

WITH TotalStock AS (
    SELECT warehouseCode, SUM(quantityInStock) AS totalQuantityInStock
    FROM products
    GROUP BY warehouseCode
)
SELECT P.warehouseCode, W.warehouseName, W.warehousePctCap, SUM(OD.quantityOrdered) AS totalQuantityOrdered, 
TS.totalQuantityInStock, AVG(DATEDIFF(O.shippedDate, O.orderDate)) AS AvgTimespent,
ROUND((AVG(DATEDIFF(O.shippedDate, O.orderDate)) / 3.764 * 100),2) AS pctAvgTimeSpent
FROM orders O 
JOIN orderdetails OD ON O.orderNumber = OD.orderNumber
JOIN products P ON OD.productCode = P.productCode
JOIN warehouses W ON W.warehouseCode = P.warehouseCode
JOIN TotalStock TS ON P.warehouseCode = TS.warehouseCode
GROUP BY P.warehouseCode, W.warehouseName, TS.totalQuantityInStock
ORDER BY P.warehouseCode;

###
WITH CostOfGoodSold AS 
	(SELECT P.productLine, P.warehouseCode, SUM(OD.quantityOrdered*OD.priceEach) AS COGS FROM orderdetails OD
JOIN products P ON P.productCode = OD.productCode
GROUP BY P.productLine, P.warehouseCode),
AvgInventory AS 
	(SELECT productLine, warehouseCode, AVG(quantityInStock) AS AvgStock FROM products
GROUP BY productLine, warehouseCode)
SELECT CG.productLine, CG.warehouseCode, ROUND((CG.COGS/AI.AvgStock),2) RateOnReturn
FROM CostOfGoodSold CG
JOIN AvgInventory AI ON CG.productLine = AI.productLine AND CG.warehouseCode = AI.warehouseCode
ORDER BY CG.productLine;

###
WITH CostOfGoodSold AS 
	(SELECT P.warehouseCode, SUM(OD.quantityOrdered*OD.priceEach) AS COGS FROM orderdetails OD
JOIN products P ON P.productCode = OD.productCode
GROUP BY P.warehouseCode),
AvgInventory AS 
	(SELECT warehouseCode, AVG(quantityInStock) AS AvgStock FROM products
GROUP BY  warehouseCode)
SELECT  CG.warehouseCode, ROUND((CG.COGS/AI.AvgStock),2) RateOnReturn
FROM CostOfGoodSold CG
JOIN AvgInventory AI ON CG.warehouseCode = AI.warehouseCode
ORDER BY CG.warehouseCode;

###
WITH Orders AS (
    SELECT P.productLine, P.warehouseCode, P.productScale, SUM(OD.quantityOrdered) AS totalOrdered
    FROM orderdetails OD
    JOIN products P ON P.productCode = OD.productCode
    GROUP BY P.productLine, P.warehouseCode, P.productScale
),
Stocks AS (
    SELECT productLine, warehouseCode, productScale, SUM(quantityInStock) AS totalInStock
    FROM products
    GROUP BY productLine, warehouseCode, productScale
)
SELECT O.productLine, O.warehouseCode, O.productScale, O.totalOrdered, S.totalInStock
FROM Orders O
JOIN Stocks S ON O.productLine = S.productLine AND O.warehouseCode = S.warehouseCode AND O.productScale = S.productScale
ORDER BY O.warehouseCode;
###
