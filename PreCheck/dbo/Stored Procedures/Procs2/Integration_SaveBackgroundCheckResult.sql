-- =============================================
-- Author:		Douglas DeGenaro
-- Create date: 05/03/2016
-- Description:	Saves ApplClientData for BackgroundCheck Saves
-- =============================================
CREATE PROCEDURE dbo.Integration_SaveBackgroundCheckResult 
	-- Add the parameters for the stored procedure here
	@apno int,
	@clientApno varchar(100) = null,
	@clno int,
	@xml XML
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	
	insert into dbo.ApplClientData(APNO,CLNO,ClientAPNO,XMLD,CreatedDate)
	values (@apno,@clno,@clientApno,@xml,CURRENT_TIMESTAMP)

	--select SCOPE_IDENTITY()

    -- Insert statements for procedure here
	
END
