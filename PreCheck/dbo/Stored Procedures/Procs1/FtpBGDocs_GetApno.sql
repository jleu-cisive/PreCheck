
-- =============================================
-- Author:		<Najma Begum>
-- Create date: <05/18/2011,>
-- Description:	<Get apno for background documents (FileAutomation)>
-- =============================================
CREATE PROCEDURE [dbo].[FtpBGDocs_GetApno]
	-- Add the parameters for the stored procedure here
	@tblName varchar(50), @colName varchar(100), @colValue nvarchar(50), @clno nvarchar(50) = 0
	
AS
BEGIN
	SET NOCOUNT ON
	
	declare @query varchar(200)
	set @query = 'select top 1 apno from ' + @tblName + ' where ' + @colName + ' = ''' + @colValue + ''''
	if(@colName <> 'DOCRETRIEVER_REFERENCE')
		set @query = @query + ' and clno = ' + @clno
	set @query = @query + ' order by requestdate desc'
	exec(@query)
END

