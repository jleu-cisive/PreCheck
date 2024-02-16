
-- =============================================
-- Author:		Douglas DeGenaro
-- Create date: 07/08/2013
-- Description:	Log callback transaction
-- =============================================
CREATE PROCEDURE [dbo].[Integration_LogCallback_06042022] 
	-- Add the parameters for the stored procedure here
	@clno int,
	@apno int,
	@partnerreference varchar(200) = null,
	@cbstatus varchar(30),
	@cbdate datetime,
	@result xml,
	@request xml = null,
	@error varchar(max),
	@iscomplete bit = 0,
	@action varchar(20)= null
AS
BEGIN
	
    -- Insert statements for procedure here
	if (IsNull(@apno,0) <> 0) 
	INSERT INTO dbo.Integration_CallbackLogging(
		Clno,
		Apno,
		CallbackStatus,
		CallbackDate,
		CallbackPostResult,
		CallbackPostRequest,
		CallbackError,
		CallbackCompletedStatus,
		[Action]
		)
	VALUES(
		@clno,
		@apno,
		@cbstatus,
		@cbdate,
		@result,
		@request,
		@error,
		@iscomplete,
		@action
	)
	ELSE
		INSERT INTO dbo.Integration_CallbackLogging(
		Clno,
		Partner_Reference,
		CallbackStatus,
		CallbackDate,
		CallbackPostResult,
		CallbackPostRequest,
		CallbackError,
		CallbackCompletedStatus,
		[Action]
		)
	VALUES(
		@clno,
		@partnerreference,
		@cbstatus,
		@cbdate,
		@result,
		@request,
		@error,
		@iscomplete,
		@action
	)
END


