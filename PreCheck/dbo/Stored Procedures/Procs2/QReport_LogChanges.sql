-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 07/30/2021
-- Description:	Log QReport Changes
-- =============================================
CREATE PROCEDURE [dbo].[QReport_LogChanges]
	-- Add the parameters for the stored procedure here
	@userName varchar(8),
	@qreportid int

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	INSERT INTO [ala-SQL-05].Precheck.dbo.[ChangeLog]([TableName], [ID], [OldValue], [NewValue], [ChangeDate], [UserID]) 
    values ('QreportUserMap', -200, 'AssignedTo:' + @userName, 'QReportID:' + CAST(@qreportid as varchar), GETDATE(), @userName)
END
