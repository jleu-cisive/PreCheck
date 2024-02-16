-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 02/14/2019
-- Description:	INOVA Monthly TAT [date], to include all reports closed to date by month
-- =============================================
CREATE PROCEDURE [dbo].[INOVA_Monthly_TAT]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	CREATE TABLE #tmpMonthlyClosedReports
	(
		[ReportNumber] [int] NOT NULL,
		[ClientID] [int] NOT NULL,
		[ClientName] [varchar](100) NOT NULL,
		[ReportCreatedDate] [datetime] NULL,
		[OriginalClosedDate] [datetime] NULL,
		[OriginalCloseMonth] [Varchar](20) NULL,
		[Turnaround] [decimal](10,2) NULL
	)

	INSERT INTO #tmpMonthlyClosedReports
	SELECT a.Apno as [ReportNumber], a.CLNO as [ClientID], C.Name as [ClientName], A.ApDate as [ReportCreatedDate], 
		A.OrigCompDate as [OriginalClosedDate], FORMAT(A.OrigCompDate, 'MMMM') as [OriginalCloseMonth],
		[dbo].[ElapsedBusinessDays_2](A.ApDate, A.OrigCompDate) [Turnaround]
	FROM Appl A (NOLOCK)
	INNER JOIN CLIENT C (NOLOCK) ON A.CLNO = C.CLNO
	WHERE MONTH(A.OrigCompDate) BETWEEN MONTH(GETDATE())-1 AND MONTH(GETDATE()) 
	AND YEAR(A.OrigCompDate) = YEAR(GETDATE())
	AND A.apstatus = 'F'
	AND C.CLNO in (1932,1934,1935,1936,1937,3696,8789)
	Order by APNO


	SELECT [ReportNumber], [ClientID], [ClientName],	FORMAT([ReportCreatedDate], 'MM/dd/yyyy hh:mm:ss tt') as [ReportCreatedDate], 
		FORMAT([OriginalClosedDate], 'MM/dd/yyyy hh:mm:ss tt') as [OriginalClosedDate], [OriginalCloseMonth],[Turnaround] FROM #tmpMonthlyClosedReports

	UNION ALL

	SELECT 0,0,'',NULL,NULL,'AverageOfTAT', AVG(Turnaround) FROM #tmpMonthlyClosedReports













END
