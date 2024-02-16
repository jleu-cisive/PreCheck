

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[StateBoardDisciplinaryRun_UpdateBatchDate]
	-- Add the parameters for the stored procedure here
(
	 @BatchDate datetime
	,@StateBoardDisciplinaryRunID int
)
	
AS
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON

    -- Insert statements for procedure here
	 UPDATE dbo.StateBoardDisciplinaryRun SET BatchDate=@BatchDate 
	 WHERE StateBoardDisciplinaryRunID=@StateBoardDisciplinaryRunID
	
	SET NOCOUNT OFF

--===========================================================

set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
