
-- =============================================
-- Author:		<Arindam Mitra>
-- Requested by: Michelle Paz HDT:124404  
-- Create date: <01/29/2024>
-- Description:	The QReport shows closed references for HarverCheckster with parameters.
-- exec [dbo].[QReport_HarverChecksterClosedRefernces] '01/01/2024','01/31/2024','0', '0'
-- =============================================
CREATE PROCEDURE [dbo].[QReport_HarverChecksterClosedRefernces]
(
	@StartDate datetime,
	@EndDate datetime,
	@CLNO varchar(max),
	@AffiliateID varchar(MAX)
)
AS
BEGIN
	SET NOCOUNT ON;

	if(@CLNO = '' OR LOWER(@CLNO) = 'null') OR @CLNO = ''
	Begin  
		SET @CLNO = NULL  
	END  

IF @AffiliateId = '0' 
	BEGIN  
		SET @AffiliateId = NULL  
	END
	
	
			  select distinct  c.clno,c.name [Client Name],af.AffiliateID, af.Affiliate [Affiliate Name],pr.APNO [Report number],pr.PersRefID, (a.first +' '+ a.last) [Applicant Name], ss.Description [SectStatus], sss.SectSubStatus,wss.description [WebStatus], 
		 vvolg.OrderID HarverChecksterRefID, pr.DateOrdered, pr.Priv_Notes, pr.Pub_Notes, vvolg.ProcessedDate, vvolg.CreatedDate,pr.Phone, pr.email
			 FROM [dbo].[Verification_VendorOrderLog] vvolg with (nolock)
			inner join dbo.PersRef pr with (nolock) on vvolg.OrderID=pr.OrderId
			inner join dbo.appl a with (nolock) on a.apno= pr.APNO
			inner join dbo.client c with (nolock) on a.clno = c.CLNO
			inner join dbo.SectStat ss with (nolock) on pr.SectStat = ss.Code
			left join dbo.refAffiliate af with (nolock)  on af.AffiliateID = c.AffiliateID
			left join SectSubStatus sss with (nolock) on sss.SectStatusCode= pr.SectStat and sss.ApplSectionID=3 and sss.SectSubStatusID= pr.SectSubStatusID
			left join  Websectstat wss with (nolock) on pr.Web_Status = wss.code
			 inner join dbo.VendorAccounts va with (nolock) on vvolg.VendorID = va.VendorAccountId
			   where 
			   vvolg.OperationType='completed' and va.VendorAccountName='HarverCheckster'
			   and pr.DateOrdered>=@StartDate and pr.DateOrdered<=@EndDate +1
			   AND (@CLNO IS NULL OR c.CLNO IN (SELECT * from [dbo].[Split](':',@CLNO))) 
			   AND (@AffiliateId IS NULL OR af.AffiliateId IN (SELECT value FROM fn_Split(@AffiliateId,':')))
			   AND a.clno NOT IN (2135, 3468)
	


END
