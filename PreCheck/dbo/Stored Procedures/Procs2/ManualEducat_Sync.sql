-- =============================================
-- Author:		DEEPAK VODETHELA
-- Create date: 09/09/2020
-- Description:	Educat
-- Execution : EXEC [ManualEducat_Sync]
-- =============================================
CREATE PROCEDURE [ManualEducat_Sync] 
	-- Add the parameters for the stored procedure here
	@Apno int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	 
	SELECT  CT.*
			,A.ApplicantNumber 
		INTO #Educat_CT
	FROM ENTERPRISE.[dbo].[ApplicantEducation] CT INNER JOIN ENTERPRISE.[dbo].Applicant A
	ON CT.ApplicantId = A.ApplicantId
	WHERE ApplicantNumber = @Apno


	SELECT  [ApplicantEducationId]  [EducatID]
		  , ApplicantNumber  [APNO]
		  ,[SchoolName]  [School]
		  ,Null [SectStat]
		  ,Null [Worksheet]
		  ,[State]  [State]
		  ,NULL [Phone]
		  ,[DegreeName]  [Degree_A]
		   ,[Major] [Studies_A]
		  ,[AttendedFrom]  [From_A]
		  ,[AttendedTo] [To_A]
		  ,[NameOnDegree]  [Name]
		  ,Null [Degree_V]
		  ,Null [Studies_V]
		  ,Null [From_V]
		  ,Null [To_V]
		  ,Null [Contact_Name]
		  ,Null [Contact_Title]
		  ,Null [Contact_Date]
		  ,Null [Investigator]
		  ,Null [Priv_Notes]
		  ,Null [Pub_Notes]
		  ,Null [web_status]
		  ,Null [includealias]
		  ,Null [includealias2]
		  ,Null [includealias3]
		  ,Null [includealias4]
		  ,Null [pendingupdated]
		  ,Null [web_updated]
		  ,Null [Time_In]
		  ,[ModifyDate] [Last_Updated]
		  ,[City]  [city]
		  ,Null [zipcode]
		  ,[CampusName]  [CampusName]
		  ,Null [InUse]
		  , [CreateDate]  [CreatedDate]
		  ,Null [ToPending]
		  ,Null [FromPending]
		  ,Null [Completed]
		  ,Null [Last_Worked]
		  ,Null [SchoolID]
		  ,Null [IsCAMReview]
		  ,Null [IsOnReport]
		  ,Null [IsHidden]
		  ,Null [IsHistoryRecord]
		  ,ISNULL([IsGraduated],0) [HasGraduated]
		  ,NULL  [HighestCompleted]
		  ,Null [EducatVerifyID]
		  ,Null [GetNextDate]
		  ,Null [SubStatusID]
		  ,Null [ClientAdjudicationStatus]
		  ,Null [ClientRefID]
		  ,case when Country in ('USA','US','America','States') then 0 else 1 end [IsIntl]
		  ,Null [DateOrdered]
		  ,Null [OrderId]
		  ,Null [InUse_TimeStamp]
		  ,Null [LastModifiedDate]
		  ,Null [LastModifiedBy]
		INTO   #Educat
	  FROM #Educat_CT

	BEGIN TRAN

		INSERT INTO Precheck.[dbo].[Educat] 
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
			,[HighestCompleted])
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
		FROM  Precheck.[dbo].[Educat] A RIGHT OUTER JOIN #Educat S
		ON ISNULL(A.[APNO],0) = S.[APNO] AND CONVERT(Varchar(50),S.[School])  = A.School
		WHERE A.[EducatID] IS  NULL

	COMMIT TRAN

 DROP TABLE #Educat_CT
 DROP TABLE #Educat 


END
