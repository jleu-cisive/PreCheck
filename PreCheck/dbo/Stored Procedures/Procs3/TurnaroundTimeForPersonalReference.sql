/****************************************************************************************************
Author: Amy Liu
HDT:33082: TAT Report for Personal References by Jeff Rackler:
This report should display similarly to the Turnaround Time for Education, Employment reports
Filter by Date Range
Execcution: EXEC [dbo].[TurnaroundTimeForPersonalReference] '05/26/2017','06/30/2017'

******************************************************************************************************/

CREATE PROCEDURE [dbo].[TurnaroundTimeForPersonalReference]
(
  @StartDate datetime,
  @EndDate datetime
)
AS

--DECLARE	  @StartDate datetime='05/26/2017',
--  @EndDate datetime='06/30/2017'
	-- Get all the PersonalReference records which are closed in the given time range
	DECLARE @PReferenceTable TABLE 
	( 
	   Apno int,
	   PersRefID int,
	   CreatedDate DateTime,
	   SectStat char(1),
	   LastUpdated DateTime,
	   Turnaround int 
	) 

	INSERT INTO @PReferenceTable (Apno, PersRefID, CreatedDate,SectStat, LastUpdated, Turnaround)
	SELECT PR.APNO,PR.PersRefID, PR.CreatedDate,PR.SectStat, PR.Last_Updated, dbo.elapsedbusinessdays_2(PR.CreatedDate, PR.Last_Updated) AS Turnaround 
	FROM [dbo].[PersRef] AS PR(NOLOCK)
	WHERE PR.IsHidden = 0
	  AND PR.IsOnReport = 1
	  AND PR.SectStat in ('2','3','4','5')
	  AND PR.CreatedDate >= @StartDate
	  AND PR.Last_Updated < @EndDate
	ORDER BY 1 DESC

	--SELECT * FROM @PReferenceTable

	DECLARE @PReferenceTableSum TABLE 
	( 
		Turnaround int, 
		Total int,
		Percentage decimal(16,4),
		GrandTotal int
	) 

	INSERT INTO @PReferenceTableSum (Turnaround, Total, Percentage, GrandTotal)
	SELECT CASE WHEN GROUPING(Turnaround) = 1 THEN 50 ELSE Turnaround END AS Turnaround,
			SUM(COUNT(*)) OVER(PARTITION BY Turnaround ) AS Total,
			SUM(COUNT(*)) OVER(PARTITION BY Turnaround)*2/ CAST(SUM(COUNT(*)) OVER()AS DECIMAL) AS Percentage,
			SUM(COUNT(*)) OVER()/2 AS Grandtotal
	FROM @PReferenceTable
	GROUP BY Turnaround
	WITH CUBE

	--SELECT * FROM @EducatTableSum

	SELECT	CASE WHEN A.Total/CAST(A.GrandTotal AS DECIMAL) = 1 THEN 'Total'
				ELSE CASE WHEN A.Turnaround = 50 THEN CAST(A.Turnaround AS VARCHAR(8)) + '+ Days' 
						ELSE CAST(A.Turnaround AS VARCHAR(8)) + ' Days' 
					 END 
			END AS [Days],
			A.Total AS [Count],
			(CAST(((A.Total/CAST(A.GrandTotal AS DECIMAL))*100)AS DECIMAL(16,4))) AS Percentage,
			(CAST(((A.Total/cast(A.GrandTotal AS decimal) + COALESCE((SELECT SUM(B.Total/cast(B.GrandTotal as decimal)) r
			FROM @PReferenceTableSum AS B WHERE B.Turnaround < A.Turnaround AND A.Turnaround <> 7),0))*100)AS DECIMAL(16,4))) AS [Cumulative Percentage]
	FROM @PReferenceTableSum AS A
	GROUP BY A.Turnaround, A.Total, A.GrandTotal 


