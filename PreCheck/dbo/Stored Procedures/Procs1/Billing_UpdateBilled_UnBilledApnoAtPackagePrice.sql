-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 01/01/2020
-- Description:	Billed the apno's at the package level
-- =============================================
CREATE PROCEDURE [dbo].[Billing_UpdateBilled_UnBilledApnoAtPackagePrice]
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

DROP TABLE IF EXISTS #apnosToRemove
DROP TABLE IF EXISTS #invDet
DROP TABLE IF EXISTS #tempAPNOs
DROP TABLE IF EXISTS #tempResetBilledAPNOs

SELECT * INTO #invDet
FROM Precheck.dbo.InvDetail i1 with (nolock)
WHERE year(CreateDate)>= 2020 
AND month(CreateDate) >= 1
AND Billed = 1 
AND NOT EXISTS (SELECT * FROM Precheck.dbo.InvDetail i2 WITH (NOLOCK) WHERE i1.APNO = i2.APNO and i2.Type = 0 ) -- type =0 is package price

select distinct APNO into #apnosToRemove 
 from #invDet i1 where exists(select * from #invDet i2 where i1.APNO = i2.APNO and i2.Type <> 1 ) 

--select * from #apnosToRemove

DELETE FROM #invDet where APNO in (select APNO from #apnosToRemove)

SELECT DISTINCT APNO into #tempAPNOs from Precheck.dbo.InvDetail where APNO in (select distinct APNO from #invDet) and Billed = 1

SELECT x.* INTO #tempResetBilledAPNOs from #tempAPNOs x  (nolock)
INNER JOIN Precheck.dbo.appl a (nolock) on x.APNO = a.APNO
WHERE a.CLNO not in (3468,3668,3079,2135)

Update Precheck.dbo.Appl set Billed =0 where APNO in (select APNO from #tempResetBilledAPNOs)

select APNO from #tempResetBilledAPNOs


END
