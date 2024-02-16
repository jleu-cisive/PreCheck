CREATE PROCEDURE dbo.FormCrimOnlineCopyCrimRecord
(@CrimID int)
AS
SET NOCOUNT ON

DECLARE @APNO int, @CNTY_NO int, @VendorID int, @ParentCrimID int
DECLARE @ReadyToSend bit
DECLARE @County varchar(40), @Iris_Rec varchar(3), @DeliveryMethod varchar(50), @B_Rule varchar(50)

SELECT 	TOP 1
	@APNO = APNO
	, @County = County
	, @CNTY_NO = CNTY_NO
	, @Iris_Rec = Iris_Rec
	, @VendorID = VendorID
	, @DeliveryMethod = DeliveryMethod
	, @B_Rule = B_Rule
	, @ReadyToSend = ReadyToSend
FROM	dbo.Crim
WHERE	CrimID = @CrimID

SELECT @ParentCrimID = MAX(CrimID) FROM dbo.Crim

INSERT INTO dbo.Crim (APNO, County, [Clear], CNTY_NO, Iris_Rec, VendorID, DeliveryMethod, B_Rule, ReadyToSend, ParentCrimID)
VALUES (@APNO, @County, 'R', @CNTY_NO, @Iris_Rec, @VendorID, @DeliveryMethod, @B_Rule, @ReadyToSend, @ParentCrimID)

SELECT @@IDENTITY AS CrimID

SET NOCOUNT OFF
