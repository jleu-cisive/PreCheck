/*
EXEC [Enterprise].[ManualAppSync_Deepak] (@Apno int,@AddressOnly bit = 0 )
*/
CREATE PROCEDURE [Enterprise].[ManualAppSync_Deepak] (@Apno int,@AddressOnly bit = 0 ) AS
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

		-- ApplAddress
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

		-- [ApplAlias]
		INSERT INTO [dbo].[ApplAlias] 
				([APNO]
				  ,[First]
				  ,[Middle]
				  ,[Last]
				  ,[CreatedDate]
				  ,[AddedBy])
			SELECT 
				 S.[APNO]
				  ,CONVERT(VARCHAR(50),S.[First])
				  ,CONVERT(VARCHAR(50),S.[Middle])
				  ,CONVERT(VARCHAR(50),S.[Last])
				  ,S.[CreatedDate]
				  ,CONVERT(VARCHAR(25),S.[AddedBy])
			FROM [dbo].[ApplAlias] A RIGHT OUTER JOIN [STG].[vw_ApplAlias_CT] S
			ON A.[APNO] = S.[APNO] 
			AND S.Operation = 'I'
			where A.[APNO] IS NULL   AND 
			S.RowNum > 4

		-- Empl
		INSERT INTO [dbo].[Empl] 
			( [Apno]
			,[Employer]
			,[Location]
			,[Supervisor]
			,[SupPhone]
			,Phone
			,[RFL]
			,[From_A]
			,[To_A]
			,[Position_A]
			,[Salary_A]
			,[Last_Updated]
			,[city]
			,[state]
			,[zipcode]
			,[CreatedDate]
			,[EnteredBy]
			,[IsOKtoContact]
			,DNC
			,IsIntl
			,Priv_Notes)
			SELECT 
				DISTINCT S.[Apno]
				,CONVERT(Varchar(30),S.[Employer]) AS [Employer]
				,S.[Location]
				,CONVERT(Varchar(25),S.[Supervisor]) AS [Supervisor]
				,CONVERT(Varchar(20),S.[SupPhone]) AS [SupPhone]
				,CONVERT(Varchar(20),S.[SupPhone]) AS Phone
				,CONVERT(Varchar(30),S.[RFL]) AS [RFL] 
				,CONVERT(Varchar(10),S.[From_A], 101) AS [From_A]
				,CONVERT(Varchar(10),S.[To_A], 101) AS [To_A]
				,CONVERT(Varchar(50),S.[Position_A]) AS [Position_A]
				,CONVERT(Varchar(15),S.[Salary_A]) AS [Salary_A]
				,ISNULL(S.[Last_Updated],CURRENT_TIMESTAMP) AS [Last_Updated]
				,CONVERT(Varchar(50),S.[city]) AS [city]
				,CONVERT(Varchar(2),S.[state]) AS [state]
				,CONVERT(Varchar(5),S.[zipcode]) AS [zipcode]
				,S.[CreatedDate]
				,S.[EnteredBy]
				,S.[IsOKtoContact]
				,ISNULL(CAST(S.DNC AS BIT),0)
				,S.IsIntl
				--Modified by Larry Ouch 11/14/2018
				,CONCAT(
					(SELECT IIF([Enterprise].[GetClientConfigFlag](A2.CLNO, 'VerifyPresentEmployer', 'true') = 1 AND S.IsPresentEmployer = 1, 
						'Always OK to contact present employer. The candidate was notified that the client requires verification of all present employment.' + CHAR(13), NULL)),
					(CASE WHEN S.IsIntl = 1 THEN 'This employment occurred outside of the United States.' + CHAR(13) ELSE NULL END) 
				) AS [Priv_Notes]
			FROM [dbo].[Empl] A RIGHT OUTER JOIN [STG].[Empl_CT] S
			ON A.APNO = S.APNO AND A.[Employer] = CONVERT(Varchar(30),S.[Employer])
			AND S.Operation = 'I'
			INNER JOIN dbo.Appl A2 ON A2.APNO = S.APNO	
			WHERE A.APNO IS NULL
			AND S.APNO IS NOT NULL

		-- Educat
		INSERT INTO [dbo].[Educat] 
				(-- [EducatID],
				[APNO]
				,[School]
				,[SectStat]
				,Worksheet
				,[State]
				,[Degree_A]
				,[Studies_A]
				,[From_A]
				,[To_A]
				,[Name]
				,[Last_Updated]
				,[city]
				,[CampusName]
				,[CreatedDate]
				,[HasGraduated]
				,[HighestCompleted]
				,IsIntl
				,Priv_Notes)
			SELECT DISTINCT 
				S.[APNO]
				,CONVERT(Varchar(50),S.[School]) AS School
				,0 AS [SectStat] -- S.[SectStat]
				,0 AS Worksheet  --S.Worksheet
				,CONVERT(varchar(2),S.[State]) AS [State]
				,CONVERT(Varchar(25),S.[Degree_A]) AS [Degree_A]
				,CONVERT(Varchar(25),S.[Studies_A]) AS [Studies_A]
				,CONVERT(VARCHAR(10),S.[From_A],101) AS [FROM_A]
				,CONVERT(VARCHAR(10),S.[To_A],101) AS [To_A]
				,CONVERT(VARCHAR(100),S.[Name]) AS [Name]
				,S.[Last_Updated]
				,CONVERT(varchar(50),S.[city]) AS City
				,CONVERT(Varchar(25),S.[CampusName]) AS [CampusName]
				,S.[CreatedDate]
				,S.[HasGraduated]
				,S.[HighestCompleted]
				,S.IsIntl
				--Modified by Larry Ouch 11/14/2018
				,(CASE WHEN S.IsIntl = 1 THEN 'This education was received outside of the United States.' ELSE NULL END) AS [Priv_Notes]
			FROM [dbo].[Educat] A RIGHT OUTER JOIN [STG].[Educat_CT] S
			ON ISNULL(A.[APNO],0) = S.[APNO] AND CONVERT(Varchar(50),S.[School])  = A.School AND A.[Degree_A] = CONVERT(Varchar(25),S.[Degree_A])  
			AND S.Operation = 'I'
			WHERE A.[EducatID] IS  NULL
			AND S.APNO IS NOT NULL

			-- [ApplicantCrim]
			INSERT INTO [dbo].[ApplicantCrim] 
			(--[ApplicantCrimID],
			[APNO]
			,[City]
			,[State]
			,[Country]
			,[CrimDate]
			,[Offense]
			,[Source]
			,[SSN]
			,[CLNO]
		--  ,[CreatedDate]
			)
			SELECT 
				S.[APNO]
			  ,S.[City]
			  ,S.[State]
			  ,S.[Country]
			  ,S.[CrimDate]
			  ,CONVERT(varchar(50),S.[Offense]) AS [Offense]
			  ,S.[Source]
			  ,S.[SSN]
			  ,S.[CLNO]
			 -- ,S.[CreateDate] AS [CreatedDate]
			FROM [dbo].[ApplicantCrim] A RIGHT OUTER JOIN [STG].[ApplicantCrim_CT] S
			ON A.[APNO] = S.[APNO] 
			AND S.Operation = 'I'
			WHERE A.[APNO] IS NULL

		-- [ProfLic]
		INSERT INTO [dbo].[ProfLic] 
				([Apno]  
				  ,[Lic_Type]
				  ,[Lic_No]
				  ,[Year]
				  ,[Expire]
				  ,[State] 
				  ,[Last_Updated]
				  ,[InUse]
				  ,[Priv_Notes]
				  ,[CreatedDate])
			SELECT 
			   S.Apno
			  ,S.[Lic_Type]
			  ,S.[Lic_No]
			  --modified by gauravadded conversion as data was being truncated earlier
			  ,CONVERT(VARCHAR(10),S.[Year],101)
			  ,S.[Expire]
			  ,CONVERT(varchar(8),S.[State])
			  ,S.[Last_Updated]
			  ,S.[InUse]
			  --Modified by Larry Ouch 11/14/2018
			  ,CONCAT(IIF(LEN(S.[State])> 2 , 'STATE : ' + S.[State] + CHAR(13), NULL) , (CASE WHEN S.IsValidLifeTime = 1 THEN 'This license does not expire.' ELSE NULL END))  AS [Priv_Notes]
			  ,S.[CreatedDate]
			FROM [dbo].[ProfLic] A RIGHT OUTER JOIN [STG].[ProfLic_CT] S
			ON A.[APNO] = S.[APNO] 	AND S.Operation = 'I'
			WHERE A.[APNO] IS NULL
			AND S.APNO IS NOT NULL

		-- [PersRef]
		INSERT INTO [dbo].[PersRef] 
				( [APNO]
				,SectStat
				,Worksheet
				,[Name]
				,[Phone]
				,[Last_Updated]
				,[CreatedDate]
				,[Email]
				,[JobTitle])
			SELECT 
				S.[APNO]
				,'0'
				,0
				,CONVERT(VARCHAR(25),S.[Name])
				,CONVERT(VARCHAR(20),S.[Phone])
				,S.[Last_Updated]
				,S.[CreatedDate]
				,CONVERT(VARCHAR(50),S.[Email])
				,CONVERT(VARCHAR(100),S.[JobTitle])
			FROM [dbo].[PersRef] A RIGHT OUTER JOIN [STG].[PersRef_CT] S
			ON A.[APNO] = S.[APNO] 
			AND S.Operation = 'I'
			WHERE A.[APNO] IS NULL

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

