-- =============================================
-- Author:		Deepak Vodetheka
-- Create date: 05/08/2019
-- Description:	Report that will pull all employments in the THORNGREN module with webstatus T and T
-- Execution: EXEC Employments_In_THORNGREN '04/01/2019','04/30/2019'
-- =============================================
CREATE PROCEDURE Employments_In_THORNGREN 
	-- Add the parameters for the stored procedure here
	@StartDate DATE,
	@EndDate DATE
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT	A.CLNO, C.[Name] AS [Client Name], e.Apno AS [Report#], e.Employer AS [Employer Name], S.[Description] AS [Status]
	FROM dbo.Empl AS e(NOLOCK)
	INNER JOIN Appl AS A(NOLOCK) ON E.APNO = A.APNO
	INNER JOIN Client AS c(NOLOCK) ON A.CLNO = C.CLNO
	INNER JOIN SectStat AS S ON e.SectStat = S.Code
	WHERE e.IsOnReport = 1
	  AND e.IsHidden = 0
	  AND e.web_status = 87
	  AND e.CreatedDate BETWEEN @StartDate AND DATEADD(d,1,@EndDate)
	ORDER BY e.CreatedDate
END
