-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 06/08/2018
-- Description:	Audit Report for Client Manager  
-- =============================================
CREATE PROCEDURE AuditReportforClientManager
	-- Add the parameters for the stored procedure here
	@CLNO int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	select * from [dbo].[ChangeLogCM] WITH(NOLOCK) where CLNO = @CLNO
	Order by ChangeDate DESC
END
