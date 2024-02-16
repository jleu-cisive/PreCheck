-- =============================================
-- Modified By:	DEEPAK VODETHELA	
-- Create date: 07/07/2017
-- Description:	To capture all the Web Status Updates for Employment
-- Execution:  EXEC dbo.WebStatus_Update_Tracking_Report_Employment '01/01/2020','10/02/2020'
-- =============================================
CREATE PROCEDURE [dbo].[WebStatus_Update_Tracking_Report_Employment]
	-- Add the parameters for the stored procedure here
    @StartDate date, 
    @EndDate date
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT E.EmplID, E.InUse, a.Apno as ReportNumber,E.SectStat,a.ApStatus, (case when E.DNC = 0 then 'No' else 'Yes' end) as DoNotContact,
			dbo.elapsedbusinessdays_2(a.ApDate, getDate() +1) as BusinessDays,
			a.ApDate as ReportCreatedDate, E.Investigator, E.InvestigatorAssigned as InvestigatorAssignedDate,
			E.Employer as EmployerName, C.Name as CLientName, rtrim(ltrim(Ws.Description)) as WebStatus,
			E.Web_Updated, MainDB.dbo.fnGetTimeZone(E.[ZipCode], E.[City], E.[State]) [TimeZone],
			RA.Affiliate,a.UserID CAM
			,Parent =CAST(c.WebOrderParentCLNO AS VARCHAR) + ' - ' + P.Name
	FROM Empl AS E WITH(NOLOCK)
	INNER JOIN Appl AS a WITH(NOLOCK) on a.Apno = E.Apno
	INNER JOIN CLient AS C WITH(NOLOCK) on a.CLNO = C.CLNO
	INNER JOIN WebSectStat AS Ws WITH(NOLOCK) on Ws.code = E.web_status
	INNER JOIN refAffiliate AS ra WITH (NOLOCK) ON ra.AffiliateID = c.AffiliateID
	LEFT JOIN CLient AS P WITH(NOLOCK) on C.WebOrderParentCLNO = P.CLNO
	WHERE E.IsOnReport = 1 
	 AND E.SectStat = '9' 
     AND (CAST(a.[ApDate] AS DATE) BETWEEN @StartDate AND @EndDate)
ORDER BY E.Investigator, a.ApStatus
END