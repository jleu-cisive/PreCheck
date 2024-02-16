-- =============================================
-- Author:		<Steven Bauch>
-- Create date: <10/26/2022>
-- Description:	<iCIMS Callback Error Report>
-- =============================================
CREATE PROCEDURE dbo.IntegrationCallBackErrorReport @tdStartDate datetime, @tdEndDate datetime = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

   If  isdate(@tdStartDate) <> 1
		set @tdStartDate = cast(getdate() as date)

If  isdate(@tdEndDate) <> 1
		set @tdEndDate = getdate()
		
  SELECT IOM.RequestID,CCI.CLNO,Client.Name, CallBackError,sum(cast(ICL.CallbackCompletedStatus as int)) as Error
	FROM ClientConfig_Integration  CCI (nolock) join Integration_OrderMgmt_Request IOM (nolock) on CCI.clNO = iom.CLNO
                                              join Integration_CallbackLogging ICL (nolock) on IOM.RequestID = ICL.RequestId  
											  join Client (nolock) on CCI.ClNO = Client.ClNo
    WHERE isActive = 1 and refATSid = 3 and RequestDate between @tdStartDate and @tdEndDate and CallbackCompletedStatus = 0 
  group by IOM.RequestID, CCI.CLNO,CallBackError,Client.Name
  having  sum(cast(ICL.CallbackCompletedStatus as INT)) = 0
END
