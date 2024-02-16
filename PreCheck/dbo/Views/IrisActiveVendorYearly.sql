CREATE VIEW dbo.IrisActiveVendorYearly
AS
SELECT DISTINCT TOP 100 PERCENT vendorid
FROM         dbo.Crim
WHERE     (Crimenteredtime BETWEEN '9/24/2003' AND GETDATE())
ORDER BY vendorid
