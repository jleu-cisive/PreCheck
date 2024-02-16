CREATE procedure [dbo].[Integration_Verification_UpdateMVRVerification_10072016]
(
	@apno int = null,
	@loggingid int = null,
	@request xml = null,
	@response xml = null,	
	@report varchar(max) = null,
	@needsReviewFlag bit = 0,
	@createdBy varchar(50) = null	
) 
as
--This is only a sectstat/webstat update
if (@request is null or @response is null) 
	begin
		-- Check if it needs review, if so then we are only setting the web_status flag to 44
		if (@needsReviewFlag = 1)
			update DL SET 
					Report = @report,
					Web_Status = 44,
					MVRLoggingId = @loggingid,
					IsReleaseNeeded = case when charindex('requires a special signed release',@report)>0 then 1 else 0 end,	 
					Last_Updated = CURRENT_TIMESTAMP
					where APNO = @apno	
		else
			-- otherwise we set the sectstat flag to pen
			update DL SET 
					Report = @report,
					Web_Status = null,
					MVRLoggingId = @loggingid,
					SectStat = 5,			 
					Last_Updated = CURRENT_TIMESTAMP
			where APNO = @apno				
	end
else
	-- we are inserting a records the request response in the MVR logging table
	begin				
		insert into Integration_Verification_MVRLogging(Request,Response,Created,CreatedBy)
		values(@request,@response,CURRENT_TIMESTAMP,@createdBy)					
		
		set @loggingid = (select scope_identity())
		
		update DL SET MVRLoggingId = @loggingid 
		where APNO = @apno	
		select @loggingid as mvrloggingid		

				
								
	end