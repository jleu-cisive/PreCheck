-- =========================================================================================
/* Modified By: Vairavan A
-- Modified Date: 07/05/2022
-- Description: Ticketno-53763 
Modify existing q-reports that have affiliate ids in their search parameters
Details: 
Change search parameters for the Affiliate Id field
     * search by multiple affiliate ids (ex 4:297)
     * want to also be able to search all affiliates by putting zero - meaning 0 to search all affiliates
     * multiple affiliates to be separated by a colon  
Under Parameter Names - after Affiliate ID include this wording (separate by colon, default 0)
Child ticket id -54478 Update AffiliateID Parameters 516-678
*/
---Testing
/*
EXEC TurnaroundTimeForEmployment '03/01/2020','06/25/2020','0'
EXEC TurnaroundTimeForEmployment '03/01/2020','06/25/2020','4'
EXEC TurnaroundTimeForEmployment '03/01/2020','06/25/2020','4:8'
*/
-- =========================================================================================
CREATE PROCEDURE [dbo].[TurnaroundTimeForEmployment]
(
  @StartDate datetime,
  @EndDate datetime,
 -- @AffiliateID int--code commented by vairavan for ticket id -53763
  @AffiliateID varchar(MAX) = '0'--code added by vairavan for ticket id -53763
)
AS
BEGIN

	--code added by vairavan for ticket id -53763 starts
	IF @AffiliateID = '0' 
	BEGIN  
		SET @AffiliateID = NULL  
	END
	--code added by vairavan for ticket id -53763 ends

	-- Get all the Employment records which are closed in the given time range
	DECLARE @EmplTable TABLE   
	( 
	   Apno int,
	   EmplID int,
	   CreatedDate DateTime,
	   SectStat char(1),
	   LastUpdated DateTime,
	   Turnaround int 
	) 

	INSERT INTO @EmplTable (Apno, EmplID, CreatedDate,SectStat, LastUpdated, Turnaround)
	SELECT E.APNO, E.EmplID, E.CreatedDate, E.SectStat, E.Last_Updated, dbo.elapsedbusinessdays_2(E.CreatedDate, E.Last_Updated) AS Turnaround
	FROM Empl AS E with(NOLOCK)
	INNER JOIN Appl a with(NOLOCK) on e.apno = a.apno
	INNER JOIN CLient C with(NOLOCK) on a.clno = c.clno
	INNER JOIN refaffiliate rf with(NOLOCK) on c.Affiliateid = rf.Affiliateid
	WHERE E.IsHidden = 0
	  AND E.IsOnReport = 1
	  AND E.SectStat in ('2','3','4','5')
	  AND E.CreatedDate BETWEEN @StartDate AND DATEADD(d,1,@EndDate)
	  --AND c.Affiliateid = IIF(@AffiliateID=0,C.AffiliateID,@AffiliateID)--code Commented by vairavan for ticket id -53763
	  and (@AffiliateID IS NULL OR CAST(c.AffiliateID AS VARCHAR(15)) IN (SELECT value FROM fn_Split(@AffiliateID,':')))--code added by vairavan for ticket id -53763
	ORDER BY 1 DESC

	--SELECT * FROM @EmplTable

	CREATE TABLE #EmplTableSum  
	( 
		Turnaround int, 
		Total int,
		Percentage decimal(16,4),
		GrandTotal int
	) 

	INSERT INTO #EmplTableSum (Turnaround, Total, Percentage, GrandTotal)
	SELECT CASE WHEN GROUPING(Turnaround) = 1 THEN 50 ELSE Turnaround END AS Turnaround,
			SUM(COUNT(*)) OVER(PARTITION BY Turnaround ) AS Total,
			SUM(COUNT(*)) OVER(PARTITION BY Turnaround)*2/ CAST(SUM(COUNT(*)) OVER()AS DECIMAL) AS Percentage,
			SUM(COUNT(*)) OVER()/2 AS Grandtotal
	FROM @EmplTable
	GROUP BY Turnaround
	WITH CUBE

	--SELECT * FROM @EmplTableSum

	SELECT	CASE WHEN A.Total/CAST(A.GrandTotal AS DECIMAL) = 1 THEN 'Total'
				ELSE CASE WHEN A.Turnaround = 50 THEN CAST(A.Turnaround AS VARCHAR(8)) + '+' 
						ELSE CAST(A.Turnaround AS VARCHAR(8)) --+ ' ' 
					 END 
			END AS [Days],
			A.Total AS [Count],
			(CAST(((A.Total/CAST(A.GrandTotal AS DECIMAL))*100)AS DECIMAL(16,4))) AS [Percentage],
				(CAST(((A.Total/cast(A.GrandTotal AS DECIMAL) + 
					COALESCE((SELECT SUM(B.Total/cast(B.GrandTotal AS DECIMAL)) r FROM #EmplTableSum AS B 
								WHERE B.Turnaround < A.Turnaround AND A.Turnaround <> 7),0))*100) AS DECIMAL(16,4))) AS [Cumulative Percentage],
			0 as apno, null as 'App Created Date',null as 'Employment Created Date', null as 'Employment Last Verified', null as 'Employment Original Complete Date'
	FROM #EmplTableSum AS A
	GROUP BY A.Turnaround, A.Total, A.GrandTotal 

	UNION All

	SELECT CAST(( DBO.ELAPSEDBUSINESSDAYS_2(A.APDATE, ED.LAST_WORKED)) AS NVARCHAR(100)) AS [Days],
		0 AS [Count],
		0 AS [Percentage], 
		0 AS [Cumulative Percentage], A.APNO, A.APDATE AS 'App Created Date', ED.CREATEDDATE AS 'Employment Created Date',
		ED.LAST_UPDATED AS 'Employment Last Verified',ED.LAST_WORKED AS 'Employment Original Complete Date'
	FROM APPL A with(nolock)
	INNER JOIN Empl ED  with(nolock) ON A.APNO = ED.APNO
	WHERE ED.LAST_WORKED >= @STARTDATE
	 AND ED.LAST_WORKED < @ENDDATE 
	 AND ED.SECTSTAT NOT IN ('9')
	GROUP BY A.APNO, A.APDATE, ED.LAST_UPDATED, ED.LAST_WORKED, ED.CREATEDDATE 

END
