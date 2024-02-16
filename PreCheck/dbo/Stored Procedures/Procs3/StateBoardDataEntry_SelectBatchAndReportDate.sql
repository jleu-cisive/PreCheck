
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[StateBoardDataEntry_SelectBatchAndReportDate]
	-- Add the parameters for the stored procedure here
	(
	 @StateBoardDisciplinaryRunID int
	,@UserID varchar(20)
	)
AS
-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
    -- Insert statements for procedure here
	SELECT TOP 1 BatchDate, ReportDate FROM dbo.StateBoardDataEntry 
	WHERE (StateBoardDisciplinaryRunID=@StateBoardDisciplinaryRunID) AND (UserID=@UserID)
	
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED
	SET NOCOUNT OFF
