
Create VIEW [dbo].[vwApplAddress]
AS
SELECT  MAX(ApplAddressID) AS ApplAddressID, APNO, Address, City, State, zip, Country, MAX(DateStart) AS DateStart, MAX(DateEnd) AS DateEnd, MAX(IsPrimary) AS IsPrimary,isnull(max([Source]),'Appl') [Source]
FROM            (SELECT        ApplAddressID, APNO, LTRIM(RTRIM(Address)) AS Address, City, State, LEFT(Zip, 5) AS zip, Country, DateStart, DateEnd, 0 AS IsPrimary,[Source]
                          FROM            dbo.ApplAddress WITH (NOLOCK)
                          UNION ALL
                SELECT        0 AS ApplAddressID, APNO, Addr_Street AS Address, City, State, Zip, NULL as Country, NULL AS DateStart, NULL AS DateEnd, 1 AS IsPrimary,null
                FROM            dbo.Appl WITH (NOLOCK)) AS QRY
GROUP BY APNO, Address, City, State, zip, Country
