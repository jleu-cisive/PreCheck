
--select * from [HEVN].[ClientLicenseType]
CREATE VIEW [HEVN].[ClientLicenseType]
AS
SELECT  CT.EmployerID AS CLNO,
        LT.ItemValue AS LicenseType,
		LT.Description AS Description,
        CT.LicenseType AS ClientLicenseType
	   FROM [HEVN].[dbo].[ClientLicenseType]  CT 
	   JOIN [HEVN].[dbo].[LicenseType] LT
	     ON CT.lmsLicenseTypeID = LT.LicenseTypeID 
      WHERE CT.IsActive = 1 
		AND LT.IsActive = 1
		AND LT.LicenseTypeID NOT IN (1, 2)


