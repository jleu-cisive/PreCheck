
CREATE PROCEDURE [dbo].[ZipCrim_WorkOrder_GetMasterInfo]
	@APNO int 
AS
BEGIN
	SET NOCOUNT ON;
	SELECT 
		a.Email AS SubjectEmail,
		'Unknown' AS SubjectGender,
		c.ZipCrimClientID AS ClientCode,
		cp.ZipCrimClientPackageID AS CaseType
	FROM dbo.Appl a
	INNER JOIN client c ON c.CLNO = a.CLNO
	LEFT JOIN dbo.ClientPackages cp ON cp.CLNO = a.CLNO AND cp.PackageID = a.PackageID 
	WHERE a.APNO = @APNO
END
