/*
Author: DEEPAK VODETHELA
Requested by: Jeff
Description: Please create a qreport that measures the turnaround time of Employment components from time that report is created to the time that the Employment component is closed.  
			 Show elapsed business days in left hand side, associated counts, as well as percentage and cumulative percentage. 
Execcution: EXEC [dbo].[TestEnvTurnaroundTimeForEmployment] '06/01/2017','07/30/2017'
*/

CREATE PROCEDURE [dbo].[TestEnvTurnaroundTimeForEmployment]
(
  @StartDate datetime,
  @EndDate datetime
)
AS

	-- Get all the Education records which are closed in the given time range
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
	FROM [Hou-SQLTEST-01].PreCheck.dbo.Empl AS E(NOLOCK)
	WHERE E.IsHidden = 0
	  AND E.IsOnReport = 1
	  AND E.SectStat in ('2','3','4','5')
	  AND E.CreatedDate BETWEEN @StartDate AND DATEADD(d,1,@EndDate)
	ORDER BY 1 DESC

	--SELECT * FROM @EmplTable

	DECLARE @EmplTableSum TABLE 
	( 
		Turnaround int, 
		Total int,
		Percentage decimal(16,4),
		GrandTotal int
	) 

	INSERT INTO @EmplTableSum (Turnaround, Total, Percentage, GrandTotal)
	SELECT CASE WHEN GROUPING(Turnaround) = 1 THEN 50 ELSE Turnaround END AS Turnaround,
			SUM(COUNT(*)) OVER(PARTITION BY Turnaround ) AS Total,
			SUM(COUNT(*)) OVER(PARTITION BY Turnaround)*2/ CAST(SUM(COUNT(*)) OVER()AS DECIMAL) AS Percentage,
			SUM(COUNT(*)) OVER()/2 AS Grandtotal
	FROM @EmplTable
	GROUP BY Turnaround
	WITH CUBE

	--SELECT * FROM @EmplTableSum

	SELECT	CASE WHEN A.Total/CAST(A.GrandTotal AS DECIMAL) = 1 THEN 'Total'
				ELSE CASE WHEN A.Turnaround = 50 THEN CAST(A.Turnaround AS VARCHAR(8)) + '+ Days' 
						ELSE CAST(A.Turnaround AS VARCHAR(8)) + ' Days' 
					 END 
			END AS [Days],
			A.Total AS [Count],
			(CAST(((A.Total/CAST(A.GrandTotal AS DECIMAL))*100)AS DECIMAL(16,4))) AS Percentage,
			(CAST(((A.Total/cast(A.GrandTotal AS DECIMAL) + COALESCE((SELECT SUM(B.Total/cast(B.GrandTotal AS DECIMAL)) r
																		FROM @EmplTableSum AS B 
																		WHERE B.Turnaround < A.Turnaround 
																		  AND A.Turnaround <> 7),0))*100) AS DECIMAL(16,4))) AS [Cumulative Percentage]
	FROM @EmplTableSum AS A
	GROUP BY A.Turnaround, A.Total, A.GrandTotal 


