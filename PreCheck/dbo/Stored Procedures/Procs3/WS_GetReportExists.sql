-- =============================================
-- Author:		Douglas DeGenaro
-- Create date: January 3,2011
-- Description:	Check if report exists for precheck appno, used in GetStatus
-- =============================================
CREATE PROCEDURE dbo.WS_GetReportExists 
	-- Add the parameters for the stored procedure here
	@apno int	
	
AS
BEGIN
	declare @reportId int
	declare @reportStatus bit
	declare @reportCount int
	set @reportId = 0
	set @reportStatus = 0
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	set @reportId = (select top 1 backgroundreportid FROM backgroundreports.dbo.backgroundreport WHERE apno = @apno order by CreateDate)	
	if (@reportId <> 0)
	BEGIN
		set @reportStatus = 1		 
	END
	select @reportStatus
END
