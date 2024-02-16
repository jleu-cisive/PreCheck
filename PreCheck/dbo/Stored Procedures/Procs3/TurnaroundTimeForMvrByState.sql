-- =============================================
-- Author:		Deepak Vodethela
-- Create date: 06/04/2018
-- Description:	Turnaround time for MVR by State
-- Execution: EXEC TurnaroundTimeForMvrByState '05/22/2018','06/06/2018'
-- =============================================
CREATE PROCEDURE [dbo].[TurnaroundTimeForMvrByState]
	-- Add the parameters for the stored procedure here
	@StartDate Datetime,
	@EndDate Datetime 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
	DECLARE @tmpMVRReportsByTAT TABLE 
	(
		[TurnAroundTime] INT,
		[DLState] VARCHAR(2),
		NoOfReportsClosed INT
	)

	INSERT INTO @tmpMVRReportsByTAT(TurnAroundTime, [DLState], NoOfReportsClosed)
	SELECT	DISTINCT dbo.elapsedbusinessdays_2(CAST(M.CreatedDate AS DATE), CAST(M.Last_Updated AS DATE)) AS TurnAroundTime,
			[DL_State] AS [DLState],
			COUNT(M.APNO) OVER (PARTITION BY dbo.elapsedbusinessdays(CAST(M.CreatedDate AS DATE), CAST(M.Last_Updated AS DATE)), [DL_State]) AS 'DLState'
	FROM DL AS M(NOLOCK)
	INNER JOIN dbo.Appl a(nolock) ON m.APNO = a.APNO
	WHERE M.IsHidden = 0
	  AND M.SectStat IN ('2','3','4','5')
	  AND M.CreatedDate BETWEEN @StartDate AND DATEADD(S,-1,DATEADD(D,1,@EndDate)) 

	SELECT * FROM @tmpMVRReportsByTAT ORDER BY [DLState],TurnAroundTime

	/*
	DECLARE @DLTable TABLE 
	( 
	   Apno int,
	   CreatedDate DateTime,
	   SectStat char(1),
	   LastUpdated DateTime,
	   Turnaround int,
	   DLState VARCHAR(2)
	) 

	INSERT INTO @DLTable (Apno,  CreatedDate,SectStat, LastUpdated, Turnaround,[DLState])
	SELECT D.APNO,  D.CreatedDate, D.SectStat, D.Last_Updated, dbo.elapsedbusinessdays_2(D.CreatedDate, D.Last_Updated) AS Turnaround,[DL_State]
	FROM DL AS D(NOLOCK)
	INNER JOIN dbo.Appl a(nolock) ON D.APNO = a.APNO
	WHERE D.IsHidden = 0
	  AND D.SectStat in ('2','3','4','5')
	  AND D.CreatedDate >= @StartDate
	  AND D.Last_Updated < @EndDate
	ORDER BY 1 DESC

	--SELECT * FROM @DLTable ORDER BY DLState

	DECLARE @DLTableSum TABLE 
	( 
		Turnaround int, 
		Total int,
		Percentage decimal(16,4),
		GrandTotal int,
		DLState VARCHAR(2)
	) 

	INSERT INTO @DLTableSum (Turnaround, Total, Percentage, GrandTotal, DLState)
	SELECT CASE WHEN GROUPING(Turnaround) = 1 THEN 10 ELSE Turnaround END AS Turnaround,
			SUM(COUNT(*)) OVER(PARTITION BY Turnaround, DLState ) AS Total,
			SUM(COUNT(*)) OVER(PARTITION BY Turnaround)*2/ CAST(SUM(COUNT(*)) OVER()AS DECIMAL) AS Percentage,
			SUM(COUNT(*)) OVER()/2 AS Grandtotal,
			DLState
	FROM @DLTable
	GROUP BY DLState, Turnaround
	WITH CUBE

	--SELECT * FROM @DLTableSum

	DECLARE @DLTableOrder TABLE 
	( 
		[Days] VARCHAR(10), 
		[Count] int,
		[Percentage] decimal(16,4),
		[Cumulative Percentage] decimal(16,4),
		DLState VARCHAR(2)
	) 

	INSERT INTO @DLTableOrder ([Days], [Count], [Percentage], [Cumulative Percentage], DLState)
	SELECT	CASE WHEN A.Total/CAST(A.GrandTotal AS DECIMAL) = 1 THEN 'Total'
				ELSE CASE WHEN A.Turnaround = 10 THEN CAST(A.Turnaround AS VARCHAR(8)) + '+ Days' 
						ELSE CAST(A.Turnaround AS VARCHAR(8)) + ' Days' 
					 END 
			END ,
			A.Total ,
			(CAST(((A.Total/CAST(A.GrandTotal AS DECIMAL))*100)AS DECIMAL(16,4))) AS Percentage,
			(CAST(((A.Total/cast(A.GrandTotal AS decimal) + COALESCE((SELECT SUM(B.Total/cast(B.GrandTotal as decimal)) r
																		FROM @DLTableSum AS B 
																		WHERE B.Turnaround < A.Turnaround 
																		  AND A.Turnaround <> 7),0))*100)AS DECIMAL(16,4))),
			DLState
	FROM @DLTableSum AS A
	GROUP BY A.Turnaround, A.Total, A.GrandTotal, DLState

	SELECT * FROM @DLTableOrder ORDER BY DLState --DESC, [Days] ASC
	*/
END
