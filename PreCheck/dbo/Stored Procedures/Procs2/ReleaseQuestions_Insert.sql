
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[ReleaseQuestions_Insert]
	-- Add the parameters for the stored procedure here
(
	 @CLNO int
	,@Question varchar(700)
	,@QuestionType varchar(10)
	,@Sequence int
)	
AS
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON

	INSERT INTO dbo.ReleaseQuestions(CLNO,Question,QuestionType,Sequence) 
	VALUES(@CLNO,@Question,@QuestionType,@Sequence)

	SET NOCOUNT OFF


