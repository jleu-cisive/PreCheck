-- =============================================
-- Author:		Humera Ahmed
-- Create date: 6/11/2019
	/*Description:Please create new q-report to mirror  - existing q-report: Unbilled Service charges by Client #

	1) Add Date Range in the Search Parameters
	2) Allow to search by all clients as well as individual client id/number
	3) Add Affiliate ID in the search Parameters as well as a column named Affiliate
	4)  Change the current Date columns to the below Date format.
	mm/dd/yyyy hh:mm AM/PM (ex. 05/01/2019 01:01 PM)
	*/
--EXEC [dbo].[Qreport_UnbilledServiceChargesByDate] '6/11/2019','6/11/2019' ,'0',0
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
EXEC [dbo].[Qreport_UnbilledServiceChargesByDate] '6/11/2019','6/11/2022' ,'0','0'
EXEC [dbo].[Qreport_UnbilledServiceChargesByDate] '6/11/2019','6/11/2022' ,'0','4'
EXEC [dbo].[Qreport_UnbilledServiceChargesByDate] '6/11/2019','6/11/2022' ,'0','4:8'
*/
-- =============================================
CREATE PROCEDURE [dbo].[Qreport_UnbilledServiceChargesByDate] 
	-- Add the parameters for the stored procedure here
	@StartDate datetime,
	@Enddate datetime,
	@CLNO VARCHAR(MAX) = '0',
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
	SELECT 
		app.APNO AS [App #]
		, cl.CLNO AS [Client #]
		, cl.[NAME] AS [Client Name] 
		, cl.AffiliateID
		, ra.Affiliate AS [Affiliate Name]
		, FORMAT(app.ApDate, 'MM/dd/yyyy hh:mm tt') AS [Application Date]
		, FORMAT(CompDate, 'MM/dd/yyyy hh:mm tt') AS [Completed Date] 
		, FORMAT(ReopenDate, 'MM/dd/yyyy hh:mm tt') AS [ReOpen Date]
		, FORMAT(OrigCompDate, 'MM/dd/yyyy hh:mm tt') AS [Orginal Completion Date] 
		,DESCRIPTION as [Description],AMOUNT as [Amount]  
		, pm.PackageDesc [Package Name], cp.Rate [Package Price] 
	FROM DBO.[INVDETAIL] inv WITH (NOLOCK)    
		INNER JOIN DBO.[APPL] app WITH (NOLOCK)    ON inv.APNO = app.APNO     
		INNER JOIN DBO.[CLIENT] cl WITH (NOLOCK)    ON app.[CLNO] = cl.[CLNO]   
		INNER JOIN dbo.refAffiliate ra WITH (NOLOCK) on  cl.AffiliateID = ra.AffiliateID
		INNER JOIN dbo.PackageMain pm WITH (NOLOCK) ON app.PackageID = pm.PackageID
		INNER JOIN dbo.ClientPackages cp WITH (NOLOCK) ON app.PackageID = cp.PackageID AND app.CLNO = cp.CLNO
		
	WHERE inv.[BILLED] = 0 and Amount > 0  
	AND (@clno ='0' OR app.[CLNO] IN (SELECT VALUE FROM fn_Split(@clno,':')))
	AND app.ApDate >=@StartDate AND app.ApDate<=dateadd(d,1,@EndDate)   
	--AND (cl.AffiliateID = IIF(@AffiliateID=0,cl.AffiliateID,@AffiliateID))  --code commented by vairavan for ticket id -53763
	and (@AffiliateIDs IS NULL OR cl.AffiliateID IN (SELECT value FROM fn_Split(@AffiliateIDs,':')))--code added by vairavan for ticket id -53763(54481)
	order by APDATE DESC
END



