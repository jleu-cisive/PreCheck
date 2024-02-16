

CREATE PROCEDURE [dbo].[CreateMedInteg_New]
(
	@APNO int
	, @IsCreated bit OUTPUT
)
AS
SET NOCOUNT ON

IF (SELECT COUNT(*) FROM dbo.MedInteg WHERE APNO = @APNO) = 0
BEGIN
	INSERT INTO dbo.MedInteg (Apno) VALUES (@APNO)
	SET @IsCreated = 1
END
ELSE
	SET @IsCreated = 0

SET NOCOUNT OFF