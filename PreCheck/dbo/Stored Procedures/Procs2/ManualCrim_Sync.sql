-- =============================================
-- Author:		DEEPAK VODETHELA
-- Create date: 09/09/2020
-- Description: Criminal Records
-- Execution : EXEC [ManualCrim_Sync]
-- =============================================
CREATE PROCEDURE [ManualCrim_Sync] 
	-- Add the parameters for the stored procedure here
	@Apno int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT 	CT.*
			,A.ApplicantNumber INTO #Crim_CT
	FROM ENTERPRISE.[dbo].[ApplicantCriminalHistory] CT 
	INNER JOIN ENTERPRISE.dbo.Applicant A  ON CT.ApplicantId = A.ApplicantId
	WHERE ApplicantNumber = @Apno 

	SELECT A.ApplicantNumber AS [APNO]      
		  ,CH.[City]
		  ,CH.[State]
		  ,CH.[Country]
		  ,CH.[OffenseDate] AS [CrimDate]
		  ,CH.[OffenseDescription] AS Offense
		  ,'Enterprise' As [Source]
		  , SocialNumber AS [SSN]
		  , NULL AS CLNO
		  ,CH.[CreateDate]
		  INTO #Crim   
	FROM #Crim_CT CH
	INNER JOIN ENTERPRISE.[dbo].[Applicant] A ON A.[ApplicantId] = CH.[ApplicantId] 

	BEGIN TRAN

		  INSERT INTO Precheck.[dbo].[ApplicantCrim] 
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
		FROM Precheck.[dbo].[ApplicantCrim] A RIGHT OUTER JOIN #Crim S
		ON A.[APNO] = S.[APNO] 
		WHERE A.[APNO] IS NULL
	
	COMMIT TRAN

	DROP TABLE #Crim_CT
	DROP TABLE #Crim
	
END
