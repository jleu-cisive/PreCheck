-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[ReportsWithNoMVR] 
@clno int,
@StartDate DateTime = '01/01/2011' 

AS
BEGIN
	Select APNO, apdate into #temp1 from APPL where clno = @clno and apdate between @StartDate and getdate()

	select apno, apdate from #temp1 where apno not in(select apno from DL)

	drop table #temp1
END
