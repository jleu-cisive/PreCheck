
CREATE VIEW [Enterprise].[vwLicenseType]
AS
SELECT        7 AS DynamicAttributeTypeId, LicenseTypeID AS DynAttributeId, Item AS ItemName, ItemValue AS ShortName
FROM            HEVN.dbo.LicenseType
WHERE        (IsActive = 1) AND (IsCredentiable = 1) AND (ItemValue <> 'e')

