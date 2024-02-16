CREATE PROCEDURE [STG].[usp_process_ApplicantEmployment_CT] 
-- =============================================
-- Author:		Balaji Sankar
-- Create date: 03/27/2016
-- Modified date: 11/14/2018
-- Modified by: Larry Ouch
-- Modification purpose: Stamp private notes if record is international or has VerifyPresentEmployer config
-- Description:	Process Empl Change tracking table
-- =============================================
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE A SET 
	 A.[Employer] = CONVERT(Varchar(30),S.[Employer])
	,A.[Location]   = S.[Location]  
	,A.[Supervisor] = CONVERT(Varchar(25),S.[Supervisor])
	,A.[SupPhone] = CONVERT(Varchar(20),S.[SupPhone])
	,A.Phone = CONVERT(Varchar(20),S.[SupPhone])
	,A.[RFL] = CONVERT(Varchar(30),S.[RFL])
	,A.[From_A] = CONVERT(Varchar(10),S.[From_A], 101)
	,A.[To_A] = CONVERT(Varchar(10),S.[To_A],101)
	,A.[Position_A] = CONVERT(Varchar(50),S.[Position_A])
	,A.[Salary_A] = CONVERT(Varchar(15),S.[Salary_A])
	,A.[Last_Updated] = S.[Last_Updated]
	,A.[city] = CONVERT(Varchar(50),S.[city])
	,A.[state] = CONVERT(varchar(2),S.[state]) 
	,A.[zipcode] = CONVERT(varchar(5),S.[zipcode])
	,A.[CreatedDate] = S.[CreatedDate]
	,A.[EnteredBy] = S.[EnteredBy]
	,A.[IsOKtoContact] = S.[IsOKtoContact]
	,A.DNC = ISNULL(CAST(S.DNC AS BIT),0)
	FROM [dbo].[Empl] A INNER JOIN [STG].[Empl_CT] S
	ON A.APNO = S.APNO AND A.[Employer] = CONVERT(Varchar(30),S.[Employer])
	AND S.Operation = 'U'
	WHERE S.APNO IS NOT NULL
	--/*
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

	
END


-------------------------------------------------------------------------------------------
--[STG].[usp_process_ApplicantEducation_CT] 
-------------------------------------------------------------------------------------------

