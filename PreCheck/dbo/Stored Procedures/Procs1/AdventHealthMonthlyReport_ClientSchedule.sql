-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 08/09/2021
-- Description:	Advent Health Monthly Report
-- EXEC dbo.[AdventHealthMonthlyReport_ClientSchedule] 
-- =============================================
CREATE PROCEDURE [dbo].[AdventHealthMonthlyReport_ClientSchedule] 
	-- Add the parameters for the stored procedure here


AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @StartDate Date = CONVERT(DATE, DATEADD(m, -1, GetDate()))
    
	SELECT DISTINCT aa.ClientCandidateID, 
			A.[First] AS [Applicant First Name],
			a.[Last] AS [Applicant Last Name],
			A.APNO AS [Report Number],	
			A.OrigCompDate as [Original Completion Date],		
			A.CompDate as [Completion Date]	
	FROM Appl A(NOLOCK) 
	INNER JOIN CLient C (NOLOCK) ON a.CLNO = c.CLNO
	LEFT OUTER JOIN Enterprise.Staging.[ApplicantStage] AS aa(NOLOCK) ON aa.ApplicantNumber = A.APNO 
	WHERE C.Weborderparentclno = 15355
	AND a.OrigCompDate > @StartDate
	AND a.Apstatus ='F'

END
