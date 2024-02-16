
--[Update_Empl_Module_GetNext] 3115593,3884446,'schapyal',null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,89,null,null,null,'9',null,null,null,null,null,null,null,'01/19/2016',0

CREATE PROCEDURE [dbo].[Update_Empl_Module_GetNext]
      @Apno int,
      @EmplID int,
      @User_ID varchar(25),
      @ver_by varchar(25),
      @phone varchar(20),
      @supervisor varchar(25),
      @dept varchar(30),
      @city varchar(16),
      @state varchar(2),
      @zipcode varchar(5),
      @position_v varchar(25),
      @title varchar(25),
      @salary_a varchar(15),
      @salary_v varchar(15),
      @from_v varchar(12),
      @to_v varchar(12),
      @pub_notes text,
      @priv_notes text,
      @web_status int,
      @emp_type char(1),
      @rehire varchar(1),
      @rel_cond varchar(30),
      @sectstat char(1),
      @employer varchar(30),
      @location varchar(250),
      @IsCamReview bit,
      @includealias char(1),
      @includealias2 char(1),
      @includealias3 char(1),
      @includealias4 char(1),
      @Last_Worked datetime,
      @isIntl bit,
	  @t_followupinterval int = null
	  ,@FollowupDate DateTime = null

as
  set nocount on
  
  -- Relese the investigator like "CallBack" when the investigator selects the "Team Lead QA"
  IF @web_status = 91 --Team Lead QA to exit the record without any SAVE
	Select 0 AS AllowGetNext
  ELSE
	Begin
		 Declare @OldValue as varchar(8),@Old_Last_Worked datetime,@OldWebStatValue as varchar(8), @AllowGetNext bit,@webstatusUpdated DateTime
		 --,@oldPrivateNotes varchar(8000),@OldPublicNotes varchar(8000)  --added by schapyala on 11/14/2013 - Dana's request

		 -- VD : For Save And GetNext functionality
		 SET @AllowGetNext = 0

		select @OldValue = SectStat,@Old_Last_Worked = Last_Worked, @OldWebStatValue = isnull(web_status,0)
			   --,@oldPrivateNotes = cast(Priv_Notes as varchar(8000)), @OldPublicNotes = cast(Pub_Notes  as varchar(8000)) --added by schapyala on 11/14/2013 - Dana's request
		  from Empl where APNO = @Apno and EmplID = @EmplID 

		--if(@Last_Worked > @Old_Last_Worked) 
		--begin
		UPDATE DBO.APPL Set InUse = @User_ID
		Where APNO = @Apno

		if ((Select apstatus from dbo.appl where apno  = @Apno) = 'F')
		BEGIN
			UPDATE DBO.APPL Set ApStatus = 'P',last_updated = current_timestamp
			Where APNO = @Apno

			INSERT INTO [dbo].[ChangeLog]
				   ([TableName]
				   ,[ID]
				   ,[OldValue]
				   ,[NewValue]
				   ,[ChangeDate]
				   ,[UserID])
			 VALUES
				   ('appl.apstatus'
				   ,@Apno
				   ,'F'
				   ,'P'
				   ,current_timestamp
				   ,@User_ID + '-empl')
		END

		IF @web_status in (5,77,75) 
			Set @sectstat = '6' --unverified/see attached

		if ( @sectstat <> @OldValue)
		Begin
		INSERT INTO [dbo].[ChangeLog]
				   ([TableName]
				   ,[ID]
				   ,[OldValue]
				   ,[NewValue]
				   ,[ChangeDate]
				   ,[UserID])
			 VALUES
				   ('Empl.SectStat'
				   ,@EmplID
				   ,@OldValue
				   ,@sectstat
				   ,@Last_Worked
				   ,@User_ID + '-empl')



			SET @AllowGetNext = 1
		END


		INSERT INTO dbo.getNextAudit 
		SELECT @Apno, @EmplID, 'New SectStat VS Old SectStat', 'New SectStat : ' + @sectstat + ' Old SectStat : ' + @OldValue + ' - AllowGetNext : ' + Cast(@AllowGetNext AS varchar),GETDATE(),@User_ID

		-- Added the below change for updating web status.
		--if @sectstat <> '9' and @web_status in (73,75,
		--	set @web_status = 0

	if (@web_status <> @OldWebStatValue) OR (@web_status in (74,89))
		Begin
		INSERT INTO [dbo].[ChangeLog]
				   ([TableName]
				   ,[ID]
				   ,[OldValue]
				   ,[NewValue]
				   ,[ChangeDate]
				   ,[UserID])
			 VALUES
				   ('Empl.web_status'
				   ,@EmplID
				   ,@OldWebStatValue
				   ,@web_status
				   ,@Last_Worked
				   ,@User_ID + '-empl')


			set @webstatusUpdated = current_timestamp

			IF @web_status in (5,77,75)
				BEGIN
					Declare @msg nvarchar(2000),@CAM_Email nvarchar(200),@sub nvarchar(100),@investigatorEmail Nvarchar(200), @investigatorName Nvarchar(200), @applicantName Nvarchar(200), @clientName Nvarchar(200), @clno int,@applicantemail varchar(200)
					declare @Recepients varchar(1000)

					Select @CAM_Email = isnull(U.EmailAddress,'CarlaBingham@precheck.com'), @applicantName = A.First + ' ' + A.Last, @clno = A.CLNO,@applicantemail = A.Email
					From dbo.Appl A left join dbo.Users U on A.UserID = U.UserID
					Where A.Apno = @Apno

					SELECT @clientName = Name FROM Client where CLNO = @clno

					Select @investigatorEmail = isnull(EmailAddress,'PamelaEsquero@precheck.com'), @investigatorName = Name
					From dbo.Users
					wHERE UserID = @User_ID

					Set @investigatorEmail = 'Employment Investigator <' + @investigatorEmail + '>'

					IF DATEPART(HOUR, GETDATE()) < 12
						set @msg = 'Good Morning' 
					else
						set @msg = 'Good Afternoon'

					if @web_status = 5
						Begin
							set @msg = @msg + ', ' + char(9) + char(13)+ char(9) + char(13)+ 'Employer: ' + @employer + ' requires'

							Set @sub = 'Release is required for APNO: ' + cast(@Apno AS nvarchar)  + '; Employer: ' + @employer

							set @msg = @msg + ' a release to process a request for employment verification. Please attach the release and re-open the file.'  
						End
					else if @web_status = 77
						Begin
							set @msg = @msg + ', ' + char(9) + char(13)+ char(9) + char(13)+ 'Employer: ' + @employer + ' requires'

							Set @sub = 'Fee Approval is required for APNO: ' + cast(@Apno AS nvarchar) + '; Employer: ' + @employer

							set @msg = @msg + ' an additional fee to process a request for employment verification. If the fee is approved, please re-open the file.' 
						End
					else if @web_status = 75
						Begin
							set @msg = @msg + ' ' + @applicantName + ',' + char(9) + char(13)+ char(9) + char(13)
					
							Set @sub = 'Application Number: ' + cast(@Apno AS nvarchar) + ' - Employer: ' + @employer

							Set @msg = @msg + 'My name is ' + @investigatorName + '. I’m an employment verifications investigator with PreCheck, Inc., the background screening company that is conducting your background check in connection with your possible employment with ' + @clientName + '.'
							Set @msg = @msg + 'Your assistance is needed to complete the investigation of your employment history.  Could you please furnish a W-2 or paystub as evidence of your employment with ' + @employer + '?'
							Set @msg = @msg + CHAR(13) + CHAR(13)
							Set @msg = @msg + 'We will append these documents to your background report and forward it to ' + @clientName + '.'
				
							SET @Recepients = @applicantemail
				
						End

						IF @web_status = 75
							SET @Recepients = @applicantemail
						else
							SET @Recepients = @CAM_Email

					set @msg = @msg + char(9) + char(13)+ char(9) + char(13) + 'Please let me know if you have any questions. '  + char(9) + char(13)+ char(9) + char(13) + 'Thanks, ' + char(9) + char(13) + @investigatorName + char(9) + char(13) + 'Fax: 866-402-9349'


					EXEC msdb.dbo.sp_send_dbmail   @from_address = @investigatorEmail,@subject=@sub, @recipients=@Recepients,@copy_recipients = @investigatorEmail,@body=@msg ;


				END
	

		 -- VD : For Save And GetNext functionality
			SET @AllowGetNext = 1
		End


		INSERT INTO dbo.getNextAudit 
		SELECT @Apno, @EmplID, 'New WebStatus VS Old WebStatus', 'New WebStatus : ' + cast(@web_status as varchar) + ' Old WebStatus : ' + cast(@OldWebStatValue as varchar) + ' - AllowGetNext : ' + Cast(@AllowGetNext AS varchar),GETDATE(),@User_ID




	
		 -- VD : For Save And GetNext functionality
			IF (@AllowGetNext = 1)
			BEGIN


		--INSERT INTO dbo.getNextAudit 
		--SELECT @Apno, @EmplID, 'New SectStat VS Old SectStat', 'New SectStat : ' + @sectstat + ' Old SectStat : ' + @OldValue + ' In AllowGetNext : ' + Cast(@AllowGetNext AS varchar)


				DECLARE @EmplInvestigator varchar(20)
				set @EmplInvestigator = null

				--For Post Action ReRouting, get the original investigator from the Empl table and update staging along with follow up time
				--The assumption is that the original investigator will not set any of these statuses by themselves....it is usually set by the supervisor, QA or CAM
				IF (@web_status in (33,42,66,79,86,88)) -- 'QA Reviewed'
				begin
						Select @EmplInvestigator = investigator
						From dbo.Empl 
						Where Emplid = @EmplID

						UPDATE EmplGetNextStaging
							SET AppPickedUpDate = NULL,
								Investigator = case when @web_status in (88) THEN null ELSE @EmplInvestigator END,
								TransitionalState = NULL,
								FollowUpOn = CURRENT_TIMESTAMP,
								QueueType = CASE WHEN @web_status = 86 THEN 'Rush' ELSE QueueType end
						WHERE APNO = @Apno 
						  AND EmplID = @EmplID
				end
				ELSE	
					SET @EmplInvestigator = @User_ID

				-- Update GetNextLog table with the exit date
					UPDATE dbo.EmplGetNextLog 
						SET AppExitDate = CURRENT_TIMESTAMP
					WHERE APNO = @Apno
					  AND EmplID = @EmplID

				-- Update Empl / EmplGetNextStaging / ApplSections_Follwup etc
				EXEC [dbo].[VerificationGetNext_WebStatus_Updates] @apno, @emplid, @sectstat, @web_status, @t_followupinterval, @EmplInvestigator, @FollowupDate

			END

			If @OldWebStatValue in (57,87,90)  
			BEGIN
				SET @AllowGetNext = 0
			END

			if (@web_status in (33,42,88,90))
			BEGIN
				SET @AllowGetNext = 0
			END




		Update dbo.Empl
		 SET 
			  [Employer] = @employer
			  ,[Location] = @location
			  ,[SectStat] = @sectstat
   
			  ,[Phone] = @phone
			  ,[Supervisor] = @supervisor
   
			  ,[Dept] = @dept
   
			  ,[From_V] = @from_v
			  ,[To_V] = @to_v
			  ,[Position_V] = @position_v
			  ,[Salary_V] = @salary_v
			  ,[Emp_Type] = @emp_type
			  ,[Rel_Cond] = @rel_cond
				,[Rehire] = @Rehire
			  ,[Ver_By] =@ver_by
			  ,[Title] = @title
			  ,[Priv_Notes] = @priv_notes
			  ,[Pub_Notes] = @pub_notes

			  --New webstatus - Callback logic to set the webstatus to the previous webstatus and is used for callback and releasing to any investigator
			  --if the old status is choose or no status - leave callback as the status

			  --,[web_status] = case when @web_status = 89 and isnull(@OldWebStatValue,0) <> 0 THEN [web_status] ELSE @web_status END
			  ,[web_status] = case when @web_status = 89 and isnull(@OldWebStatValue,0) IN (57, 76, 78, 80, 87) THEN [web_status] ELSE @web_status END

			  --Please check with business and uncomment based on feedback
			  --,investigator = case when @web_status in (89,88) THEN null ELSE investigator END  
			  ,investigator = case when @web_status in (89,88) THEN null 
								   when @web_status in (33,42,66,79,86,88) THEN investigator   -- 'QA Reviewed kinds - set back to the original investigators'
								   ELSE @User_ID END


			  ,[Includealias] = @includealias
			  ,[Includealias2] = @includealias2
			  ,[Includealias3] = @includealias3
			  ,[Includealias4] =@includealias4

			  ,[city] = @city
			  ,[state] = @state
			  ,[zipcode] = @zipcode

			  ,[IsCamReview] = @IsCamReview
			  ,[Last_Worked] = @Last_Worked
			  ,web_updated =    case when @webstatusUpdated is NULL THEN web_updated ELSE @webstatusUpdated end
			  ,[IsIntl] = @isIntl
     
		Where  APNO = @Apno and
			  EmplID = @EmplID 


		UPDATE DBO.APPL Set InUse = null
			Where APNO = @Apno


		SELECT @AllowGetNext AS AllowGetNext
	END
