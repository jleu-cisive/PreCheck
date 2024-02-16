--===================================================================================================
--Modified by AmyLiu on 04/28/2020: Project:IntranetModule-Status-Substatus
--Modified by AmyLiu on 08/21/2020: Fix 53508: public note was not logged into log table
--Modified by Abhijit Awari on 07/22/2022 HDT#20801 to save Investigator old and new value in change log
--MOdified by Tanay Dubey on  09/01/2022 HDT 60206 to capture Investigator Assigned Date .(line 353)
--Modified on 9/26/2023 by Dongmei He for Velocity Update 1.7
--===================================================================================================
--exec [dbo].[Update_Educat_Module] 7231453, 3883821, 'dhe', 'TX', null, 'test school', 'n/a', 'n/a', null, null, '0',  '1', null, null, 'n/a', 'n/a', null, 0, 0, null, null, null, null, null, null, null, null, null, null, null, '0','0', '0', '0', null, 0, null, 'test'
CREATE PROCEDURE [dbo].[Update_Educat_Module]  
      @Apno int,  
      @EducatID int,  
      @User_ID char(8),  
      @state varchar(2),  
      @phone varchar(20),  
      @school varchar(50),  
      @to_a varchar(12),  
      @from_a varchar(12),  
      @priv_notes text,  
      @pub_notes text,  
      @sectstat char(1),  
   @sectSubStatusID int,  --Amyliu added on 02/27/2020  
      @degree_a char(25),  
      @studies_a char(25),  
      @from_v char(12),  
      @to_v char(12),  
      @contact_title char(30),  
      @web_status int,  
      @IsCamReview bit,  
      @contact_date datetime,  
      @city varchar(16),  
      @campusname varchar(25),  
      @zipcode varchar(5),  
      @name varchar(30),  
      @degree_v char(25),  
      @studies_v char(25),  
      @topending datetime,  
      @frompending datetime,  
      @contact_name char(30),  
      @investigator char(30),  
      @includealias char(1),  
      @includealias2 char(1),  
      @includealias3 char(1),  
      @includealias4 char(1),  
      @Last_Worked datetime,  
      @isIntl bit,  
      @ETADate datetime,
	   @recipientname_v varchar(150) = null,
	   @graduationdate_v datetime = null,
	   @city_v varchar(50) = null,
	   @state_v varchar(20) = null,
	   @country_v varchar(50) = null
  
as  
  SET NOCOUNT ON  
   if (@sectSubStatusID=0) set @sectSubStatusID= null  ---AmyLiu added to allow NULL value inserted into SectSubStatus column as I don't want to chage code with parameter varibles for existing code.  
  DECLARE @OldValue as varchar(8),@Old_Last_Worked datetime, @OldWebStatValue as varchar(8), --Added (@OldWebStatValue)by RDereddy on 03/27/2014  
    @oldPrivateNotes varchar(8000),@OldPublicNotes varchar(8000) --added by radhika dereddy on 05/13/2014 - Dana's request   
   ,@OldETADate datetime, @OldInvestigator as varchar(8) -- Added by Deepak Vodethela on 02/22/2018 - Aggregate ETA's project  
   ,@OldReopenDate datetime, @NewReopenDate datetime  --Added by Radhika Dereddy on 01/02/2020 for Reopen Date for Modules  
   ,@OldSectSubStatusID int   --Amyliu on 02/27/2020  
  
 SELECT @OldValue = SectStat,@Old_Last_Worked = Last_Worked, @OldWebStatValue = web_status, @OldSectSubStatusID= SectSubStatusID,  --AmyLiu added on 02/25/2020  
   @oldPrivateNotes = cast(Priv_Notes as varchar(8000)), @OldPublicNotes = cast(Pub_Notes as varchar(8000)) --added by radhika dereddy on 05/13/2014 - Dana's request  
   ,@OldInvestigator = investigator  
  FROM Educat(NOLOCK)   
  WHERE APNO = @Apno and EducatID = @EducatID --Added (@OldWebStatValue = web_status) by RDereddy on 03/27/2014  
  
 -- Get Existing ETADate before update  
 SELECT @OldETADate = ETADate  
 FROM ApplSectionsETA AS X(NOLOCK)  
 WHERE X.ApplSectionID = 2 AND X.Apno = @Apno AND X.SectionKeyID = @EducatID   
  
 UPDATE DBO.APPL   
  SET InUse = @User_ID  
 WHERE APNO = @Apno  
  
 IF(@ETADate != '1900-01-01')  
 BEGIN  
  IF ((SELECT COUNT(*) FROM ApplSectionsETA(NOLOCK) WHERE SectionKeyID = @EducatID AND ApplSectionID = 2) = 0)  
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
        (2  
        ,@Apno  
        ,@EducatID  
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
        (2  
        ,@Apno  
        ,@EducatID  
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
   WHERE ApplSectionID = 2  
     AND Apno = @Apno   
     AND SectionKeyID = @EducatID  
  
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
        (2  
        ,@Apno  
        ,@EducatID  
        ,@OldETADate  
        ,CAST(@ETADate AS DATE)  
        ,CURRENT_TIMESTAMP  
        ,@OldInvestigator  
        ,CURRENT_TIMESTAMP  
        ,@User_ID)  
   END  
  END  
 END  
  
 IF ((SELECT apstatus FROM dbo.appl(NOLOCK) WHERE apno  = @Apno) = 'F')  
 BEGIN  
  --Get Existing ReopenDate from Appl Table Added by Radhika Dereddy on 01/02/2020  
  SELECT @OldReopenDate = ReopenDate FROM APPL WHERE APNO = @APNO   
  
  UPDATE DBO.APPL Set ApStatus = 'P',last_updated = current_timestamp, ReopenDate = current_timestamp --added ReopenDate by Radhika Dereddy on 07/24/2014  
  Where APNO = @Apno  
  
  --Get Updated ReopenDate from Appl Table Added by Radhika Dereddy on 01/02/2020  
  SELECT @NewReopenDate =ReopenDate FROM APPL WHERE APNO = @Apno  
  
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
      ,@User_ID + '-Educat')  
  
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
      ,@User_ID + '-Educat')  
  
 END  
  
 IF ( @sectstat <>@OldValue)  
 BEGIN  
 INSERT INTO [dbo].[ChangeLog]  
      ([TableName]  
      ,[ID]  
      ,[OldValue]  
      ,[NewValue]  
      ,[ChangeDate]  
      ,[UserID])  
   VALUES  
      ('Educat.SectStat'  
      ,@EducatID  
      ,@OldValue  
      ,@sectstat  
      ,current_timestamp  
      ,@User_ID + '-Educat')  
 END  
 IF (isnull(@sectSubStatusID,0) <> isnull(@OldSectSubStatusID,0))  --AmyLiu added on 02/27/2020  
 BEGIN  
 INSERT INTO [dbo].[ChangeLog]  
      ([TableName]  
      ,[ID]  
      ,[OldValue]  
      ,[NewValue]  
      ,[ChangeDate]  
      ,[UserID])  
   VALUES  
      ('Educat.SectSubStatus'  
      ,@EducatID  
      ,@OldSectSubStatusID  
      , cast(@sectSubStatusID as varchar)  
      ,current_timestamp  
      ,@User_ID + '-Educat')  
 END  
 --Added by Radhika Dereddy on 03/27/2014 (as per Kiran)  
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
      ('Educat.web_status'  
      ,@EducatID  
      ,@OldWebStatValue  
      ,@web_status  
     ,current_timestamp  
      ,@User_ID + '-Educat')  
 END  
  
 ---- Added the below change for updating Private Notes  
 ----added by radhika dereddy on 05/13/2014 - Dana's request  
 IF (CAST(@priv_notes as varchar(8000)) <> isnull(@oldPrivateNotes,''))  
 BEGIN  
 INSERT INTO [dbo].[ChangeLog]  
      ([TableName]  
      ,[ID]  
      ,[OldValue]  
      ,[NewValue]  
      ,[ChangeDate]  
      ,[UserID])  
   VALUES  
      ('Educat.priv_notes'  
      ,@EducatID  
      ,@oldPrivateNotes  
      ,cast(@priv_notes as varchar(8000))  
      ,current_timestamp  
      ,@User_ID + '-Educat')  
 End  
  
  
 ---- Added the below change for updating web status.  
 ----added by radhika dereddy on 05/13/2014 - Dana's request  
 IF (CAST(@pub_notes as varchar(8000)) <> isnull(@OldPublicNotes,''))  
 BEGIN  
 INSERT INTO [dbo].[ChangeLog]  
      ([TableName]  
      ,[ID]  
      ,[OldValue]  
      ,[NewValue]  
      ,[ChangeDate]  
      ,[UserID])  
   VALUES  
      ('Educat.pub_notes'  
      ,@EducatID  
      ,@OldPublicNotes  
      ,cast(@pub_notes as varchar(8000))  
      ,current_timestamp  
      ,@User_ID + '-Educat')  
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
      ('Educat.Investigator'  
      ,@EducatID  
      ,@OldInvestigator  
      ,@investigator  
     ,current_timestamp  
      ,@User_ID)  
 END  
   
 ---End of code Added by Abhijit Awari on 07/18/2022 HDT#20801  
  
 UPDATE Educat  
  SET   
    state = @state,  
    phone = @phone,  
    school = @school,  
    to_a = @to_a,  
    from_a = @from_a,  
    priv_notes = @priv_notes,  
    pub_notes = @pub_notes,  
    sectstat = @sectstat,  
    [SectSubStatusID] = @sectSubStatusID,    ---AmyLiu added on 02/27/2020  
    degree_a = @degree_a,  
    studies_a = @studies_a,  
    from_v = ltrim(Rtrim(@from_v)),  
    to_v = ltrim(Rtrim(@to_v)),  
    contact_title = ltrim(Rtrim(@contact_title)),  
    web_status = ltrim(Rtrim(@web_status)),  
    IsCamReview = @IsCamReview,  
    contact_date = @contact_date,  
    city = @city,  
    campusname  = @campusname,  
    zipcode = @zipcode,  
    [name] = @name,  
    degree_v = ltrim(Rtrim(@degree_v)),  
    studies_v =ltrim(Rtrim( @studies_v)),  
    topending = @topending,  
    frompending = @frompending,  
    contact_name = ltrim(Rtrim(@contact_name)),  
    investigator = @investigator,  
    includealias = @includealias,  
    includealias2 = @includealias2,  
    includealias3 = @includealias3,  
    includealias4 = @includealias4,  
    Last_Worked = @Last_Worked,  
    isIntl = @isIntl  ,
	 InvestigatorAssignedDate = GETDATE(),  ---added by Tanay Dubey on 1st Sept,2022
    Recipientname_V = @recipientname_v,
	 GraduationDate_V = @graduationdate_v,
	 City_V = @city_v,
	 State_V = @state_v,
	 Country_V = @country_v
 WHERE APNO = @Apno   
   AND EducatID = @EducatID   
  
 UPDATE DBO.APPL Set InUse = null  
 WHERE APNO = @Apno  