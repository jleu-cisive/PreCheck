-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Web_FileUploadActivity]
	-- Add the parameters for the stored procedure here
	@CLNO int, @UserName varchar(30),@InternalFileName varchar(300),@ClientFileName varchar(300),
	@FileContent varchar(100),@FileSize int	,@Source varchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   Insert into FileUploadActivity (CLNO,UserName,InternalFileName,clientFileName,FileContent,FileSize,UploadDate,Source)
	VALUES (@CLNO,@UserName,@InternalFileName,@ClientFileName,@FileContent,@FileSize,getDate(),@Source)
END

