/*
Procedure Name : Testing_AUTOORDER_SAME_DB
Requested By: Kiran Miryala
Developer: Deepak Vodethela
Execution : EXEC [dbo].[Testing_AUTOORDER_IN_PROD] 4769537, 15711
*/
CREATE PROCEDURE [dbo].[Testing_AUTOORDER_SAME_DB]
@Apno int , @clno int = null AS
SET NOCOUNT ON

BEGIN TRANSACTION 
BEGIN TRY

DECLARE @NeedsReviewValue varchar(2) = 'X1', --Change the NeedsReview column to '%1' for ApplPreprocessor to Run at given interval
		@NewApno int

-- Insert into Appl
INSERT INTO [dbo].[Appl]
           (--[APNO],
		   [ApStatus]
           --,[UserID]
           ,[Billed]
           --,[Investigator]
           ,[EnteredBy]
           ,[EnteredVia]
           ,[ApDate]
           ,[CompDate]
           ,[CLNO]
           ,[Attn]
           ,[Last]
           ,[First]
           ,[Middle]
           ,[Alias]
           ,[Alias2]
           ,[Alias3]
           ,[Alias4]
           ,[SSN]
           ,[DOB]
           ,[Sex]
           ,[DL_State]
           ,[DL_Number]
           ,[Addr_Num]
           ,[Addr_Dir]
           ,[Addr_Street]
           ,[Addr_StType]
           ,[Addr_Apt]
           ,[City]
           ,[State]
           ,[Zip]
           ,[Pos_Sought]
           ,[Update_Billing]

           ,[Priv_Notes]
           ,[Pub_Notes]

           ,[PC_Time_Stamp]
           ,[Pc_Time_Out]
           ,[Special_instructions]
           ,[Reason]
           ,[ReopenDate]
           ,[OrigCompDate]
           ,[Generation]

           ,[Alias1_Last]
           ,[Alias1_First]
           ,[Alias1_Middle]
           ,[Alias1_Generation]
           ,[Alias2_Last]
           ,[Alias2_First]
           ,[Alias2_Middle]
           ,[Alias2_Generation]
           ,[Alias3_Last]
           ,[Alias3_First]
           ,[Alias3_Middle]
           ,[Alias3_Generation]
           ,[Alias4_Last]
           ,[Alias4_First]
           ,[Alias4_Middle]
           ,[Alias4_Generation]

           ,[PrecheckChallenge]
           ,[InUse]
           ,[ClientAPNO]
           ,[ClientApplicantNO]
           ,[Last_Updated]
           ,[DeptCode]
           ,[NeedsReview]
           ,[StartDate]
           ,[RecruiterID]
           ,[Phone]
           ,[Rush]
           ,[IsAutoPrinted]
           ,[AutoPrintedDate]
           ,[IsAutoSent]
           ,[AutoSentDate]
           ,[PackageID]
           ,[Rel_Attached]
           ,[CreatedDate]
           ,[ClientProgramID]
           ,[I94]
           ,[Recruiter_Email]
           ,[CAM]
           ,[SubStatusID]
           ,[GetNextDate]
           ,[Email]
           ,[CellPhone]
           ,[OtherPhone]
           ,[IsDrugTestFileFound_bit]
           ,[IsDrugTestFileFound]
           ,[FreeReport]
           ,[ClientNotes])
     
     SELECT 
      --Apno,
	  'P'
     -- ,[UserID]
      ,[Billed]
      --,[Investigator]
      ,'Testing'
      ,[EnteredVia]
      ,[ApDate]
      ,NULL
      ,coalesce(@clno, [CLNO])
      ,[Attn]
      ,[Last]
      ,[First]
      ,[Middle]
      ,[Alias]
      ,[Alias2]
      ,[Alias3]
      ,[Alias4]
      ,[SSN]
      ,[DOB]
      ,[Sex]
      ,[DL_State]
      ,[DL_Number]
      ,[Addr_Num]
      ,[Addr_Dir]
      ,[Addr_Street]
      ,[Addr_StType]
      ,[Addr_Apt]
      ,[City]
      ,[State]
      ,[Zip]
      ,[Pos_Sought]
      ,[Update_Billing]

      ,[Priv_Notes]
      ,[Pub_Notes]

      ,[PC_Time_Stamp]
      ,[Pc_Time_Out]
	  ,[Special_instructions]
      ,[Reason]
      ,[ReopenDate]
      ,[OrigCompDate]
      ,[Generation]

      ,[Alias1_Last]
      ,[Alias1_First]
      ,[Alias1_Middle]
      ,[Alias1_Generation]
      ,[Alias2_Last]
      ,[Alias2_First]
      ,[Alias2_Middle]
      ,[Alias2_Generation]
      ,[Alias3_Last]
      ,[Alias3_First]
      ,[Alias3_Middle]
      ,[Alias3_Generation]
      ,[Alias4_Last]
      ,[Alias4_First]
      ,[Alias4_Middle]
      ,[Alias4_Generation]

      ,[PrecheckChallenge]
      ,NULL
      ,[ClientAPNO]
      ,CAST(@Apno as varchar(10))
      ,[Last_Updated]
      ,[DeptCode]
	  ,@NeedsReviewValue
      ,[StartDate]
      ,[RecruiterID]
      ,[Phone]
      ,[Rush]
      ,[IsAutoPrinted]
      ,[AutoPrintedDate]
      ,[IsAutoSent]
      ,[AutoSentDate]
      ,[PackageID]
      ,[Rel_Attached]
      ,GETDATE()
      ,[ClientProgramID]
      ,[I94]
      ,[Recruiter_Email]
      ,[CAM]
      ,[SubStatusID]
      ,[GetNextDate]
      ,[Email]
      ,[CellPhone]
      ,[OtherPhone]
      ,[IsDrugTestFileFound_bit]
      ,[IsDrugTestFileFound]
      ,[FreeReport]
      ,[ClientNotes]
  FROM [dbo].[Appl] 
  WHERE Apno IN (@Apno)

  -- Query to capture the new Apno created in DevTest and pass it on to related tables
  SELECT TOP 1 @NewApno = Apno from [dbo].[Appl] WHERE ClientApplicantNO = CAST(@Apno as nvarchar) ORDER BY dbo.Appl.CreatedDate DESC ;

 
  IF @NewApno IS NOT NULL OR @NewApno > 0
  BEGIN

-- Insert into Empl

INSERT INTO [dbo].[Empl]
           ([Apno]
           ,[Employer]
           ,[Location]
           ,[SectStat]
           ,[Worksheet]
           ,[Phone]
           ,[Supervisor]
           ,[SupPhone]
           ,[Dept]
           ,[RFL]
           ,[DNC]
           ,[SpecialQ]
           ,[Ver_Salary]
           ,[From_A]
           ,[To_A]
           ,[Position_A]
           ,[Salary_A]
           ,[From_V]
           ,[To_V]
           ,[Position_V]
           ,[Salary_V]
           ,[Emp_Type]
           ,[Rel_Cond]
           ,[Rehire]
           ,[Ver_By]
           ,[Title]
           ,[Priv_Notes]
           ,[Pub_Notes]
           ,[web_status]
           ,[web_updated]
           ,[Includealias]
           ,[Includealias2]
           ,[Includealias3]
           ,[Includealias4]
           ,[PendingUpdated]
           ,[Time_In]
           ,[Last_Updated]
           ,[city]
           ,[state]
           ,[zipcode]
           ,[Investigator]
           ,[EmployerID]
           ,[InvestigatorAssigned]
           ,[PendingChanged]
           ,[TempInvestigator]
           ,[InUse]
           ,[CreatedDate]
           ,[EnteredBy]
           ,[EnteredDate]
           ,[IsCamReview]
           ,[Last_Worked]
           ,[ClientEmployerID]
           ,[AutoFaxStatus]
           ,[IsOnReport]
           ,[IsHidden]
           ,[IsHistoryRecord]
           ,[EmploymentStatus]
           ,[IsOKtoContact]
           ,[OKtoContactInitial]
           ,[EmplVerifyID]
           ,[GetNextDate]
           ,[SubStatusID]
           ,[ClientAdjudicationStatus]
           ,[ClientRefID]
           ,[IsIntl]
           ,[DateOrdered]
           ,[OrderId]
           ,[Email]
           ,[AdverseRFL]
           ,[InUse_TimeStamp])

     SELECT
           @NewApno
           ,[Employer]
           ,[Location]
           ,'0'
           ,[Worksheet]
           ,[Phone]
           ,[Supervisor]
           ,[SupPhone]
           ,[Dept]
           ,[RFL]
           ,[DNC]
           ,[SpecialQ]
           ,[Ver_Salary]
           ,[From_A]
           ,[To_A]
           ,[Position_A]
           ,[Salary_A]
           ,[From_V]
           ,[To_V]
           ,[Position_V]
           ,[Salary_V]
           ,[Emp_Type]
           ,[Rel_Cond]
           ,[Rehire]
           ,[Ver_By]
           ,[Title]
           ,[Priv_Notes]
           ,[Pub_Notes]
           ,[web_status]
           ,[web_updated]
           ,[Includealias]
           ,[Includealias2]
           ,[Includealias3]
           ,[Includealias4]
           ,[PendingUpdated]
           ,[Time_In]
           ,[Last_Updated]
           ,[city]
           ,[state]
           ,[zipcode]
           ,[Investigator]
           ,[EmployerID]
           ,[InvestigatorAssigned]
           ,[PendingChanged]
           ,[TempInvestigator]
           ,[InUse]
           ,GETDATE()
           ,[EnteredBy]
           ,[EnteredDate]
           ,[IsCamReview]
           ,[Last_Worked]
           ,[ClientEmployerID]
           ,[AutoFaxStatus]
           ,0
           ,[IsHidden]
           ,[IsHistoryRecord]
           ,[EmploymentStatus]
           ,[IsOKtoContact]
           ,[OKtoContactInitial]
           ,[EmplVerifyID]
           ,[GetNextDate]
           ,[SubStatusID]
           ,[ClientAdjudicationStatus]
           ,[ClientRefID]
           ,[IsIntl]
           ,[DateOrdered]
           ,[OrderId]
           ,[Email]
           ,[AdverseRFL]
           ,[InUse_TimeStamp]
  FROM [dbo].[Empl] 
  WHERE Apno IN (@Apno)

-- Insert into Educat

INSERT INTO [dbo].[Educat]
           ([APNO]
           ,[School]
           ,[SectStat]
           ,[Worksheet]
           ,[State]
           ,[Phone]
           ,[Degree_A]
           ,[Studies_A]
           ,[From_A]
           ,[To_A]
           ,[Name]
           ,[Degree_V]
           ,[Studies_V]
           ,[From_V]
           ,[To_V]
           ,[Contact_Name]
           ,[Contact_Title]
           ,[Contact_Date]
           ,[Investigator]
           ,[Priv_Notes]
           ,[Pub_Notes]
           ,[web_status]
           ,[includealias]
           ,[includealias2]
           ,[includealias3]
           ,[includealias4]
           ,[pendingupdated]
           ,[web_updated]
           ,[Time_In]
           ,[Last_Updated]
           ,[city]
           ,[zipcode]
           ,[CampusName]
           ,[InUse]
           ,[CreatedDate]
           ,[ToPending]
           ,[FromPending]
           ,[Completed]
           ,[Last_Worked]
           ,[SchoolID]
           ,[IsCAMReview]
           ,[IsOnReport]
           ,[IsHidden]
           ,[IsHistoryRecord]
           ,[HasGraduated]
           ,[HighestCompleted]
           ,[EducatVerifyID]
           ,[GetNextDate]
           ,[SubStatusID]
           ,[ClientAdjudicationStatus]
           ,[ClientRefID]
           ,[IsIntl]
           ,[DateOrdered]
           ,[OrderId]
           ,[InUse_TimeStamp])
(
     SELECT
            @NewApno
           ,[School]
           ,'0'
           ,[Worksheet]
           ,[State]
           ,[Phone]
           ,[Degree_A]
           ,[Studies_A]
           ,[From_A]
           ,[To_A]
           ,[Name]
           ,[Degree_V]
           ,[Studies_V]
           ,[From_V]
           ,[To_V]
           ,[Contact_Name]
           ,[Contact_Title]
           ,[Contact_Date]
           ,[Investigator]
           ,[Priv_Notes]
           ,[Pub_Notes]
           ,[web_status]
           ,[includealias]
           ,[includealias2]
           ,[includealias3]
           ,[includealias4]
           ,[pendingupdated]
           ,[web_updated]
           ,[Time_In]
           ,[Last_Updated]
           ,[city]
           ,[zipcode]
           ,[CampusName]
           ,[InUse]
           ,GETDATE()
           ,[ToPending]
           ,[FromPending]
           ,[Completed]
           ,[Last_Worked]
           ,[SchoolID]
           ,[IsCAMReview]
           ,0
           ,[IsHidden]
           ,[IsHistoryRecord]
           ,[HasGraduated]
           ,[HighestCompleted]
           ,[EducatVerifyID]
           ,[GetNextDate]
           ,[SubStatusID]
           ,[ClientAdjudicationStatus]
           ,[ClientRefID]
           ,[IsIntl]
           ,[DateOrdered]
           ,[OrderId]
           ,[InUse_TimeStamp]
  FROM [dbo].[Educat] 
  WHERE APNO IN (@Apno))


  INSERT INTO [dbo].[PersRef]
           ([APNO]
           ,[SectStat]
           ,[Worksheet]
           ,[Name]
           ,[Phone]
           ,[Rel_V]
           ,[Years_V]
           ,[Priv_Notes]
           ,[Pub_Notes]
           ,[Last_Updated]
           ,[Investigator]
           ,[Emplid]
           ,[PendingUpdated]
           ,[Web_Status]
           ,[web_updated]
           ,[time_in]
           ,[InUse]
           ,[CreatedDate]
           ,[Last_Worked]
           ,[IsCAMReview]
           ,[IsOnReport]
           ,[IsHidden]
           ,[IsHistoryRecord]
           ,[ClientAdjudicationStatus]
           ,[Email]
           ,[JobTitle]
           ,[InUse_TimeStamp])
	(
     SELECT
            @NewApno
           ,'0'
           ,[Worksheet]
           ,[Name]
           ,[Phone]
           ,[Rel_V]
           ,[Years_V]
           ,[Priv_Notes]
           ,[Pub_Notes]
           ,[Last_Updated]
           ,[Investigator]
           ,[Emplid]
           ,[PendingUpdated]
           ,[Web_Status]
           ,[web_updated]
           ,[time_in]
           ,[InUse]
           ,CURRENT_TIMESTAMP
           ,[Last_Worked]
           ,[IsCAMReview]
           ,[IsOnReport]
           ,[IsHidden]
           ,[IsHistoryRecord]
           ,[ClientAdjudicationStatus]
           ,[Email]
           ,[JobTitle]
           ,[InUse_TimeStamp]
	FROM [dbo].[PersRef] 
	WHERE APNO IN (@Apno))

INSERT INTO dbo.ProfLic
(
    --ProfLicID - column value is auto-generated
    Apno,
    SectStat,
    Worksheet,
    Lic_Type,
    Lic_No,
    [Year],
    Expire,
    [State],
    Status,
    Priv_Notes,
    Pub_Notes,
    Web_status,
    includealias,
    includealias2,
    includealias3,
    includealias4,
    pendingupdated,
    web_updated,
    time_in,
    Organization,
    Contact_Name,
    Contact_Title,
    Contact_Date,
    Investigator,
    Last_Updated,
    InUse,
    CreatedDate,
    Status_A,
    ToPending,
    FromPending,
    Last_Worked,
    IsCAMReview,
    IsOnReport,
    IsHidden,
    IsHistoryRecord,
    ClientAdjudicationStatus,
    ClientRefID,
    Lic_Type_V,
    Lic_No_V,
    State_V,
    Expire_V,
    Year_V,
    GenerateCertificate,
    CertificateAvailabilityStatus,
    DisclosedPastAction,
    InUse_TimeStamp,
    NameOnLicense_V,
    Speciality_V,
    LifeTime_V,
    MultiState_V,
    BoardActions_V,
    ContactMethod_V,
    LicenseTypeID
)
SELECT @NewApno,
    '0',
    Worksheet,
    Lic_Type,
    Lic_No,
    [Year],
    Expire,
    [State],
    Status,
    Priv_Notes,
    Pub_Notes,
    Web_status,
    includealias,
    includealias2,
    includealias3,
    includealias4,
    pendingupdated,
    web_updated,
    time_in,
    Organization,
    Contact_Name,
    Contact_Title,
    Contact_Date,
    Investigator,
    Last_Updated,
    InUse,
    CURRENT_TIMESTAMP,
    Status_A,
    ToPending,
    FromPending,
    Last_Worked,
    IsCAMReview,
    0,
    IsHidden,
    IsHistoryRecord,
    ClientAdjudicationStatus,
    ClientRefID,
    Lic_Type_V,
    Lic_No_V,
    State_V,
    Expire_V,
    Year_V,
    GenerateCertificate,
    CertificateAvailabilityStatus,
    DisclosedPastAction,
    InUse_TimeStamp,
    NameOnLicense_V,
    Speciality_V,
    LifeTime_V,
    MultiState_V,
    BoardActions_V,
    ContactMethod_V,
    LicenseTypeID FROM dbo.ProfLic pl WHERE APNO IN (@APNO)

  
INSERT INTO [dbo].[ApplAdditionalData]
           ([CLNO]
           ,[APNO]
           ,[SSN]
           ,[Crim_SelfDisclosed]
           ,[Empl_CanContactPresentEmployer]
           ,[DataSource]
           ,[DateCreated]
           ,[SalaryRange]
           ,[StateEmploymentOccur]
           ,[DateUpdated])
		   (SELECT coalesce(@clno, [CLNO]), @NewApno, SSN, Crim_SelfDisclosed, Empl_CanContactPresentEmployer, DataSource, DateCreated, SalaryRange, StateEmploymentOccur, DateUpdated
			FROM dbo.ApplAdditionalData
			WHERE SSN IN (SELECT SSN FROM dbo.Appl WITH(NOLOCK) WHERE APNO IN (@Apno)) or APNO = @Apno)

INSERT INTO [dbo].[ApplicantCrim]
           ([APNO]
           ,[City]
           ,[State]
           ,[Country]
           ,[CrimDate]
           ,[Offense]
           ,[Source]
           ,[SSN]
           ,[CLNO])
		   (SELECT @NewApno, City, State, Country, CrimDate, Offense, Source, SSN, coalesce(@clno, [CLNO])
			FROM dbo.ApplicantCrim 
			WHERE SSN IN (SELECT SSN FROM dbo.Appl WITH(NOLOCK) WHERE APNO IN (@Apno)) or APNO = @Apno)

--SELECT * FROM [ala-devtest-01].[PreCheck].[dbo].Appl WHERE APNO = @NewApno
--SELECT * FROM dbo.Empl WHERE APNO = @Apno
--SELECT * FROM dbo.Educat WHERE APNO = @Apno

INSERT INTO [dbo].[DL]
           ([APNO]
           ,[Ordered]
           ,[SectStat]
           ,[Report]
           ,[Web_status]
           ,[Time_in]
           ,[Last_Updated]
           ,[InUse]
           ,[CreatedDate]
           ,[IsHidden]
           ,[IsCAMReview]
           ,[ClientAdjudicationStatus]
           ,[Notes]
           ,[IsReleaseNeeded]
           ,[AttemptCounter]
           ,[DateOrdered]
           ,[MVRLoggingId])
    (SELECT @NewApno,
			[Ordered]
           ,[SectStat]
           ,[Report]
           ,[Web_status]
           ,[Time_in]
           ,[Last_Updated]
           ,[InUse]
           ,CURRENT_TIMESTAMP
           ,[IsHidden]
           ,[IsCAMReview]
           ,[ClientAdjudicationStatus]
           ,[Notes]
           ,[IsReleaseNeeded]
           ,[AttemptCounter]
           ,[DateOrdered]
           ,[MVRLoggingId]
	 FROM [dbo].[DL] 
	WHERE APNO IN (@Apno))

END

IF (@NewApno IS NOT NULL)
BEGIN
	SELECT * FROM [dbo].Appl WHERE APNO = @NewApno;
END
ELSE
BEGIN
		RAISERROR ('Did not create a Apno in Testing. Please select a different Apno!!',16,1);
		RETURN
END
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION;
	throw;
END CATCH

RAISERROR(N'Creation completed.', 0, 1) WITH NOWAIT
-- Do Not Forget to change the following line to a commit, if the script works correctly in your tests ..
Commit Transaction