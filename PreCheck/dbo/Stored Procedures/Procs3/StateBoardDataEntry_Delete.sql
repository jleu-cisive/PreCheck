
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[StateBoardDataEntry_Delete]
	-- Add the parameters for the stored procedure here
	(
	@UserID varchar(10)
   ,@StateBoardDataEntryID int
	)
AS
-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON
	DELETE FROM dbo.StateBoardDataEntry 
	WHERE (UserID=@UserID) AND (StateBoardDataEntryID=@StateBoardDataEntryID)
    -- Insert statements for procedure here
	SET NOCOUNT OFF
