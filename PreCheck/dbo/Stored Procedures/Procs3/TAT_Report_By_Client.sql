-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 06/07/2018
-- Description:	Changed the inline queery to a Stored procedure to modified it for Valerie's request to include Affiliate
-- Modified By: Amy Liu on 07/12/2018: HDT35901 requested by Valerie K. Salazar
-- Modified By: Humera Ahmed on 10/12/2021: HDT# 21823 - Please add CAM column in between the Affiliate and Report Status columns
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
EXEC [dbo].[TAT_Report_By_Client] '09/01/2018','09/14/2018', 0, '0'
EXEC [dbo].[TAT_Report_By_Client] '09/01/2018','09/14/2018', 0,'114:125'
*/
-- =============================================
CREATE PROCEDURE [dbo].[TAT_Report_By_Client]
	-- Add the parameters for the stored procedure here
	@StartDate datetime,
	@EndDate datetime,
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

    -- Insert statements for procedure here
		SELECT a.apno AS [Report Number] ,c.clno AS [Client ID], c.name AS [Client Name], rf.Affiliate AS Affiliate, rf.AffiliateID AS [Affiliate ID], 
		a.UserID [CAM],
		 a.apstatus as [Report Status], 
		a.last AS [App Last],a.first AS [App First],a.middle AS [App Middle], FORMAT(rform.date,'MM/dd/yyyy hh:mm tt') AS [Online Release Completed],
		FORMAT(a.apdate,'MM/dd/yyyy hh:mm tt') as [Create Date], FORMAT(a.origcompdate,'MM/dd/yyyy hh:mm tt') as [Original Completed Date], 
		FORMAT(a.reopendate,'MM/dd/yyyy hh:mm tt') as [Reopen Date], FORMAT(a.compdate,'MM/dd/yyyy hh:mm tt') as [Completed Date], 
		 dbo.elapsedbusinessdays_2(a.apdate,a.origcompdate) AS [Elapsed Biz Days], 
		replace(description,'Package: ' ,'') AS [Package Ordered]
		from appl a with (nolock) 
		INNER JOIN client c with (nolock) on a.clno = c.clno
		INNER JOIN refAffiliate rf WITH(NOLOCK) ON c.affiliateID = rf.AffiliateID
		LEFT OUTER JOIN 
		(
			SELECT description, CLNO, Apno 
			FROM invmaster m WITH (NOLOCK) 
			INNER JOIN invdetail d WITH (NOLOCK) on  m.InvoiceNumber = d.InvoiceNumber 
			WHERE billed =1 and	 CLNO = IIF(@clno=0,CLNO,@CLNO)  and description like 'package%'
		) Inv on a.Apno = Inv.Apno and a.CLNO = Inv.CLNO  
		OUTER APPLY	
		(
			SELECT TOP 1 * FROM 
			[dbo].[ReleaseForm]  rform with(nolock) where  a.ssn=rform.ssn AND a.First= rform.first AND a.last= rform.last  ORDER BY rform.date desc
		)rform
		WHERE c.clno = IIF(@clno=0,c.CLNO,@CLNO)  
		and a.apdate >= @StartDate and a.apdate < Dateadd(d,1,@EndDate)
		--AND rf.AffiliateID = IIF(@AffiliateID=0,rf.AffiliateID,@AffiliateID)--code commented by vairavan for ticket id -53763.
		and (@AffiliateIDs IS NULL OR rf.AffiliateID IN (SELECT value FROM fn_Split(@AffiliateIDs,':')))--code added by vairavan for ticket id -53763
END

