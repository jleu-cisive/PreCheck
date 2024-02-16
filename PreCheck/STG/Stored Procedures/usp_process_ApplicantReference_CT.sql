


CREATE PROCEDURE [STG].[usp_process_ApplicantReference_CT] 
-- =============================================
-- Author:		Balaji Sankar
-- Create date: 03/27/2016
-- Description:	Process Empl Change tracking table
-- =============================================
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE A SET 
	A.[APNO] = S.[APNO]
	,A.[Name] = CONVERT(VARCHAR(25),S.[Name])
	,A.[Phone]   = CONVERT(VARCHAR(20),S.[Phone])  
	,A.[Last_Updated] = S.[Last_Updated]
	,A.[CreatedDate] = S.[CreatedDate]
	,A.[Email] = CONVERT(VARCHAR(50),S.[Email])
	,A.[JobTitle] = CONVERT(VARCHAR(100),S.[JobTitle])
	FROM [dbo].[PersRef] A INNER JOIN [STG].[PersRef_CT] S
	ON A.[APNO] = S.[APNO]
	AND a.Name=S.Name
	AND S.Operation = 'U'

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
	WHERE A.[APNO] IS NULL AND s.APNO IS NOT null

END




