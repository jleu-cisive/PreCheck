-- =============================================
-- Author:		Vairavan A 
-- Create date: 03/13/2023
-- Description:	Qreport that shows County Count by Date Range Summary Report
-- execution: EXEC County_Count_DateRange_Summary_Report '03/07/2023','03/07/2023'
-- =============================================
Create PROCEDURE dbo.County_Count_DateRange_Summary_Report
	@StartDate Date,
	@EndDate Date
AS
BEGIN
	
Drop table if exists #tmp

Select @StartDate as FromDate, @EndDate as ToDate,a.CNTY_NO,b.A_County,b.State,Count(0) As Cnt into #tmp
from crim a  with(NOLOCK) 
	 inner join 
	 TblCounties b with(nolock)
on(a.CNTY_NO = b.CNTY_NO)
where a.ishidden = 0
and   a.crimenteredtime between @StartDate and DateAdd(d,1,@EndDate) 
group by a.CNTY_NO,b.A_County,b.State

Declare @CriminalSearchescount int 

Select @CriminalSearchescount = sum(cnt) from #tmp

Select FromDate as [From Date],ToDate as [To Date],@CriminalSearchescount as [Criminal Searches count],
	   CNTY_NO   as [County #],
	   A_County  as [County Name],
	   State,
	   Cnt as [Count]
from #tmp

END




