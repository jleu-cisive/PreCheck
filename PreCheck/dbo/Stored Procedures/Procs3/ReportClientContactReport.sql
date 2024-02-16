-- EXEC [dbo].[ReportClientContactReport] '2135:7032'
-----------------------------------------------
-- Modified By: Radhika Dereddy
-- Modified Date: 07/23/2019
-- Description: HDT#55567 making a change to the report to add affiliate.
--------------------------------------------------
-- Modified By: Vairavan A
-- Modified Date: 06/14/2022
-- Description: Ticketno-38155, Client Contact Report update to include user ID and date of last log-in
/* Modified By: Vairavan A
-- Modified Date: 06/30/2022
-- Description: Main Ticketno-53763 
Modify existing q-reports that have affiliate ids in their search parameters
Details: 
Change search parameters for the Affiliate Id field
     * search by multiple affiliate ids (ex 4:297)
     * want to also be able to search all affiliates by putting zero - meaning 0 to search all affiliates
     * multiple affiliates to be separated by a colon  
Under Parameter Names - after Affiliate ID include this wording (separate by colon, default 0)

Subticket id -54476 Update AffiliateID Parameter 130-429
*/
---Testing
/*
EXEC ReportClientContactReport 0,'0'
EXEC ReportClientContactReport 0,'4'
EXEC ReportClientContactReport 0,'4:30'
*/
-----------------------------------------------

CREATE PROCEDURE [dbo].[ReportClientContactReport] 
@CLNO VARCHAR(500),
--@AffiliateId int--code commented by vairavan for ticket id -54476
@AffiliateIDs varchar(MAX) = '0'--code added by vairavan for ticket id -54476
AS
BEGIN
SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

   --code added by vairavan for ticket id -54476 starts
	IF @AffiliateIDs = '0' 
	BEGIN  
		SET @AffiliateIDs = NULL  
	END
	--code added by vairavan for ticket id -54476 ends

SELECT 
	cc.CLNO AS [Account Number],
	c.[Name] AS [Client Name],
	CASE WHEN FirstName IS NOT NULL OR FirstName <> '' THEN FirstName ELSE '' END AS [First Name],  
	CASE WHEN LastName IS NOT NULL OR LastName <> '' THEN LastName ELSE '' END AS [Last Name],
	CASE WHEN cc.Phone IS NOT NULL OR cc.Phone <> '' THEN cc.Phone ELSE '' END AS Phone, 
	CASE WHEN cc.Email IS NOT NULL OR cc.Email <> '' THEN cc.Email ELSE '' END AS Email,
	CASE WHEN Title IS NOT NULL OR Title <> '' THEN Title ELSE '' END AS Title, 
	--code addd by vairavan for ticket no - 38155 starts
	cc.username as username,
	cast(NULL  as datetime) as  last_login_date
	into #tmp
	--code addd by vairavan for ticket no - 38155 ends
FROM [PreCheck].[dbo].[ClientContacts] cc WITH(NOLOCK)
INNER JOIN [PreCheck].[dbo].[Client] c  WITH(NOLOCK) ON c.CLNO = cc.CLNO
INNER JOIN [Precheck].[dbo].[refAffiliate] rf  WITH(NOLOCK) ON c.AffiliateID = rf.AffiliateID
WHERE cc.CLNO IN (SELECT splitdata FROM dbo.fnSplitString(@CLNO,':')) OR  cc.CLNO = IIF(@CLNO=0, cc.CLNO, @CLNO)
--AND rf.AffiliateId = IIF(@AffiliateID =0, rf.AffiliateID, @AffiliateID)--code commented by vairavan for ticket id -54476
and (@AffiliateIDs IS NULL OR rf.AffiliateID IN (SELECT value FROM fn_Split(@AffiliateIDs,':')))--code added by vairavan for ticket id -54476
ORDER BY cc.CLNO, FirstName

--code addd by vairavan for ticket no - 38155 starts
;with cte as (
select Clientid,username,convert(datetime,max(logdate)) as max_logdate
from ClientAccess_Login_Audit  with (nolock)
group by Clientid,username
)

Update a 
set a.last_login_date = convert(datetime,b.max_logdate)
from #tmp a 
	 inner join 
	 cte b 
on(a.[Account Number] = b.clientid 
and  a.username = b.username
  )

 select * from #tmp
 --code addd by vairavan for ticket no - 38155 ends

SET TRANSACTION ISOLATION LEVEL READ COMMITTED

END


