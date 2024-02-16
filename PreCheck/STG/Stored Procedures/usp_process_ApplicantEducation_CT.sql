CREATE PROCEDURE [STG].[usp_process_ApplicantEducation_CT] 
-- =============================================
-- Author:		Balaji Sankar
-- Create date: 03/27/2016
-- Modified date: 11/14/2018
-- Modified by: Larry Ouch
-- Modification purpose: Stamp private notes if record is international
-- Description:	Process Educat Change tracking table
-- Modified by Humera Ahmed on 08/05/2021 for Task--#6120 CIC Education Graduation Information

-- Last Modify By: Gaurav Bangia
-- Last Modify Date: 12/11/2022 (PROD)
-- Last Modify Reason: Project HCA PR05- new Educational data fields 
-- =============================================
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE A SET 
	A.[School] = S.[School]
	,A.[State]   = CONVERT(varchar(2),S.[State])   
	,A.[Degree_A] = CONVERT(Varchar(25),S.[Degree_A])  
	,A.[Studies_A] = S.[Studies_A]
	,A.[From_A] = CONVERT(VARCHAR(10),S.[From_A],101)
	,A.[To_A] =  CONVERT(VARCHAR(10),S.[To_A],101)
	,A.[Name] = CONVERT(VARCHAR(100),S.[Name])
	,A.[Last_Updated] = S.[Last_Updated]
	,A.[city] = CONVERT(varchar(50),S.[city])  
	,A.[CampusName] = CONVERT(Varchar(25),S.[CampusName]) 
	,A.[CreatedDate] = S.[CreatedDate]
	,A.[HasGraduated] = S.[HasGraduated]
	,A.[HighestCompleted] = S.[HighestCompleted]
	,A.[GraduationYear] = S.[GraduationYear]
	FROM [dbo].[Educat] A 
	INNER JOIN [STG].[Educat_CT] S ON A.[APNO] = S.[APNO] AND S.[School] = A.School AND A.[Studies_A] = S.[Studies_A]
	AND ISNULL(A.[From_A],'01/01/1900') = CONVERT(VARCHAR(10),S.[From_A],101)
	AND S.Operation = 'U'

	DECLARE @apnos TABLE(apno int)
	DECLARE @APNOS_csv VARCHAR(MAX)
	BEGIN TRY
		INSERT INTO @apnos (apno)
		SELECT DISTINCT APNO FROM [STG].[Educat_CT]	
		SELECT @APNOS_csv = COALESCE(@APNOS_csv + ',', '') + CONVERT(VARCHAR(15),apno) FROM @apnos
    END TRY
    BEGIN CATCH
	END CATCH
	--/*
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
		,Priv_Notes
		,[GraduationYear]
		,EducationLevelCode
		,EducationLevel
		,SchoolCode
		,StudiesCode
		)
	SELECT DISTINCT 
		S.[APNO]
		,S.[School] AS School
		,0 AS [SectStat] -- S.[SectStat]
		,0 AS Worksheet  --S.Worksheet
		,CONVERT(varchar(2),S.[State]) AS [State]
		,CONVERT(Varchar(25),S.[Degree_A]) AS [Degree_A]
		,S.[Studies_A] AS [Studies_A]
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
		,(CASE WHEN S.IsIntl = 1 THEN 'This education was received outside of the United States.'  ELSE NULL END) AS [Priv_Notes]
		,S.[GraduationYear]
		,(CASE 
				WHEN ae.DAEducationLevelId=123 THEN 'Other'
				ELSE CONVERT(Varchar(25),ell.ShortName)
				END) 
		AS EducationLevelCode
		,(CASE 
				WHEN ae.DAEducationLevelId=123 THEN CONVERT(Varchar(50),StgEdu.EducationLevelOther)
				ELSE  CONVERT(Varchar(50),ell.ItemName)
				END) 
		AS EducationLevel
		,(CASE 
			WHEN sl.DynamicAttributeId IS NOT NULL and CONVERT(Varchar(50),SL.ItemName)<>'Other' then CONVERT(Varchar(50),SL.ShortName)
			ELSE 'Other' 
		END)
		AS SchoolCode
		,(CASE 
			WHEN ML.DynamicAttributeId IS NOT NULL then CONVERT(Varchar(50),ML.ShortName )
			ELSE 'Other'
		END)
		AS StudiesCode
	FROM [dbo].[Educat] A 
	RIGHT OUTER JOIN [STG].[Educat_CT] S ON ISNULL(A.[APNO],0) = S.[APNO] 
						AND S.[School]  = A.School 
						AND ISNULL(A.[Studies_A],'') = ISNULL(S.[Studies_A],'')
						AND S.Operation = 'I'
	INNER JOIN Enterprise.DBO.ApplicantEducation AE ON s.EducatID=ae.ApplicantEducationId
	
	LEFT OUTER JOIN Enterprise.[Staging].[ListApplicantEducations_ByApnos](@APNOS_csv) StgEdu ON
		ae.ApplicantId=StgEdu.ApplicantId 
		AND ISNULL(ae.DAEducationLevelId,0)=ISNULL(StgEdu.EducationLevelId,0) 
		and ae.SchoolName=StgEdu.SchoolName
		AND ISNULL(ae.Major,'') = ISNULL(StgEdu.Major,'')
	--Education Level Lookup
	LEFT OUTER JOIN Enterprise.dbo.DynamicAttribute ELL ON ELL.DynamicAttributeTypeId=3 AND AE.DAEducationLevelId=ELL.DynamicAttributeId
	-- School Lookup
	LEFT OUTER JOIN Enterprise.dbo.DynamicAttribute SL ON SL.DynamicAttributeTypeId=33 AND StgEdu.SchoolId=SL.DynamicAttributeId
	-- Major Lookup
	LEFT OUTER JOIN Enterprise.dbo.DynamicAttribute ML ON mL.DynamicAttributeTypeId=32 AND AE.Major=ML.ItemName
	

	WHERE A.[EducatID] IS  NULL
	AND S.APNO IS NOT NULL
	--*/
END


