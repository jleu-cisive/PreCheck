
-- =============================================
-- Author:		Prasanna
-- Create date: 07/22/2016
-- Description:	Gets SantionCheck Report for Client
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

EXEC  [dbo].[GetSanctionReportPerClient]  10985,'06/01/2015','05/31/2016',4
EXEC  [dbo].[GetSanctionReportPerClient]  0,'06/01/2015','05/31/2016','4:30:177'
*/

CREATE PROCEDURE [dbo].[GetSanctionReportPerClient] --10985,'06/01/2015','05/31/2016'
	-- Add the parameters for the stored procedure here
	@clno int = 0, 
	@StartDate datetime, 
	@EndDate datetime,
	-- @AffiliateID int --code added by Sunil Mandal for ticket id -53763
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

    -- Insert statements for procedure here
	select appl.Apno,appl.CLNO, rf.Affiliate, rf.AffiliateID,appl.Last,appl.First,appl.Middle,appl.SSN,appl.DOB,sectstat.Description
	from Appl appl 
	inner join MedInteg medInteg on appl.apno = medInteg.apno
	inner join SectStat sectstat on CAST(medInteg.SectStat as char(1)) = CAST(sectstat.Code as char(1))
	INNER JOIN client c  on appl.clno = c.clno
	INNER JOIN refAffiliate rf  ON c.affiliateID = rf.AffiliateID
	where CAST(medInteg.SectStat as char(1)) <> '1' 
	and appl.ApDate between @StartDate  and  Dateadd(d,1,@EndDate)
	and	c.CLNO = IIF(@clno=0,c.CLNO,@CLNO)
	--AND rf.AffiliateID = IIF(@AffiliateID=0,rf.AffiliateID,@AffiliateID) --code added by Sunil Mandal for ticket id -53763
	AND (@AffiliateIDs IS NULL OR c.AffiliateID IN (SELECT value FROM fn_Split(@AffiliateIDs,':')))--code added by Sunil Mandal for ticket id -53763
END


