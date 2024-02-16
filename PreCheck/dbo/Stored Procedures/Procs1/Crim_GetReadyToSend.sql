CREATE PROCEDURE [dbo].[Crim_GetReadyToSend]
(@DeliveryMethod varchar(25), @LockBy varchar(8))
AS
SET NOCOUNT ON

SELECT 	C.APNO
	, C.CrimID
	, ISNULL(C.CNTY_NO, 0) AS CNTY_NO
	, ISNULL(C.VendorID, 0) AS VendorID
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
WHERE 	A.InUse = @LockBy AND C.[Clear] = 'M' AND IR.R_Delivery = @DeliveryMethod
  AND c.IsHidden = 0
ORDER BY C.VendorID, C.CNTY_NO, C.Status

SET NOCOUNT OFF
