
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[StateBoardDisciplinaryRun_Insert]
	-- Add the parameters for the stored procedure here
	(
	@StateBoardSourceID int
	)
	
AS
	DECLARE @returnvalue int
	SET @returnvalue = (SELECT Count(*) FROM dbo.StateBoardDisciplinaryRun WHERE (StateBoardSourceID=@StateBoardSourceID) AND ((DateCompletedA IS NULL) OR (DateCompletedB IS NULL)) )
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON

	IF(@returnvalue > 0)
	BEGIN
		SET @returnvalue = @returnvalue
	END
	ELSE
	BEGIN
		INSERT INTO dbo.StateBoardDisciplinaryRun (StateBoardSourceID) VALUES (@StateBoardSourceID)
	END
	SET NOCOUNT OFF

--=================================================================

set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
