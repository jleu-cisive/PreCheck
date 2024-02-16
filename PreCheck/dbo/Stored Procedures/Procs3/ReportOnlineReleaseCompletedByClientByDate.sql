/* Modified By: Vairavan A
-- Modified Date: 10/28/2022
-- Description: Main Ticketno-67221 - Update Affiliate ID Parameter Parent HDT#56320
exec  [dbo].[ReportOnlineReleaseCompletedByClientByDate] '15420:17686','03/12/2020','09/18/2022','230:123'
exec  [dbo].[ReportOnlineReleaseCompletedByClientByDate] '0','03/12/2020','09/18/2022','230:123'
*/

CREATE procedure [dbo].[ReportOnlineReleaseCompletedByClientByDate]
(
@CLNO VARCHAR(500)='0',
@StartDate Datetime,
@EndDate Datetime,
@AffiliateIDs varchar(MAX) = '0'--code added by vairavan for ticket id -67221
) AS
BEGIN

SET NOCOUNT ON

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

SELECT a.CLNO, a.first AS 'First Name', a.last AS 'Last Name', a.dob AS 'Date of Birth', a.ssn AS SSN, a.date AS 'Created Date', a.EnteredVia AS 'Entered Via'
FROM [PreCheck].[dbo].[ReleaseForm] a with(nolock)
     Left JOIN dbo.Client e with(nolock) ON a.CLNO = e.CLNO--code added by vairavan for ticket id - 67221
WHERE 
	(@CLNO is null or a.CLNO IN (SELECT splitdata FROM dbo.fnSplitString(@CLNO,':'))) AND
	(CONVERT(DATETIME, FLOOR(CONVERT(FLOAT, Date))) >= @StartDate AND CONVERT(DATETIME, FLOOR(CONVERT(FLOAT, Date))) < = @EndDate)
	and (@AffiliateIDs IS NULL OR e.AffiliateID IN (SELECT value FROM fn_Split(@AffiliateIDs,':')))--code added by vairavan for ticket id -67221
ORDER BY a.CLNO, a.EnteredVia, a.date DESC

SET TRANSACTION ISOLATION LEVEL READ COMMITTED

END
