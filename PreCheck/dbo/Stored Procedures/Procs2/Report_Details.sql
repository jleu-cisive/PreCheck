
-- =========================================================================================
-- Author:		Suchitra Yellapantula
-- Create date: 08/30/2016
-- Description:	Get Report Details --2015-08-01--,--2016-08-01--
-- Execution: EXEC [dbo].[Report_Details] '06/01/2019','06/25/2019'
-- Modified by: Radhika Dereddy to include affiliate column.
-- Modified by: Radhika Dereddy on 07/05/2018 to change an existing column EnteredBy to EnteredVia(there was a duplicate entry of the same column).
-- Modified by Humera Ahmed on 6/25/2019 for HDT#53733 - To add 6 new columns
-- Modified By Radhika Dereddy on 06/25/2019 for CAM it is USERID in APPL, added First App Date Yr/Mo
-- Modified by Doug DeGenaro on 03/28/2021 for Brian Silver to add three new columns InProgressReviewed,AutoClosed,and ReportStatus
-- Modified by Abhijit Awari on 07/08/2022 for HDT#3645 
-- EXEC [Report_Details] '04/09/2021','04/10/2021',0
-- =========================================================================================

/* Modified By: Sunil Mandal A
-- Modified Date: 06/29/2022
-- Description: Ticketno-53763 
Modify existing q-reports that have affiliate ids in their search parameters
Details: 
Change search parameters for the Affiliate Id field
     * search by multiple affiliate ids (ex 4:297)
     * want to also be able to search all affiliates by putting zero - meaning 0 to search all affiliates
     * multiple affiliates to be separated by a colon  
Under Parameter Names - after Affiliate ID include this wording (separate by colon, default 0)
*/
---Testing
/*

EXEC [Report_Details] '04/09/2021','04/10/2021','0'
EXEC [Report_Details] '04/09/2021','04/10/2021','4:30:158'
*/

CREATE PROCEDURE [dbo].[Report_Details] 
	-- Add the parameters for the stored procedure here
	@StartDate datetime,
	@EndDate datetime,
	-- @AffiliateId int -code added by Sunil Mandal for ticket id -53763
	@AffiliateIDs varchar(MAX) = '0'--code added by Sunil Mandal for ticket id -53763
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

		--code added by Sunil Mandal for ticket id -53763 starts
	IF @AffiliateIDs = '0' 
	BEGIN  
		SET @AffiliateIDs = NULL  
	END
     --code added by Sunil Mandal for ticket id -53763 Ends	

	DROP TABLE IF EXISTS #tempReports
	
	SELECT APNO, ApDate, CLNO, ClientName, OrigCompDate, CAM, InProgressReviewed INTO #tempReports
	FROM
	(
		SELECT APNO, ApDate, A.CLNO, C.Name AS ClientName, A.OrigCompDate, A.UserID AS CAM, InProgressReviewed
			FROM dbo.Appl(NOLOCK) AS A
			INNER JOIN dbo.Client AS C(NOLOCK) ON A.CLNO = C.CLNO
			WHERE ApStatus in ('F','P','M') --Updated by Abhijit Awari on 07/08/2022 for HDT#3645
			AND A.CLNO NOT IN (2135)--Updated by Abhijit Awari on 07/08/2022 for HDT#3645
	)A

	SELECT	CONVERT(VARCHAR(10),A.ApDate,101)  as 'Report Created Date', 
			CONVERT(VARCHAR(10),A.Apdate,108) as 'Report Created Time',
			Format(A.ApDate, 'tt') as 'Report Created AM/PM', 
			A.APNO as 'Report Number', A.EnteredBy, A.UserID as 'CAM', A.EnteredVia, 
			C.CLNO as 'Client Number',C.Name as 'Client Name', rct.ClientType,
			A.First as 'Applicant First Name',A.Last as 'Applicant Last Name',  
			rf.Affiliate as Affiliate, c.AffiliateID as AffiliateID,
			(CASE WHEN CC.[Value] = 'False' THEN 'False' ELSE 'True' END ) AS [Auto Order Enabled],
			CASE WHEN IsNull(T.InProgressReviewed,0) = 0 THEN 'False' ELSE 'True' END AS InProgressReviewed, --Added 03/28/2022 Doug
			CASE WHEN AACL.ClosedOn IS NULL THEN 'False' ELSE 'True' END AS AutoClosed, --Added 03/28/2022 Doug
			--case when a.ApStatus in ('P','W') then 'Pending' when a.ApStatus in ('F') then 'Completed' end as ReportStatus, --Added 03/28/2022 Doug
			case when a.ApStatus in ('W','M') then 'On Hold' 
			when a.ApStatus in ('P') then 'Pending' 
			when a.ApStatus in ('F') then 'Completed' end as ReportStatus, --Added by Abhijit Awari on 07/08/2022 for HDT#3645
			(Case when C.IsInActive = 0 then 'False' else 'True' end ) as IsInactive,
			--Format(min(a.apdate), 'yyyy MMMM') as 'First App Date Yr/Mo'
			(select Format(min(apdate), 'yyyy MMMM') from Appl where CLNO = a.CLNO ) AS 'First App Date Yr/Mo',
			(select Format(min(apdate), 'MM/dd/yyyy hh:mm tt') from Appl where CLNO = a.CLNO ) AS 'First App Date',
			(select Format(max(apdate), 'MM/dd/yyyy hh:mm tt') from Appl where CLNO = a.CLNO ) AS 'Last App Date',
			a.EnteredVia, ISNULL(cp.PackageID, pm.PackageID) as PackageID,
			pm.PackageDesc as PackageOrdered
	FROM dbo.Appl A(NOLOCK)
	INNER JOIN dbo.Client C(NOLOCK) on A.CLNO = C.CLNO
	INNER JOIN dbo.refAffiliate rf(NOLOCK) on c.AffiliateID = rf.AffiliateID
	INNER JOIN #tempReports AS T ON A.Apno = T.APNO
	LEFT OUTER JOIN dbo.ApplAutoCloseLog AS AACL(NOLOCK) ON T.APNO = AACL.Apno
	LEFT OUTER JOIN dbo.ClientConfiguration AS CC(NOLOCK) ON A.CLNO = CC.CLNO AND CC.ConfigurationKey = 'AUTOORDER'
	INNER JOIN dbo.refClientType rct(NOLOCK) ON C.ClientTypeID = rct.ClientTypeID
	INNER JOIN dbo.ClientPackages cp(NOLOCK) on a.PackageID = cp.PackageiD 
	INNER JOIN dbo.PackageMain pm(NOLOCK) on cp.PackageID = pm.PackageID
	WHERE A.ApDate between @StartDate and DATEADD(d,1,@EndDate)
		-- AND c.AffiliateId = IIF(@AffiliateId=0,C.AffiliateId,@AffiliateId) --code added by Sunil Mandal for ticket id -53763
		AND (@AffiliateIDs IS NULL OR c.AffiliateID IN (SELECT value FROM fn_Split(@AffiliateIDs,':'))) --code added by Sunil Mandal for ticket id -53763
	GROUP BY A.ApDate, A.APNO, A.EnteredBy, A.CAM, A.EnteredVia, C.Clno,C.Name, rct.ClientType, 
		A.First, A.Last,rf.Affiliate, C.AffiliateID, CC.[Value], C.IsInactive, A.UserID, A.CLNO,
		a.EnteredVia,ISNULL(cp.PackageID, pm.PackageID), pm.PackageDesc,T.InProgressReviewed,
		AACL.ClosedOn,A.ApStatus
	


END
