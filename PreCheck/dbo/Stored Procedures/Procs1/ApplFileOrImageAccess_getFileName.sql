




-- =============================================
-- Author:		<Najma Begum>
-- Create date: <10/25/2012>
-- Description:	<This is to get Image file name for release forms based on in which table i
-- it is available.
--NOTE: Here query looks at if the ImageFile or ClientFileName contains 'Release' to filter out other
-- file types. but in some special cases this restriction will not be enough in which case
-- though the file exists it will not show up online due to different naming convention;
--  this is due to the limitation of table as of now.
-- =============================================

CREATE PROCEDURE [dbo].[ApplFileOrImageAccess_getFileName]
	-- Add the parameters for the stored procedure here
	@APNO int, @FileType int
AS
BEGIN
	Declare @FileName varchar(150);
	Declare @TableName varchar(15);
	
	select @FileName = ImageFilename,@TableName = 'ApplFile' from applfile
    where apno = @APNO and refapplfiletype = @FileType and deleted = 0;
    
    if(@FileName is NULL or @FileName = '')
    BEGIN
		select @FileName = ImageFilename, @TableName = 'ApplImages' from applImages
		where apno = @APNO and (ImageFileName like '%Release%' or ClientFileName like '%Release%') and CHARINDEX('Thumb', [ImageFileName]) = 0;
    END
    
    Select @FileName as ImageFileName , @TableName as TableName;
END





