
/***************************************************************/
--Modified by AmyLiu on 04/28/2020: Project:IntranetModule-Status-Substatus
--Modified by AmyLiu on 08/21/2020: Fix 53508: public note was not logged into log table
/****************************************************************/
CREATE PROCEDURE [dbo].[Update_ProfLic_Module]
      @Apno int,
      @ProfLicID int,
      @User_ID char(8),
      @sectstat char(1),
	  @sectSubStatusID int,  --Amyliu added on 02/25/2020
      @lic_type varchar(30),
      @lic_type_v varchar(100), -- changed by Radhika Dereddy on 01/15/2014 the datatype from varchar(30) to varchar(100)
      @lic_no_v varchar(20),
      @year_v varchar(10),
      @expire_v datetime= null,
      @state_v varchar(8),
      @state varchar(8),
      @status varchar(50), -- changed by Radhika Dereddy on 08/03/2016 the datatype from varchar (20) to varchar(50)
      @priv_notes text,
      @pub_notes text,
      @web_status int,
      @includealias char(1),
      @includealias2 char(1),
      @includealias3 char(1),
      @includealias4 char(1),
      @organization varchar(30),
      @contact_name varchar(30),
      @contact_title varchar(30),
      @contact_date datetime= null,
      @investigator varchar(30),
      @topending datetime,
      @frompending datetime,
      @Last_Worked datetime,
      @IsCamReview bit,
      @generatecertificate bit,
      @certificateavailabilitystatus int,
	  @name_v varchar(200),-- changed by Radhika Dereddy on 01/15/2014
	  @speciality_v varchar(50),
	  @lifetime_v bit,
	  @multistate_v varchar(15),
	  @boardactions_v varchar(10),
	  @contactmethod_v varchar(50),
	  @licenseTypeId int,-- changed by Radhika Dereddy on 01/15/2014
	  @ETADate datetime
    
as
	set nocount on
		if (@sectSubStatusID=0) set @sectSubStatusID= null  ---AmyLiu added to allow NULL value inserted into SectSubStatus column as I don't want to chage code with parameter varibles for existing code.
	Declare @OldValue as varchar(8),@Old_Last_Worked datetime, @OldWebStatValue as varchar(8), --Added (@OldWebStatValue)by RDereddy on 03/27/2014
			@oldPrivateNotes varchar(8000),@OldPublicNotes varchar(8000), --added by radhika dereddy on 05/13/2014 - Dana's request 
			@OldETADate datetime, @OldInvestigator as varchar(8) -- Added by Deepak Vodethela on 02/22/2018 - Aggregate ETA's project
			,@OldReopenDate datetime, @NewReopenDate datetime  --Added by Radhika Dereddy on 01/02/2020 for Reopen Date for Modules
			,@OldSectSubStatusID int --AmyLiu added on 02/25/2020

	SELECT	@OldValue = SectStat,@Old_Last_Worked = Last_Worked, @OldWebStatValue = web_status, 
			@oldPrivateNotes = CAST(Priv_Notes as varchar(8000)), @OldPublicNotes = cast(Pub_Notes  as varchar(8000)) --added by radhika dereddy on 05/13/2014 - Dana's request 
			,@OldInvestigator = investigator -- Added by Deepak Vodethela on 02/22/2018 - Aggregate ETA's project
			,@OldSectSubStatusID= SectSubStatusID  --AmyLiu added on 02/25/2020
	FROM ProfLic (NOLOCK)
	WHERE APNO = @Apno AND ProfLicID = @ProfLicID --Added (@OldWebStatValue = web_status) by RDereddy on 03/27/2014

	-- Get Existing ETADate before update
	SELECT @OldETADate = ETADate
	FROM ApplSectionsETA AS X(NOLOCK)
	WHERE X.ApplSectionID = 4 AND X.Apno = @Apno AND X.SectionKeyID = @ProfLicID 

	UPDATE DBO.APPL 
		Set InUse = @User_ID
	Where APNO = @Apno

	-- Added by Deepak Vodethela on 02/22/2018 - Aggregate ETA's project
	IF(@ETADate != '1900-01-01')
	BEGIN
		IF ((SELECT COUNT(*) FROM ApplSectionsETA(NOLOCK) WHERE SectionKeyID = @ProfLicID AND ApplSectionID = 4) = 0)
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
					   (4
					   ,@Apno
					   ,@ProfLicID
					   ,CAST(@ETADate AS DATE)
					   ,CURRENT_TIMESTAMP
					   ,@User_ID
					   ,CURRENT_TIMESTAMP
					   ,@User_ID)

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
						(4
						,@Apno
						,@ProfLicID
						,@OldETADate
						,CAST(@ETADate AS DATE)
						,CURRENT_TIMESTAMP
						,@OldInvestigator
						,CURRENT_TIMESTAMP
						,@User_ID)
		END
		ELSE
		BEGIN
			-- Update ApplSectionsETA with the new ETADate
			UPDATE ApplSectionsETA 
				SET ETADate = CAST(@ETADate AS DATE), 
					UpdatedBy = @User_ID, 
					UpdateDate = CURRENT_TIMESTAMP 
			WHERE ApplSectionID = 4
			  AND Apno = @Apno 
			  AND SectionKeyID = @ProfLicID

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
						   (4
						   ,@Apno
						   ,@ProfLicID
						   ,@OldETADate
						   ,CAST(@ETADate AS DATE)
						   ,CURRENT_TIMESTAMP
						   ,@OldInvestigator
						   ,CURRENT_TIMESTAMP
						   ,@User_ID)
			END
		END
	END

	IF ((SELECT apstatus FROM dbo.appl(NOLOCK) where apno  = @Apno) = 'F')
	BEGIN

		--Get Existing ReopenDate from Appl Table Added by Radhika Dereddy on 01/02/2020
		SELECT @OldReopenDate = ReopenDate FROM APPL WHERE APNO = @APNO 

		UPDATE DBO.APPL 
			Set ApStatus = 'P',
				last_updated = current_timestamp, 
				ReopenDate = current_timestamp
		WHERE APNO = @Apno

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
			   ,@User_ID + '-ProfLic')

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
			   ,@User_ID + '-ProfLic')

	END

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
			   ('ProfLic.SectStat'
			   ,@ProfLicID
			   ,@OldValue
			   ,@sectstat
			   ,@Last_Worked
			   ,@User_ID)
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
			   ('ProfLic.SectSubStat'
			   ,@ProfLicID
			   ,@OldSectSubStatusID
			   , cast(@sectSubStatusID as varchar)
			   ,@Last_Worked
			   ,@User_ID )
	END
	--Added by Radhika Dereddy on 03/27/2014 as per Dana's Request & Kirans approval
	-- Added the below change for updating web status.
	IF (@web_status <> @OldWebStatValue)
	BEGIN
	INSERT INTO [dbo].[ChangeLog]
			   ([TableName]
			   ,[ID]
			   ,[OldValue]
			   ,[NewValue]
			   ,[ChangeDate]
			   ,[UserID])
		 VALUES
			   ('ProfLic.web_status'
			   ,@ProfLicID
			   ,@OldWebStatValue
			   ,@web_status
			   ,@Last_Worked
			   ,@User_ID)
	END

	---- Added the below change for updating Private Notes
	----added by radhika dereddy on 05/13/2014 - Dana's request
	if (cast(@priv_notes as varchar(8000)) <> isnull(@oldPrivateNotes,''))
	Begin
	INSERT INTO [dbo].[ChangeLog]
			   ([TableName]
			   ,[ID]
			   ,[OldValue]
			   ,[NewValue]
			   ,[ChangeDate]
			   ,[UserID])
		 VALUES
			   ('ProfLic.priv_notes'
			   ,@ProfLicID
			   ,@oldPrivateNotes
			   ,cast(@priv_notes as varchar(8000))
			   ,@Last_Worked
			   ,@User_ID)
	End

	---- Added the below change for updating web status.
	----added by radhika dereddy on 05/13/2014 - Dana's request
	if (cast(@pub_notes as varchar(8000)) <> isnull(@OldPublicNotes,''))
	Begin
	INSERT INTO [dbo].[ChangeLog]
			   ([TableName]
			   ,[ID]
			   ,[OldValue]
			   ,[NewValue]
			   ,[ChangeDate]
			   ,[UserID])
		 VALUES
			   ('ProfLic.pub_notes'
			   ,@ProfLicID
			   ,@OldPublicNotes
			   ,cast(@pub_notes as varchar(8000))
			   ,@Last_Worked
			   ,@User_ID)
	End
	
	DECLARE @license_Type_V AS VARCHAR(100)
	--Commented by Radhika Dereddy on  05/05/2014
	--SET @license_Type_V = (SELECT ItemValue + '-' + Item FROM HEVN.dbo.LicenseType WHERE LicenseTypeId  = @licenseTypeId)

	SET @license_Type_V = (SELECT Item FROM HEVN.dbo.LicenseType(NOLOCK) WHERE LicenseTypeId  = @licenseTypeId)


	Update ProfLic
	 SET 
		  sectstat = @sectstat,
		  [SectSubStatusID] = @sectSubStatusID,    ---AmyLiu added on 02/25/2020
		  lic_type = @lic_type,
		  lic_type_v = @license_Type_V,
		  lic_no_v = @lic_no_v,
		  year_v = @year_v,
		  expire_v = @expire_v,
		  state_v = @state_v,
		  state = @state,
		  status = @status,
		  priv_notes = @priv_notes,
		  pub_notes = @pub_notes,
		  web_status = @web_status,
		  includealias = @includealias,
		  includealias2 = @includealias2,
		  includealias3 = @includealias3,
		  includealias4 = @includealias4,
		  organization = @organization,
		  contact_name = @contact_name,
		  contact_title = @contact_title,
		  contact_date = @contact_date,
		  investigator = @investigator,
		  topending = @topending,
		  frompending = @frompending,
		  Last_Worked = @Last_Worked,
		  IsCamReview = 0,
		  generatecertificate = @generatecertificate,
		  certificateavailabilitystatus = @certificateavailabilitystatus,
		  nameonLicense_v = @name_v, 
		  speciality_v = @speciality_v, 
		  lifeTime_v= @lifetime_v ,
		  multistate_v= @multistate_v, 
		  boardactions_v= @boardactions_v ,
		  contactmethod_v = @contactmethod_v,
		  LicenseTypeID = @licenseTypeId      
	Where  APNO = @Apno and
		   ProfLicID = @ProfLicID 

	UPDATE DBO.APPL Set InUse = null
	Where APNO = @Apno









