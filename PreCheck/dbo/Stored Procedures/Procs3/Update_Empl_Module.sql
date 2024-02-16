/***************************************************************/
--Modified by AmyLiu on 04/28/2020: Project:IntranetModule-Status-Substatus
--Modified by AmyLiu on 08/21/2020: Fix 53508: public note was not logged into log table
--Modified by Abhijit Awari on 07/22/2022 HDT#20801 to save Investigator old and new value in change log
--Modified on 9/26/2023 by Dongmei He for Velocity Update 1.7
/****************************************************************/
CREATE PROCEDURE [dbo].[Update_Empl_Module]
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
	  @sectSubStatusID int,  --Amyliu added on 02/25/2020
      @employer varchar(30),
      @location varchar(250),
      @IsCamReview bit,
      @includealias char(1),
      @includealias2 char(1),
      @includealias3 char(1),
      @includealias4 char(1),
      @Last_Worked datetime,
      @isIntl bit,
	  @investigator char(8), -- VD --07/06/2016
	  @ETADate datetime,
	  @recipientname_v varchar(150),
	  @city_v varchar(50),
	  @state_v varchar(20),
	  @country_v varchar(50)
as
  set nocount on

	if (@sectSubStatusID=0) set @sectSubStatusID= null  ---AmyLiu added to allow NULL value inserted into SectSubStatus column as I don't want to chage code with parameter varibles for existing code.
	Declare @OldValue as varchar(8),@Old_Last_Worked datetime,@OldWebStatValue as varchar(8)
			,@oldPrivateNotes varchar(8000),@OldPublicNotes varchar(8000)  --added by schapyala on 11/14/2013 - Dana's request
			,@OldInvestigator as varchar(8) --Deepak(07/15/2016) - Get Next Audit Tracking
			,@OldETADate datetime
			,@OldReopenDate datetime, @NewReopenDate datetime  --Added by Radhika Dereddy on 01/02/2020 for Reopen Date for Modules			
			,@OldSectSubStatusID int 

	SELECT @OldValue = SectStat,@Old_Last_Worked = Last_Worked, @OldWebStatValue = web_status
		   ,@OldSectSubStatusID= SectSubStatusID  --AmyLiu added on 02/25/2020
		   ,@oldPrivateNotes = cast(Priv_Notes as varchar(8000)), @OldPublicNotes = cast(Pub_Notes as varchar(8000)) --added by schapyala on 11/14/2013 - Dana's request
		   ,@OldInvestigator = Investigator --Deepak(07/15/2016) - Get Next Audit Tracking
	FROM Empl(NOLOCK) 
	WHERE APNO = @Apno and EmplID = @EmplID 

	-- Get Existing ETADate before update
	SELECT @OldETADate = ETADate
	FROM ApplSectionsETA AS X(NOLOCK)
	WHERE X.ApplSectionID = 1 AND X.Apno = @Apno AND X.SectionKeyID = @EmplID 

	UPDATE DBO.APPL Set InUse = @User_ID
	WHERE APNO = @Apno

	IF(@ETADate != '1900-01-01')
	BEGIN
		IF ((SELECT COUNT(*) FROM ApplSectionsETA(NOLOCK) WHERE SectionKeyID = @EmplID AND ApplSectionID = 1) = 0)
		BEGIN
			-- Insert into main Table 
			INSERT INTO [dbo].[ApplSectionsETA]
					   ([ApplSectionID]
					   ,[Apno]
					   ,[SectionKeyID]
					   ,[ETADate]
					   ,[CreatedDate]
					   ,[CreatedBy]
					   ,[UpdateDate]
					   ,[UpdatedBy])
				 VALUES
					   (1
					   ,@Apno
					   ,@EmplID
					   ,CAST(@ETADate AS DATE)
					   ,CURRENT_TIMESTAMP
					   ,@investigator
					   ,CURRENT_TIMESTAMP
					   ,@investigator)

			-- Insert into LOG Table to maintain as a record.
			INSERT INTO [dbo].[ApplSectionsETALog]
					   ([ApplSectionID]
					   ,[Apno]
					   ,[SectionKeyID]
					   ,[OldValue]
					   ,[NewValue]
					   ,[CreatedDate]
					   ,[CreatedBy]
					   ,[UpdateDate]
					   ,[UpdatedBy])
				 VALUES
					   (1
					   ,@Apno
					   ,@EmplID
					   ,@OldETADate
					   ,CAST(@ETADate AS DATE)
					   ,CURRENT_TIMESTAMP
					   ,@OldInvestigator
					   ,CURRENT_TIMESTAMP
					   ,@investigator)

		END
		ELSE
		BEGIN
			-- Update ApplSectionsETA with the new ETADate
			UPDATE ApplSectionsETA 
				SET ETADate = CAST(@ETADate AS DATE), 
					UpdatedBy = @investigator, 
					UpdateDate = CURRENT_TIMESTAMP 
			WHERE ApplSectionID = 1 
			  AND Apno = @Apno 
			  AND SectionKeyID = @EmplID

			-- ETADate -- VD - 02/08/2018 
			IF (@ETADate <> @OldETADate)
			BEGIN

			INSERT INTO [dbo].[ApplSectionsETALog]
					   ([ApplSectionID]
					   ,[Apno]
					   ,[SectionKeyID]
					   ,[OldValue]
					   ,[NewValue]
					   ,[CreatedDate]
					   ,[CreatedBy]
					   ,[UpdateDate]
					   ,[UpdatedBy])
				 VALUES
					   (1
					   ,@Apno
					   ,@EmplID
					   ,@OldETADate
					   ,CAST(@ETADate AS DATE)
					   ,CURRENT_TIMESTAMP
					   ,@OldInvestigator
					   ,CURRENT_TIMESTAMP
					   ,@investigator)
			END
		END
	END

	if ((Select apstatus from dbo.appl where apno  = @Apno) = 'F')
	BEGIN
		--Get Existing ReopenDate from Appl Table Added by Radhika Dereddy on 01/02/2020
		SELECT @OldReopenDate = ReopenDate FROM APPL WHERE APNO = @APNO 

		UPDATE DBO.APPL Set ApStatus = 'P',last_updated = current_timestamp, ReopenDate = current_timestamp --added ReopenDate by Radhika Dereddy on 07/24/2014
		Where APNO = @Apno

		--Get Updated ReopenDate from Appl Table Added by Radhika Dereddy on 01/02/2020
		SELECT @NewReopenDate = ReopenDate FROM APPL WHERE APNO = @Apno

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

-- Added by Radhika Dereddy to log the Reopen date and the User From module on 01/02/2020 CR682
		INSERT INTO [dbo].[ChangeLog]
			   ([TableName]
			   ,[ID]
			   ,[OldValue]
			   ,[NewValue]
			   ,[ChangeDate]
			   ,[UserID])
		 VALUES
			   ('appl.ReopenDate'
			   ,@Apno
			   ,@OldReopenDate
			   ,@NewReopenDate
			   ,current_timestamp
			   ,@User_ID + '-empl')
	END

	/*
	-- ETADate -- VD - 02/08/2018 
	IF (@ETADate <> @OldETADate)
	BEGIN
		INSERT INTO [dbo].[ChangeLog]
				   ([TableName]
				   ,[ID]
				   ,[OldValue]
				   ,[NewValue]
				   ,[ChangeDate]
				   ,[UserID])
			 VALUES
				   ('ApplSectionsETA.ETADate'
				   ,@EmplID
				   ,CONVERT(VARCHAR,@OldETADate,121)
				   ,CONVERT(VARCHAR,@ETADate,121)
				   ,CURRENT_TIMESTAMP
				   ,@investigator)
	END
	*/


	-- SectStat
	IF (@sectstat <> @OldValue)
	BEGIN
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
	END
	IF (isnull(@sectSubStatusID,0) <> isnull(@OldSectSubStatusID,0))  --AmyLiu added on 02/25/2020
	BEGIN
	INSERT INTO [dbo].[ChangeLog]
			   ([TableName]
			   ,[ID]
			   ,[OldValue]
			   ,[NewValue]
			   ,[ChangeDate]
			   ,[UserID])
		 VALUES
			   ('Empl.SectSubStatus'
			   ,@EmplID
			   ,@OldSectSubStatusID
			   , cast(@sectSubStatusID as varchar)
			   ,@Last_Worked
			   ,@User_ID + '-empl')
	END
	-- Added the below change for updating web status.
	if (@web_status <> @OldWebStatValue)
	BEGIN
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
	End

	---- Added the below change for updating priv_notes.
	----added by schapyala on 11/14/2013 - Dana's request
	IF (cast(@priv_notes as varchar(8000)) <> isnull(@oldPrivateNotes,''))
	BEGIN
	INSERT INTO [dbo].[ChangeLog]
			   ([TableName]
			   ,[ID]
			   ,[OldValue]
			   ,[NewValue]
			   ,[ChangeDate]
			   ,[UserID])
		 VALUES
			   ('Empl.priv_notes'
			   ,@EmplID
			   ,@oldPrivateNotes
			   ,cast(@priv_notes as varchar(8000))
			   ,@Last_Worked
			   ,@User_ID + '-empl')
	End


	---- Added the below change for updating pub_notes
	----added by schapyala on 11/14/2013 - Dana's request
	IF (cast(@pub_notes as varchar(8000)) <> isnull(@OldPublicNotes,''))
	BEGIN
	INSERT INTO [dbo].[ChangeLog]
			   ([TableName]
			   ,[ID]
			   ,[OldValue]
			   ,[NewValue]
			   ,[ChangeDate]
			   ,[UserID])
		 VALUES
			   ('Empl.pub_notes'
			   ,@EmplID
			   ,@OldPublicNotes
			   ,cast(@pub_notes as varchar(8000))
			   ,@Last_Worked
			   ,@User_ID + '-empl')
	End

	-- Added the below change for insert into Audit Table -- Deepak (07/15/2016)
	IF ( @investigator <> @OldInvestigator)
	BEGIN
	INSERT INTO [dbo].[GetNextAudit]
			   ([Apno]
			   ,[EmplId]
			   ,[OldValue]
			   ,[NewValue]
			   ,[Description]
			   ,[CreatedDate]
			   ,[CreatedBy]
			   ,[UpdateDate]
			   ,[UpdatedBy])
		 VALUES
			   (@Apno
			   ,@EmplID
			   ,@OldInvestigator
			   ,@investigator
			   ,'ReferenceModule'
			   ,CURRENT_TIMESTAMP
			   ,@User_ID
			   ,CURRENT_TIMESTAMP
			   ,@User_ID)
	END

	---Start of Code Added by Abhijit Awari on 07/22/2022 HDT#20801
	IF ( @investigator <> @OldInvestigator)
	BEGIN
	INSERT INTO [dbo].[ChangeLog]
			   ([TableName]
			   ,[ID]
			   ,[OldValue]
			   ,[NewValue]
			   ,[ChangeDate]
			   ,[UserID])
		 VALUES
			   ('Empl.Investigator'
			   ,@EmplID
			   ,@OldInvestigator
			   ,@investigator
			  ,current_timestamp
			   ,@User_ID)
	END
	
	---End of code Added by Abhijit Awari on 07/18/2022 HDT#20801

	Update Empl
	 SET 
		  [Employer] = @employer
		  ,[Location] = @location
		  ,[SectStat] = @sectstat
		  ,[SectSubStatusID] = @sectSubStatusID    ---AmyLiu added on 02/25/2020
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
		  ,[web_status] = @web_status

		  ,[Includealias] = @includealias
		  ,[Includealias2] = @includealias2
		  ,[Includealias3] = @includealias3
		  ,[Includealias4] =@includealias4

		  ,[city] = @city
		  ,[state] = @state
		  ,[zipcode] = @zipcode

		  ,[IsCamReview] = @IsCamReview
		  ,[Last_Worked] = @Last_Worked
		  ,[IsIntl] = @isIntl
		  ,[Investigator] = CASE WHEN @web_status in (57, 76, 78, 80, 87) THEN null -- VD --07/06/2016
							WHEN @investigator = '0' THEN null
							ELSE @investigator END
							,RecipientName_V = @recipientname_v
		  ,City_V = @city_v
		  ,State_V = @state_v
		  ,Country_V = @country_v
     
	Where  APNO = @Apno and
		  EmplID = @EmplID 


	UPDATE DBO.APPL Set InUse = null
		Where APNO = @Apno



