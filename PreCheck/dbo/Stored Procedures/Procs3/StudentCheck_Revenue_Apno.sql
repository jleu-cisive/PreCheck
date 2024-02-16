-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- Modified by Radhika Dereddy on 07/11/2019 - removed the incorrect package rate logic 
-- =============================================
CREATE PROCEDURE [dbo].[StudentCheck_Revenue_Apno]
	-- Add the parameters for the stored procedure here
	@StartDate datetime,
	@EndDate datetime,
	@SchoolWillPay bit = 0,
	@CLNO int = null

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON;

    -- Insert statements for procedure here

SELECT A.Apdate, a.apno as APNO, a.state, c.TaxRate, c.clno as CLNO,c.name as ClietnName,cp.name as ProgramName, ISNUll(cps.Rate, pm.DefaultPrice) as PackageRate,
pm.packagedesc as PackageName, p.Amount  as 'SubTotal', p.TaxAmount as 'Sales_tax', (p.Amount + p.TaxAmount) as 'Total', c.Billcycle
FROM appl a  
INNER JOIN client c on a.clno = c.clno
INNER JOIN clientprogram cp on cp.clientprogramid = a.clientprogramid
LEFT JOIN clientpackages cps on cps.packageid = a.packageid and cps.clno = c.clno
LEFT JOIN packagemain pm on pm.packageid = cps.packageid
INNER JOIN PrecheckServices..Payment p on a.Apno = p.appno
WHERE a.Apdate >= @StartDate AND a.Apdate < DateAdd(d,1,@EndDate)
AND c.SchoolWillPay = @SchoolWillPay
ORDER BY a.Apdate,c.clno,cp.name


--select * from PrecheckServices..Payment (nolock) where appno =2977466
--case when a.packageid is null then
--(select top 1 rate from clientpackages  with (nolock) where clno = c.clno) else cps.rate end as PackageRate ,
--ii.invdate >= @StartDate and ii.invdate < @EndDate --and c.clno = @CLNO

END
