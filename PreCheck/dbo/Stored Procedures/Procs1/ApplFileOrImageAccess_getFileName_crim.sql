
-- =============================================  
-- Author:  <Lalit Kumar>  
-- Create date: <11/30/2023>  
-- Description: <This is to get Image file name for release forms for crim
-- ApplFileOrImageAccess_getFileName_crim 7231810,1
-- =============================================  
  
CREATE PROCEDURE [dbo].[ApplFileOrImageAccess_getFileName_crim]  
 -- Add the parameters for the stored procedure here  
 @APNO int, @FileType int  
AS  
BEGIN  
 Declare @FileName varchar(150);  
 Declare @TableName varchar(15);  
   
 select @FileName = ImageFilename,@TableName = 'ApplFile' from applfile  
    where apno = @APNO and refapplfiletype = @FileType and deleted = 0 AND AttachToReport IS NULL
	 AND ImageFilename LIKE '%GA_Consent%' and ImageFilename NOT LIKE '%_RA_%'   
          
    Select @FileName as ImageFileName , @TableName as TableName;  
END  