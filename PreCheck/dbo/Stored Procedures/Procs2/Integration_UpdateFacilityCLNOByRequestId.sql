-- =============================================
-- Author:		Doug DeGenaro
-- Create date: 08/07/2019
-- Description:	Updating facility clno in integration request table
-- =============================================
CREATE PROCEDURE dbo.Integration_UpdateFacilityCLNOByRequestId 
	-- Add the parameters for the stored procedure here
	@RequestId int = null, 
	@FacilityCLNO int = null,
	@Apno int = null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	update 
		dbo.Integration_OrderMgmt_Request 
	set 
		FacilityCLNO = @facilityClno,
		Apno = @apno 
	where 
		RequestID = @RequestID
END
