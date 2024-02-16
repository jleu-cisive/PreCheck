-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[StateBoardReview_Delete]
	-- Add the parameters for the stored procedure here
	(
	@StateBoardReviewID int
	)
AS
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON

    -- Insert statements for procedure here
	DELETE FROM dbo.StateBoardReview WHERE StateBoardReviewID =@StateBoardReviewID
	
	SET NOCOUNT OFF
--====================================================

