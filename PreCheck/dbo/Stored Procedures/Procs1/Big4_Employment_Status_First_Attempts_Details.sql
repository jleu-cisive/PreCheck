-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 09/08/2017
-- Description:	QReport should show - Totals of Employment Needing a First Attempt for our Top Client Groups and their Aging.  First attempt needed can be determined 
--      by those in Web Status "Choose." First Column would have Days Aging, Second Column is HCA, third column is Tenet, fourth column is CHI, 
--      and fifth column is Universal Health Systems.  HCA data should be derived using affiliates HCA, and HCA - Parallon (aggregated), 
--      Tenet data should be derived using affiliates Tenet Healthcare and Tenet EWS,
--      CHI data should be derived using affiliates CHI - Independent and CHI - National, and Universal Health Systems should be derived using web parent CLNO 13126. 
-- Execution: EXEC [dbo].[Big4_Employment_Status_First_Attempts_Details] '01/01/2017','09/22/2017'
-- =============================================
CREATE PROCEDURE [dbo].[Big4_Employment_Status_First_Attempts_Details]
	@StartDate datetime,
	@EndDate datetime

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT	a.Apno as ReportNumber, a.ApStatus, (case when E.DNC = 0 then 'No' else 'Yes' end) as DoNotContact,
			dbo.elapsedbusinessdays_2(a.ApDate, E.InvestigatorAssigned) as BusinessDays,
			a.ApDate as ReportCreatedDate, A.Investigator, E.InvestigatorAssigned as InvestigatorAssignedDate,
			E.Employer as EmployerName, C.Name as CLientName, rtrim(ltrim(Ws.Description)) as WebStatus,
			E.Web_Updated, MainDB.dbo.fnGetTimeZone(E.[ZipCode], E.[City], E.[State]) [TimeZone],
			RA.Affiliate, RA.AffiliateID, a.UserID CAM,Parent =CAST(c.WebOrderParentCLNO AS VARCHAR) + ' - ' + P.Name
	FROM Empl AS E WITH(NOLOCK)
	INNER JOIN Appl AS a WITH(NOLOCK) on a.Apno = E.Apno
	INNER JOIN CLient AS C WITH(NOLOCK) on a.CLNO = C.CLNO
	INNER JOIN WebSectStat AS Ws WITH(NOLOCK) on Ws.code = E.web_status
	INNER JOIN refAffiliate AS ra WITH (NOLOCK) ON ra.AffiliateID = c.AffiliateID
	LEFT JOIN CLient AS P WITH(NOLOCK) on C.WebOrderParentCLNO = P.CLNO
	WHERE E.IsOnReport = 1 
	 AND E.SectStat IN('0','9' )
	 AND E.WEB_STATUS = 0
	 AND A.ApDate BETWEEN @StartDate AND DATEADD(S,-1,DATEADD(D,1,@EndDate))
	 AND A.CLNO NOT IN (3468,2135)
	 AND RA.AffiliateID IN (4,5,10, 164,166,147,159,177)
	ORDER BY E.Investigator, a.ApStatus





END
