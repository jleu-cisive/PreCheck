
CREATE FUNCTION [dbo].[ZipCrimReportReachedMaxAttempts]
	(@apno int, @maxAttempts int)
RETURNS bit
AS
BEGIN
	IF NOT EXISTS(SELECT * FROM dbo.ZipCrimWorkOrders zcwo WHERE zcwo.APNO = @apno)
	BEGIN
		RETURN 0
	END
	DECLARE @refStatus int, @submitAttempts int, @getLeadsAttempts int;
	SELECT 
		@refStatus = zcwo.refWorkOrderStatusID,
		@submitAttempts = zcwo.SubmitWorkOrderAttempts,
		@getLeadsAttempts = zcwo.GetLeadsAttempts
	 FROM dbo.ZipCrimWorkOrders zcwo WHERE zcwo.APNO= @apno
	 IF(@refStatus = 6 OR @submitAttempts > @maxAttempts OR @getLeadsAttempts > @maxAttempts)
	 BEGIN
		RETURN 1
	 END
	 RETURN 0
END
