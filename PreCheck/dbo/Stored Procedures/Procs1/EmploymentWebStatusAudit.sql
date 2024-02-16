-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 06/11/2019
-- Description:	Any items put in Team Pamela Webstatus we need to pull
-- MichellePaz : Report #, Employer Name and Applicant name, Date it was placed in the web status.

-- EXEC EmploymentWebStatusAudit '06/04/2019', '06/10/2019'
-- =============================================
CREATE PROCEDURE EmploymentWebStatusAudit
	-- Add the parameters for the stored procedure here
	@StartDate datetime,
	@EndDate datetime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT	E.Apno, E.EmplID as EmploymentID, E.Employer AS [Employer Name], S.[Description] AS [Status],W.[description] AS [Web Status], C.NewValue,
			(CASE WHEN LEN(LTRIM(RTRIM(C.USERID))) <=8 THEN LTRIM(RTRIM(C.UserID)) ELSE  SUBSTRING ( LTRIM(RTRIM(C.UserID)) ,1 , LEN(LTRIM(RTRIM(C.UserID))) -5) END) AS UserID,
			C.ChangeDate AS [Date]
	INTO #tempChangeLogAudit
	FROM ChangeLog AS C(NOLOCK) 
	INNER JOIN Empl AS E(NOLOCK) ON C.ID = E.EmplID
	INNER JOIN SectStat AS S(NOLOCK) ON E.SectStat = S.Code
	INNER JOIN Websectstat AS W(NOLOCK) ON E.web_status = W.code
	WHERE C.TableName like 'Empl.web_status' 
	  AND C.NewValue like '29'
	  AND C.changedate BETWEEN @StartDate AND DATEADD(S,-1,DATEADD(D,1,@EndDate))
	ORDER BY C.ChangeDate DESC


	Select t.*, A.First, A.Last, A.Middle from #tempChangeLogAudit t
	INNER JOIN APPL A ON T.APNO = A.APNO


END
