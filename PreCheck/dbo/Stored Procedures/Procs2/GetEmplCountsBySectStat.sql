-- =================================================================================
-- Author:		Suchitra Yellapantula
-- Create date: 11/28/2016
-- Description:	Get number of Empl records closed in SectStat of 5,6,7 (for QReport)
-- Execution: exec GetEmplCountsBySectStat 2569, '11/01/2016','11/25/2016'
-- =================================================================================
CREATE PROCEDURE GetEmplCountsBySectStat
	-- Add the parameters for the stored procedure here
	@clno int,
	@startdate date,
	@enddate date
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @Count_5 int, @Count_6 int, @Count_7 int

	IF OBJECT_ID('tempdb..#TempEmpl') IS NOT NULL DROP TABLE #TempEmpl

    -- Insert statements for procedure here
	SELECT E.* 
	INTO #TempEmpl
	FROM Empl E
	INNER JOIN Appl A on A.APNO = E.APNO 
	WHERE A.CLNO = @CLNO
	AND E.LastModifiedDate between @startdate and dateadd(day,1,@enddate)
	AND E.SectStat in ('5','6','7')

	SET @Count_5 = (SELECT COUNT(*) from #TempEmpl where SectStat = '5')
	SET @Count_6 = (SELECT COUNT(*) from #TempEmpl where SectStat = '6')
	SET @Count_7 = (SELECT COUNT(*) from #TempEmpl where SectStat = '7')

	SELECT @Count_5 as 'VERIFIED/SEE ATTACHED', @Count_6 as 'UNVERIFIED/SEE ATTACHED', @Count_7 as 'ALERT/SEE ATTACHED'
	
	IF OBJECT_ID('tempdb..#TempEmpl') IS NOT NULL DROP TABLE #TempEmpl
END
