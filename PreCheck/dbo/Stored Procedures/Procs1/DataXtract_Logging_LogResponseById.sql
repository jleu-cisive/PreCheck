

CREATE Procedure [dbo].[DataXtract_Logging_LogResponseById]
(
   @LogId int,
   @Response varchar(MAX) = null,
   @ResponseError varchar(MAX) = null,  
   @ResponseStatus varchar(30)=null,
   @totalrecords int = 0,
   @totalclears int = 0,
   @totalexceptions int = 0,
   @pflag int = 0
) 
	
as



if (IsNull(@ResponseStatus,'') <> 'Error')
	set @pflag = 1

Begin Try
	Update dbo.DataXtract_Logging 
	Set Response = @Response,
		ResponseError = @ResponseError,
		ResponseStatus = @ResponseStatus,	
		DateLogResponse = CURRENT_TIMESTAMP,
		ProcessFlag = @pflag,
		total_records = @totalrecords,
		total_clears = @totalclears,
		total_exceptions = @totalexceptions
	
	Where DataXtract_LoggingId = @LogId
End Try
Begin Catch
	--Test
End Catch;

