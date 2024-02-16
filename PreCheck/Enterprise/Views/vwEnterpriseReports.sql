CREATE VIEW Enterprise.vwEnterpriseReports
AS
SELECT 
	a.APNO,
	o.OrderId,
	o.DASourceId
FROM dbo.Appl a 
INNER JOIN Enterprise..[Order] o 
ON a.APNO=o.OrderNumber