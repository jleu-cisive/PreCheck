-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 04/13/2020
-- Description:	Component Fees FOr Reports to Validate PowerBI visualizations.
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
EXEC [dbo].[ComponentFeesForReports] '2022','01','0'
EXEC [dbo].[ComponentFeesForReports] '2022','01','4'
EXEC [dbo].[ComponentFeesForReports] '2022','01','4:8'
*/
-- =============================================
CREATE PROCEDURE [PRECHECK\VAzagappan].ComponentFeesForReports 
	-- Add the parameters for the stored procedure here
	@InvoiceYear varchar(4),
	@InvoiceMonth varchar(2),
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
	SELECT i.APNO as [Report Number], c.CLNO as ClientId, c.Name as [Client Name], rf.Affiliate as [Affiliate Name],a.Apdate as [App Created Date],
	i.Type, i.InvoiceNumber, i.Billed, i.CreateDate as [Invoice CreatedDate], i.Description, i.Amount
	FROM InvDetail i  with(nolock)
	INNER JOIN Appl a with(nolock) ON i.apno = a.apno
	INNER JOIN Client c with(nolock) ON a.CLNO = c.clno
	INNER JOIN refAffiliate rf with(nolock) ON c.AffiliateID = rf.AffiliateID
	WHERE
	--(c.AffiliateID = IIF(@AffiliateID=0,cl.AffiliateID,@AffiliateID))  --code commented by vairavan for ticket id -53763
	 (@AffiliateIDs IS NULL OR c.AffiliateID IN (SELECT value FROM fn_Split(@AffiliateIDs,':')))--code added by vairavan for ticket id -53763(54481)
	AND Year(i.CreateDate) = @InvoiceYear
	AND Month(i.CreateDate) = @InvoiceMonth 
	AND i.Type in (1,6,7)
	AND a.Billed = 1
	AND i.InvoiceNumber IS NOT NULL

END

