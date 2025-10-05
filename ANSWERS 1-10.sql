--1 ANSWER
SELECT TOP 5 c.CustomerID,c.Name,so.TotalAmount FROM dbo.Customer c
INNER JOIN dbo.SalesOrder so
ON c.CustomerID = so.CustomerID
ORDER BY so.TotalAmount DESC;

--2 ANSWER
SELECT s.SupplierID,s.Name,COUNT(pd.Quantity) AS Product_count FROM dbo.Supplier s
INNER JOIN dbo.PurchaseOrder po
ON s.SupplierID = po.SupplierID
INNER JOIN dbo.PurchaseOrderDetail pd
ON po.OrderID = pd.OrderID
GROUP BY s.SupplierID,s.Name
HAVING COUNT(pd.Quantity) > 10;

--3 ANSWER
SELECT p.ProductID,p.Name,COUNT(od.Quantity) AS Total_order_quantity FROM dbo.Product p
INNER JOIN dbo.SalesOrderDetail od
ON p.ProductID = od.ProductID
INNER JOIN dbo.ReturnDetail r
ON od.ProductID =r.ProductID
WHERE NOT EXISTS (SELECT r.ProductID FROM dbo.ReturnDetail r)
GROUP BY p.ProductID,p.Name;

--ANSWER 4
SELECT c.CategoryID,c.Name,p.Name,p.Price FROM Category c
INNER JOIN dbo.Product p
ON c.CategoryID = p.CategoryID
WHERE p.Price IN (
SELECT MAX(Price) FROM Product)

--ANSWER 5
SELECT  P.ProductID,so.OrderID,c.Name CustomerName,p.Name ProductName,ct.Name CategoryName,S.Name SupplierName, od.Quantity FROM SalesOrder SO 
INNER JOIN Customer C 
ON SO.CustomerID=C.CustomerID
INNER JOIN SalesOrderDetail od
ON od.OrderID=so.OrderID
INNER JOIN Product P 
ON P.ProductID=od.ProductID
INNER JOIN Category CT 
ON CT.CategoryID=p.CategoryID
INNER JOIN PurchaseOrderDetail POD 
ON POD.ProductID=p.ProductID
INNER JOIN PurchaseOrder PO 
ON PO.OrderID=pod.OrderID
INNER JOIN Supplier S 
ON S.SupplierID=po.SupplierID

--ANSWER 6
SELECT s.ShipmentID,l.Name WareHouseName,e.Name ManagerName,p.Name ProductName,sd.Quantity QuantityShipped,s.TrackingNumber FROM Shipment S
INNER JOIN ShipmentDetail SD 
ON S.ShipmentID=sd.ShipmentID
INNER JOIN Warehouse W 
ON W.WarehouseID=s.WarehouseID
INNER JOIN Location L 
ON L.LocationID=w.LocationID
INNER JOIN Product P 
ON P.ProductID=sd.ProductID
INNER JOIN Employee E 
ON E.EmployeeID=w.ManagerID

--ANSWER 7
SELECT t.CustomerID,t.CustomerName,t.OrderID,t.TotalAmount FROM (
SELECT RANK () OVER ( PARTITION BY c.customerID ORDER BY so.TotalAmount DESC) rank_no  ,c.CustomerID,c.Name CustomerName,so.OrderID,so.TotalAmount
FROM Customer C 
INNER JOIN SalesOrder SO 
ON SO.CustomerID=c.CustomerID
)t where t.rank_no <=3

--ANSWER 8
SELECT P.ProductID, P.Name ProductName, SO.OrderID, SO.OrderDate, SOD.Quantity,
LAG(SOD.Quantity, 1) OVER (PARTITION BY P.ProductID ORDER BY SO.OrderDate) AS PrevQuantity,
LEAD(SOD.Quantity, 1) OVER (PARTITION BY P.ProductID ORDER BY SO.OrderDate) AS NextQuantity
FROM Product P
INNER JOIN SalesOrderDetail SOD ON SOD.ProductID = P.ProductID
INNER JOIN SalesOrder SO ON SO.OrderID = SOD.OrderID
INNER JOIN Customer C ON C.CustomerID = SO.CustomerID

--ANSWER 9
CREATE VIEW vw_CustomerOrderSummary
AS
SELECT c.CustomerID,c.Name CustomerName,
COUNT(o.OrderID) TotalOrder,
SUM(o.TotalAmount) TotalAmountSpent,
MAX(o.OrderDate) LastOrderDate
FROM Customer C
INNER JOIN SalesOrder O ON O.CustomerID = c.CustomerID
GROUP BY c.CustomerID,c.Name;

--ANSWER 10
CREATE PROC sp_GetSupplierSales
@SupplierID INT 
AS
BEGIN

SELECT sum(TotalAmount)TotalSalesAmount FROM SalesOrderDetail so
where exists(
SELECT 1 FROM PurchaseOrderDetail pod
INNER JOIN PurchaseOrder po 
ON po.OrderID=pod.OrderID
where pod.ProductID=so.ProductID
and po.SupplierID=@SupplierID
)
END

exec sp_GetSupplierSales 2