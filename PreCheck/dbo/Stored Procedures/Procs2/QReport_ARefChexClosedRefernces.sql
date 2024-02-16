-- =============================================
-- Author:		<Amy Qing Liu>
-- Create date: <03/01/2021>
-- Description:	<The QReport shows closed references for aRefChex with parameters>
-- exec [dbo].[QReport_ARefChexClosedRefernces] '02/01/2021','03/05/2021','0', 0
-- exec [dbo].[QReport_ARefChexClosedRefernces] '02/01/2021','03/05/2021','', 177
-- exec [dbo].[QReport_ARefChexClosedRefernces] '02/01/2021','03/05/2021','13308:13309:13310', 0
-- =============================================
CREATE PROCEDURE [dbo].[QReport_ARefChexClosedRefernces]
(
	@StartDate datetime,
	@EndDate datetime,
	@CLNO varchar(max),
	@AffiliateID int =0
)
AS
BEGIN
	SET NOCOUNT ON;

	DROP TABLE IF EXISTS #clnoList;
	--declare 	@StartDate datetime ='02/01/2021',
	--			@EndDate datetime = '03/05/2021',
	--			@CLNO varchar(max) ='13308:13309:13310',
	--			@AffiliateID int =0
	declare @isEmptyClno bit =0
	if(@CLNO = '' OR LOWER(@CLNO) = 'null' OR @CLNO='0')
	Begin 
		SET @isEmptyClno = 0
	end
	else
	begin
		SELECT item as clno into #clnoList from [dbo].[Split](':',@CLNO)
		--select * from #clnoList
			SET @isEmptyClno = 1
	end

	if (@isEmptyClno = 0)
	begin
	
			 select distinct  c.clno,c.name [Client Name],af.AffiliateID, af.Affiliate [Affiliate Name],pr.APNO [Report number],pr.PersRefID, (a.first +' '+ a.last) [Applicant Name], ss.Description [SectStatus], sss.SectSubStatus,wss.description [WebStatus], 
		 vvolg.OrderID ARefChexRefID,pr.DateOrdered, pr.Priv_Notes, pr.Pub_Notes, vvolg.ProcessedDate, vvolg.CreatedDate,pr.Phone, pr.email
			 FROM [dbo].[Verification_VendorOrderLog] vvolg
			inner join dbo.PersRef pr with (nolock) on vvolg.OrderID=pr.OrderId
			inner join dbo.appl a with (nolock) on a.apno= pr.APNO
			inner join dbo.client c with (nolock) on a.clno = c.CLNO
			inner join dbo.SectStat ss with (nolock) on pr.SectStat = ss.Code
			left join dbo.refAffiliate af with (nolock)  on af.AffiliateID = c.AffiliateID
			left join SectSubStatus sss with (nolock) on sss.SectStatusCode= pr.SectStat and sss.ApplSectionID=3 and sss.SectSubStatusID= pr.SectSubStatusID
			left join  Websectstat wss with (nolock) on pr.Web_Status = wss.code
			 inner join dbo.VendorAccounts va with (nolock) on vvolg.VendorID = va.VendorAccountId
			   where 
			   vvolg.OperationType='completed' and va.VendorAccountName='ARefchex'
			   and pr.DateOrdered>=@StartDate and pr.DateOrdered<=@EndDate +1
			   AND af.AffiliateID = IIF(@AffiliateID=0, af.AffiliateID, @AffiliateID)
			   AND a.clno NOT IN (2135, 3468)
	end
	else
	begin

		 select distinct c.clno,cl.clno ,c.name [Client Name],af.AffiliateID, af.Affiliate [Affiliate Name],pr.APNO [Report number],pr.PersRefID, (a.first +' '+ a.last) [Applicant Name], ss.Description [SectStatus], sss.SectSubStatus,wss.description [WebStatus], 
		 vvolg.OrderID ARefChexRefID,pr.DateOrdered, pr.Priv_Notes, pr.Pub_Notes, vvolg.ProcessedDate, vvolg.CreatedDate,pr.Phone, pr.email
			 FROM [dbo].[Verification_VendorOrderLog] vvolg
			inner join dbo.PersRef pr with (nolock) on vvolg.OrderID=pr.OrderId
			inner join dbo.appl a with (nolock) on a.apno= pr.APNO
			inner join dbo.client c with (nolock) on a.clno = c.clno
			inner join #clnoList cl with (nolock) on cl.clno = c.clno
			inner join dbo.SectStat ss with (nolock) on pr.SectStat = ss.Code
			left join dbo.refAffiliate af with (nolock)  on af.AffiliateID = c.AffiliateID
			left join SectSubStatus sss with (nolock) on sss.SectStatusCode= pr.SectStat and sss.ApplSectionID=3 and sss.SectSubStatusID= pr.SectSubStatusID
			left join  Websectstat wss with (nolock) on pr.Web_Status = wss.code
			 inner join dbo.VendorAccounts va with (nolock) on vvolg.VendorID = va.VendorAccountId
			   where 
			   vvolg.OperationType='completed' and va.VendorAccountName='ARefchex'
			   and pr.DateOrdered>=@StartDate and pr.DateOrdered<=@EndDate +1
			  AND af.AffiliateID = IIF(@AffiliateID=0, af.AffiliateID, @AffiliateID)
			 AND a.clno NOT IN (2135, 3468)
	end


END
