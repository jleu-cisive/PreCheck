CREATE PROCEDURE dbo.Crim_GetVendorResend
(@LockBy varchar(8), @Clear varchar(1))
AS
SET NOCOUNT ON
--created from the sp, dbo.Crim_GetReadyToSend
--the differences are the parameters and criterias

SELECT 	C.APNO
	, C.CrimID
	, C.CNTY_NO 
	, C.VendorID 
	, C.Status
	, C.BatchNumber
	, IR.R_Delivery
	, IR.R_Name
	, IR.R_Fax 
	, IR.R_Email_Address
FROM 	dbo.Appl A WITH (NOLOCK)
	INNER JOIN dbo.Crim C WITH (NOLOCK)
	ON A.APNO = C.APNO
	LEFT OUTER JOIN dbo.Iris_Researchers IR WITH (NOLOCK)
	ON C.VendorID = IR.R_ID
WHERE 	A.ApStatus IN ('P','W') AND C.[Clear] = @Clear 
	AND C.VendorID IN (SELECT VendorID FROM dbo.CrimVendorResend WHERE InUse = @LockBy)
ORDER BY IR.R_Delivery, C.VendorID, C.Status, C.BatchNumber

SET NOCOUNT OFF

