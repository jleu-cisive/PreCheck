

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Rolodex_updateSectionLink]
	-- Add the parameters for the stored procedure here
	@SectionCode int, @SectionID int,@RolodexID int
AS
BEGIN	
SET XACT_ABORT ON;
BEGIN TRANSACTION
IF(SELECT COUNT(*) FROM RolodexLink  WHERE refSectionCode = @SectionCode and sectionid = @sectionid) = 0
	BEGIN
		INSERT INTO RolodexLink(refsectioncode,sectionid,rolodexid) 
		VALUES (@SectionCode,@SectionID,@RolodexID)
	END
ELSE
	BEGIN
	   UPDATE RolodexLink SET RolodexID = @RolodexID WHERE refSectionCode = @SectionCode and sectionid = @sectionid
	END

SELECT @@ROWCOUNT;

COMMIT TRANSACTION

END