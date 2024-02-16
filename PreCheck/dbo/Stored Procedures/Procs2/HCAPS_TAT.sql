-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 06/05/2015
-- Description:	<Description,,>
-- Modified by: Prasanna on 09/22/2020 to change the search parameter as AffiliateId (HDT#77784)
-- Modified by Humera Ahmed on 09/25/2020 to format date columns to Precheck Standards, add column Client Name, rename CLNO to Client ID.
-- exec dbo.HCAPS_TAT 11625,'06/1/2020','06/15/2020',0
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
EXEC [dbo].[HCAPS_TAT] 0,'6/11/2021','6/11/2022','0'
EXEC [dbo].[HCAPS_TAT] 0,'6/11/2021','6/11/2022','4'
EXEC [dbo].[HCAPS_TAT] 0,'6/11/2021','6/11/2022','4:8'
*/
-- =============================================
CREATE PROCEDURE [dbo].[HCAPS_TAT]
	@CLNO int,
	@StartDate datetime,
	@EndDate datetime,
	--@AffiliateName varchar(max)=NULL,--code commented by vairavan for ticket id -53763(55503)
	@AffiliateIDs varchar(max)=NULL--code added by vairavan for ticket id -53763(55503)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--IF(LTRIM(RTRIM(@AffiliateName)) = '' OR LTRIM(RTRIM(LOWER(@AffiliateName))) = 'null') 
	--Begin  
	--	SET @AffiliateName = NULL  
	--END

    --code added by vairavan for ticket id -53763(55503) starts
	IF @AffiliateIDs = '0' 
	BEGIN  
		SET @AffiliateIDs = NULL  
	END
	--code added by vairavan for ticket id -53763(55503) ends
	
SELECT a.CLNO [ClientID], C.Name [Client Name],c.AffiliateID,RA.Affiliate, a.First as 'First Name', a.Last as 'Last Name', a.Apno as 'Report Number',
format((select top 1 date from ReleaseForm with (nolock) where clno = a.clno and date between @StartDate and @EndDate and ssn = a.ssn and first = a.First and last = a.last
order by date desc), 'MM/dd/yyyy HH:mm tt') as 'Online Release Date',
format(a.apdate,'MM/dd/yyyy HH:mm tt') as 'Created Date', (dbo.elapsedbusinessdays_2( Apdate, Origcompdate ) ) as 'TAT Days',
format(a.origcompdate,'MM/dd/yyyy HH:mm tt')  as 'Completed Date', a.Apstatus as 'Report Status', a.DeptCode as 'Process Level'
FROM appl a WITH (NOLOCK)
INNER JOIN Client C with (nolock) on A.CLNO = C.CLNO
INNER JOIN refAffiliate RA with (nolock) on RA.AffiliateID = C.AffiliateID
WHERE Apdate >= @StartDate and Apdate < @EndDate and A.CLNO = IIF(@CLNO=0,a.CLNO,@CLNO)
--AND (isnull(@AffiliateName,'')='' OR RA.Affiliate LIKE '%' + @AffiliateName + '%')
--AND C.AffiliateID = IIF(@AffiliateId=0,c.AffiliateID,@AffiliateId)--code Commented by vairavan for ticket id -53763(55503)
and (@AffiliateIDs IS NULL OR c.AffiliateID IN (SELECT value FROM fn_Split(@AffiliateIDs,':')))--code added by vairavan for ticket id -53763(55503)


END

