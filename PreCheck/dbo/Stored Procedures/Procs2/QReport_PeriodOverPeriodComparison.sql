-- =============================================
-- Author:		Humera Ahmed
-- Create date: 1/28/2019
-- Description:	The ability to run all activity (App Count) for one time period as scope of search example (01/01 - 02/01) with selected years (2018:2017:2016) adding First repot date for a given client ID number.
-- EXEC QReport_PeriodOverPeriodComparison '1/1','1/25','2018','2019'
-- =============================================
CREATE PROCEDURE [dbo].[QReport_PeriodOverPeriodComparison] 
	-- Add the parameters for the stored procedure here
	 @StartDate_Month AS nvarchar(20),
	 @EndDate_Month as nvarchar(20),
	 @Year1 as nvarchar(20),
	 @Year2 as nvarchar(20)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	
	SET NOCOUNT ON;

	DECLARE @start1 AS datetime = @StartDate_Month +'/'+@Year1
	DECLARE @end1 AS datetime = @EndDate_Month +'/'+@Year1
	DECLARE @start2 AS datetime = @StartDate_Month +'/'+@Year2
	DECLARE @end2 AS datetime = @EndDate_Month +'/'+@Year2

    -- Insert statements for procedure here
	CREATE TABLE #TempAppCount_year2(
					clno int,
					Name varchar(100),
					AffiliateID int,
					Appcount_year2 int,
					)

	INSERT INTO #TempAppCount_year2
	(
	    clno,
	    Name,
	    AffiliateID,
	    AppCount_year2
	)
	SELECT 
		a.clno,
		c.Name,
		c.AffiliateID, 
		count(*) 
	FROM appl a
		INNER JOIN client c ON a.CLNO = c.CLNO
	WHERE 
		(a.apdate >=@start2 and a.apdate <=dateadd(d,1,@end2))
	GROUP BY a.clno, c.Name, c.AffiliateID
	ORDER BY a.clno


	CREATE TABLE #TempAppCount_year1(
					clno int,
					Name varchar(100),
					AffiliateID int,
					Appcount_year1 int,
					)

	INSERT INTO #TempAppCount_year1
	(
	    clno,
	    Name,
	    AffiliateID,
	    AppCount_year1
	)
	SELECT 
		a.clno,
		c.Name,
		c.AffiliateID, 
		count(*) 
	FROM appl a
		INNER JOIN client c ON a.CLNO = c.CLNO
	WHERE 
		(a.apdate >=@start1 and a.apdate <=dateadd(d,1,@end1))
	GROUP BY a.clno, c.Name, c.AffiliateID
	ORDER BY a.clno
	
	CREATE TABLE #TempFirstAppDate(
					clno int,
					apdate datetime,
					)

	INSERT INTO #TempFirstAppDate
	(
	    clno,
	    apdate
	)
	SELECT clno, min(apdate) FROM appl where apdate IS NOT null 
	GROUP BY dbo.appl.CLNO
	ORDER BY clno

	--SELECT * FROM #TempFirstAppDate fad
	--SELECT * FROM #TempAppcount_year2 tay ORDER BY clno
	--SELECT * FROM #TempAppcount_year1 tay ORDER BY clno
	
	DECLARE @sql NVARCHAR(MAX)
	SET @sql = 'SELECT c.clno as [Client Number],c.Name as [Client Name],c.AffiliateID,tacy.Appcount_year1 as [AppCount_'+@Year1+'], tacy2.Appcount_year2 as [AppCount_'+@Year2+'], FORMAT(tfad.apdate,''MM/dd/yyyy'') [FirstAppDate]
	FROM client c
	LEFT JOIN #TempAppCount_year1 tacy ON c.CLNO=tacy.clno
	LEFT JOIN #TempAppCount_year2 tacy2 ON c.CLNO=tacy2.clno
	inner JOIN #TempFirstAppDate tfad ON c.clno=tfad.clno
	WHERE (tacy.Appcount_year1 IS NOT NULL or tacy2.Appcount_year2 IS NOT null)'
	exec(@sql)
		
	DROP TABLE #TempAppCount_year1
	DROP TABLE #TempAppCount_year2
	DROP TABLE #TempFirstAppDate

END
