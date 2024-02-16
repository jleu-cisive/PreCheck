
-- =============================================
-- Author:		Douglas DeGenaro
-- Create date: January 3,2011
-- Description:	Check if report exists for precheck appno
-- =============================================
CREATE PROCEDURE [dbo].[Integration_OrderMgmt_GetReportExists] 
	-- Add the parameters for the stored procedure here
	@apno int
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT top 1 * FROM backgroundreports.dbo.backgroundreport WHERE apno = @apno
END

