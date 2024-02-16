




-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[ApplFileAccess_getList]
	-- Add the parameters for the stored procedure here
	@APNO int, @FileType int
AS
BEGIN
	select applfileid,refapplfiletype as FileType,ImageFilename,clientfilename,deleted,ISNULL(attachtoreport,0) as attachtoreport from applfile
    where apno = @APNO and refapplfiletype = @FileType and deleted = 0
END





