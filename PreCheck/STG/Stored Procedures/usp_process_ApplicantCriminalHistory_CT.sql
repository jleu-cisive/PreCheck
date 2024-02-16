
CREATE PROCEDURE [STG].[usp_process_ApplicantCriminalHistory_CT] 
-- =============================================
-- Author:		Balaji Sankar
-- Create date: 07/04/2016
-- Description:	Process Applicant Cirminal History Change tracking table from Enterprise to Precheck
-- =============================================
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE A SET 
      A.[City] = S.[City]
      ,A.[State] =  S.[State]
      ,A.[Country] = S.[Country]
      ,A.[CrimDate] = S.[CrimDate]
      ,A.[Offense] = CONVERT(varchar(50),S.[Offense]) 
      ,A.[Source] = S.[Source]
      ,A.[SSN] = S.[SSN]
      ,A.[CLNO] = S.[CLNO]
--      ,A.[CreatedDate] = S.[CreateDate]
	FROM [dbo].[ApplicantCrim] A INNER JOIN [STG].[ApplicantCrim_CT] S
	ON A.[APNO] = S.[APNO] 
	AND S.Operation = 'U'

	--/*
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
	--*/
END

