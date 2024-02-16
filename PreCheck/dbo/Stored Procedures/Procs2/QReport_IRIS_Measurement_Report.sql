-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--EXEC [QReport_IRIS_Measurement_Report] @StartDate = '07/21/2015',@EndDate='07/21/2015'
--EXEC [QReport_IRIS_Measurement_Report] null,null,0,0,null,null,null,null

CREATE PROCEDURE [dbo].[QReport_IRIS_Measurement_Report]
	-- Add the parameters for the stored procedure here
  @Investigator varchar(8) = null, 
  @Category varchar(20) = null,
  @CategoryID int = 0,
  @CLNO int = 0,
  @State varchar(20) = null,
  @County varchar(50) = null,
  @StartDate datetime = null,
  @EndDate datetime = null

  
AS

BEGIN


DECLARE @SQL varchar(2000)
SET @SQL = 'SELECT i.Investigator
	, (SELECT ResultLogCategory FROM dbo.IRIS_ResultLogCategory with (nolock) WHERE ResultLogCategoryID = i.ResultLogCategoryID) AS Category
	, CASE	WHEN i.Clear = ''T'' THEN ''Clear''
			WHEN i.Clear = ''F'' THEN ''Record Found''
			WHEN i.Clear = ''P'' THEN ''Possible Record''
			WHEN i.Clear = ''Q'' THEN ''Needs QA''
			WHEN i.Clear = ''I'' THEN ''Needs Research''
			ELSE ''Ordered'' 
	  END AS Status
	, COUNT(ResultLogID) AS RecordCount
FROM dbo.IRIS_ResultLog i with (NOLOCK) inner join crim c with (nolock) on i.crimid = c.crimid 
	inner join counties cc with (nolock) on cc.cnty_no = c.cnty_no left join appl a 
	with (nolock) on i.apno = a.apno
WHERE i.Clear IN (''T'',''F'',''Q'',''I'',''P'') AND i.LogDate >= '' AND i.LogDate < DATEADD(day, 1,'')'


SET @Investigator = '';
SET @Category = '';
SET @CLNO = '';
SET @State = '';
SET @County = '';
SELECT @CategoryID = ResultLogCategoryID FROM dbo.IRIS_ResultLogCategory WHERE ResultLogCategory = @Category
SET @CategoryID = ISNULL(@CategoryID, 0)

IF LEN(@Investigator) > 0
	SET @SQL = @SQL + ' AND i.Investigator = ''' + @Investigator + ''''
IF LEN(@Category) > 0
	SET @SQL = @SQL + ' AND i.ResultLogCategoryID = ' + CAST(@CategoryID as varchar)
IF LEN(@CLNO) > 1
	SET @SQL = @SQL + ' AND a.clno = ' + CAST(@CLNO as varchar)
IF LEN(@State) > 0
	SET @SQL = @SQL + ' AND cc.state = ''' + @State + ''''
IF LEN(@County) > 0
	SET @SQL = @SQL + ' AND c.county like ''%' + @County + '%'''

SET @SQL = @SQL + ' GROUP BY i.Investigator, i.ResultLogCategoryID, i.Clear'
EXEC(@SQL)

	CREATE TABLE #tempIMR (
		FileType varchar(20),
		Investigator varchar(8),
		Category varchar(20),
		Status varchar(20),
		RecordCount int
		)

		insert into #tempIMR
		EXEC(@SQL)


	Select * from #tempIMR

	UNION ALL 

	Select 'Total', NULL,NULL, sum(RecordCount) as RecordCount from #tempIMR

End
