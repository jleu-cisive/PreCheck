

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Billing_GetPackageInformation]
	-- Add the parameters for the stored procedure here
	@CLNO int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
--check for shared pricing
IF(select count(*) from clienthierarchyByService where clno = @CLNO and refHierarchyServiceID = 3) > 0
BEGIN
SET @CLNO = (select ParentCLNO from clienthierarchyByService where clno = @CLNO and refHierarchyServiceID = 3);
END

SELECT P.PackageID, P.PackageDesc, C.Rate, ps.ServiceType, ps.IncludedCount, ps.MaxCount,C.clientpackagecode
FROM PackageMain P (NOLOCK)
inner join  ClientPackages C (NOLOCK) on p.packageid = c.packageid
inner join packageservice ps (NOLOCK) on c.packageid = ps.packageid
WHERE (C.CLNO = @CLNO)
order by p.packageid 


END


