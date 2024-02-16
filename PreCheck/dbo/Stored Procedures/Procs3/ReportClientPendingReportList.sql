---------------------------------------------------------------------------------------------
/* Modified By: Vairavan A
-- Modified Date: 10/28/2022
-- Description: Main Ticketno-67221 - Update Affiliate ID Parameter Parent HDT#56320

EXEC [dbo].[ReportClientPendingReportList] '2135','5'
EXEC [dbo].[ReportClientPendingReportList] '0','4:8'
*/
-----------------------------------------------------

CREATE PROCEDURE [dbo].[ReportClientPendingReportList]
@CLNO VARCHAR(500)= '0',
@AffiliateIDs varchar(MAX) = '0'--code added by vairavan for ticket id -67221

AS

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

--code added by vairavan for ticket id -67221 starts
IF @AffiliateIDs = '0' 
BEGIN  
	SET @AffiliateIDs = NULL  
END

IF @CLNO = '0'
BEGIN  
	SET @CLNO = NULL  
END
--code added by vairavan for ticket id -67221 ends

SELECT 
	a.APNO AS 'Report Number',
	c.Name AS 'Client Name',
	a.Last AS 'Applicant Last Name',
	a.First AS 'Applicant First Name',
	a.CreatedDate AS 'Date Created'
FROM [PreCheck].[dbo].[Appl] a
LEFT OUTER JOIN [PreCheck].[dbo].[Client] c ON a.CLNO  = c.CLNO
WHERE a.ApStatus = 'P' AND (@Clno IS NULL  or a.CLNO IN (SELECT splitdata FROM dbo.fnSplitString(@CLNO,':')))
and (@AffiliateIDs IS NULL OR c.AffiliateID IN (SELECT value FROM fn_Split(@AffiliateIDs,':')))--code added by vairavan for ticket id -67221
ORDER BY a.CLNO


SET TRANSACTION ISOLATION LEVEL READ COMMITTED
