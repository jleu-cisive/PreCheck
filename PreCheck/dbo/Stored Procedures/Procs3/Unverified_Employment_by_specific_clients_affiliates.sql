-- =============================================
-- Author:		Humera Ahmed
-- Create date: 10/1/2019
-- Description:	Qreport that pulls the unverified employments by date range by specific client. 
-- EXEC [dbo].[Unverified_Employment_by_specific_clients_affiliates] '9/30/2019','10/1/2019','',''
 /* Modified By: Vairavan A
-- Modified Date: 07/06/2022
-- Description: Ticketno-53763 
Modify existing q-reports that have affiliate ids in their search parameters
Details: 
Change search parameters for the Affiliate Id field
     * search by multiple affiliate ids (ex 4:297)
     * want to also be able to search all affiliates by putting zero - meaning 0 to search all affiliates
     * multiple affiliates to be separated by a colon  
Under Parameter Names - after Affiliate ID include this wording (separate by colon, default 0)

Child ticket id -54481 Update AffiliateID Parameters 971-1053
*/
---Testing
/*
EXEC [dbo].[Unverified_Employment_by_specific_clients_affiliates] '9/30/2019','10/1/2019','','0'
EXEC [dbo].[Unverified_Employment_by_specific_clients_affiliates] '9/30/2019','10/1/2019','','4'
EXEC [dbo].[Unverified_Employment_by_specific_clients_affiliates] '9/30/2019','10/1/2019','','4:8'
*/
-- =============================================
CREATE PROCEDURE [dbo].[Unverified_Employment_by_specific_clients_affiliates]
	-- Add the parameters for the stored procedure here
	@StartDate DateTime,
	@EndDate DateTime,
	@CLNO VARCHAR(500) = NULL,
	--@AffiliateID int,--code commented by vairavan for ticket id -53763(54481)
    @AffiliateIDs varchar(MAX) = '0'--code added by vairavan for ticket id -53763(54481)
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
	IF(@CLNO = '0' OR @CLNO IS NULL OR @CLNO = 'null')
	BEGIN
		SET @CLNO = ''
	END

	SELECT 
		e.Employer,
		a.APNO [Report Number],
		a.First [First Name],
		a.Last [Last Name],
		S.Description [Status],
		e.Investigator,
		format(e.InvestigatorAssigned,'MM/dd/yyyy hh:mm') [Investigator Assigned Date],
		e.Priv_Notes [Private Notes]
	FROM appl a  with(nolock)
		INNER JOIN empl e  with(nolock) ON a.APNO = e.Apno
		INNER JOIN Client   AS C with(nolock) ON A.CLNO = C.CLNO
		INNER JOIN refAffiliate AS RA   with(nolock) ON C.AffiliateID = RA.AffiliateID
		INNER JOIN dbo.SectStat   AS S(NOLOCK) ON E.SectStat = S.CODE
	WHERE 
	e.SectStat = '6'
	AND a.ApDate >= @StartDate  
	AND a.ApDate < DATEADD(DAY, 1, @EndDate)
	AND (ISNULL(@CLNO,'') = '' OR A.CLNO IN (SELECT splitdata FROM dbo.fnSplitString(@CLNO,':')))
	--AND RA.AffiliateID = IIF(@AffiliateID =0, RA.AffiliateID, @AffiliateID)--code Commented by vairavan for ticket id -53763(54481)
	and (@AffiliateIDs IS NULL OR RA.AffiliateID IN (SELECT value FROM fn_Split(@AffiliateIDs,':')))--code added by vairavan for ticket id -53763(54481)
END


