
--EXEC SectionUsage_Open 2464972, 'Danielle'

CREATE PROCEDURE [dbo].[SectionUsage_Open]
(
	@APNO int
	, @Investigator varchar(8)
)
AS
SET NOCOUNT ON

DECLARE @InUse varchar(8),@RAPNO int;


SELECT @RAPNO = apno,@InUse = InUse FROM dbo.Appl WHERE APNO = @APNO
IF @RAPNO is not null AND (@InUse IS NULL OR @InUse = @Investigator)
BEGIN
	INSERT INTO SectionUsage (TableName, TableID, APNO, UserID, TimeOpen, Role)
	SELECT 'Appl', @APNO, @APNO, @Investigator, getdate(), 'Investigator'

	UPDATE Appl SET InUse = @Investigator WHERE APNO = @APNO

	SELECT CAST(1 as bit) AS IsLock, @Investigator AS InUse, @@IDENTITY AS SectionUsageID
END
ELSE
	SELECT CAST(0 as bit) AS IsLock, @InUse AS InUse, 0 AS SectionUsageID

SET NOCOUNT OFF




