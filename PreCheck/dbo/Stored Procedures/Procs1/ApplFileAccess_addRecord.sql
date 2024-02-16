

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[ApplFileAccess_addRecord]
	-- Add the parameters for the stored procedure here
@APNO int,@FileName varchar(150),@FileType int,@AttachToReport bit = 0,@FileSize bigint = 0
AS
BEGIN

SET XACT_ABORT ON;
BEGIN TRANSACTION;
DECLARE @FILECOUNT int;
SET @FILECOUNT = 0;

SELECT @FILECOUNT = COUNT(*) FROM applfile where refapplfiletype = @filetype and apno = @APNO;
SET @FILECOUNT = @FILECOUNT + 1;
SET @FileName = REPLACE(@FileName,'**','' + CAST(@FILECOUNT as varchar));
INSERT into ApplFile
(apno,imagefilename,refapplfiletype,AttachToReport,createddate,FileSize)
VALUES
(@APNO,@FileName,@FileType,@AttachToReport,getdate(),@FileSize)
SELECT @@IDENTITY as 'FileID',@FileName as 'FileName';


COMMIT TRANSACTION;
END

