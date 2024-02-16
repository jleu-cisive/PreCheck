


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[ReleaseQuestions_Update] 
	-- Add the parameters for the stored procedure here
(
	 @ReleaseQuestionsID int
	,@CLNO int
	,@Question varchar(700)
	,@QuestionType varchar(10)
	,@Sequence int
)
AS

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON

UPDATE dbo.ReleaseQuestions
SET    CLNO=@CLNO,Question = @Question,
	   QuestionType=@QuestionType,
	   Sequence=@Sequence 
WHERE  ReleaseQuestionsID = @ReleaseQuestionsID 
AND    CLNO=@CLNO
	
SET NOCOUNT OFF




