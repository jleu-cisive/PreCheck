
--exec [dbo].[QReport_FuzzyNameMatchingLog] '02/01/2023', '02/08/2023', 1

CREATE PROCEDURE [dbo].[QReport_FuzzyNameMatchingLog] 
	@StartDate datetime,
	@EndDate datetime,
	@ShowOnlyUsed BIT = 0
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @TempMachingLog TABLE(EmplID INT, APNO INT, EmployerName_ByCandidate VARCHAR(155), EmployerName_Normalized VARCHAR(155), EmployerName_ByTALX VARCHAR(155), Scorecard INT, CreatedDate DATETIME, WasUsed BIT)


	INSERT INTO @TempMachingLog
	SELECT l.EmplID, l.APNO, l.EmployerName_ByCandidate, l.EmployerName_Normalized, l.EmployerName_ByTALX, l.Scorecard, l.CreatedDate,
			CASE WHEN (l.CreatedDate <= '2023-02-07 11:00:00' AND l.Scorecard > 65) THEN 1 
				WHEN (l.CreatedDate > '2023-02-07 11:00:00' AND l.Scorecard > 75) THEN 1
				ELSE 0 END AS WasUsed
	FROM dbo.EmployerFuzzyNameMatching_Log l
	WHERE CONVERT(DATE,l.CreatedDate) BETWEEN @StartDate AND @EndDate
	ORDER BY l.CreatedDate, l.APNO, l.EmplID

	-- if multiple matched.
	;WITH cte AS (
		SELECT *,
			ROW_NUMBER() OVER(PARTITION BY t.EmplID, t.WasUsed ORDER BY Scorecard DESC, CreatedDate ASC) AS CountNum
		FROM @TempMachingLog t

	)

	SELECT c.EmplID,c.APNO,c.EmployerName_ByCandidate,c.EmployerName_Normalized,c.EmployerName_ByTALX,c.Scorecard,c.CreatedDate,c.WasUsed
	FROM cte c
	WHERE ((c.CountNum = 1 AND c.WasUsed = 1) OR (@ShowOnlyUsed = 0)) -- take first one if multiple matched.
	ORDER BY c.CreatedDate DESC


  


END 

