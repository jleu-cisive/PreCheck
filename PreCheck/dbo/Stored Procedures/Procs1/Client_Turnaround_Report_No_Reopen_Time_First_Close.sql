/*---------------------------------------------------------------------------------
Procedure Name : [dbo].[Client_Turnaround_Report_No_Reopen_Time_First_Close]
Requested By: Dana Sangerhausen
Developed By: Deepak Vodethela  08/01/16-08/31/16, 09/01/16-09/30/16 and 10/01/16-10/31/16
Execution : EXEC [dbo].[Client_Turnaround_Report_No_Reopen_Time_First_Close] '12374:12365:12373:12487','08/01/2016','11/11/2016','Tenet Healthcare'
			EXEC [dbo].[Client_Turnaround_Report_No_Reopen_Time_First_Close] NULL,'10/01/2016','10/31/16','Tenet Healthcare'
			EXEC [dbo].[Client_Turnaround_Report_No_Reopen_Time_First_Close] '12374:12365:12373:12487','08/01/2016','11/11/2016',NULL
			EXEC [dbo].[Client_Turnaround_Report_No_Reopen_Time_First_Close] NULL,'08/01/2016','11/11/2016',NULL
			EXEC [dbo].[Client_Turnaround_Report_No_Reopen_Time_First_Close] '13343','05/01/2017','06/06/2017',null
			EXEC [dbo].[Client_Turnaround_Report_No_Reopen_Time_First_Close] '','05/01/2017','08/06/2017','HCA'
*/---------------------------------------------------------------------------------

CREATE PROCEDURE [dbo].[Client_Turnaround_Report_No_Reopen_Time_First_Close]
@ClientList varchar(MAX) = NULL, 
@StartDate datetime,
@EndDate datetime, 
@AffiliateName varchar(max)
AS
SET NOCOUNT ON
	DECLARE @Total int

	SET @EndDate = DateAdd(d,1,@EndDate);

	IF(@ClientList = '' OR LOWER(@ClientList) = 'null' ) 
	Begin  
		SET @ClientList = NULL  
	END

	IF(@AffiliateName = '' OR LOWER(@AffiliateName) = 'null') 
	Begin  
		SET @AffiliateName = NULL  
	END

	SET @Total = (SELECT COUNT(APNO) 
				  FROM appl AS A WITH(NOLOCK)
				  INNER JOIN [dbo].[Client] AS C WITH(NOLOCK) ON A.CLNO = C.CLNO
				  INNER JOIN [dbo].[refAffiliate] AS R WITH(NOLOCK) ON C.AffiliateID = R.AffiliateID
				  WHERE Apdate >= @StartDate 
					AND Apdate < @EndDate 
					AND (@ClientList IS NULL OR A.CLNO in (SELECT value FROM fn_Split(@ClientList,':')))
					AND (@AffiliateName IS NULL OR R.Affiliate = @AffiliateName));

	SELECT	0 AS apno, 0 AS CLNO, '' AS ClientName, (dbo.elapsedbusinessdays_2( Apdate, Origcompdate )) AS turnaround, COUNT(1) AS totalcount, COUNT(1)/ (CAST(@Total AS NUMERIC( 10, 2 ))) AS 'percentage', 
			null AS 'App Created Date', null AS 'Original Closed Date' 
			INTO #temptable 
	FROM appl AS A WITH(NOLOCK)
	INNER JOIN [dbo].[Client] AS C WITH(NOLOCK) ON A.CLNO = C.CLNO
	INNER JOIN [dbo].[refAffiliate] AS R WITH(NOLOCK) ON C.AffiliateID = R.AffiliateID
	WHERE ApDate >= @StartDate 
	  AND ApDate < @EndDate 
	  --and A.CLNO in (select value from fn_Split(@ClientList,':')) 
	  AND (@ClientList IS NULL OR A.CLNO in (SELECT value FROM fn_Split(@ClientList,':')))
	  AND (@AffiliateName IS NULL OR R.Affiliate = @AffiliateName)
	  AND apstatus in ('W','F')
	GROUP BY ( dbo.elapsedbusinessdays_2( Apdate, Origcompdate ))

	--SELECT * FROM #temptable

	SELECT  a1.apno AS APNO, a1.clno AS CLNO, a1.ClientName, a1.turnaround AS Turnaround, a1.totalcount AS TotalCount, a1.percentage AS Percentage, SUM(a2.percentage) AS [Cumulative Percentage], a1.[App Created Date], a1.[Original Closed Date] 
			INTO #temptable1
	FROM #temptable a1
	JOIN #temptable a2 ON a1.turnaround >= a2.turnaround
	GROUP BY a1.totalcount, a1.turnaround, a1.apno, a1.clno, a1.ClientName, a1.percentage, a1.[App Created Date], a1.[Original Closed Date]

	SELECT * FROM #temptable1
	UNION ALL
	SELECT	apno, A.CLNO, C.Name AS ClientName, (dbo.elapsedbusinessdays_2( Apdate, Origcompdate)) AS turnaround,
			0 AS totalcount,
			0 AS percentage, 
			0 AS [Cumulative Percentage],
			apdate AS 'App Created Date', origcompdate AS 'Original Closed Date'
	FROM appl AS A WITH(NOLOCK)
	INNER JOIN [dbo].[Client] AS C WITH(NOLOCK) ON A.CLNO = C.CLNO
	INNER JOIN [dbo].[refAffiliate] AS R WITH(NOLOCK) ON C.AffiliateID = R.AffiliateID
	WHERE apstatus in ('W','F')
	  AND OrigCompDate >= @StartDate 
	  AND OrigCompDate < @EndDate 
	  AND (@ClientList IS NULL OR A.CLNO in (SELECT value FROM fn_Split(@ClientList,':')))
	  AND (@AffiliateName IS NULL OR R.Affiliate = @AffiliateName)	   
	ORDER BY apno, clno, turnaround

	--SELECT * FROM #temptable1

	DROP TABLE #temptable, #temptable1
	SET NOCOUNT OFF