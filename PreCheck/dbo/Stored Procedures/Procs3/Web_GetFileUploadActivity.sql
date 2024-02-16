
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Web_GetFileUploadActivity]
	-- Add the parameters for the stored procedure here
	@CLNO int, 
	@apno varchar(10)= null
AS
BEGIN

if (@apno is null)
begin
set @apno = '0'
end
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
if (@apno = 0)
	begin
		SELECT TOP 10 ClientFileName As FileName, UploadDate As DateReceived, FileSize As FileLength, FileContent As Content FROM precheck.dbo.FileUploadActivity 
		WHERE CLNO = @CLNO order by UploadDate DESC 
	end
else
Begin
		SELECT ClientFileName As FileName, UploadDate As DateReceived, FileSize As FileLength, FileContent As Content FROM precheck.dbo.FileUploadActivity 
		WHERE CLNO = @CLNO 
		and  InternalFileName like @apno+'%'
		order by UploadDate DESC 
End
END


