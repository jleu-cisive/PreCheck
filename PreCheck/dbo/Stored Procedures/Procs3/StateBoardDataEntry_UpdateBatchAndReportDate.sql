


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[StateBoardDataEntry_UpdateBatchAndReportDate]
	-- Add the parameters for the stored procedure here
(
 @ReportDate varchar(20)
,@BatchDate datetime
,@UserID varchar(20)
,@StateBoardDisciplinaryRunID int

)
AS
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON
	UPDATE dbo.StateBoardDataEntry SET BatchDate=@BatchDate, ReportDate=@ReportDate 
	WHERE (UserID=@UserID) AND (StateBoardDisciplinaryRunID=@StateBoardDisciplinaryRunID)
	SET NOCOUNT OFF

--=========================================================

