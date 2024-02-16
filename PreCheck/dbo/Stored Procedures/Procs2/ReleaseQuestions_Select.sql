


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[ReleaseQuestions_Select]
	-- Add the parameters for the stored procedure here
(
	@CLNO int
)
AS
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON
	
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT ReleaseQuestionsID, CLNO, Question, QuestionType, Sequence 
FROM   dbo.ReleaseQuestions 
WHERE CLNO=@CLNO

SET NOCOUNT OFF

SET TRANSACTION ISOLATION LEVEL READ COMMITTED









