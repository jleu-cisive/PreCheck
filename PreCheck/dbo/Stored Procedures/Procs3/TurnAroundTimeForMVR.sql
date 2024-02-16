-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 04/18/2018
-- Description:	TAT for MVR
-- EXEC TurnAroundTimeForMVR '01/01/2018', '01/31/2018'
-- =============================================
CREATE PROCEDURE TurnAroundTimeForMVR
	-- Add the parameters for the stored procedure here
	@StartDate Datetime,
	@EndDate Datetime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	-- Get all the DL records which are closed in the given time range
	DECLARE @DLTable TABLE 
	( 
	   Apno int,
	   CreatedDate DateTime,
	   SectStat char(1),
	   LastUpdated DateTime,
	   Turnaround int 
	) 

	INSERT INTO @DLTable (Apno,  CreatedDate,SectStat, LastUpdated, Turnaround)
	SELECT APNO,  CreatedDate, SectStat,Last_Updated, dbo.elapsedbusinessdays_2(CreatedDate, Last_Updated) AS Turnaround
	FROM DL (NOLOCK)
	WHERE IsHidden = 0
	  AND SectStat in ('2','3','4','5')
	  AND CreatedDate >= @StartDate
	  AND Last_Updated < @EndDate
	ORDER BY 1 DESC

	--SELECT * FROM @DLTable

	DECLARE @DLTableSum TABLE 
	( 
		Turnaround int, 
		Total int,
		Percentage decimal(16,4),
		GrandTotal int
	) 

	INSERT INTO @DLTableSum (Turnaround, Total, Percentage, GrandTotal)
	SELECT CASE WHEN GROUPING(Turnaround) = 1 THEN 50 ELSE Turnaround END AS Turnaround,
			SUM(COUNT(*)) OVER(PARTITION BY Turnaround ) AS Total,
			SUM(COUNT(*)) OVER(PARTITION BY Turnaround)*2/ CAST(SUM(COUNT(*)) OVER()AS DECIMAL) AS Percentage,
			SUM(COUNT(*)) OVER()/2 AS Grandtotal
	FROM @DLTable
	GROUP BY Turnaround
	WITH CUBE

	--SELECT * FROM @DLTableSum

	SELECT	CASE WHEN A.Total/CAST(A.GrandTotal AS DECIMAL) = 1 THEN 'Total'
				ELSE CASE WHEN A.Turnaround = 50 THEN CAST(A.Turnaround AS VARCHAR(8)) + '+ Days' 
						ELSE CAST(A.Turnaround AS VARCHAR(8)) + ' Days' 
					 END 
			END AS [Days],
			A.Total AS [Count],
			(CAST(((A.Total/CAST(A.GrandTotal AS DECIMAL))*100)AS DECIMAL(16,4))) AS Percentage,
			(CAST(((A.Total/cast(A.GrandTotal AS decimal) + COALESCE((SELECT SUM(B.Total/cast(B.GrandTotal as decimal)) r
			FROM @DLTableSum AS B WHERE B.Turnaround < A.Turnaround AND A.Turnaround <> 7),0))*100)AS DECIMAL(16,4))) AS [Cumulative Percentage]
	FROM @DLTableSum AS A
	GROUP BY A.Turnaround, A.Total, A.GrandTotal 



END
