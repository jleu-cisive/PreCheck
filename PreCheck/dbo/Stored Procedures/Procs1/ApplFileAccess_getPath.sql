
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[ApplFileAccess_getPath] 
	-- Add the parameters for the stored procedure here
	@APNO int,@FileType int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    SELECT TOP 1 * from applfilelocation where apnostart <= @APNO AND apnoend >= @APNO
	AND refApplTypeID = @FileType;
END

