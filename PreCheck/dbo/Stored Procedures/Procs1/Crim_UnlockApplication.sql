
CREATE PROCEDURE [dbo].[Crim_UnlockApplication]
(@DeliveryMethod varchar(25), @LockBy varchar(8))
AS
SET NOCOUNT ON

IF @DeliveryMethod = 'OnlineDB'
BEGIN

  INSERT INTO dbo.Iris_OnlineDB_PATAR_History
  SELECT 	C.CrimID, getdate(), NULL
  FROM 		dbo.Appl A WITH (NOLOCK)
		INNER JOIN dbo.Crim C WITH (NOLOCK)
		ON A.APNO = C.APNO 
		LEFT OUTER JOIN dbo.Iris_Researchers IR WITH (NOLOCK)
		ON C.VendorID = IR.R_ID
  WHERE 	A.InUse = @LockBy AND IR.R_Delivery = @DeliveryMethod AND C.[Clear] = 'O'

END

UPDATE dbo.Appl SET InUse = NULL WHERE APNO IN
(
SELECT 	C.APNO
FROM 	dbo.Appl A WITH (NOLOCK)
	INNER JOIN dbo.Crim C WITH (NOLOCK)
	ON A.APNO = C.APNO 
	LEFT OUTER JOIN dbo.Iris_Researchers IR WITH (NOLOCK)
	ON C.VendorID = IR.R_ID
WHERE 	A.InUse = @LockBy AND IR.R_Delivery = @DeliveryMethod AND (C.[Clear] = 'M' OR C.[Clear] = 'O' OR C.[Clear] = 'W')
)



SET NOCOUNT OFF

