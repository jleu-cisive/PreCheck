-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 02/14/2019
-- Description:	INOVA Previous Week Closed Report [date], to include all reports closed during the previous week 
-- =============================================
CREATE PROCEDURE [dbo].[INOVA_Previous_Week_Closed_Report]
	-- Add the parameters for the stored procedure here

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
DECLARE @StartDate datetime, @EndDate Datetime

SELECT @StartDate = DATEADD(wk, DATEDIFF(wk, 6, GETDATE()), 0)   --start of last week
SELECT @EndDate = DATEADD(wk, DATEDIFF(wk, 6, GETDATE()), 6)    --end of last week

CREATE TABLE #tmpWeeklyClosedReports
(
	[ReportNumber] [int] NOT NULL,
	[ClientID] [int] NOT NULL,
	[ClientName] [varchar](100) NOT NULL,
	[ReportCreatedDate] [datetime] NULL,
	[OriginalClosedDate] [datetime] NULL,
	[Turnaround] [decimal](10,2) NULL
)

INSERT INTO #tmpWeeklyClosedReports
SELECT a.Apno as [ReportNumber], a.CLNO as [ClientID], C.Name as [ClientName], A.ApDate as [ReportCreatedDate], 
		A.OrigCompDate as [OriginalClosedDate],
		[dbo].[ElapsedBusinessDays_2](A.ApDate, A.OrigCompDate) [Turnaround]
FROM Appl A (NOLOCK)
INNER JOIN CLIENT C (NOLOCK) ON A.CLNO = C.CLNO
WHERE A.OrigCompDate Between @StartDate and @EndDate
AND A.apstatus = 'F'
AND C.CLNO in (1932,1934,1935,1936,1937,3696,8789)
ORDER BY APNO



SELECT [ReportNumber], [ClientID], [ClientName], FORMAT([ReportCreatedDate], 'MM/dd/yyyy hh:mm:ss tt') as [ReportCreatedDate], 
  FORMAT([OriginalClosedDate], 'MM/dd/yyyy hh:mm:ss tt')as [OriginalClosedDate], [Turnaround] FROM #tmpWeeklyClosedReports

UNION ALL

SELECT 0,0,'AverageOfTAT',NULL,NULL, AVG(Turnaround) FROM #tmpWeeklyClosedReports

END
