









/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [STG].[Appl_CT]   
AS
SELECT  A.[ApplicantNumber] AS [APNO]
      , A.OrderStatus [ApStatus]
      , NULL [UserID]
      , NULL [Billed]
      , NULL [Investigator]
      ,A.[CreateBy] [EnteredBy]
      , NULL [EnteredVia]
      , NULL [ApDate]
      , NULL [CompDate]
      , NULL [CLNO]
      , NULL [Attn]
      ,A.[LastName] [Last]
      ,A.[FirstName] [First]
      ,A.[MiddleName] [Middle]
      ,NULL [Alias]
      ,NULL [Alias2]
      ,NULL [Alias3]
      , NULL [Alias4]
      ,A.[SocialNumber] [SSN]
      ,A.[DateOfBirth] [DOB]
      , NULL [Sex]
      ,A.[DriverLicenseState] [DL_State]
      ,A.[DriverLicenseNumber] [DL_Number]
      , NULL [Addr_Num]
      , NULL [Addr_Dir]
      , AR.[Address] [Addr_Street]
      , NULL [Addr_StType]
      , NULL [Addr_Apt]
      ,AR.[City] [City]
      ,AR.[State] [State]
      ,AR.[Zip] [Zip]
      , NULL [Pos_Sought]
      , NULL [Update_Billing]
      , NULL [Priv_Notes]
      , NULL [Pub_Notes]
      , NULL [PC_Time_Stamp]
      , NULL [Pc_Time_Out]
      , NULL [Special_instructions]
      , NULL [Reason]
      , NULL [ReopenDate]
      , NULL [OrigCompDate]
      , NULL [Generation]
      , AA1.[Last] [Alias1_Last]
      , AA1.[First] [Alias1_First]
      , AA1.[Middle] [Alias1_Middle]
      , NULL [Alias1_Generation]
      , AA2.[Last] [Alias2_Last]
      , AA2.[First] [Alias2_First]
      , AA2.[Middle] [Alias2_Middle]
      , NULL [Alias2_Generation]
      , AA3.[Last] [Alias3_Last]
      , AA3.[First] [Alias3_First]
      , AA3.[Middle] [Alias3_Middle]
      , NULL [Alias3_Generation]
      , AA4.[Last] [Alias4_Last]
      , AA4.[First] [Alias4_First]
      , AA4.[Middle] [Alias4_Middle]
      , NULL [Alias4_Generation]
      , NULL [PrecheckChallenge]
      , NULL [InUse]
      , NULL [ClientAPNO]
      , NULL [ClientApplicantNO]
      ,A.[ModifyDate] [Last_Updated]
      , NULL [DeptCode]
      , NULL [NeedsReview]
      , NULL [StartDate]
      , NULL [RecruiterID]
      ,A.[Phone] [Phone]
      , NULL [Rush]
      , NULL [IsAutoPrinted]
      , NULL [AutoPrintedDate]
      , NULL [IsAutoSent]
      , NULL [AutoSentDate]
      , NULL [PackageID]
      , NULL [Rel_Attached]
      ,A.[CreateDate] [CreatedDate]
      , NULL [ClientProgramID]
      ,ISNULL(A.[I94],A.ForeignIDNumber) [I94]
      , NULL [Recruiter_Email]
      , NULL [CAM]
      , NULL [SubStatusID]
      , NULL [GetNextDate]
      ,A.[Email] [Email]
      ,A.[CellPhone] [CellPhone]
      ,A.[OtherPhone] [OtherPhone]
      , NULL [IsDrugTestFileFound_bit]
      , NULL [IsDrugTestFileFound]
      , NULL [FreeReport]
      , NULL [ClientNotes]
      , NULL [InProgressReviewed]
      , NULL [LastModifiedDate]
      , NULL [LastModifiedBy]
	  ,A.IntegrationRequestId
	  ,A.FacilityID
	  ,A.Operation
 FROM [STG].[Applicant_CT] A
LEFT JOIN [STG].[vw_ApplAlias_CT] AA1 ON A.[ApplicantId] = AA1.[ApplicantId] AND AA1.RowNum = 1
LEFT JOIN [STG].[vw_ApplAlias_CT] AA2 ON A.[ApplicantId] = AA2.[ApplicantId] AND AA2.RowNum = 2
LEFT JOIN [STG].[vw_ApplAlias_CT] AA3 ON A.[ApplicantId] = AA3.[ApplicantId] AND AA3.RowNum = 3
LEFT JOIN [STG].[vw_ApplAlias_CT] AA4 ON A.[ApplicantId] = AA4.[ApplicantId] AND AA4.RowNum = 4
LEFT JOIN [STG].[ApplicantResidence_CT] AR   ON A.[ApplicantId] = AR.[ApplicantId]  AND AR.IsCurrent = 1


