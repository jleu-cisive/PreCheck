-- =============================================
-- Author:		Douglas DeGenaro
-- Create date: 08/15/2013
-- Description:	Gets the report html for the client
-- =============================================
CREATE PROCEDURE dbo.NHDBWeb_GetClientReportHTML 
	-- Add the parameters for the stored procedure here
	@clno int =null, 
	@transactionId int = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
    -- Insert statements for procedure here
	select html from onlinereporthtml o inner join 
	nhdbweb_transaction n on n.onlinereporthtmlid = o.onlinereporthtmlid 
	where o.refreporttypeid = 1 and IsnUll(o.clno,2135) = 2135 and n.nhdbweb_transactionid = @transactionId
END
