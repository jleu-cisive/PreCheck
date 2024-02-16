--[dbo].[Integration_Verification_UpdateMVRVerification] 2963088,null,null,null,null,0,'MVR'
---- Modified by Lalit for #96018 on 2 august 2023


CREATE procedure [dbo].[Integration_Verification_UpdateMVRVerification]
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
		declare @oldsectstat char
		declare @oldwebstat int
		select @oldsectstat = SectStat,@oldwebstat = web_status from dbo.DL where apno = @apno 		
		-- Check if it needs review, if so then we are only setting the web_status flag to 44
		if (@needsReviewFlag = 1)
		BEGIN
				update DL SET 
					Report = @report,
					Web_Status = 44,
					MVRLoggingId = @loggingid,
					IsReleaseNeeded = case when charindex('requires a special signed release',@report)>0 then 1 else 0 end,	 
					Last_Updated = CURRENT_TIMESTAMP
					where APNO = @apno	and DateOrdered is not null ---- added to prevent failed to order MVR's from appearing in Reviewd list before re-ordering  

					insert into dbo.ChangeLog				
					select 'DL.Web_Status',@apno,@oldwebstat,44,CURRENT_TIMESTAMP,@createdBy
			END
			
		else
			-- otherwise we set the sectstat flag to pen

			BEGIN					
				
				update DL SET 
					Report = @report,
					Web_Status = null,
					MVRLoggingId = @loggingid,
					SectStat = 5,			 
					Last_Updated = CURRENT_TIMESTAMP
				where APNO = @apno	
			
				insert into dbo.ChangeLog				
				select 'DL.SectStat',@apno,@oldsectstat,5,CURRENT_TIMESTAMP,@createdBy

				insert into dbo.ChangeLog				
				select 'DL.Web_Status',@apno,@oldwebstat,null,CURRENT_TIMESTAMP,@createdBy
		
			END

		
						
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