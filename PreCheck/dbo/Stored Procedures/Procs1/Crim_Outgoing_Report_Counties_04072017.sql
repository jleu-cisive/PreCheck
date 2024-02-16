CREATE PROCEDURE [dbo].[Crim_Outgoing_Report_Counties_04072017] 
(@newprintnumber int, @LockBy varchar(8), @Clear varchar(1))
AS
SET NOCOUNT ON
-- Create Batch Numbers for individual counties
-- This SP was created from dbo.Iris_Outgoing_Report_Counties
-- The differences are the number of parameters and some of criterias are different

SELECT	dbo.Appl.[Last]
	, dbo.Appl.[First]
	, dbo.Appl.Middle
	, dbo.Appl.Alias
	, dbo.Appl.Alias2
	, dbo.Appl.Alias3
	, dbo.Appl.Alias4
	, dbo.Appl.SSN
	, dbo.Appl.DOB
	, dbo.Crim.CRIM_SpecialInstr
	, dbo.Appl.Addr_Num + ' ' + dbo.Appl.Addr_Street AS address
	, dbo.Appl.City
	, dbo.Appl.State
	, dbo.Appl.Zip
	, dbo.Appl.ApStatus
	, dbo.Crim.txtlast
	, dbo.Crim.txtalias
	, dbo.Crim.txtalias2
	, dbo.Crim.txtalias3
	, dbo.Crim.txtalias4
	, dbo.Appl.Alias AS Expr1
	, dbo.Appl.Alias1_Last
	, dbo.Appl.Alias1_First
	, dbo.Appl.Alias1_Middle
	, dbo.Appl.Alias1_Generation
	, dbo.Appl.Alias2_Last
	, dbo.Appl.Alias2_First
	, dbo.Appl.Alias2_Middle
	, dbo.Appl.Alias2_Generation
	, dbo.Appl.Alias3_Last
	, dbo.Appl.Alias3_First
	, dbo.Appl.Alias3_Middle
	, dbo.Appl.Alias3_Generation
	, dbo.Appl.Alias4_Last
	, dbo.Appl.Alias4_First
	, dbo.Appl.Alias4_Middle
	, dbo.Appl.Alias4_Generation
	, dbo.Appl.Alias2 AS Expr2
	, dbo.Appl.Alias3 AS Expr3
	, dbo.Crim.[Clear] as Expr4	--dbo.Appl.Alias4 AS Expr4
	, dbo.Iris_Researchers.R_Name
	, dbo.Iris_Researchers.R_Email_Address
	, dbo.Crim.Ordered
	, dbo.Iris_Researchers.R_Zip
	, dbo.Iris_Researchers.R_Phone
	, dbo.Iris_Researchers.R_Fax
	, dbo.Iris_Researchers.R_Firstname
	, dbo.Iris_Researchers.R_Lastname
	, dbo.Iris_Researchers.R_Middlename
	, dbo.Crim.batchnumber
	, dbo.Iris_Researchers.R_VendorNotes
	, dbo.Crim.County AS Bis_Crim_County
	, dbo.Appl.APNO
	, dbo.Counties.A_County
	, dbo.Counties.State AS crimstate
	, dbo.counties.country
	, dbo.Crim.CrimID
FROM	dbo.Appl WITH (NOLOCK) 
	INNER JOIN dbo.Crim WITH (NOLOCK) 
	ON dbo.Appl.APNO = dbo.Crim.APNO 
	INNER JOIN dbo.Iris_Researchers WITH (NOLOCK) 
	ON dbo.Crim.vendorid = dbo.Iris_Researchers.R_id 
	INNER JOIN dbo.Counties WITH (NOLOCK) 
	ON dbo.Crim.CNTY_NO = dbo.Counties.CNTY_NO
WHERE	(dbo.Appl.ApStatus = 'P' OR dbo.Appl.ApStatus = 'W') 
	AND ISNULL(dbo.Appl.InUse, '') LIKE '%' + @LockBy + '%'
	AND dbo.Crim.Status = @newprintnumber
	AND dbo.Crim.[Clear] = @Clear

SET NOCOUNT OFF

