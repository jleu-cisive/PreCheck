-- =============================================
-- Author:		DEEPAK VODETHELA	
-- Create date: 10/03/2017
-- Description:	QReport that identifies the detail's for personal reference verifications. 
-- Execution: [Personal_Reference_Detail_Report] '01/01/2017','09/30/2017',0,0
--			  [Personal_Reference_Detail_Report] '08/01/2017','08/31/2017',0,177
--			  [Personal_Reference_Detail_Report] '08/01/2017','08/31/2017',1934,0
--			  [Personal_Reference_Detail_Report] '01/01/2017','08/31/2017',12909,147
/* Modified By: Vairavan A
-- Modified Date: 07/05/2022
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
EXEC [dbo].[Personal_Reference_Detail_Report] '02/01/2020','02/15/2020','0','0'
EXEC [dbo].[Personal_Reference_Detail_Report] '02/01/2020','02/15/2020','0','4'
EXEC [dbo].[Personal_Reference_Detail_Report] '02/01/2020','02/15/2020','0','4:8'
*/
-- =============================================
CREATE PROCEDURE [dbo].[Personal_Reference_Detail_Report] 
(
	-- Add the parameters for the stored procedure here
	@StartDate DATETIME,
	@EndDate DATETIME,
	@Clno INT,
	-- @AffiliateID int--code commented by vairavan for ticket id -53763
  @AffiliateIDs varchar(MAX) = '0'--code added by vairavan for ticket id -53763
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	
		--code added by vairavan for ticket id -53763 starts
	IF @AffiliateIDs = '0' 
	BEGIN  
		SET @AffiliateIDs = NULL  
	END
	--code added by vairavan for ticket id -53763 ends

    -- Insert statements for procedure here
	SELECT	A.ApDate AS [Report Date],A.APNO AS [Report #], A.CLNO AS [Client #], C.[NAME] AS [Client Name],
			RA.AffiliateID AS [Affiliate #], REPLACE(REPLACE(RA.Affiliate, CHAR(10),';'),CHAR(13),';') AS Affiliate,
			A.[First] AS [App First Name],  A.[LAST] AS [App Last Name], P.[NAME] AS [Reference Name], S.[Description] AS [Reference Status]
	FROM dbo.PersRef AS P with(NOLOCK)
	INNER JOIN Appl AS A with(NOLOCK) ON P.APNO = A.APNO
	INNER JOIN Client AS C with(NOLOCK) ON A.CLNO = C.CLNO
	INNER JOIN SectStat AS S with(NOLOCK) ON P.SectStat = S.CODE
	INNER JOIN refAffiliate AS RA WITH (NOLOCK) ON C.AffiliateID = RA.AffiliateID
	WHERE P.SectStat  IN ('5','6','7','8')
	  AND P.IsOnReport = 1
	  AND P.IsHidden = 0
	  AND A.ApDate BETWEEN @StartDate AND DATEADD(S,-1,DATEADD(D,1,@EndDate))
	  AND A.CLNO = IIF(@CLNO = 0,A.CLNO, @CLNO)
	 -- AND RA.AffiliateID = IIF(@AffiliateID = 0,RA.AffiliateID, @AffiliateID)--code commented by vairavan for ticket id -53763
	  and (@AffiliateIDs IS NULL OR RA.AffiliateID IN (SELECT value FROM fn_Split(@AffiliateIDs,':')))--code added by vairavan for ticket id -53763
	ORDER BY A.ApDate
END


