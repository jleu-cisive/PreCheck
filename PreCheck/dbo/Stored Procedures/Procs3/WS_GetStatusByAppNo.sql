
-- =============================================
-- Author:		Douglas DeGenaro
-- Create date: January 3,2011
-- Description:	Gets the status by the precheck appno
-- =============================================
CREATE PROCEDURE [dbo].[WS_GetStatusByAppNo] 
	-- Add the parameters for the stored procedure here
	@apno int 	
AS
BEGIN
	declare @status varchar(30)
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	set @status = (select IsNull(apd.AppStatusValue,'InProgress') from AppStatusDetail apd right join appl a on apd.AppStatusItem = a.ApStatus where a.apno = @apno)
	select @status
END

