
CREATE PROCEDURE [dbo].[FormCrimOnlineGetNextApplication]
(
	@PrevAPNO int
	, @PrevVendorID int
	, @WindowsUserID varchar(8)
	, @Investigator varchar(8)
)
AS
SET NOCOUNT ON

DECLARE @NextAPNO int
	, @R_ID int
	, @R_Name varchar(50)

SELECT TOP 1 
	@NextAPNO = A.APNO
	, @R_ID = IR.R_ID
	, @R_Name = IR.R_Name
FROM dbo.Appl A WITH (NOLOCK)
	INNER JOIN dbo.Crim C WITH (NOLOCK)
	ON A.APNO = C.APNO
	INNER JOIN dbo.Iris_Researchers IR WITH (NOLOCK)
	ON C.VendorID = IR.R_ID
WHERE A.ApStatus IN ('P','W') 
	AND A.ApDate IS NOT NULL
	AND A.InUse IS NULL 
	AND C.BatchNumber IS NULL 
	AND C.[Clear] = 'R' 
	AND C.IRIS_Rec = 'Yes'
	AND DATEDIFF(mi, C.CrimEnteredTime, GETDATE()) >= 1
	AND IR.R_Delivery = 'NewOnline'
	AND IR.R_ID = ISNULL(@PrevVendorID, IR.R_ID)
	AND IR.Investigator = ISNULL(@Investigator, IR.Investigator)	--for future use
ORDER BY A.ApDate

IF @NextAPNO IS NOT NULL 
BEGIN
	UPDATE dbo.Appl SET InUse = NULL WHERE InUse = @WindowsUserID AND APNO = @PrevAPNO
	UPDATE dbo.Appl SET InUse = @WindowsUserID WHERE InUse IS NULL AND APNO = @NextAPNO

	SELECT TOP 1 *, @R_ID AS R_ID, @R_Name AS R_Name FROM dbo.Appl WHERE APNO = @NextAPNO
END
ELSE IF @PrevVendorID IS NOT NULL
	EXEC dbo.FormCrimOnlineGetNextApplication @PrevAPNO, NULL, @WindowsUserID, @Investigator
ELSE IF @Investigator IS NOT NULL
	EXEC dbo.FormCrimOnlineGetNextApplication @PrevAPNO, NULL, @WindowsUserID, NULL
ELSE
BEGIN
	UPDATE dbo.Appl SET InUse = NULL WHERE InUse = @WindowsUserID AND APNO = @PrevAPNO
	SELECT TOP 1 * FROM dbo.Appl WHERE APNO = 0
END

SET NOCOUNT OFF