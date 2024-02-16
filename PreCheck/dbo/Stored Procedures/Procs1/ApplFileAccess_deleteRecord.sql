
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[ApplFileAccess_deleteRecord]
	-- Add the parameters for the stored procedure here
	@APNO int, @ApplFileID int, @FileType int
AS
BEGIN
	

    UPDATE applfile set deleted = 1 where apno = @APNO and refapplfiletype = @Filetype and applfileid = @ApplFileID
	SELECT @@ROWCOUNT
END

