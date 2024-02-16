/*
Procedure Name : Client_Reports_List
Requested By: Dana Sangerhausen
Developer: Deepak Vodethela
Request ID : 6027 - Client Reports List with Start Date Detail
/* Modified By: Vairavan A
-- Modified Date: 10/28/2022
-- Description: Main Ticketno-67221 
Update Affiliate ID Parameter Parent HDT#56320
*/
Execution : 1.) EXEC Client_Reports_List 0, '08/01/2014', '08/15/2014'
			2.) EXEC Client_Reports_List 10782, '08/01/2014', '08/15/2014'

*/

CREATE PROCEDURE [dbo].[Client_Reports_List]
@Clno int = 0,
@StartDate varchar(10), 
@EndDate varchar(10),
@AffiliateIDs varchar(MAX) = '0'--code added by vairavan for ticket id -67221
AS

--code added by vairavan for ticket id -67221 starts
IF @AffiliateIDs = '0' 
BEGIN  
	SET @AffiliateIDs = NULL  
END

IF @Clno = 0 
BEGIN  
	SET @Clno = NULL  
END
--code added by vairavan for ticket id -67221 ends

SELECT a.APNO,a.First, a.Middle, a.Last, a.StartDate, a.CompDate, a.ApStatus
FROM dbo.Appl a WITH(NOLOCK)
	 Left JOIN dbo.Client c with(nolock) ON a.CLNO = c.CLNO--code added by vairavan for ticket id -67221
WHERE @StartDate IS NULL OR ApDate >= @StartDate
  AND ApDate < DATEADD(DAY, 1, @EndDate)
  AND (@Clno IS NULL OR a.CLNO = @Clno)
   and (@AffiliateIDs IS NULL OR c.AffiliateID IN (SELECT value FROM fn_Split(@AffiliateIDs,':')))--code added by vairavan for ticket id -67221
ORDER BY a.CLNO, a.ApDate

