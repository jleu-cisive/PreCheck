
CREATE PROCEDURE [STG].[usp_process_ApplicantLicense_CT] 
-- =============================================
-- Author:		Balaji Sankar
-- Create date: 03/27/2016
-- Modified date: 12/9/2016 17:55 CST
-- Modified by: Gaurav Bangia
-- Modification purpose: error in data conversion for Year field. RID:7279
-- Modified date: 11/14/2018
-- Modified by: Larry Ouch
-- Modification purpose: Stamp private notes if license is LifeTime
-- Description:	Process ProfLic Change tracking table
-- =============================================
AS
BEGIN
	SET NOCOUNT ON;

	UPDATE A SET 
	A.[Lic_Type] = CONVERT(VARCHAR(100),S.[Lic_Type])
	,A.[Lic_No] = CONVERT(VARCHAR(20),S.[Lic_No])
	,A.[Year]   =  CONVERT(VARCHAR(10),S.[Year],101)  
	,A.[Expire] = S.[Expire]
	,A.[State] = CONVERT(VARCHAR(8),S.[State])
	,A.[Last_Updated] = S.[Last_Updated]
	,A.[InUse] = S.[InUse]
	,A.[CreatedDate] = S.[CreatedDate]
	FROM [dbo].[ProfLic] A INNER JOIN [STG].[ProfLic_CT] S
	ON A.[APNO] = S.[APNO] AND A.[Lic_Type] = CONVERT(VARCHAR(100),S.[Lic_Type])
	AND S.Operation = 'U'
	WHERE S.APNO IS NOT NULL

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
END


-------------------------------------------------------------------------------------------
--[STG].[usp_process_ApplicantEmployment_CT] 
-------------------------------------------------------------------------------------------

