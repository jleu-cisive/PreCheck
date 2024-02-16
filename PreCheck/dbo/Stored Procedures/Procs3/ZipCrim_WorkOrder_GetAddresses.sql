CREATE PROCEDURE [dbo].[ZipCrim_WorkOrder_GetAddresses]
	@APNO int
AS
BEGIN
	SET NOCOUNT ON;
	SELECT 
		a.ApplAddressID, 
		a.Address AS StreetName, 
		NULL AS Address2, 
		a.City,
		a.State, 
		a.Zip AS ZipCode,
		a.Country AS CountryCode, 
		cast(a.IsPrimary as bit) AS IsCurrent, 
		--convert(varchar, DateStart,25) AS ReportedFromDate,  
		--convert(varchar, DateEnd, 25) AS ReportedToDate,
		FORMAT (DateStart, 'yyyy-MM-dd') AS ReportedFromDate,
		FORMAT (DateEnd, 'yyyy-MM-dd') AS ReportedToDate,
		NULL AS AddressFormat, 
		cast(0 as bit) AS IsDeleted 
	FROM dbo.vwApplAddress a 
	WHERE a.APNO = @APNO
	  AND (DateEnd IS NULL OR DATEDIFF(YEAR, DateEnd, GETDATE()) <= 7) --VD:02252020-Per Dana (Bug#85244) relaxing this condition.
END