--[dbo].[WS_GetPackageInformation] 7519

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[WS_GetPackageInformation]
--DECLARE
	-- Add the parameters for the stored procedure here
	@CLNO int,
	@GetMainPackageDesc Bit =0,
	@IncludeDrugTestPackages bit = 1
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	declare @includecombopackages bit = 0
	select @includecombopackages = ConfigSettings.value('(//IncludeComboPackages)[1]','bit') 
	 from dbo.ClientConfig_iNtegration where clno = @CLNO 
--IF (select count(1) from [dbo].[ClientBusinessPackage] cpb where (cpb.Clientid = @CLNO)) = 0 
--IF (select count(1) from [dbo].[ClientBusinessPackage] cpb where (cpb.Clientid = @CLNO)) = 0 or @IncludeDrugTestPackages = 0 

SELECT P.PackageID, case when @GetMainPackageDesc = 0 then isnull(C.clientPackageDesc,PackageDesc) else PackageDesc end clientPackageDesc
--, C.Rate, ps.ServiceType, ps.IncludedCount, ps.MaxCount
FROM PackageMain P (NOLOCK)
inner join  ClientPackages C (NOLOCK) on p.packageid = c.packageid
--inner join packageservice ps (NOLOCK) on c.packageid = ps.packageid
WHERE (C.CLNO = @CLNO) and Isnull(P.refpackagetypeid,0) not in (4,5)
 
-- this will be set up when we need combo packages with oracle integration 
--else if (@IncludeDrugTestPackages = 1)
UNION ALL
SELECT cast(P.PackageID as varchar) as PackageId, case when @GetMainPackageDesc = 0 then isnull(C.clientPackageDesc,PackageDesc) else PackageDesc end clientPackageDesc
--, C.Rate, ps.ServiceTyp	e, ps.IncludedCount, ps.MaxCount
FROM PackageMain P (NOLOCK)
inner join  ClientPackages C (NOLOCK) on p.packageid = c.packageid
--inner join packageservice ps (NOLOCK) on c.packageid = ps.packageid
WHERE (C.CLNO = @CLNO) and isnull(P.refpackagetypeid,0) in (4)
UNION ALL
select cbp.PackageCode as PackageId,cbp.PackageDescription
from [dbo].[ClientBusinessPackage] cbp inner join [dbo].[ClientBusinessPackageComponent] cbpc
on cbp.ClientBusinessPackageId = cbpc.ClientBusinessPackageId
where (cbp.Clientid = @CLNO) 
and @includecombopackages = 1
END




