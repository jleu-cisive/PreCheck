CREATE PROCEDURE [dbo].[IntegrationCrimVendorUsage] --'10/01/2019', '10/31/2019'
@fromDate DateTime,  
@toDate DateTime
AS
--DECLARE @vendor varchar(100)
--DECLARE @fromDate DateTime
--DECLARE @toDate DateTime
--SET @vendor = null --'Baxter Research'
--SET @fromDate = '10/01/2019'
--SET @toDate = '10/31/2019'

DECLARE @VendorUsage TABLE
(
  VendorName varchar(100) 
)

Insert into @VendorUsage
select r.R_Name  from crim(nolock)  c join Iris_Researchers(nolock) r on c.vendorid = r.R_id
WHERE r.R_id in
(250,
86396,
4133336,
20,
5679614,
79,
513806,
951788,
1278446,
1320350,
1585529,
1736838,
1736839,
2602325,
883824
) and 
Crimenteredtime > @fromDate and  Crimenteredtime < @toDate and c.vendorid is not null


select A.[Vendor Name],  A.[Number Of Record(s)], A.[Percentage] From (
select VendorName AS [Vendor Name], count(*) AS [Number Of Record(s)], 
count(*)*100/sum(count(*)) over () AS [Percentage], 0 AS [Order] from
@VendorUsage group by VendorName 
Union 
select 'TOTAL'AS [Vendor Name], count(*)  AS [Number Of Record(s)], 100 AS [Percentage], 1 AS [Order]
from @VendorUsage
)A

