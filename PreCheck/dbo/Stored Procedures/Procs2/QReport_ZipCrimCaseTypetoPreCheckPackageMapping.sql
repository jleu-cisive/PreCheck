-- =============================================
-- Author:		<Amy Liu>
-- Create date: <07/21/2021>
-- Description:	<QReport pull ZipCrim CaseType to PreCheckPackage Mapping>
--[dbo].[QReport_ZipCrimCaseTypetoPreCheckPackageMapping] 0,0,252
--[dbo].[QReport_ZipCrimCaseTypetoPreCheckPackageMapping] 0,0,0
--[dbo].[QReport_ZipCrimCaseTypetoPreCheckPackageMapping] 7519,0,0
--[dbo].[QReport_ZipCrimCaseTypetoPreCheckPackageMapping] 0,1050,0
-- =============================================
CREATE PROCEDURE [dbo].[QReport_ZipCrimCaseTypetoPreCheckPackageMapping] 
( @ParnetCLNO  varchar(10) ='all',
  @FacilityNo int =0,
  @AffiliateID int =0
)
AS
BEGIN

	SET NOCOUNT ON;
	
	 
	--declare  @ParnetCLNO  varchar(10) ='all',
	--  @FacilityNo int =10692 ,  --0  ,  --12725,
	--  @AffiliateID int =0  --252

	  if (@ParnetCLNO='all' or @ParnetCLNO = null) set @ParnetCLNO=-1

			select distinct  c.clno as PreCheckCLNO, c.Name as PreCheckClientName ,  af.Affiliate as PreCheckAffiliate, 
			pm.PackageDesc as PreCheckPackageName, pm.PackageID as PreCheckPackageID,
			c.ZipCrimClientID AS ZipCrimClientCode,cp.ZipCrimClientPackageID AS ZipCrimCaseType, c.AffiliateID,c.WebOrderParentCLNO ParentCLNO
			from dbo.ClientPackages cp (nolock)
			inner join dbo.client c (nolock) on cp.clno = c.clno and cp.ZipCrimClientPackageID is not null
			inner join  dbo.PackageMain pm (nolock) on pm.PackageID = cp.PackageID
			left join dbo.refAffiliate af (nolock) on af.AffiliateID = c.AffiliateID
			where 
				af.AffiliateID = IIF(isnull(@AffiliateID,0)=0, af.AffiliateID, @AffiliateID)
			and isnull(c.WebOrderParentCLNO,-1) = IIf( isnull(@ParnetCLNO,-1) =-1, isnull(c.WebOrderParentCLNO,-1), @ParnetCLNO)
			and c.clno = IIF(isnull(@FacilityNo, 0)= 0, c.CLNO,  @FacilityNo)
			--and cp.clno =16752 and cp.PackageID=1517
			order by c.clno
END

