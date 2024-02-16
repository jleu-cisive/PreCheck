
CREATE PROCEDURE [dbo].[ZipCrim_WorkOrder_GetMVRs]
	@APNO int
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		a.DL_Number AS LicenseNumber, 
		'US' AS CountryCode, 
		a.DL_State AS LicenseState, 
		cast(1 as bit) AS IsCurrent,
		cast(0 as bit) AS IsForced, 
		NULL ISORegionCode,
		NULL AS LicenseClass,
		NULL AS EndorseCodes, 
		NULL AS RestricCodes, 
		cast(0 as bit) AS IsDeleted 
	FROM dbo.Appl a
	WHERE a.APNO = @APNO
END
