/*
Procedure Name : [dbo].[ReleaseForms_Submitted_ByClient_ByDateRange]
Requested By: Lori McGowan
Developer: Prasanna
/* Modified By: Vairavan A'
-- Modified Date: 10/28/2022
-- Description: Main Ticketno-67221 - Update Affiliate ID Parameter Parent HDT#56320
*/
Execution : EXEC [dbo].[ReleaseForms_Submitted_ByClient_ByDateRange] 3813,'01/28/2014', '04/02/2015','63'
EXEC [dbo].[ReleaseForms_Submitted_ByClient_ByDateRange] 0,'01/28/2014', '04/02/2015','63'
*/



CREATE PROCEDURE [dbo].[ReleaseForms_Submitted_ByClient_ByDateRange] 
	@CLNO int = 0,
	@StartDate datetime,
	@EndDate datetime,
	@AffiliateIDs varchar(MAX) = '0'--code added by vairavan for ticket id -67221

AS
BEGIN


--code added by vairavan for ticket id -67221 starts
IF @AffiliateIDs = '0' 
BEGIN  
	SET @AffiliateIDs = NULL  
END
IF @CLNO = 0
BEGIN  
	SET @CLNO = NULL  
END
--code added by vairavan for ticket id -67221 ends

	select rf.CLNO, c.Name as ClientName, rf.[last] as LastName, rf.[first] as FirstName,'XXX-XX-'+Right((rf.SSN),4) as MaskedSSN, 
	case when rf.clno in (1932,1934,1935,1936,1937,2081,2993,3068,3696,3791,5559,5615,8789,9747,11104,11673,11947,12049) then rf.SSN end SSN, [Date] as ReleaseSignedDate, convert(varchar(10), rf.DOB, 110) as DOB -- Added DOB by radhika on 07/08/2015 as per Dana
    from ReleaseForm rf with(nolock)
	inner join client c on rf.CLNO = c.CLNO 
	where (@CLNO is null or rf.CLNO = @clno )
	and (Date between @StartDate and DATEADD(d,1,@EndDate))
	and (@AffiliateIDs IS NULL OR c.AffiliateID IN (SELECT value FROM fn_Split(@AffiliateIDs,':')))--code added by vairavan for ticket id -67221

END


