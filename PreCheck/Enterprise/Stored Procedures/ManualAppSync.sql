CREATE PROCEDURE [Enterprise].[ManualAppSync] (@Apno int,@AddressOnly bit = 0 ) AS
BEGIN
	SET NOCOUNT ON;
IF @addressOnly = 1
  BEGIN
    UPDATE A SET 
	    --	A.[APNO]	= S.[APNO]	
	
	    A.Addr_Street = 	AR.Address
	    ,A.[City]	= CONVERT(VARCHAR(50),AR.[City])	
	    ,A.[State]	= CONVERT(VARCHAR(2),AR.[State])	
	    ,A.[Zip]	= CONVERT(VARCHAR(5),AR.[Zip])	
	    --,A.[Last_Updated]	= S.[Last_Updated]	
	
	    FROM [dbo].[Appl] A INNER JOIN Enterprise.dbo.Applicant S  
	    ON A.[APNO] = S.ApplicantNumber
    LEFT JOIN Enterprise..ApplicantResidence 	    AR   ON S.[ApplicantId] = AR.[ApplicantId]  AND AR.IsCurrent = 1
    WHERE apno = @Apno

    INSERT INTO dbo.ApplAddress
					    (	[APNO]
							 ,[Address]
							 ,[City]
							 ,[State]
							 ,[Zip]
							 ,[Country]
							 ,[DateStart]
							 ,[DateEnd]
							 ,[Source]
							 ,[CLNO]
							 ,[SSN])
	    SELECT A.ApplicantNumber AS [APNO]
			 ,AR.[Address]
			 ,AR.[City]
			 ,AR.[State]
			 ,AR.[Zip]
			 ,AR.[Country]
			 ,AR.DateFrom AS [DateStart]
			 ,AR.DateTo AS [DateEnd]
			 ,'Enterprise' AS [Source]
			 ,NULL AS [CLNO]
			 ,A.SocialNumber AS [SSN]
	   FROM Enterprise.dbo.Applicant  A
	   INNER JOIN Enterprise..ApplicantResidence AR   ON A.[ApplicantId] = AR.[ApplicantId]  
	   WHERE A.ApplicantNumber	= @Apno
    END
ELSE
    BEGIN
	UPDATE A SET 
	--	A.[APNO]	= S.[APNO]	
	A.[EnteredBy]	= S.CreateBy	 	
	,A.[Last]	= CONVERT(VARCHAR(20),S.[LastName])	
	,A.[First]	= CONVERT(VARCHAR(20),S.[FirstName])	
	,A.[Middle]	= CONVERT(VARCHAR(20),S.[MiddleName])	
	--,A.[Alias]	= CONVERT(VARCHAR(30),S.[Alias])
	--,A.[Alias2]	= CONVERT(VARCHAR(30),S.[Alias2])	
	--,A.[Alias3]	= CONVERT(VARCHAR(30),S.[Alias3])	
	,A.[SSN]	= CONVERT(VARCHAR(11),S.SocialNumber )	
	,A.[DOB]	= S.DateOfBirth  	
	,A.[DL_State]	= CONVERT(VARCHAR(2),S.DriverLicenseState   )	
	,A.[DL_Number]	= CONVERT(VARCHAR(20),S.DriverLicenseNumber )
	,A.Addr_Street = 	AR.Address
	,A.[City]	= CONVERT(VARCHAR(50),AR.[City])	
	,A.[State]	= CONVERT(VARCHAR(2),AR.[State])	
	,A.[Zip]	= CONVERT(VARCHAR(5),AR.[Zip])	
	--,A.[Last_Updated]	= S.[Last_Updated]	
	,A.[Phone]	= CONVERT(VARCHAR(50),S.[Phone])	
	--,A.[CreatedDate]	= S.[CreatedDate]	
	,A.[I94]	= CONVERT(VARCHAR(50),S.[I94])
	,A.[Email]	= CONVERT(VARCHAR(100),S.[Email])	
	,A.[CellPhone]	= CONVERT(VARCHAR(20),S.[CellPhone])	
	,A.[OtherPhone]	= CONVERT(VARCHAR(20),S.[OtherPhone])
	--,A.Alias1_Generation = AA1.First
	,A.Alias1_Last = CONVERT(VARCHAR(20),AA1.Last)
	,A.Alias1_First = CONVERT(VARCHAR(20),AA1.First)
	,A.Alias1_Middle = CONVERT(VARCHAR(20),AA1.Middle)
	--,A.Alias2_Generation = CONVERT(VARCHAR(3),s.[Alias2_Generation])
	,A.Alias2_Last = CONVERT(VARCHAR(20),AA2.Last)
	,A.Alias2_First = CONVERT(VARCHAR(20),AA2.First)
	,A.Alias2_Middle = CONVERT(VARCHAR(20),AA2.Middle)
	--,A.Alias3_Generation = s.[Alias3_Generation]
	,A.Alias3_Last = CONVERT(VARCHAR(20),AA3.Last)
	,A.Alias3_First = CONVERT(VARCHAR(20),AA3.First)
	,A.Alias3_Middle = CONVERT(VARCHAR(20),AA3.Middle)
	--,A.Alias4_Generation = s.[Alias4_Generation]
	,A.Alias4_Last = CONVERT(VARCHAR(20),AA4.Last)
	,A.Alias4_First = CONVERT(VARCHAR(20),AA4.First)
	,A.Alias4_Middle = CONVERT(VARCHAR(20),AA4.Middle)
	,A.NeedsReview = CASE WHEN ISNULL(ltrim(rtrim(A.NeedsReview)),'')='' THEN 'C1' ELSE A.NeedsReview END
	--schapyala 09/08/16 - Added the below temprarily - need TO be fixed AT the package level
	,A.Pos_Sought = CONVERT(VARCHAR(100),OD.JobTitle)
	,A.Priv_Notes = A.Priv_Notes + '; Job State: ' + ISNULL(OD.jobstate,'') + '; Salary Range: ' + ISNULL(OD.JobSalaryRange,'')
	,A.Pub_Notes = ISNULL(A.Pub_Notes,'') + CASE WHEN ISNULL(OS.Instruction,'') = '' THEN '' ELSE 'Ordering Instructions: ' + OS.Instruction +';; ' +  char(9) + char(13) +  char(9) + char(13) END --Added by schapyala on 06/20/2017
	--schapyala 09/08/16 - Added the below temprarily - need TO be fixed AT the package level
	--SELECT * FROM appl WHERE apno =3960612
	--SELECT *
	FROM [dbo].[Appl] A INNER JOIN Enterprise.dbo.Applicant S  
	ON A.[APNO] = S.ApplicantNumber
	LEFT JOIN enterprise.[vw_ApplAlias_tmp]     AA1 ON S.[ApplicantId] = AA1.[ApplicantId] AND AA1.RowNum = 1
LEFT JOIN enterprise.[vw_ApplAlias_tmp] AA2 ON S.[ApplicantId] = AA2.[ApplicantId] AND AA2.RowNum = 2
LEFT JOIN enterprise.[vw_ApplAlias_tmp] AA3 ON S.[ApplicantId] = AA3.[ApplicantId] AND AA3.RowNum = 3
LEFT JOIN enterprise.[vw_ApplAlias_tmp] AA4 ON S.[ApplicantId] = AA4.[ApplicantId] AND AA4.RowNum = 4
LEFT JOIN Enterprise..ApplicantResidence 	    AR   ON S.[ApplicantId] = AR.[ApplicantId]  AND AR.IsCurrent = 1
	
	--schapyala 09/08/16 - Added the below temprarily - need TO be fixed AT the package level
	LEFT JOIN  Enterprise..[Order]  O ON S.ApplicantNumber	 = O.OrderNumber
	INNER JOIN Enterprise..OrderJobDetail OD ON O.OrderId = OD.OrderId
	LEFT JOIN  Enterprise..OrderService OS ON O.OrderId = OS.OrderId
	--schapyala 09/08/16 - Added the below temprarily - need TO be fixed AT the package level
	--AND S.Operation = 'U'
	WHERE apno = @APNO


	
	--DELETE A
	--FROM [dbo].ApplAddress A
	--INNER JOIN [STG].[ApplicantResidence_CT] AR   ON A.[APNO] = AR.ApplicantNumber  AND AR.IsCurrent = 1

	INSERT INTO dbo.ApplAddress
					(		[APNO]
						  ,[Address]
						  ,[City]
						  ,[State]
						  ,[Zip]
						  ,[Country]
						  ,[DateStart]
						  ,[DateEnd]
						  ,[Source]
						  ,[CLNO]
						  ,[SSN])
	SELECT A.ApplicantNumber AS [APNO]
		  ,AR.[Address]
		  ,AR.[City]
		  ,AR.[State]
		  ,AR.[Zip]
		  ,AR.[Country]
		  ,AR.DateFrom AS [DateStart]
		  ,AR.DateTo AS [DateEnd]
		  ,'Enterprise' AS [Source]
		  ,NULL AS [CLNO]
		  ,A.SocialNumber AS [SSN]
			FROM Enterprise.dbo.Applicant  A
			INNER JOIN Enterprise..ApplicantResidence AR   ON A.[ApplicantId] = AR.[ApplicantId]  
			WHERE A.ApplicantNumber	= @APNO --AND AR.IsCurrent = 0



	INSERT INTO [dbo].[ApplAdditionalData]
			   ([CLNO]
			   ,[APNO]
			   ,[SSN]
			   ,[Crim_SelfDisclosed]
			   ,[Empl_CanContactPresentEmployer]
			   ,[DataSource]
			   ,[DateCreated]
			   ,[SalaryRange]
			   ,[StateEmploymentOccur])
	SELECT		S.CLNO [CLNO]
			   ,A.[ApplicantNumber]
			   ,A.[SocialNumber]
			   ,isnull(A.[HasSelfDisclosedCriminal],0)
			   ,null [Empl_CanContactPresentEmployer]
			   ,'Enterprise' [DataSource]
			   ,A.[CreateDate]
			   ,jobSalaryRange [SalaryRange]
			   ,JobState [StateEmploymentOccur]
	FROM Enterprise.dbo.Applicant  A  INNER JOIN  [dbo].[Appl] S
	ON A.[ApplicantNumber] = S.[APNO]
	LEFT JOIN  Enterprise..[Order]  O ON A.ApplicantNumber	 = O.OrderNumber
	INNER JOIN Enterprise..OrderJobDetail OD ON O.OrderId = OD.OrderId
	WHERE APNO=@APNO

	UPDATE S
		SET s.[Crim_SelfDisclosed] = isnull(A.[HasSelfDisclosedCriminal],0),
		    s.SalaryRange = jobsalaryrange,
			S.StateEmploymentOccur = Jobstate,
			S.SSN = A.SocialNumber
	FROM [dbo].[ApplAdditionalData] S inner join Enterprise.dbo.Applicant  A  
	ON A.[ApplicantNumber] = S.[APNO]
	LEFT JOIN  Enterprise..[Order]  O ON A.ApplicantNumber	 = O.OrderNumber
	INNER JOIN Enterprise..OrderJobDetail OD ON O.OrderId = OD.OrderId
	WHERE APNO = @APNO

	-- Update the integration table to send a status update to the integration partner with the newly generated APNO.
	Update IR
	Set		APNO = A.ApplicantNumber,
			Process_Callback_Acknowledge = 1,
			Callback_Acknowledge_Date = null,
			refUserActionID = 1 ,
			IR.FacilityCLNO = A.FacilityId
	From dbo.Integration_OrderMgmt_Request IR inner Join [STG].[Applicant_CT]  A on IR.RequestID = A.IntegrationRequestId
	Where refUserActionID is null and APNO is NULL AND a.ApplicantNumber IS NOT null

--Temporary fix till the above query is fixed to handle the update properly - schapyala - 07/19/2016 - remove the below query when tested and confirmed that above query is good
-- Update the integration table to send a status update to the integration partner with the newly generated APNO.
	Update IR
	Set		APNO = A.OrderNumber,
			Process_Callback_Acknowledge = 1,
			Callback_Acknowledge_Date = null,
			refUserActionID = 1 ,
			IR.FacilityCLNO = A.FacilityId
from	 dbo.Integration_OrderMgmt_Request IR inner Join enterprise.staging.orderstage  A on IR.RequestID = A.IntegrationRequestId
	Where refUserActionID is null and APNO is NULL AND a.OrderNumber = @APNO
 END

END

