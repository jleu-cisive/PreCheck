
-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 07/20/2017
-- Description:	ReportCount by ClientID by ResidentState
-- modified by radhika dereddy 06/07/2018
-- =============================================

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
EXEC [dbo].[ReportCount_by_ClientID_by_ResidentState] '01/01/2017','01/31/2017','TX:OH:NY',1616,8
EXEC [dbo].[ReportCount_by_ClientID_by_ResidentState] '01/01/2017','01/31/2017','TX:OH:NY',0,'4:30:8'
*/
CREATE PROCEDURE [dbo].[ReportCount_by_ClientID_by_ResidentState]
	-- Add the parameters for the stored procedure here
		 @StartDate datetime,
		 @EndDate datetime,
		 @ResidentState varchar(200),
		 @Clno Int,
		-- @AffiliateID int --code added by Sunil Mandal for ticket id -53763
		 @AffiliateIDs varchar(MAX) = '0'--code added by Sunil Mandal for ticket id -53763
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
  	
	IF(@ResidentState = '' OR LOWER(@ResidentState) = 'null') 
	BEGIN  
		SET @ResidentState = NULL  
	END

		--code added by Sunil Mandal for ticket id -53763 starts
	IF @AffiliateIDs = '0' 
	BEGIN  
		SET @AffiliateIDs = NULL  
	END
     --code added by Sunil Mandal for ticket id -53763 Ends	


		SELECT a.apno AS Apno, a.clno AS ClientID, c.name AS ClientName,rf.Affiliate, rf.AffiliateID, a.City,  a.state AS [State], a.zip,  M.[County], 
		COUNT(Apno) AS NoOfReports, MAX(dbo.elapsedbusinessdays_2(A.CreatedDate, A.OrigCompDate)) AS Turnaround, a.first AS FirstName, a.last AS LastName
		FROM dbo.Appl AS A (nolock) 
		INNER JOIN dbo.Client AS C (nolock) on C.Clno = A.Clno
		INNER JOIN [MainDB].[dbo].[ZipCode_County] AS M ON A.ZIP = M.ZIP
		INNER JOIN refAffiliate rf WITH(NOLOCK) ON c.affiliateID = rf.AffiliateID
		WHERE c.CLNO = IIF(@clno=0,c.CLNO,@CLNO)
		  AND (@ResidentState IS NULL OR a.state in (SELECT VALUE FROM fn_Split(@ResidentState,':')))
		  AND (Apdate BETWEEN @StartDate AND DATEADD(d,1,@EndDate))
		  AND A.Clno NOT IN (2135,3468)
		  --AND rf.AffiliateID = IIF(@AffiliateID=0,rf.AffiliateID,@AffiliateID) --code added by Sunil Mandal for ticket id -53763
		  AND (@AffiliateIDs IS NULL OR c.AffiliateID IN (SELECT value FROM fn_Split(@AffiliateIDs,':')))--code added by Sunil Mandal for ticket id -53763
		GROUP BY a.apno, a.clno, c.name , rf.Affiliate, rf.AffiliateID, a.City, a.state, a.zip, M.[County], a.first, a.last
		ORDER BY a.state
END



