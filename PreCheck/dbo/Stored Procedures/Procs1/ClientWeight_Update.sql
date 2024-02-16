CREATE PROCEDURE [dbo].[ClientWeight_Update]
(
	@CLNO int
	, @WeightType varchar(15)
	, @Weight float
)
AS
SET NOCOUNT ON

IF (SELECT TOP 1 CLNO FROM dbo.ClientWeight WHERE CLNO = @CLNO AND WeightType = @WeightType) IS NULL
BEGIN
	INSERT INTO dbo.ClientWeight (CLNO, WeightType, Weight)
    SELECT @CLNO, @WeightType, @Weight
END
ELSE
	UPDATE dbo.ClientWeight SET Weight = @Weight WHERE CLNO = @CLNO AND WeightType = @WeightType

SET NOCOUNT OFF