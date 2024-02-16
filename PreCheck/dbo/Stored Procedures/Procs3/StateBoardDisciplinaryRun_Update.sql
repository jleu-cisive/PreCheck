


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[StateBoardDisciplinaryRun_Update]
	-- Add the parameters for the stored procedure here
	(
	 @StateBoardDisciplinaryRunID int
	,@CompletedDate datetime
	,@BatchDate datetime
	,@ReportDate datetime
	,@NoBoardAction bit
	)
AS

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON
	
	UPDATE dbo.StateBoardDisciplinaryRun SET CompletedDate=@CompletedDate, BatchDate=@BatchDate, ReportDate=@ReportDate, NoBoardAction=@NoBoardAction 
	WHERE StateBoardDisciplinaryRunID=@StateBoardDisciplinaryRunID
	
	SET NOCOUNT OFF


--============================================================

set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
