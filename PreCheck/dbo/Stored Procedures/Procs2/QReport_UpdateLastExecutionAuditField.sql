-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 07/30/2021
-- Description:	Update Last Execution User and Date
-- =============================================
CREATE PROCEDURE dbo.[QReport_UpdateLastExecutionAuditField]
	-- Add the parameters for the stored procedure here
@Username varchar(8),
@ReportID int

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	UPDATE [ala-SQL-05].Precheck.dbo.QReport SET LastExecutionDate = GETDATE(), LastExecutedBy = @userName WHERE QReportID = @ReportID
END
