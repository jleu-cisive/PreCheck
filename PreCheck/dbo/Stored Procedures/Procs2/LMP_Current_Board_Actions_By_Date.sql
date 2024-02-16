-- =============================================
-- Author:		DEEPAK VODETHELA
-- Create date: 10/02/2018
-- Description:	Please create a new Q-Report for LMP which will report all current board actions for all clients with any given date ranges.
-- Execution: EXEC LMP_Current_Board_Actions_By_Date '10/03/2018','10/03/2018'
-- =============================================
CREATE PROCEDURE [dbo].[LMP_Current_Board_Actions_By_Date] 
	-- Add the parameters for the stored procedure here
	@StartDate datetime,
	@EndDate datetime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT	DISTINCT L.LicenseID, vc.Item AS [Client Name], er.First, er.Last, lt.Description AS [License Type],L.IssuingState, L.Number AS [License Number],
		L.Status AS [License Status], L.CurrentRestrictions, L.VerifiedBy
	FROM HEVN.dbo.EmployeeRecord er(NOLOCK)
	INNER JOIN HEVN.dbo.LICENSE AS L(NOLOCK) ON ER.SSN = L.SSN
	INNER JOIN HEVN.dbo.LicenseType lt(NOLOCK) ON L.LicenseTypeID = lt.LicenseTypeID
	INNER JOIN HEVN.dbo.vwClients AS vc(NOLOCK) ON L.Employer_ID	 = vc.ItemValue	
	WHERE l.LastModifiedDate BETWEEN @StartDate AND DATEADD(S,-1,DATEADD(D,1,@EndDate))
	  --AND l.DuplicateLicense  = 0
	  AND l.CurrentRestrictions = 1
END
