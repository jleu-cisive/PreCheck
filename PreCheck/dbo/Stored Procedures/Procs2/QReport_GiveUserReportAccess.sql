-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 07/30/2021
-- Description:	[QReport_GiveUserReportAccess]
-- =============================================
CREATE PROCEDURE dbo.[QReport_GiveUserReportAccess]
	-- Add the parameters for the stored procedure here
@userName varchar(8),
@QReportid int

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	INSERT INTO [ala-SQL-05].Precheck.dbo.[QReportUserMap]([UserID], [QReportID]) 
	values (@userName, @QReportid)
END
