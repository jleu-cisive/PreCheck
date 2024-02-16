

CREATE PROCEDURE [dbo].[Integration_OrderMgmt_UpdateHoldStatus] 
	-- Add the parameters for the stored procedure here
	@clientappno int,@status char(1) = null,@subStatus int = null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;	
if (@status is null)
	set @status = 'M'

    -- Insert statements for procedure here
	update 
		dbo.appl 
	set 
		apstatus = @status, 
		substatusId = IsNull(@subStatus,subStatusId)
	where apno = @clientappno
END




