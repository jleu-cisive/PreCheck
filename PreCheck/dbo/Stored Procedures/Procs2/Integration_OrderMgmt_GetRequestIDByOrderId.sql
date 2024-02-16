-- =============================================
-- Author:		Douglas DeGenaro
-- Create date: 10/13/2014
-- Description:	get parent request id from order
-- =============================================
CREATE PROCEDURE dbo.Integration_OrderMgmt_GetRequestIDByOrderId 
	-- Add the parameters for the stored procedure here
	@apno int
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	select top 1 RequestID from dbo.Integration_OrderMgmt_Request where apno = @apno order by 1 asc
    -- Insert statements for procedure here	
END
