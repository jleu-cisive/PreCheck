-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 06/25/2019
-- Description:	 Login Activity by User by Client. requested by Valerie
-- EXEC [LoginActivityByUserByClient] '','06/01/2019','06/24/2019',3115,0
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
EXEC [LoginActivityByUserByClient] '','06/01/2019','06/24/2019',3115,'0'
EXEC [LoginActivityByUserByClient] '','06/01/2019','06/24/2019',3115,'4'
EXEC [LoginActivityByUserByClient] '','06/01/2019','06/24/2022',0,'4:8'
*/
-- =============================================
CREATE PROCEDURE [dbo].[LoginActivityByUserByClient]
	-- Add the parameters for the stored procedure here
	@Username varchar(14) ='',
	@StartDate date,
	@EndDate date,
	@CLNO int = 0,
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
SELECT A.ClientID, C.Name as 'Client Name', ra.Affiliate as 'Affiliate Name', CC.FirstName, CC.LastName, A.username as 'User Name', FORMAT(A.LogDate, 'yyyy MMMM')as 'Log Month',
FORMAT(A.LogDate,'MM/dd/yyyy hh:mm tt')  as 'Log Date',
case LoginSuccess when 1 then 'True' else 'False' end  as 'Login Successful', CC.WOLockout as 'User LockOut by number of attempts'
FROM ClientAccess_Login_Audit A  with(nolock) 
INNER JOIN Client c  with(nolock) on A.clientid = C.CLNO
INNER JOIN ClientContacts CC with(nolock)  on C.CLNO = cc.CLNO and A.username = CC.username
INNER JOIN refClientType r with(nolock)  on A.ClientType = R.ClientTypeID 
INNER JOIN refAffiliate ra with(nolock)  on C.AffiliateID = ra.AffiliateID
WHERE ( A.ClientID in (SELECT CLNO FROM Client  with(nolock) WHERE WeborderParentClNO = @CLNO ) OR A.Clientid = IIF(@CLNO=0,C.CLNO,@CLNO))
and cast(A.LogDate as Date) between @StartDate and DATEADD(d,1,@EndDate)
and (A.Username = @Username or isnull(@Username,'') = '')
--and ra.AffiliateID = IIF(@AffiliateID=0,ra.AffiliateID,@AffiliateID)--code commented by vairavan for ticket id -53763(54481)
and (@AffiliateIDs IS NULL OR ra.AffiliateID IN (SELECT value FROM fn_Split(@AffiliateIDs,':')))--code added by vairavan for ticket id -53763(54481)

END


