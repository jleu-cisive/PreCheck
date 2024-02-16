
/****** Object:  StoredProcedure [STG].[usp_process_Applicant_CT]    Script Date: 4/21/2016 6:57:39 PM ******/
CREATE PROCEDURE [STG].[usp_process_Applicant_CT] 
-- =============================================
-- Author:		Balaji Sankar
-- Create date: 03/27/2016
-- Description:	Process Empl Change tracking table
--Modified Date: 07/04/16
--Modified By: schapyala to add additional fields.
--Modified Date: 1/28/2019
--Modified By: Humera Ahmed - updated PrivNotes and PublicNotes field logic
--Deployed/Executed By: Gaurav Bangia
--Modified By: AmyLiu on 06/02/2022 for HDT49951 Process Levels Not Attaching to Background Reports for HCA
-- Modified by: Gaurav Bangia 12/7/2022 for HCA-PR05 : Adding private notes conditionally for HCA GHR orders
-- Modified by: Dongmei He 10/13/2023 for ME 53422 - Remove Character Limitation in Name/Alias Fields to be Unlimited
-- EXEC [STG].[usp_process_Applicant_CT]

-- =============================================
AS
BEGIN
	SET NOCOUNT ON;
	UPDATE A SET 
	--	A.[APNO]	= S.[APNO]	
	A.[EnteredBy]	= S.[EnteredBy]	
	,A.[Last]	= CONVERT(VARCHAR(50),S.[Last])	
	,A.[First]	= CONVERT(VARCHAR(50),S.[First])	
	,A.[Middle]	= CONVERT(VARCHAR(50),S.[Middle])	
	--,A.[Alias]	= CONVERT(VARCHAR(30),S.[Alias])
	--,A.[Alias2]	= CONVERT(VARCHAR(30),S.[Alias2])	
	--,A.[Alias3]	= CONVERT(VARCHAR(30),S.[Alias3])	
	,A.[SSN]	= CONVERT(VARCHAR(11),S.[SSN])	
	,A.[DOB]	= S.[DOB]	
	,A.[DL_State]	= CONVERT(VARCHAR(2),S.[DL_State])	
	,A.[DL_Number]	= CONVERT(VARCHAR(20),S.[DL_Number])
	,A.Addr_Street = 	S.[Addr_Street]
	,A.[City]	= CONVERT(VARCHAR(50),S.[City])	
	,A.[State]	= CONVERT(VARCHAR(2),S.[State])	
	,A.[Zip]	= CONVERT(VARCHAR(5),S.[Zip])	
	,A.[Last_Updated]	= S.[Last_Updated]	
	,A.[Phone]	= CONVERT(VARCHAR(50),S.[Phone])	
	--,A.[CreatedDate]	= S.[CreatedDate]	
	,A.[I94]	= CONVERT(VARCHAR(50),S.[I94])
	,A.[Email]	= CONVERT(VARCHAR(100),S.[Email])	
	,A.[CellPhone]	= CONVERT(VARCHAR(20),S.[CellPhone])	
	,A.[OtherPhone]	= CONVERT(VARCHAR(20),S.[OtherPhone])
	---- Schapyala modified on 10/06/2023 for preventing aliases being oveverwritten to null
	,A.Alias1_Generation = CONVERT(VARCHAR(3),s.[Alias1_Generation])
	,A.Alias1_Last = CONVERT(VARCHAR(50),isnull(s.Alias1_Last,A.Alias1_Last))
	,A.Alias1_First = CONVERT(VARCHAR(50),isnull(s.Alias1_First,A.Alias1_First))
	,A.Alias1_Middle = CONVERT(VARCHAR(50),isnull(s.Alias1_Middle,A.Alias1_Middle))
	,A.Alias2_Generation = CONVERT(VARCHAR(3),s.[Alias2_Generation])
	,A.Alias2_Last = CONVERT(VARCHAR(50),isnull(s.Alias2_Last,A.Alias2_Last))
	,A.Alias2_First = CONVERT(VARCHAR(50),isnull(s.Alias2_First,A.Alias2_First))
	,A.Alias2_Middle = CONVERT(VARCHAR(50),isnull(s.Alias2_Middle,A.Alias2_Middle))
	,A.Alias3_Generation = CONVERT(VARCHAR(3),s.[Alias3_Generation])
	,A.Alias3_Last = CONVERT(VARCHAR(50),isnull(s.Alias3_Last,A.Alias3_Last))
	,A.Alias3_First = CONVERT(VARCHAR(50),isnull(s.Alias3_First,A.Alias3_First))
	,A.Alias3_Middle = CONVERT(VARCHAR(50),isnull(s.Alias3_Middle,A.Alias3_Middle))
	,A.Alias4_Generation = CONVERT(VARCHAR(3),s.[Alias4_Generation])
	,A.Alias4_Last = CONVERT(VARCHAR(50),isnull(s.Alias4_Last,A.Alias4_Last))
	,A.Alias4_First = CONVERT(VARCHAR(50),isnull(s.Alias4_First,A.Alias4_First))
	,A.Alias4_Middle = CONVERT(VARCHAR(50),isnull(s.Alias4_Middle,A.Alias4_Middle))
	,A.NeedsReview = CASE WHEN ISNULL(LTRIM(RTRIM(A.NeedsReview)),'')='' THEN 'C1' ELSE A.NeedsReview END
	--schapyala 09/08/16 - Added the below temprarily - need TO be fixed AT the package level
	,A.Pos_Sought = CONVERT(VARCHAR(100),OD.JobTitle)
	,A.Priv_Notes = CASE 
						WHEN (A.Priv_Notes LIKE '%Job State:%' OR A.Priv_Notes LIKE '%; Client:%') THEN A.Priv_Notes 
						ELSE CONCAT(ISNULL(A.Priv_Notes,'') + ';', 
							'Job State: ', ISNULL(OD.jobstate,''), 
							'; Salary Range: ', OD.JobSalaryRange, 
							CASE WHEN ISNULL(IR.CLNO,0)=15163 THEN '; Client: HCA-GHR ' ELSE ';' END
						)
					 END
	,A.Pub_Notes =  CASE 
						WHEN (A.Pub_Notes LIKE '%Ordering Instructions:%') THEN A.Pub_Notes 
						ELSE CONCAT('Ordering Instructions: ' + OS.Instruction +';' + CHAR(9) + CHAR(13), A.Pub_Notes)
						END
	,A.DeptCode =  COALESCE(IR.TransformedRequest.value('(//DeptCode)[1]','VARCHAR(20)'),IR.TransformedRequest.value('(//CostCenter)[1]','VARCHAR(20)'))    --added by schapyala on 02/08/2018 as temp fix
	--schapyala 09/08/16 - Added the below temprarily - need TO be fixed AT the package level
	FROM [dbo].[Appl] A  INNER JOIN [STG].[Appl_CT] S
	ON A.[APNO] = S.[APNO]
	--schapyala 09/08/16 - Added the below temprarily - need TO be fixed AT the package level
	LEFT OUTER JOIN  Enterprise..[Order]  O WITH(NOLOCK) ON S.APNO = O.OrderNumber
	LEFT OUTER JOIN Enterprise..OrderJobDetail OD WITH(NOLOCK) ON O.OrderId = OD.OrderId
	LEFT OUTER JOIN  Enterprise..OrderService OS WITH(NOLOCK) ON O.OrderId = OS.OrderId AND os.BusinessServiceId=1
	LEFT OUTER JOIN dbo.Integration_OrderMgmt_Request IR WITH(NOLOCK) ON IR.RequestID = O.IntegrationRequestId --added by schapyala on 02/08/2018 as temp fix
	--schapyala 09/08/16 - Added the below temprarily - need TO be fixed AT the package level
	--AND S.Operation = 'U'


	
	/*
	INSERT INTO [dbo].[Appl] 
		( [EnteredBy]	
		,[Last]	
		,[First]	
		,[Middle]	
		,[Alias]	
		,[Alias2]	
		,[Alias3]	
		,[SSN]	
		,[DOB]	
		,[DL_State]	
		,[DL_Number]	
		,[City]	
		,[State]	
		,[Zip]	
		,[Last_Updated]	
		,[Phone]	
		,[CreatedDate]	
		,[I94]	
		,[Email]	
		,[CellPhone]	
		,[OtherPhone]	)
	SELECT 
		 S.[EnteredBy]	
		,S.[Last]	
		,S.[First]	
		,S.[Middle]	
		,S.[Alias]	
		,S.[Alias2]	
		,S.[Alias3]	
		,S.[SSN]	
		,S.[DOB]	
		,S.[DL_State]	
		,S.[DL_Number]	
		,S.[City]	
		,S.[State]	
		,S.[Zip]	
		,S.[Last_Updated]	
		,S.[Phone]	
		,S.[CreatedDate]	
		,S.[I94]	
		,S.[Email]	
		,S.[CellPhone]	
		,S.[OtherPhone]	
	FROM [dbo].[Appl] A RIGHT OUTER JOIN [STG].[Appl_CT] S
	ON A.[APNO] = S.[APNO] AND A.[APNO] IS NULL
	AND S.Operation = 'I'
	*/



	DELETE A
	FROM [dbo].ApplAddress A
	INNER JOIN [STG].[ApplicantResidence_CT] AR   ON A.[APNO] = AR.ApplicantNumber  AND ISNULL(A.Address,'') = ISNULL(AR.Address,'') AND ISNULL(A.Zip,0) = ISNULL(AR.Zip,0)--AND AR.IsCurrent = 1


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
			FROM [STG].[Applicant_CT] A
			INNER JOIN [STG].[ApplicantResidence_CT] AR   ON A.[ApplicantId] = AR.[ApplicantId]  AND A.Operation = 'U' --AND AR.IsCurrent = 0
			
			
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
			   ,null [SalaryRange]
			   ,null [StateEmploymentOccur]
	FROM [STG].[Applicant_CT] A  INNER JOIN  [dbo].[Appl] S
	ON A.[ApplicantNumber] = S.[APNO]
	WHERE A.Operation = 'U'

	UPDATE A
		SET A.[Crim_SelfDisclosed] = isnull(S.[HasSelfDisclosedCriminal],0),
		    A.SalaryRange = null,
			A.StateEmploymentOccur = null,
			A.SSN = S.SocialNumber
	FROM [dbo].[ApplAdditionalData] A inner join [STG].[Applicant_CT] S on A.APNO = S.ApplicantNumber
	WHERE S.Operation = 'U'

	
	-- Update the integration table to send a status update to the integration partner with the newly generated APNO.
	Update IR
	Set		APNO = A.ApplicantNumber,
			Process_Callback_Acknowledge = 1,
			Callback_Acknowledge_Date = null,
			refUserActionID = 1 ,
			IR.FacilityCLNO = A.FacilityId
	From dbo.Integration_OrderMgmt_Request IR 
	inner Join [STG].[Applicant_CT]  A on IR.RequestID = A.IntegrationRequestId
	join Enterprise.Staging.OrderStage os on os.IntegrationRequestId=A.IntegrationRequestId
	join Enterprise.Staging.ApplicantStage app on os.StagingOrderId=app.StagingOrderId
	left join Enterprise.staging.ReviewRequest rr on rr.StagingApplicantId=app.StagingApplicantId
	Where
	APNO is NULL AND a.ApplicantNumber IS NOT NULL and 
	(os.ReviewModeId<>2 and rr.ClosingReviewStatusId<>3) -- reviewMode 2 is conditional and  ClosingReviewStatusId is approval

	--AND refUserActionID is null --commented by schapyala on 09/05/2019 to accomodate newer refuseractions

--Temporary fix till the above query is fixed to handle the update properly - schapyala - 07/19/2016 - remove the below query when tested and confirmed that above query is good
-- Update the integration table to send a status update to the integration partner with the newly generated APNO.
	Update IR
	Set		APNO = A.OrderNumber,
			Process_Callback_Acknowledge = 1,
			Callback_Acknowledge_Date = null,
			refUserActionID = 1 ,
			IR.FacilityCLNO = A.FacilityId
from	 dbo.Integration_OrderMgmt_Request IR inner Join Enterprise.staging.orderstage  A on IR.RequestID = A.IntegrationRequestId
	Where APNO is NULL AND a.OrderNumber IS NOT NULL
	--AND refUserActionID is null --commented by schapyala on 09/05/2019 to accomodate newer refuseractions


END

