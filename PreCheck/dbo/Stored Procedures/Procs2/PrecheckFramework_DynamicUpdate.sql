-- =============================================
-- Author:		Douglas DeGenaro
-- Create date: 9/13/2013
-- Description:	uses multiple parameters to form an update statement
-- =============================================
/* [dbo].[PrecheckFramework_DynamicUpdate] 2188058, 'dhe', 'Appl', 'Priv_Notes', 'fffgfdfdffcxvxc'
select priv_notes from dbo.Appl where apno = 2188058
*/
CREATE PROCEDURE [dbo].[PrecheckFramework_DynamicUpdate] 
	-- Add the parameters for the stored procedure here
	
	@apno int,
	@Username varchar(100),
	@tblName varchar(300),	
	@fieldName varchar(50),
	@fieldValue varchar(4000)	
AS
BEGIN
	declare @sql    nvarchar(4000)
	declare @params nvarchar(4000)
	declare @UserNameShort varchar(8)
	SET @UserNameShort = 	substring(LTRIM(RTRIM(@Username)), 1, 8)
	

	SET NOCOUNT ON;
	IF (Select 1 from dbo.Appl where Apno = @apno and (Lower(InUse) = Lower(@UserNameShort) or IsNull(InUse,'') = '')) > 0
	BEGIN
		
		if (@fieldName = 'Priv_Notes' or @fieldName = 'Pub_Notes')
		   set @sql = N'Update ' + @tblName + ' Set ' + @fieldName  + ' = IsNull(@fieldValue,'''') where apno = @apno'
		Else
			set @sql = N'Update ' + @tblName + ' Set ' +  @fieldName + ' = @fieldValue where apno = @apno'
		
		select @params = N'@fieldValue varchar(4000), @apno int'
		EXEC sp_executesql 
			@sql,
			@params,
			@fieldValue ,
			@apno			
									  
	END
	
   Select @@ROWCOUNT as RowsUpdated 
   --select priv_notes,* from appl where apno=2188058
	
END
