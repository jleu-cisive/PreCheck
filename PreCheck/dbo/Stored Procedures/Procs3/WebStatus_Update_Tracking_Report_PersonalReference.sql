-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 07/18/2017
-- Description:	Change the inline query from Qreport to Stored Procedure.
-- Modified: Add a new column affiliate
-- EXEC WebStatus_Update_Tracking_Report_PersonalReference '01/30/2020', '12/29/2020'
-- Modified By : Sahithi 11/12/2020, added new columns for Phone , email and Apno-- HDT :80996
-- Modified by Radhika Dereddy on 12/18/2020 to add InvestigatorAssignedDate 
-- =============================================
CREATE PROCEDURE [dbo].[WebStatus_Update_Tracking_Report_PersonalReference]
	-- Add the parameters for the stored procedure here
	@StartDate date, 
    @EndDate date
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;	

		 Select a.Apno as ReportNumber,PR.SectStat,
		 dbo.elapsedbusinessdays_2(a.ApDate, getDate() +1) as BusinessDays,
		 a.ApDate as ReportCreatedDate, PR.Investigator, PR.InvestigatorAssignedDate as InvestigatorAssignedDate,
		 PR.Name as Name, C.Name as CLientName, Ws.Description as WebStatus,
		 PR.Web_Updated, RA.Affiliate ,a.UserID CAM,Parent =CAST(c.WebOrderParentCLNO AS VARCHAR) + ' - ' + P.Name,
		 PR.Phone as PhoneNumber,PR.APNO,PR.Email --- HDT 80996
		 From PersRef as PR(NOLOCK)
		 Inner Join Appl a WITH (NOLOCK) on a.Apno = PR.Apno
		 Inner Join CLient C WITH (NOLOCK) on a.CLNO = C.CLNO
		 Inner Join WebSectStat Ws WITH (NOLOCK) on Ws.code = PR.web_status
		 INNER JOIN refAffiliate ra WITH (NOLOCK) ON ra.AffiliateID = c.AffiliateID
		 LEFT JOIN CLient AS P WITH(NOLOCK) on C.WebOrderParentCLNO = P.CLNO
		 WHERE PR.IsOnReport = 1 AND PR.SectStat = '9' 
		 AND (CAST(a.[ApDate] AS DATE) BETWEEN @StartDate AND @EndDate)
END
