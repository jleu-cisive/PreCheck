CREATE PROCEDURE [dbo].[SectionUsage_Close]
(
	@APNO int
	, @Investigator varchar(8)
	, @SectionUsageID int
)
AS
SET NOCOUNT ON

UPDATE dbo.SectionUsage SET TimeClose = getdate() WHERE SectionUsageID = @SectionUsageID
UPDATE dbo.Appl SET InUse = NULL WHERE APNO = @APNO AND InUse = @Investigator

SET NOCOUNT OFF