-- ===========================================================
-- Author:		Prasanna
-- Create date: 05/08/2018
-- Description:	Pulls reports with Entry method using daterange
/* Modified By: Vairavan A
-- Modified Date: 07/12/2022
-- Description: Ticketno-53763 
Modify existing q-reports that have affiliate ids in their search parameters
Details: 
Change search parameters for the Affiliate Id field
     * search by multiple affiliate ids (ex 4:297)
     * want to also be able to search all affiliates by putting zero - meaning 0 to search all affiliates
     * multiple affiliates to be separated by a colon  
Under Parameter Names - after Affiliate ID include this wording (separate by colon, default 0)

Child ticket id -55503 Velocity Q reports Part 2
*/
---Testing
/*
EXEC [dbo].[ReportsWithEnteredVia_CA] 0,'0','6/11/2010','6/11/2022'
EXEC [dbo].[ReportsWithEnteredVia_CA] 0,'4','6/11/2019','6/11/2022' 
EXEC [dbo].[ReportsWithEnteredVia_CA] 0,'4:8','05/11/2022','06/11/2022'
*/
-- =============================================================
CREATE PROCEDURE [dbo].[ReportsWithEnteredVia_CA]  
  	@CLNO INT,
	--@AffiliateID INT = 0,--code commented by vairavan for ticket id -53763(55503)
	 @AffiliateIDs varchar(MAX) = '0',--code added by vairavan for ticket id -53763(55503)
    @StartDate datetime,
    @EndDate datetime
AS
BEGIN


   --code added by vairavan for ticket id -53763(55503) starts
	IF @AffiliateIDs = '0' 
	BEGIN  
		SET @AffiliateIDs = NULL  
	END

	IF @CLNO = 0 
	begin 
	 select @CLNO = NULL
	end 
	--code added by vairavan for ticket id -53763(55503) ends

	select A.clno as [Client ID]
		,C.Name AS [Client Name]
		,ra.Affiliate
	    ,apno as [Report Number] 
	    ,EnteredVia as [Entry Method] 
	    ,[First] AS [First Name] 
	    ,Middle AS [Middle Name] 
	    ,[Last] AS [Last Name] 
		,FORMAT(a.ApDate, 'MM/dd/yyyy hh:mm tt') AS 'Report Create Date'
		,FORMAT(a.OrigCompDate, 'MM/dd/yyyy hh:mm tt') AS 'Original Closed Date'
		,FORMAT(a.ReopenDate, 'MM/dd/yyyy hh:mm tt') AS 'Reopen Date'
		,FORMAT(a.CompDate, 'MM/dd/yyyy hh:mm tt') AS 'Complete Date'
	 from Appl A with(Nolock)
	 	INNER JOIN dbo.Client AS C with(NOLOCK) ON A.CLNO = C.CLNO
	    INNER JOIN refAffiliate ra with (Nolock) on ra.AffiliateID = c.AffiliateID
	where (@CLNO IS NULL OR A.CLNO = @CLNO)
	 -- AND C.AffiliateID = IIF(@AffiliateID=0,C.AffiliateID,@AffiliateID)--code Commented by vairavan for ticket id -53763(55503)
	    and (@AffiliateIDs IS NULL OR c.AffiliateID IN (SELECT value FROM fn_Split(@AffiliateIDs,':')))--code added by vairavan for ticket id -53763(55503)
	  AND (apdate >=@StartDate and apdate <= @EndDate)

END


