-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 04/02/2021
-- Description:	Thomas and Thorngren request
-- EXEC [ThomasAndCompanyIntegration] 
-- Modified by Amy Liu on 04/14/2021 per Radhika's instruction below
--	Within a transaction, update the Empl table for those EmpliD’s with Webstatus as “Do NOT Close” (60) and private and public notes stamped with this verbiage 
-- (“[Datetime stamp]10/15/2020 11:28 PM- Employment information is being obtained via an online employment verification system. The expected return date is within 24 hours.” ).
-- Insert all these records with the new private/public notes and webstatus in the EmplAudittable.
-- Modified by Radhika Dereddy on 04/27/2021 -Add AffiliateId inaddition to ParentCLNO 
-- Modified by AmyLiu on 06/02/2021 for HDT7226 to trim whitespace
-- Modified by Radhika on 08/02/2021 commenting steward since they no longer use T&C 15382, 228 
-- Modified By Lalit on 5 may 2023 for #92965
-- =============================================
CREATE PROCEDURE [dbo].[ThomasAndCompanyIntegration_ClientSchedule]


AS
BEGIN
	SET NOCOUNT ON;

	DROP TABLE IF EXISTS #EmplNotClose

	
	CREATE TABLE #tempCLNO
	(
		CLNO int,
		ClientName varchar(100),
		AffiliateID int
	)

	INSERT INTO #tempCLNO
	SELECT CLNO,[Name] as ClientName, AffiliateID FROM dbo.Client (NOLOCK) where (WebOrderParentCLNO in (7519,15623) OR Affiliateid in (4,5,237)) -- commenting steward since they no longr use T&C by RD on 08/02/2021 


	SELECT distinct e.EmplID, A.APNO [Report Number],A.SSN, A.First [Applicant First Name], A.Last  [Applicant Last Name], 
					E.Employer [Employer Name], E.State, E.From_A [Start Date Per Applicant],
					E.To_A [End Date Per Applicant],E.Position_A [Position Per Applicant], R.Affiliate,e.web_status,
					e.Pub_Notes,e.Priv_Notes, e.pub_Notes as OldPubNotes, e.priv_Notes as OldPrivNotes, e.web_status as OldWebStatus,
					t.ClientName [HCA Client Name], t.CLNO 
	 INTO #EmplNotClose            -- drop table #EmplNotClose 
	FROM dbo.Appl A WITH(NOLOCK)
	INNER JOIN dbo.Empl E WITH(NOLOCK) ON A.APNO = E.APNO     
	INNER JOIN #tempCLNO t ON t.CLNO = a.CLNO	 
	INNER JOIN dbo.refAffiliate R WITH(NOLOCK) ON t.AffiliateID = R.AffiliateID 
	INNER JOIN dbo.[ClientEmployer] CE WITH(NOLOCK) ON (E.Employer = CE.Company OR CHARINDEX(ltrim(rtrim(e.Employer)), CE.AliasList) > 0 ) AND CE.Deleted = 0
	INNER JOIN #tempCLNO t1 ON t1.CLNO = CE.CLNO 
	WHERE A.ApStatus IN ('P')  
	AND E.DNC = 0     
	AND E.SectStat = '9'  
	AND E.IsOnReport = 1      
	AND E.Investigator = 'THORNGRE'     
	AND E.web_status NOT IN (60)  

	DECLARE @currentDateTime varchar(30) = FORMAT(getdate(),'MM/dd/yyyy hh:mm:s tt');

BEGIN TRY
	BEGIN TRANSACTION;

		 UPDATE enc SET enc.web_status=60,
				 enc.Pub_Notes ='['+ @currentDateTime +'] - Employment information is being obtained via an online employment verification system. The expected return date is within 24 hours.'  + CHAR(13) +  isnull(enc.Pub_Notes,''),
				 enc.Priv_Notes ='['+ @currentDateTime +'] - submitted to Thomas & Company.'  + CHAR(13) +  isnull(enc.Priv_Notes,'')
		 FROM #EmplNotClose enc

		 INSERT INTO [dbo].[EmplAudit]
				   ([CLNO]
				   ,[APNO]
				   ,[EmplID]
				   ,[Employer]
				   ,[FirstName]
				   ,[LastName]
				   ,[PrivateNotes]
				   ,[PublicNotes]
				   ,[Webstatus]
				   ,[CreateDate]
				   ,[CreateBy]
				   ,[ModifyDate]
				   ,[ModifyBy])
			SELECT enc.CLNO
				   ,enc.[Report Number] as apno
				   ,enc.EmplID
				   ,enc.[Employer Name] as Employer
				   ,enc.[Applicant First Name] as [FirstName]
				   ,enc.[Applicant Last Name] as [LastName]
				   ,CAST(enc.Priv_Notes AS VARCHAR(3998)) [PrivateNotes]
				   ,CAST(enc.Pub_Notes AS VARCHAR(3998)) [PublicNotes]
				   ,enc.web_status as [Webstatus]
				   ,@currentDateTime as [CreateDate]
				   ,'ThomasCIntegration' as [CreateBy]
				   ,NULL
				   ,NULL
			FROM #EmplNotClose enc

			insert into dbo.changelog (tablename, ID, OldValue, NewValue, ChangeDate, UserID)
			select 'Empl.web_Status',enc.EmplID, enc.OldWebStatus, '60', cast (@currentDateTime as datetime), 'ThomasC'
			from #EmplNotClose enc

			insert into dbo.changelog (tablename, ID, OldValue, NewValue, ChangeDate, UserID)
			select 'Empl.Empl.Priv_Notes',enc.EmplID, enc.OldPrivNotes, enc.Priv_Notes, cast (@currentDateTime as datetime), 'ThomasC'
			from #EmplNotClose enc
		
			insert into dbo.changelog (tablename, ID, OldValue, NewValue, ChangeDate, UserID)
			select 'Empl.Empl.Pub_Notes',enc.EmplID, enc.OldPubNotes, enc.Pub_Notes, cast (@currentDateTime as datetime), 'ThomasC'
			from #EmplNotClose enc


			UPDATE e SET e.Pub_Notes = enc.Pub_Notes, e.Priv_Notes = enc.Priv_Notes, e.web_status= enc.web_status
			FROM #EmplNotClose enc
			INNER JOIN dbo.Empl e on e.EmplID = enc.EmplID

			SELECT DISTINCT enc.[Report Number],
					enc.SSN,
					Replace(enc.[Applicant First Name],',',' ') as [Applicant First Name],
					Replace(enc.[Applicant Last Name],',',' ') as [Applicant Last Name], 
					Replace(enc.[Employer Name],',',' ') as [Employer Name], 
					enc.State,
					enc.[Start Date Per Applicant],
					enc.[End Date Per Applicant],
					Replace(enc.[Position Per Applicant] , ',', ' ') as [Position Per Applicant],
					Replace(enc.Affiliate, ',', ' ') as [Affiliate],
					Replace(enc.[HCA Client Name] , ',', ' ') as [Client Name]
			FROM #EmplNotClose enc

	IF @@TRANCOUNT > 0
	  COMMIT;
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK;
	--SELECT ERROR_NUMBER() AS ErrorNumber;
	--SELECT ERROR_MESSAGE() AS ErrorMessage;
END CATCH;

END
