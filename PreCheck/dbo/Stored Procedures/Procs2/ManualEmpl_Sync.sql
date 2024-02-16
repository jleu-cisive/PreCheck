-- =============================================
-- Author:		DEEPAK VODETHELA
-- Create date: 09/09/2020
-- Description: Employment records
-- Execution : EXEC [ManualEmpl_Sync]
-- =============================================
CREATE PROCEDURE [dbo].[ManualEmpl_Sync] 
	-- Add the parameters for the stored procedure here
	@Apno int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

	 SELECT CT.*
			,A.ApplicantNumber 
		INTO #Empl_CT
	 FROM [Enterprise].[dbo].[ApplicantEmployment] CT 
	 INNER JOIN [Enterprise].dbo.Applicant A ON CT.ApplicantId = A.ApplicantId
	 WHERE A.ApplicantNumber = @Apno

	SELECT  NULL [EmplID]
		  ,ApplicantNumber  [APNO]
		  ,EmployerName [Employer]
		  ,[Address] [Location]
		  ,NULL  [SectStat]
		  ,NULL  [Worksheet]
		  ,SupervisorPhone  [Phone]
		  ,SupervisorName [Supervisor]
		  ,SupervisorPhone [SupPhone]
		  ,NULL [Dept]
		  ,ReasonForLeaving [RFL]
		  ,~(IsOKToContact) [DNC] --flip the value - schapyala on 08/02/2017 (~ is the operator equivalent to NOT)
		  ,NULL [SpecialQ]
		  ,NULL [Ver_Salary]
		  ,EmploymentFrom [From_A]
		  ,[EmploymentTo] [To_A]
		  ,EndDesignation [Position_A] --schapyala changed from StartDesignation because EndDesignation is the current position which is what we will verify
		  ,EndSalary [Salary_A] --schapyala changed from StartSalary because EndSalary is the current salary which is what we will verify
		  ,NULL [From_V]
		  ,NULL [To_V]
		  ,NULL [Position_V]
		  ,NULL [Salary_V]
		  ,NULL [Emp_Type]
		  ,NULL [Rel_Cond]
		  ,NULL [Rehire]
		  ,NULL [Ver_By]
		  ,NULL [Title]
		  ,NULL [Priv_Notes]
		  ,NULL [Pub_Notes]
		  ,NULL [web_status]
		  ,NULL [web_updated]
		  ,NULL [Includealias]
		  ,NULL [Includealias2]
		  ,NULL [Includealias3]
		  ,NULL [Includealias4]
		  ,NULL [PendingUpdated]
		  ,NULL [Time_In]
		  ,ModifyDate [Last_Updated]
		  ,City [city]
		  ,[State] [state]
		  ,Zip [zipcode]
		  ,NULL [Investigator]
		  ,NULL [EmployerID]
		  ,NULL [InvestigatorAssigned]
		  ,NULL [PendingChanged]
		  ,NULL [TempInvestigator]
		  ,NULL [InUse]
		  ,CreateDate [CreatedDate]
		  ,CreateBy [EnteredBy]
		  ,NULL [EnteredDate]
		  ,NULL [IsCamReview]
		  ,NULL [Last_Worked]
		  ,NULL [ClientEmployerID]
		  ,NULL [AutoFaxStatus]
		  ,NULL [IsOnReport]
		  ,NULL [IsHidden]
		  ,NULL [IsHistoryRecord]
		  ,NULL [EmploymentStatus]
		  ,IsOKToContact [IsOKtoContact] 
		  ,NULL [OKtoContactInitial]
		  ,NULL [EmplVerifyID]
		  ,NULL [GetNextDate]
		  ,NULL [SubStatusID]
		  ,NULL [ClientAdjudicationStatus]
		  ,NULL [ClientRefID]
		  ,CASE WHEN Country IN ('USA','US','America','States') THEN 0 ELSE 1 END [IsIntl]
		  ,NULL [DateOrdered]
		  ,NULL [OrderId]
		  ,NULL [Email]
		  ,NULL [AdverseRFL]
		  ,NULL [InUse_TimeStamp]
		  ,NULL [LastModifiedDate]
		  ,NULL [LastModifiedBy]
		  INTO #Empl
	  FROM #Empl_CT

	  BEGIN TRAN

		INSERT INTO Precheck.[dbo].[Empl] 
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
			,DNC)
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
			,CAST(S.DNC AS BIT)
		FROM Precheck.[dbo].[Empl] A RIGHT OUTER JOIN #Empl S
		ON A.APNO = S.APNO
		WHERE A.APNO IS NULL

	COMMIT TRAN

	DROP TABLE #Empl
	DROP TABLE #Empl_CT

END
