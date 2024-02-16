
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[StateBoardLog_Update]
	-- Add the parameters for the stored procedure here
	(
	 @StateBoardDisciplinaryRunID int
	,@UserID varchar(20)
	,@CommentDate datetime
	,@Comment varchar(8000)
	)
	
AS
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON

    -- Insert statements for procedure here
	UPDATE dbo.StateBoardLog 
	SET StateBoardDisciplinaryRunID=@StateBoardDisciplinaryRunID
	 , UserID=@UserID
	 , CommentDate=@CommentDate
	 , Comment=@Comment
	
	SET NOCOUNT OFF

--=========================================================


--==============================================================

