-- Alter Procedure FormCrimOnlineGetApplicationCounty
CREATE PROCEDURE dbo.FormCrimOnlineGetApplicationCounty
(@APNO int, @PrimaryVendorID int)
AS
SET NOCOUNT ON

SELECT	C.CrimID, C.CNTY_NO
	, CASE 	WHEN C.VendorID = @PrimaryVendorID THEN '|||| '
		ELSE ''
	  END + C2.A_County + ', ' + C2.State + ', ' + C2.Country AS County
	, CASE 	WHEN C.VendorID = @PrimaryVendorID THEN 1
		ELSE 0
	  END AS IsPrimary
FROM	dbo.Crim C WITH (NOLOCK) 
	INNER JOIN dbo.TblCounties C2 WITH (NOLOCK)
	ON C.CNTY_NO = C2.CNTY_NO
WHERE	C.APNO = @APNO
ORDER BY IsPrimary DESC, C2.A_County, C.CrimID ASC

SET NOCOUNT OFF
