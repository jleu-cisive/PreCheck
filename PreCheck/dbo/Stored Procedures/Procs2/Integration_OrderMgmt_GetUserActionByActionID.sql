
-- =============================================
-- Author:		Douglas DeGenaro
-- Create date: January 3, 2011
-- Description:	Gets the user action id by the action itself
-- =============================================
CREATE PROCEDURE [dbo].[Integration_OrderMgmt_GetUserActionByActionID] 
	-- Add the parameters for the stored procedure here
	@UserAction varchar(30)	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	select refUserActionID from Integration_OrderMgmt_refUserAction where UserAction = @UserAction
END

