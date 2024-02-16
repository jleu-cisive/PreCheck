-- ========================================================================================================
-- Author:		Larry Ouch
-- Create date: 05/04/2017
-- Description:	Report that searches by investigator and date range and returns what counties/searches that investigator worked and how many.
--		Currently only displaying the CEQ and OASIS categories
-- Execution: EXEC [dbo].[Iris_Measurement_Report_by_County]  'dbassett', '05/04/2017', '05/04/2017', ''
-- =========================================================================================================
CREATE PROCEDURE [dbo].[Iris_Measurement_Report_by_County] 
	-- Add the parameters for the stored procedure here
	@investigator varchar(8), @startDate varchar(10), @endDate varchar(10), @county varchar(50)	
AS
SET NOCOUNT ON
BEGIN

DECLARE @SQL1 varchar(2000)
DECLARE @SQL2 varchar(1000)
DECLARE @SQL3 varchar(1000)
DECLARE @totalcount int

SET @SQL2 = 'SELECT IRL.Investigator, C.County, CSS.crimdescription AS Status, RLC.ResultLogCategory AS Category, COUNT(IRL.ResultLogID) AS RecordCount
FROM IRIS_RESULTLOG IRL (NOLOCK)
INNER JOIN CRIM C (NOLOCK) ON C.CrimID = IRL.CrimID
INNER JOIN IRIS_ResultLogCategory RLC (NOLOCK) ON RLC.ResultLogCategoryID = IRL.ResultLogCategoryID
INNER JOIN Crimsectstat CSS (NOLOCK) ON CSS.crimsect = IRL.Clear
WHERE IRL.Investigator IS NOT NULL AND IRL.Investigator != '''' AND IRL.ResultLogCategoryID IN (5,8)' 

SET @SQL2 = @SQL2 + 'AND IRL.LogDate between '''+ @startDate +''' and DateAdd(d,1,'''+ @endDate +''')'

SET @SQL3 = '
GROUP BY C.CNTY_NO, IRL.Investigator, CSS.crimdescription, C.County, RLC.ResultLogCategory
ORDER BY IRL.Investigator ASC, County ASC'

IF LEN(@investigator) > 0
	SET @SQL2 = @SQL2 + ' AND IRL.Investigator = ''' + @investigator + ''''
IF LEN(@county) > 0
	SET @SQL2 = @SQL2 + ' AND C.County like ''%' + @county + '%'''

SET @SQL1 = @SQL2 + @SQL3

--PRINT(@SQL1)

--EXEC(@SQL1)

Create table #tmpreport(Investigator varchar(8),County varchar(50),Status varchar(25),Category varchar(20),RecordCount int)
INSERT INTO #tmpreport EXEC (@SQL1)

SET @totalcount = (Select SUM(RecordCount) from #tmpreport)

INSERT INTO #tmpreport (Investigator, County, Status, Category, RecordCount)
Values('', '', '', 'Total', @totalcount)

SELECT * FROM #tmpreport

END
