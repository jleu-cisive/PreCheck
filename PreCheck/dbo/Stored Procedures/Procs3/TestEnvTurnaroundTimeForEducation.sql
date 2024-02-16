/***********************************************************
Author: DEEPAK VODETHELA
Requested by: Jeff
Description: Please create a qreport that measures the turnaround time of education components from time that report is created to the time that the education component is closed.  
			 Show elapsed business days in left hand side, associated counts, as well as percentage and cumulative percentage. 
Execcution: EXEC [dbo].[TestEnvTurnaroundTimeForEducation] '05/26/2018','06/30/2018'
Modified By: Amy Liu on 07/16/2018 HDT36141: remove days from cells
***********************************************************************************/

CREATE PROCEDURE [dbo].[TestEnvTurnaroundTimeForEducation]
(
  @StartDate datetime,
  @EndDate datetime
)
AS

	-- Get all the Education records which are closed in the given time range
	DECLARE @EducatTable TABLE 
	( 
	   Apno int,
	   EducatID int,
	   CreatedDate DateTime,
	   SectStat char(1),
	   LastUpdated DateTime,
	   Turnaround int 
	) 

	INSERT INTO @EducatTable (Apno, EducatID, CreatedDate,SectStat, LastUpdated, Turnaround)
	SELECT E.APNO, E.EducatID, E.CreatedDate, E.SectStat, E.Last_Updated, dbo.elapsedbusinessdays_2(E.CreatedDate, E.Last_Updated) AS Turnaround
	FROM [Hou-SQLTEST-01].PreCheck.dbo.Educat AS E(NOLOCK)
	WHERE E.IsHidden = 0
	  AND E.IsOnReport = 1
	  AND E.SectStat in ('2','3','4','5')
	  AND E.CreatedDate >= @StartDate
	  AND E.Last_Updated < @EndDate
	ORDER BY 1 DESC

	--SELECT * FROM @EducatTable

	DECLARE @EducatTableSum TABLE 
	( 
		Turnaround int, 
		Total int,
		Percentage decimal(16,4),
		GrandTotal int
	) 

	INSERT INTO @EducatTableSum (Turnaround, Total, Percentage, GrandTotal)
	SELECT CASE WHEN GROUPING(Turnaround) = 1 THEN 50 ELSE Turnaround END AS Turnaround,
			SUM(COUNT(*)) OVER(PARTITION BY Turnaround ) AS Total,
			SUM(COUNT(*)) OVER(PARTITION BY Turnaround)*2/ CAST(SUM(COUNT(*)) OVER()AS DECIMAL) AS Percentage,
			SUM(COUNT(*)) OVER()/2 AS Grandtotal
	FROM @EducatTable
	GROUP BY Turnaround
	WITH CUBE

	--SELECT * FROM @EducatTableSum

	SELECT	CASE WHEN A.Total/CAST(A.GrandTotal AS DECIMAL) = 1 THEN 'Total'
				ELSE CASE WHEN A.Turnaround = 50 THEN CAST(A.Turnaround AS VARCHAR(8)) 
						ELSE CAST(A.Turnaround AS VARCHAR(8)) 
					 END 
			END AS [Days],
			A.Total AS [Count],
			(CAST(((A.Total/CAST(A.GrandTotal AS DECIMAL))*100)AS DECIMAL(16,4))) AS Percentage,
			(CAST(((A.Total/cast(A.GrandTotal AS decimal) + COALESCE((SELECT SUM(B.Total/cast(B.GrandTotal as decimal)) r
			FROM @EducatTableSum AS B WHERE B.Turnaround < A.Turnaround AND A.Turnaround <> 7),0))*100)AS DECIMAL(16,4))) AS [Cumulative Percentage]
	FROM @EducatTableSum AS A
	GROUP BY A.Turnaround, A.Total, A.GrandTotal 


