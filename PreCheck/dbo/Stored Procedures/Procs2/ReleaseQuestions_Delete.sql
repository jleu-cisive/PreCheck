
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[ReleaseQuestions_Delete]
	-- Add the parameters for the stored procedure here
(
	@ReleaseQuestionsID int
)
AS
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON

DELETE FROM dbo.ReleaseQuestions 
WHERE  ReleaseQuestionsID = @ReleaseQuestionsID
	
SET NOCOUNT OFF


