


CREATE PROCEDURE [STG].[usp_process_ApplicantAlias_CT] 
-- =============================================
-- Author:		Balaji Sankar
-- Create date: 03/27/2016
-- Description:	Process Empl Change tracking table
-- =============================================
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE A SET 
	A.[First] = CONVERT(VARCHAR(50),S.[First])
	,A.[Middle]   = CONVERT(VARCHAR(50),S.[Middle])  
	,A.[Last] = CONVERT(VARCHAR(50),S.[Last])
	,A.[CreatedDate] = S.[CreatedDate]
	,A.[AddedBy] = CONVERT(VARCHAR(25),S.[AddedBy])
	FROM [dbo].[ApplAlias] A INNER JOIN [STG].[vw_ApplAlias_CT] S
	ON A.[APNO] = S.[APNO] 
	AND S.Operation = 'U'
	where S.RowNum > 4

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

END




