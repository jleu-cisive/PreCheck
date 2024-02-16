-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 09/11/2018 (Old Report)
-- Description:	Create a stored procedure from an inline query
-- EXEC Client_Revenue_byMonth_orCLientID 2167, 117
-------------------------------------------------------------
/* Modified By: Vairavan A
-- Modified Date: 06/27/2022
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
EXEC Client_Revenue_byMonth_orCLientID 1047,'8:22'
EXEC Client_Revenue_byMonth_orCLientID 0,'8'
*/
-- =============================================
CREATE PROCEDURE [dbo].[Client_Revenue_byMonth_orCLientID]	
	@CLNO int,
	--@AffiliateID int,--code commented by vairavan for ticket id -53763
    @AffiliateIDs varchar(MAX) = '0'--code added by vairavan for ticket id -53763
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

	SELECT invoicenumber,im.clno,invdate as 'invoicing date',sale,tax,(sale + tax) as total 
	FROM INVMASTER im with(nolock) 
	INNER JOIN Client c with(nolock) on im.CLNO = c.CLNO
	INNER JOIN refAffiliate rf with(nolock) on c.AffiliateID = rf.AffiliateID
	WHERE im.clno = @CLNO 
	--OR c.AffiliateID =IIF(@AffiliateID=0,C.AffiliateID,@AffiliateID)--code commented by vairavan for ticket id -53763
	 OR (@AffiliateIDs IS NULL OR c.AffiliateID IN (SELECT value FROM fn_Split(@AffiliateIDs,':')))--code added by vairavan for ticket id -53763
	order by invdate DESC
END
