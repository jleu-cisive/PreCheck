
-- =============================================
-- Created By:	Prasanna	
-- Create date: 07/19/2018
-- Description:	Closed Reports with Unverified/See Attached and webstatus in follow-up date given
-- Execution:  EXEC dbo.WebStatus_ClosedReports_FollowUpDateGiven_Education '05/07/2018','07/07/2018'
-- Modified By: AmyLiu on 09/04/2020 for Phase3 of Project: IntranetModule: Status -Substatus
-- Modified By: Aashima on 31/08/2022 for HDT #60979, added two new columns in output dataset - [Follow-up Date given], [Estimated Completion date]
-- =============================================

/*
Modified By: Sunil Mandal
Modified Date: 28-Jul-2022
Description: Ticket - #56459 Web Status Close Reports Tracking Follow-Up Date Given Education
 EXEC dbo.WebStatus_ClosedReports_FollowUpDateGiven_Education '05/07/2018','07/07/2018'
*/
CREATE PROCEDURE [dbo].[WebStatus_ClosedReports_FollowUpDateGiven_Education]
	-- Add the parameters for the stored procedure here
    @StartDate date, 
    @EndDate date
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--declare     @StartDate date='07/01/2022', 
	--			@EndDate date = '08/05/2022'

	SELECT	a.Apno as ReportNumber,Ed.SectStat, isnull(sss.SectSubStatus,'') SectSubStatus,
			dbo.elapsedbusinessdays_2(a.ApDate, getDate() +1) as BusinessDays,
			a.ApDate as ReportCreatedDate, AF.FollowupOn As FollowupDate,Ed.Investigator, 
			Ed.School as SchoolName, C.Name as CLientName, rtrim(ltrim(Ws.Description)) as WebStatus,
			Ed.Web_Updated, MainDB.dbo.fnGetTimeZone(Ed.[ZipCode], Ed.[City], Ed.[State]) [TimeZone],
			RA.Affiliate,a.UserID CAM,Parent =CAST(c.WebOrderParentCLNO AS VARCHAR) + ' - ' + P.Name, 
			F.FollowUpDate as [Follow-up Date given], a.OrigCompDate as [Estimated Completion date]
	FROM Educat AS Ed WITH(NOLOCK)
	INNER JOIN Appl AS a WITH(NOLOCK) on a.Apno = Ed.Apno
	INNER JOIN CLient AS C WITH(NOLOCK) on a.CLNO = C.CLNO
	INNER JOIN WebSectStat AS Ws WITH(NOLOCK) on Ws.code = Ed.web_status
	INNER JOIN refAffiliate AS ra WITH (NOLOCK) ON ra.AffiliateID = c.AffiliateID
	Left JOIN FollowUp AS F WITH(NOLOCK) on a.Apno = F.Apno
	LEFT JOIN CLient AS P WITH(NOLOCK) on C.WebOrderParentCLNO = P.CLNO
	left join dbo.SectSubStatus sss with(nolock) on Ed.SectStat = sss.SectStatusCode and Ed.SectSubStatusID = sss.SectSubStatusID
	Left Join ApplSections_Followup AS AF with(Nolock) On  AF.Apno = Ed.Apno  And (Af.CompletedBy is null And AF.CompletedOn is null)  -- Sunil  Ticket - #56459 
	WHERE Ed.IsOnReport = 1 
	 AND Ed.SectStat in ('6','U') AND Ws.code = 63
     AND (CAST(a.[ApDate] AS DATE) BETWEEN @StartDate AND @EndDate)

END

