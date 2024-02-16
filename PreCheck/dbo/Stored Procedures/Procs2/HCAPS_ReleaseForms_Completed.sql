-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 06/10/2015
-- Description:	<Description,,>
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
EXEC [dbo].[HCAPS_ReleaseForms_Completed] 1023, '05/01/2015', '06/09/2015','Hermann','4:8'
EXEC [dbo].[HCAPS_ReleaseForms_Completed] 1023, '05/01/2015', '06/09/2015','0'
EXEC [dbo].[HCAPS_ReleaseForms_Completed] 1023, '05/01/2015', '06/09/2015','4:8'
EXEC [dbo].[HCAPS_ReleaseForms_Completed] 0, '07/01/2022', '07/20/2022','10:129'
EXEC [dbo].[HCAPS_ReleaseForms_Completed] 12484, '07/01/2022', '07/20/2022','10:129'
*/
-- =============================================


--EXEC HCAPS_ReleaseForms_Completed 1023, '05/01/2015', '06/09/2015','Hermann'
CREATE PROCEDURE [dbo].[HCAPS_ReleaseForms_Completed] 
	-- Add the parameters for the stored procedure here
	@CLNO int,
	@StartDate datetime,
	@EndDate datetime,
	--@AffiliateName varchar(max) = NULL,--code Commented by vairavan for ticket id -53763(55503)
	 @AffiliateIDs varchar(MAX) = NULL--code added by vairavan for ticket id -53763(55503)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	 --code added by vairavan for ticket id -53763(55503) starts
	IF @AffiliateIDs = '0' 
	BEGIN  
		SET @AffiliateIDs = NULL  
	END

	If @CLNO= 0 
	begin 
	  select @CLNO = NULL
	end 
	--code added by vairavan for ticket id -53763(55503) ends

    -- Insert statements for procedure here
	
select rf.clno as 'CLNO',ra.Affiliate,c.name as 'Client Name',rf.first as 'First Name',rf.last as 'Last name',rf.date as 'Release Created Date',
(case when a.apno IS NOT NULL and a.apno <> '' then 'True' else 'False' end) as 'Report Created',a.apno as 'Report Number', 
a.apdate as 'Report Created Date', a.origcompdate as 'Report Completed Date', a.Apstatus as 'Report Status', a.DeptCode as 'Process Level'
from releaseform rf with(nolock)
inner  join client c  with(nolock) on rf.clno=c.clno
inner join refAffiliate ra with(nolock)  on ra.AffiliateID = c.AffiliateID
left outer join appl a with(nolock) on rf.ssn = a.ssn and rf.first = a.first and rf.last=a.last and rf.clno=a.clno
where rf.clno = isnull(@CLNO,rf.clno) and rf.date>= @startdate and rf.date <= @EndDate
--and (@AffiliateName IS NULL OR RA.Affiliate LIKE '%' + @AffiliateName + '%')--code Commented by vairavan for ticket id -53763(55503)
and (@AffiliateIDs IS NULL OR ra.AffiliateID IN (SELECT value FROM fn_Split(@AffiliateIDs,':')))--code added by vairavan for ticket id -53763(55503)


END

