-- =============================================
-- Author:		DEEPAK VODETHELA
-- Create date: 09/09/2020
-- Description:	Professional License
-- Execution : ManualProfLic_Sync
-- =============================================
CREATE PROCEDURE [ManualProfLic_Sync] 
	-- Add the parameters for the stored procedure here
	@Apno int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
	SELECT	CT.*
			,A.ApplicantNumber 
		INTO #Lic_CT
	FROM ENTERPRISE.[dbo].ApplicantLicense CT 
	INNER JOIN ENTERPRISE.dbo.Applicant A ON CT.ApplicantId = A.ApplicantId
	WHERE ApplicantNumber = @Apno

	SELECT Null [ProfLicID]
		  ,ApplicantNumber [Apno]
		  ,Null [SectStat]
		  ,Null [Worksheet]
		  ,LicenseType [Lic_Type]
		  ,LicenseNumber [Lic_No]
		  ,IssueDate [Year]
		  ,ExpirationDate [Expire]
		  ,State [State]
		  ,Null [Status]
		  ,Null [Priv_Notes]
		  ,Null [Pub_Notes]
		  ,Null [Web_status]
		  ,Null [includealias]
		  ,Null [includealias2]
		  ,Null [includealias3]
		  ,Null [includealias4]
		  ,Null [pendingupdated]
		  ,Null [web_updated]
		  ,Null [time_in]
		  ,Null [Organization]
		  ,Null [Contact_Name]
		  ,Null [Contact_Title]
		  ,Null [Contact_Date]
		  ,Null [Investigator]
		  ,ModifyDate [Last_Updated]
		  ,Null [InUse]
		  ,CreateDate [CreatedDate]
		  ,Null [Status_A]
		  ,Null [ToPending]
		  ,Null [FromPending]
		  ,Null [Last_Worked]
		  ,Null [IsCAMReview]
		  ,Null [IsOnReport]
		  ,Null [IsHidden]
		  ,Null [IsHistoryRecord]
		  ,Null [ClientAdjudicationStatus]
		  ,Null [ClientRefID]
		  ,Null [Lic_Type_V]
		  ,Null [Lic_No_V]
		  ,Null [State_V]
		  ,Null [Expire_V]
		  ,Null [Year_V]
		  ,Null [GenerateCertificate]
		  ,Null [CertificateAvailabilityStatus]
		  ,Null [DisclosedPastAction]
		  ,Null [InUse_TimeStamp]
		  ,Null [NameOnLicense_V]
		  ,Null [Speciality_V]
		  ,Null [LifeTime_V]
		  ,Null [MultiState_V]
		  ,Null [BoardActions_V]
		  ,Null [ContactMethod_V]
		  ,Null [LicenseTypeID]
	INTO #LIC   FROM #Lic_CT CH


	BEGIN TRAN

		INSERT INTO Precheck.[dbo].[ProfLic] 
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
			  ,IIF(LEN(S.[State])> 2 , 'STATE : ' + S.[State] , NULL)
			  ,S.[CreatedDate]
			FROM pRECHECK.[dbo].[ProfLic] A RIGHT OUTER JOIN #LIC S
			ON A.[APNO] = S.[APNO] 	--AND S.Operation = 'I'
			WHERE A.[APNO] IS NULL

	COMMIT TRAN

	DROP TABLE #Lic_CT
	DROP TABLE #Lic
END
