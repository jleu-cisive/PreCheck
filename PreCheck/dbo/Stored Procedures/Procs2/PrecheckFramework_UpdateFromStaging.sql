
-- =============================================  
-- Author:  Douglas DeGenaro  
-- Create date: 03/11/2013  
-- Description: Updates the corresponding table based on the staging table  
--select * from dbo.PrecheckFramework_ApplStaging where folderId = 'OASIS_TEST'  
--dbo.PrecheckFramework_UpdateFromStaging 'OASIS_TEST',2110603,'ApplicationData'  
--select * from appl where apno = 2110603  
--truncate table dbo.PrecheckFramework_ApplStaging   
--dbo.PrecheckFramework_UpdateFromStaging '0900000000000000000000012699336','6089566','ddegenaro','PublicRecords'  
-- Modified By:	Joshua Ates
-- Modified Date: 3/23/2021
-- Description:	Removed subquries in select statement, removed subqueries in the where clauses, removed redundent subqueries, reformatted code to be more readable

--Modified By: Doug DeGenaro
--Modified Date : 09/20/2021
-- No longer using #tmpCrim but are using Crim now and Apno directly

-- Modified by Humera Ahmed on 11/18/2022 to remove partnerid = 11 in update crim area in line #1027
-- Modified on 9/18/2023 by Dongmei He for Velocity Update 1.7
-- =============================================  

CREATE PROCEDURE [dbo].[PrecheckFramework_UpdateFromStaging]
	-- Add the parameters for the stored procedure here  
	@folderId VARCHAR(50)
	,@apno INT
	,@userName VARCHAR(8) = NULL
	,@sectionList VARCHAR(100) = NULL
	,@DateEntered DATETIME = NULL
	,@UnLockAppl BIT = 1
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from  
	-- interfering with SELECT statements.  
	SET NOCOUNT ON;
	
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	
	DECLARE @flag INT
		,@count INT
		,@sectionOption VARCHAR(50)
		,@ssn VARCHAR(11)
		,@dob DATETIME
		,@apstatus VARCHAR(2)
		,@id INT
		,@BigCounty VARCHAR(75)
		,@CLNO INT
		,@IsReview BIT
		,@RerunPID BIT = 0

	SELECT @IsReview = chkReview
	FROM Metastorm9_2.dbo.oasis
	WHERE apno = @apno

	DECLARE @crimid INT

	IF (charindex('UnlockAppl', @sectionList) > 0)
		SET @SectionList = REPLACE(@SectionList, 'UnlockAppl', '')

	--If Credit is Ordered, send an email to the distribution list to notify them to run the candidate's Credit history
	--moved this logic to create orders -schapyala 08/05/2013
	--IF (charindex('Order_Credit',@sectionList) > 0)  
	--BEGIN
	--	IF (SELECT count(apno) FROM dbo.Credit WHERE apno = @apno and RepType='C') = 0  
	--	 BEGIN
	--		Declare @msg nvarchar(500), @Sub nvarchar(200)
	--			Select @msg = 'This is to inform you that Client:  ' + cast(Name as nvarchar)+ '(' + cast(A.CLNO as nvarchar) + ') requires/requested Credit to be ordered for Report# ' + cast(@apno as varchar) + '; ' + char(9) + char(13)+ char(9) + char(13) +   'Applicant: ' + A.First + ' ' + A.Last  + char(9) + char(13)+ char(9) + char(13) +   'Thank you.'
	--		From DBO.APPL A inner join DBO.Client C on A.CLNO = C.CLNO
	--		Where APNO = @apno
	--		Set @Sub = 'Credit Requested For Report# ' + cast(@apno as varchar) + '; Requested By: ' + @userName
	--		EXEC msdb.dbo.sp_send_dbmail    @from_address=N'CreditReports@PreCheck.com', @recipients=N'CreditReports@PreCheck.com', @subject= @Sub,   @body=@msg ;
	--	 END
	--END
	--Start orders  
	--if (PATINDEX('%Order_%',@sectionList) > 0)
	--exec dbo.PrecheckFramework_CreateOrders @sectionList,@apno,@userName
	--truncate Username to 8 characters --should be relaxed later
	IF (@userName IS NOT NULL)
		SET @userName = Left(@userName, 8)

	IF (
			SELECT count(FolderId)
			FROM dbo.PrecheckFramework_ApplAliasStaging
			WHERE @folderId = folderId
				AND apno = @apno
				AND CreatedDate >= @DateEntered
			) > 0
	BEGIN
		--added on 05/02/2013 to delete entries that are set for deleted in the staging table
		--delete 
		--	alias
		--FROM     
		--      [dbo].[ApplAlias] alias         
		--      JOIN   
		--      [dbo].[PrecheckFramework_ApplAliasStaging] stg   
		--      ON  
		--      stg.Apno = alias.Apno and 
		--     stg.SectionId = alias.ApplAliasId   
		--     where          
		--      stg.CreatedDate >= @DateEntered	
		--      and stg.Deleted = 1 
		UPDATE alias
		SET First = stg.First
			,Middle = isnull(stg.Middle, '')
			,Last = stg.Last
			,IsMaiden = isnull(stg.IsMaiden, '')
			,Generation = isnull(stg.Generation, '')
			,IsPublicRecordQualified = isnull(stg.IsPublicRecordQualified, 0)
			,IsPrimaryName = isnull(stg.IsPrimaryName, 0)
			,CLNO = isnull(stg.CLNO, 0)
			,SSN = isnull(stg.SSN, '')
			,LastUpdateDate = getDate()
			,LastUpdatedBy = isnull(stg.LastUpdatedBy, '')
			,IsActive = CASE 
				WHEN stg.Deleted = NULL
					OR stg.Deleted = ''
					OR stg.Deleted = 0
					OR stg.Deleted = 'False'
					THEN 1
				ELSE 0
				END
		FROM [dbo].[ApplAlias] alias
		JOIN [dbo].[PrecheckFramework_ApplAliasStaging] stg ON stg.Apno = alias.Apno
			AND stg.SectionId = alias.ApplAliasId
		WHERE ISNULL(stg.SectionID, '') <> ''
			AND stg.FolderId = @folderId
			AND stg.CreatedDate >= @DateEntered

		--Disable deleted ones -----------------------------------------------------------------
		UPDATE alias
		SET IsActive = 0
			,LastUpdateDate = getDate()
			,LastUpdatedBy = @userName
		FROM [dbo].[ApplAlias] AS alias
		JOIN (
			SELECT DISTINCT 'ApplAlias' AS SectionName
				,MIN(ApplAliasID) AS SectionId
				,[First]
				,isnull(Middle, '') Middle
				,Last
				,isnull(Generation, '') Generation
				,cast(max(cast(IsPublicRecordQualified AS INT)) AS BIT) IsPublicRecordQualified
				,cast(min(cast(IsPrimaryName AS INT)) AS BIT) IsPrimaryName
				,MIN(CreatedDate) CreatedDate
				,MIN(CreatedBy) CreatedBy
			FROM dbo.ApplAlias
			WHERE Apno = @apno
				AND IsActive = 1
				AND IsPrimaryName = 0
			GROUP BY First
				,isnull(Middle, '')
				,Last
				,isnull(Generation, '')
			) P ON P.SectionId = alias.ApplAliasID
		LEFT JOIN (
			SELECT SectionId
			FROM [dbo].[PrecheckFramework_ApplAliasStaging]
			WHERE IsNull(SectionID, '') <> ''
				AND FolderId = @folderId
				AND CreatedDate >= @DateEntered
			) B ON alias.ApplAliasID = B.SectionId
		WHERE B.SectionId IS NULL

		INSERT INTO dbo.ApplAlias (
			Apno
			,First
			,Middle
			,Last
			,IsMaiden
			,AddedBy
			,IsPublicRecordQualified
			,IsPrimaryName
			,CreatedDate
			,CreatedBy
			,LastUpdateDate
			,LastUpdatedBy
			,Clno
			,IsActive
			,Generation
			)
		SELECT @Apno
			,First
			,isnull(Middle, '')
			,Last
			,IsMaiden
			,@userName
			,IsPublicRecordQualified
			,IsPrimaryName
			,GetDate()
			,CreatedBy
			,GetDate()
			,LastUpdatedBy
			,Clno
			,1
			,isnull(Generation, '')
		FROM dbo.PrecheckFramework_ApplAliasStaging
		WHERE IsNull(SectionID, '') = '' --and SectionID != 0
			AND apno = @apno
			AND CreatedDate >= @DateEntered
			AND Deleted = 0

		DELETE
		FROM [dbo].[PrecheckFramework_ApplAliasStaging]
		WHERE FolderId = @FolderId
			AND apno = @apno
	END

	IF (charindex('ApplicationData', @sectionList) > 0)
	BEGIN
		IF (
				SELECT count(folderId)
				FROM [dbo].[PrecheckFramework_ApplStaging]
				WHERE @folderId = folderId
					AND apno = @apno
					AND CreatedDate >= @DateEntered
				) > 0
		BEGIN
			UPDATE a
			SET First = t.First
				,clno = t.clno
				,Last = t.Last
				,Middle = t.Middle
				,Generation = t.Generation
				,SSN = t.SSN
				,GetNextDate = t.GetNextDate
				,SubStatusID = CASE 
					WHEN isnull(t.GetNextDate, '') = ''
						THEN (
								CASE 
									WHEN a.SubStatusID = 29
										AND a.ApStatus = 'M'
										AND t.ApStatus = 'M'
										THEN 29
									ELSE 28
									END
								)
					ELSE 7
					END
				,DOB = t.DOB
				,Last_Updated = CURRENT_TIMESTAMP
				,StartDate = CASE 
					WHEN isnull(t.StartDate, '') = ''
						THEN a.StartDate
					ELSE t.StartDate
					END
				,Addr_Num = t.Addr_Num
				,Addr_Street = t.Addr_Street
				,Addr_Apt = t.Addr_Apt
				,Addr_Dir = t.Addr_Dir
				,
				-- No reason at all to truncate, removing truncation 11/03/2014 DD
				--Attn = Case When isnull(t.Attn,'') = '' then a.Attn else left(t.Attn,25) end , 
				--Attn = Case When isnull(t.Attn,'') = '' then a.Attn end, 
				Attn = t.Attn
				,City = t.City
				,STATE = t.STATE
				,Zip = t.Zip
				,Rush = isnull(t.Rush, 0)
				,Recruiter_Email = t.Recruiter_Email
				,Email = t.Email
				,Phone = t.Phone
				,FreeReport = isnull(t.FreeReport, 0)
				,Alias1_First = t.Alias1_First
				,Alias1_Middle = t.Alias1_Middle
				,Alias1_Last = t.Alias1_Last
				,Alias1_Generation = t.Alias1_Generation
				,Alias2_First = t.Alias2_First
				,Alias2_Middle = t.Alias2_Middle
				,Alias2_Last = t.Alias2_Last
				,Alias2_Generation = t.Alias2_Generation
				,Alias3_First = t.Alias3_First
				,Alias3_Middle = t.Alias3_Middle
				,Alias3_Last = t.Alias3_Last
				,Alias3_Generation = t.Alias3_Generation
				,Alias4_First = t.Alias4_First
				,Alias4_Middle = t.Alias4_Middle
				,Alias4_Last = t.Alias4_Last
				,Alias4_Generation = t.Alias4_Generation
				,Priv_Notes = cast(t.Priv_Notes AS VARCHAR(max))
				,-- + CHAR(13) + IsNull(cast(a.Priv_Notes as varchar(max)),''),        
				DL_Number = t.DL_Number
				,DL_State = t.DL_State
				,Pos_Sought = t.Pos_Sought
				,Special_Instructions = cast(t.Special_Instructions AS VARCHAR(max))
				,-- + CHAR(13) + IsNull(cast(a.Special_Instructions as varchar(max)),''),         
				PrecheckChallenge = isnull(t.PrecheckChallenge, 0)
				,Investigator = CASE 
					WHEN isnull(a.Investigator, '') = ''
						THEN left(t.Investigator, 8)
					ELSE a.Investigator
					END
				,UserID = CASE 
					WHEN isnull(t.UserID, '') = ''
						THEN a.UserID
					ELSE t.UserID
					END
				,ApStatus = t.ApStatus
				,PackageId = t.PackageId
				,Rel_Attached = t.Rel_Attached
				,DeptCode = t.DeptCode
				,OrigCompDate = CASE 
					WHEN isnull(t.OrigCompDate, '') = ''
						THEN a.OrigCompDate
					ELSE t.OrigCompDate
					END
				,CompDate = CASE 
					WHEN isnull(t.CompDate, '') = ''
						THEN a.CompDate
					ELSE t.CompDate
					END
				,I94 = CASE 
					WHEN isnull(t.I94, '') = ''
						THEN a.I94
					ELSE t.I94
					END
				,ReOpenDate = CASE 
					WHEN isnull(t.ReOpenDate, '') = ''
						THEN a.ReOpenDate
					ELSE t.ReOpenDate
					END
				,Pub_Notes = cast(t.Pub_Notes AS VARCHAR(max))
				,-- + IsNull(cast(a.Pub_Notes as varchar(max)),''),  
				NeedsReview = CASE 
					WHEN Isnull(t.NeedsReview, '') = ''
						THEN a.NeedsReview
					ELSE t.NeedsReview
					END
				,ClientAPNO = CASE 
					WHEN Isnull(a.ClientAPNO, '') = ''
						THEN t.ClientAPNO
					ELSE a.ClientAPNO
					END
				,ClientApplicantNO = CASE 
					WHEN Isnull(a.ClientAPNO, '') = ''
						THEN a.ClientApplicantNO
					WHEN Isnull(a.ClientAPNO, '') = t.ClientAPNO
						THEN a.ClientApplicantNO
					WHEN Isnull(a.ClientApplicantNO, '') = ''
						THEN t.ClientAPNO
					ELSE a.ClientApplicantNO
					END
			FROM dbo.Appl a
			JOIN [dbo].[PrecheckFramework_ApplStaging] t ON t.Apno = a.Apno
			WHERE t.FolderId = @folderId
				AND t.CreatedDate >= @DateEntered

			---------------------------Update primary name ---------------------------
			UPDATE alias
			SET First = stg.First
				,Middle = isnull(stg.Middle, '')
				,Last = stg.Last
				,Generation = isnull(stg.Generation, '')
				,CLNO = isnull(stg.CLNO, 0)
				,SSN = isnull(stg.SSN, '')
				,LastUpdateDate = getDate()
				,LastUpdatedBy = @userName
			FROM [dbo].[ApplAlias] alias
			JOIN [dbo].[PrecheckFramework_ApplStaging] stg ON stg.Apno = alias.Apno
			WHERE stg.FolderId = @folderId
				AND stg.CreatedDate >= @DateEntered
				AND alias.IsPrimaryName = 1

			---------------------------End of updating primary name ------------------------------------
			SELECT @RerunPID = CASE 
					WHEN isnull(NeedsReview, '') LIKE '%1'
						THEN cast(1 AS BIT)
					ELSE cast(0 AS BIT)
					END
			FROM [dbo].[PrecheckFramework_ApplStaging]
			WHERE FolderId = @FolderId
				AND apno = @apno

			DELETE
			FROM [dbo].[PrecheckFramework_ApplStaging]
			WHERE FolderId = @FolderId
				AND apno = @apno
		END
	END

	IF (PATINDEX('%Order_%', @sectionList) > 0)
		EXEC dbo.PrecheckFramework_CreateOrders @sectionList
			,@apno
			,@userName

	IF (charindex('Employment', @sectionList) > 0)
	BEGIN
		IF (
				SELECT COUNT(folderId)
				FROM dbo.PrecheckFramework_EmplStaging
				WHERE @folderId = folderId
					AND CreatedDate >= @DateEntered
				) > 0
		BEGIN
			--This takes care of the inserts  
			INSERT INTO [dbo].[Empl] (
				[Apno]
				,[Employer]
				,[Location]
				,[SectStat]
				,[Worksheet]
				,[Phone]
				,[Supervisor]
				,[SupPhone]
				,[Dept]
				,[RFL]
				,[DNC]
				,[SpecialQ]
				,[Ver_Salary]
				,[From_A]
				,[To_A]
				,[Position_A]
				,[Salary_A]
				,[From_V]
				,[To_V]
				,[Position_V]
				,[Salary_V]
				,[Emp_Type]
				,[Rel_Cond]
				,[Rehire]
				,[Ver_By]
				,[Title]
				,[Priv_Notes]
				,[Pub_Notes]
				,[web_status]
				,[web_updated]
				,[Includealias]
				,[Includealias2]
				,[Includealias3]
				,[Includealias4]
				,[PendingUpdated]
				,[Time_In]
				,[Last_Updated]
				,[city]
				,[state]
				,[zipcode]
				,[Investigator]
				,[EmployerID]
				,[InvestigatorAssigned]
				,[PendingChanged]
				,[TempInvestigator]
				,[InUse]
				,[CreatedDate]
				,[EnteredBy]
				,[EnteredDate]
				,[IsCamReview]
				,[Last_Worked]
				,[ClientEmployerID]
				,[AutoFaxStatus]
				,[IsOnReport]
				,[IsHidden]
				,[IsHistoryRecord]
				,[EmploymentStatus]
				,[IsOKtoContact]
				,[OKtoContactInitial]
				,[EmplVerifyID]
				,[GetNextDate]
				,[SubStatusID]
				,[ClientAdjudicationStatus]
				,[ClientRefID]
				,[IsIntl]
				,[DateOrdered]
				,[OrderId]
				,[AdverseRFL]
				,Email
				,City_V 
				,State_V
				,Country_V
				,RecipientName_V 
				)
			SELECT [Apno]
				,[Employer]
				,[Location]
				--,IsNull([SectStat],'0') as SectStat  
				,CASE 
					WHEN @IsReview = 1
						AND SectStat = '9'
						THEN 'H'
					ELSE IsNull(SectStat, '0')
					END AS SectStat
				,IsNull([Worksheet], 1) AS WorkSheet
				,[Phone]
				,[Supervisor]
				,[SupPhone]
				,[Dept]
				,[RFL]
				,IsNull([DNC], 0) AS DNC
				,IsNull([SpecialQ], 0) AS SpecialQ
				,IsNull([Ver_Salary], 0) AS Ver_Salary
				,[From_A]
				,[To_A]
				,[Position_A]
				,[Salary_A]
				,[From_V]
				,[To_V]
				,[Position_V]
				,[Salary_V]
				,IsNull([Emp_Type], 'N') AS Emp_Type
				,IsNull([Rel_Cond], 'N') AS Rel_Cond
				,[Rehire]
				,[Ver_By]
				,[Title]
				,[Priv_Notes]
				,[Pub_Notes]
				,Isnull([web_status], 0) AS web_status
				,IsNull([web_updated], Current_Timestamp) AS web_updated
				,IsNull([Includealias], 'y') AS [Includealias]
				,IsNull([Includealias2], 'y') AS [Includealias2]
				,IsNull([Includealias3], 'y') AS [Includealias3]
				,IsNull([Includealias4], 'y') AS [Includealias4]
				,[PendingUpdated]
				,IsNull([Time_In], Current_Timestamp) AS Time_In
				,[Last_Updated]
				,[city]
				,[state]
				,[zipcode]
				,[Investigator]
				,[EmployerID]
				,[InvestigatorAssigned]
				,[PendingChanged]
				,[TempInvestigator]
				,NULL --@userName as InUse  
				,IsNull([CreatedDate], Current_Timestamp) AS CreatedDate
				,[EnteredBy]
				,[EnteredDate]
				,IsNull([IsCamReview], 0) AS IsCamReview
				,[Last_Worked]
				,[ClientEmployerID]
				,[AutoFaxStatus]
				,IsNull([IsOnReport], 0) AS IsOnReport
				,IsNull([IsHidden], 0) AS IsHidden
				,IsNull([IsHistoryRecord], 0) AS IsHistoryRecord
				,[EmploymentStatus]
				,IsNull([IsOKtoContact], 0) AS [IsOKtoContact]
				,[OKtoContactInitial]
				,[EmplVerifyID]
				,[GetNextDate]
				,[SubStatusID]
				,[ClientAdjudicationStatus]
				,[ClientRefID]
				,IsNull([IsIntl], 0) AS IsIntl
				,[DateOrdered]
				,[OrderId]
				,[AdverseRFL]
				,Email
				,City_V 
				,State_V
				,Country_V
				,RecipientName_V 
			FROM dbo.PrecheckFramework_EmplStaging
			WHERE IsNull(SectionID, '') = ''
				AND apno = @apno
				AND FolderId = @folderId
				AND CreatedDate >= @DateEntered

			-- This takes care of the updates  
			UPDATE e
			SET [Employer] = stg.Employer
				,[Location] = stg.Location
				,[city] = stg.city
				,[state] = stg.[state]
				,[zipcode] = stg.[zipcode]
				,[Position_A] = stg.[Position_A]
				,[Position_V] = stg.[Position_V]
				,[SpecialQ] = IsNull(stg.[SpecialQ], 0)
				,[Ver_Salary] = IsNull(stg.[Ver_Salary], 0)
				,[AdverseRFL] = IsNull(stg.AdverseRFL, 0)
				,[From_A] = stg.[From_A]
				,[To_A] = stg.[To_A]
				,[From_V] = stg.[From_V]
				,[To_V] = stg.[To_V]
				,[Dept] = stg.[Dept]
				,[DNC] = IsNull(stg.[DNC], 0)
				,[RFL] = stg.[RFL]
				,[Phone] = stg.Phone
				,[Supervisor] = stg.[Supervisor]
				,[SupPhone] = stg.[SupPhone]
				,Priv_Notes = cast(stg.Priv_Notes AS VARCHAR(max)) -- + CHAR(13) + IsNull(cast(e.Priv_Notes as varchar(max)),'')  
				,Pub_Notes = cast(stg.Pub_Notes AS VARCHAR(max)) -- + CHAR(13) + IsNull(cast(e.Pub_Notes as varchar(max)),'')  
				,[IsOnReport] = IsNull(stg.[IsOnReport], 0)
				,[IsHidden] = IsNull(stg.[IsHidden], 0)
				,[IsHistoryRecord] = IsNull(stg.[IsHistoryRecord], 0)
				,[Title] = stg.[Title]
				,[Emp_Type] = IsNull(stg.[Emp_Type], 'N')
				,[Rel_Cond] = IsNull(stg.[Rel_Cond], 'N')
				,[Rehire] = stg.[Rehire]
				,[web_status] = Isnull(stg.[web_status], e.web_status)
				-- ,[SectStat] = IsNull(stg.[SectStat],'0')  
				,[SectStat] = CASE 
					WHEN @IsReview = 1
						AND stg.[SectStat] = '9'
						THEN 'H'
					ELSE IsNull(stg.[SectStat], '0')
					END
				,[Worksheet] = IsNull(stg.[Worksheet], 1)
				,[Ver_By] = stg.[Ver_By]
				,[IsOKtoContact] = IsNull(stg.[IsOKtoContact], 0)
				--,[Apno] = stg.Apno,e.Apno)  
				,[Investigator] = ISNULL(stg.[Investigator], e.[Investigator])
				,[IsIntl] = IsNull(stg.IsIntl, 0)
				--,[CreatedDate] = IsNull(stg.[CreatedDate],Current_Timestamp)  
				,[IsCamReview] = IsNull(stg.[IsCamReview], 0)
				--,[Time_In] = IsNull(stg.[Time_In],Current_Timestamp)           
				,[InUse] = NULL -- @UserName
				,InUse_TimeStamp = NULL
				,[Includealias] = IsNull(stg.[Includealias], 'y')
				,[Includealias2] = IsNull(stg.[Includealias2], 'y')
				,[Includealias3] = IsNull(stg.[Includealias3], 'y')
				,[Includealias4] = IsNull(stg.[Includealias4], 'y')
				,[web_updated] = IsNull(stg.[web_updated], Current_Timestamp)
				,Email = stg.Email
				,City_V = stg.City_V
				,State_V = stg.State_V
				,Country_V = stg.Country_V
				,RecipientName_V = stg.RecipientName_V
			FROM [dbo].[Empl] e
			JOIN [dbo].[PrecheckFramework_EmplStaging] stg ON stg.Apno = e.Apno
				AND stg.SectionId = e.EmplId
			WHERE IsNull(stg.SectionID, '') <> ''
				AND stg.FolderId = @folderId
				AND stg.CreatedDate >= @DateEntered

			DELETE
			FROM [dbo].[PrecheckFramework_EmplStaging]
			WHERE FolderId = @FolderId
				AND apno = @apno
				--and IsNull(SectionId,'') <> ''  
		END

		IF (charindex('LockAppl', @sectionList) = 0)
		BEGIN
			UPDATE [dbo].[Empl]
			SET Inuse = NULL
				,InUse_TimeStamp = NULL
			WHERE apno = @apno
				AND Inuse = @UserName
		END

		IF (@IsReview = 0) -- or @UnLockAppl = 1) --dhe changed on 03/21/2018
		BEGIN
			UPDATE [dbo].[Empl]
			SET SectStat = '9'
			WHERE apno = @apno
				AND SectStat = 'H'
		END
		ELSE IF (@IsReview = 1) --dhe changed on 03/21/2018
		BEGIN
			UPDATE [dbo].[Empl]
			SET SectStat = 'H'
			WHERE apno = @apno
				AND SectStat = '9'
		END
	END

	-- Personal Reference ----  
	IF (charindex('PersRef', @sectionList) > 0)
	BEGIN
		IF (
				SELECT count(folderId)
				FROM [dbo].[PrecheckFramework_PersRefStaging]
				WHERE @folderId = folderId
					AND apno = @apno
					AND CreatedDate >= @DateEntered
				) > 0
		BEGIN
			UPDATE pr
			SET [IsCAMReview] = IsNull(stg.[IsCAMReview], 0)
				,IsHidden = IsNull(stg.IsHidden, 0)
				,Name = stg.Name
				,Investigator = ISNULL(stg.Investigator, pr.Investigator)
				,IsOnReport = IsNull(stg.IsOnReport, 0)
				,Phone = stg.Phone
				,Rel_V = stg.Rel_V
				,Years_V = stg.Years_V
				,Priv_Notes = cast(stg.Priv_Notes AS VARCHAR(max))
				,Pub_Notes = cast(stg.Pub_Notes AS VARCHAR(max))
				,Web_Status = IsNull(stg.Web_Status, pr.Web_Status)
				--,SectStat = IsNull(stg.SectStat,'0') 
				,[SectStat] = CASE 
					WHEN @IsReview = 1
						AND stg.[SectStat] = '9'
						THEN 'H'
					ELSE IsNull(stg.[SectStat], '0')
					END
				,InUse = NULL -- @UserName
				,InUse_TimeStamp = NULL
				,Email = stg.Email
				,JobTitle = stg.JobTitle
			FROM [dbo].[PersRef] pr
			JOIN [dbo].[PrecheckFramework_PersRefStaging] stg ON stg.Apno = pr.Apno
				AND stg.SectionId = pr.PersRefId
			WHERE IsNull(stg.SectionID, '') <> ''
				AND stg.FolderId = @folderId
				AND stg.CreatedDate >= @DateEntered

			INSERT INTO dbo.PersRef (
				[APNO]
				,[SectStat]
				,[Worksheet]
				,[Name]
				,[Phone]
				,[Rel_V]
				,[Years_V]
				,[Priv_Notes]
				,[Pub_Notes]
				,[Last_Updated]
				,[Investigator]
				,[Emplid]
				,[PendingUpdated]
				,[Web_Status]
				,[web_updated]
				,[time_in]
				,[InUse]
				,[CreatedDate]
				,[Last_Worked]
				,[IsCAMReview]
				,[IsOnReport]
				,[IsHidden]
				,[IsHistoryRecord]
				,[ClientAdjudicationStatus]
				,Email
				,JobTitle
				)
			SELECT [APNO]
				--,IsNull([SectStat],'0')  
				,CASE 
					WHEN @IsReview = 1
						AND SectStat = '9'
						THEN 'H'
					ELSE IsNull(SectStat, '0')
					END AS SectStat
				,IsNull([Worksheet], 1)
				,[Name]
				,[Phone]
				,[Rel_V]
				,[Years_V]
				,[Priv_Notes]
				,[Pub_Notes]
				,[Last_Updated]
				,[Investigator]
				,[Emplid]
				,[PendingUpdated]
				,IsNull([Web_Status], 0)
				,[web_updated]
				,Current_Timestamp
				,NULL --[InUse]  
				,Current_Timestamp
				,[Last_Worked]
				,IsNull([IsCAMReview], 0)
				,IsNull([IsOnReport], 0)
				,IsNull([IsHidden], 0)
				,IsNull([IsHistoryRecord], 0)
				,[ClientAdjudicationStatus]
				,Email
				,JobTitle
			FROM [dbo].[PrecheckFramework_PersRefStaging]
			WHERE IsNull(SectionID, '') = ''
				AND apno = @apno
				AND FolderId = @folderId
				AND CreatedDate >= @DateEntered

			--Update [dbo].PersRef
			--Set Inuse = NULL, InUse_TimeStamp=NULL
			--WHERE Inuse = @UserName
			DELETE
			FROM [dbo].[PrecheckFramework_PersRefStaging]
			WHERE FolderId = @FolderId
				AND apno = @apno
				--and IsNull(SectionId,'') <> ''  
		END

		IF (charindex('LockAppl', @sectionList) = 0)
		BEGIN
			UPDATE [dbo].PersRef
			SET Inuse = NULL
				,InUse_TimeStamp = NULL
			WHERE apno = @apno
				AND Inuse = @UserName
		END

		IF (@IsReview = 0) -- or @UnLockAppl = 1) --dhe changed on 03/21/2018
		BEGIN
			UPDATE [dbo].[PersRef]
			SET SectStat = '9'
			WHERE apno = @apno
				AND SectStat = 'H'
		END
		ELSE IF (@IsReview = 1) --dhe changed on 03/21/2018
		BEGIN
			UPDATE [dbo].[PersRef]
			SET SectStat = 'H'
			WHERE apno = @apno
				AND SectStat = '9'
		END
	END

	IF (charindex('Licensing', @sectionList) > 0)
	BEGIN
		IF (
				SELECT count(folderId)
				FROM [dbo].[PrecheckFramework_ProfLicStaging]
				WHERE @folderId = folderId
					AND apno = @apno
					AND CreatedDate >= @DateEntered
				) > 0
		BEGIN
			UPDATE pl
			SET Lic_Type = stg.Lic_Type
				,Lic_Type_V = stg.Lic_Type_V
				,Lic_No = stg.Lic_No
				,Lic_No_V = stg.Lic_No_V
				,STATE = stg.STATE
				,State_V = stg.State_V
				,Contact_Name = stg.Contact_Name
				,Contact_Title = stg.Contact_Title
				,Contact_Date = stg.Contact_Date
				,Investigator = ISNULL(stg.Investigator, pl.Investigator)
				,Expire = stg.Expire
				,Expire_V = stg.Expire_V
				,[Year] = stg.[Year]
				,Year_V = stg.Year_V
				,[Status] = stg.[Status]
				,Status_A = stg.Status_A
				,Organization = stg.Organization
				,Priv_Notes = cast(stg.Priv_Notes AS VARCHAR(max))
				,Pub_Notes = cast(stg.Pub_Notes AS VARCHAR(max))
				,IsOnReport = IsNull(stg.IsOnReport, 0)
				,IsHidden = IsNull(stg.IsHidden, 0)
				,IsCAMReview = IsNull(stg.IsCAMReview, 0)
				,Web_Status = IsNull(stg.Web_Status, pl.Web_status)
				--,SectStat = IsNull(stg.SectStat,'0')  
				,[SectStat] = CASE 
					WHEN @IsReview = 1
						AND stg.[SectStat] = '9'
						THEN 'H'
					ELSE IsNull(stg.[SectStat], '0')
					END
				,InUse = NULL --@UserName 
				,InUse_TimeStamp = NULL
				,DisclosedPastAction = IsNull(stg.DisclosedPastAction, 0)
				,LicenseTypeId = stg.LicenseTypeId
			FROM [dbo].[ProfLic] pl
			JOIN [dbo].[PrecheckFramework_ProfLicStaging] stg ON stg.Apno = pl.Apno
				AND stg.SectionId = pl.ProfLicId
			WHERE IsNull(stg.SectionID, '') <> ''
				AND stg.FolderId = @folderId
				AND stg.Apno = @apno
				AND stg.CreatedDate >= @DateEntered

			INSERT INTO dbo.ProfLic (
				[Apno]
				,[SectStat]
				,[Worksheet]
				,[Lic_Type]
				,[Lic_No]
				,[Year]
				,[Expire]
				,[State]
				,[Status]
				,[Priv_Notes]
				,[Pub_Notes]
				,[Web_status]
				,[includealias]
				,[includealias2]
				,[includealias3]
				,[includealias4]
				,[pendingupdated]
				,[web_updated]
				,[time_in]
				,[Organization]
				,[Contact_Name]
				,[Contact_Title]
				,[Contact_Date]
				,[Investigator]
				,[Last_Updated]
				,[InUse]
				,[CreatedDate]
				,[Status_A]
				,[ToPending]
				,[FromPending]
				,[Last_Worked]
				,[IsCAMReview]
				,[IsOnReport]
				,[IsHidden]
				,[IsHistoryRecord]
				,[ClientAdjudicationStatus]
				,[ClientRefID]
				,[Lic_Type_V]
				,[Lic_No_V]
				,[State_V]
				,[Expire_V]
				,[Year_V]
				,[GenerateCertificate]
				,[CertificateAvailabilityStatus]
				,DisclosedPastAction
				,LicenseTypeId
				)
			SELECT [Apno]
				--,IsNull(SectStat,'0')  
				,CASE 
					WHEN @IsReview = 1
						AND SectStat = '9'
						THEN 'H'
					ELSE IsNull(SectStat, '0')
					END AS SectStat
				,IsNull(WorkSheet, 1)
				,[Lic_Type]
				,[Lic_No]
				,[Year]
				,[Expire]
				,[State]
				,[Status]
				,[Priv_Notes]
				,[Pub_Notes]
				,IsNull(Web_Status, 0)
				,[includealias]
				,[includealias2]
				,[includealias3]
				,[includealias4]
				,[pendingupdated]
				,[web_updated]
				,Current_Timestamp
				,[Organization]
				,[Contact_Name]
				,[Contact_Title]
				,[Contact_Date]
				,[Investigator]
				,[Last_Updated]
				,NULL --@userName as InUse  
				,Current_Timestamp
				,[Status_A]
				,[ToPending]
				,[FromPending]
				,[Last_Worked]
				,IsNull([IsCAMReview], 0)
				,IsNull([IsOnReport], 0)
				,IsNull([IsHidden], 0)
				,IsNull([IsHistoryRecord], 0)
				,[ClientAdjudicationStatus]
				,[ClientRefID]
				,[Lic_Type_V]
				,[Lic_No_V]
				,[State_V]
				,[Expire_V]
				,[Year_V]
				,IsNull([GenerateCertificate], 0)
				,IsNull([CertificateAvailabilityStatus], 2)
				,DisclosedPastAction
				,LicenseTypeId
			FROM dbo.PrecheckFramework_ProfLicStaging plstg
			WHERE IsNull(SectionID, '') = ''
				AND apno = @apno
				AND plstg.FolderId = @folderId
				AND plstg.CreatedDate >= @DateEntered

			--Update [dbo].ProfLic
			--Set Inuse = NULL, InUse_TimeStamp=NULL
			--WHERE Inuse = @UserName
			DELETE
			FROM [dbo].[PrecheckFramework_ProfLicStaging]
			WHERE FolderId = @FolderId
				AND apno = @apno
				--and IsNull(SectionId,'') <> ''  
		END

		IF (charindex('LockAppl', @sectionList) = 0)
		BEGIN
			UPDATE [dbo].ProfLic
			SET Inuse = NULL
				,InUse_TimeStamp = NULL
			WHERE apno = @apno
				AND Inuse = @UserName
		END

		IF (@IsReview = 0) -- or @UnLockAppl = 1) --dhe changed on 03/21/2018
		BEGIN
			UPDATE [dbo].[ProfLic]
			SET SectStat = '9'
			WHERE apno = @apno
				AND SectStat = 'H'
		END
		ELSE IF (@IsReview = 1) --dhe changed on 03/21/2018
		BEGIN
			UPDATE [dbo].[ProfLic]
			SET SectStat = 'H'
			WHERE apno = @apno
				AND SectStat = '9'
		END
	END

	IF (charindex('PublicRecords', @sectionList) > 0)
	BEGIN
		IF (
				SELECT count(folderId)
				FROM dbo.PrecheckFramework_PublicRecordsStaging
				WHERE folderId = @folderId
					AND apno = @apno
					AND CreatedDate >= @DateEntered
				) > 0
		BEGIN
			EXEC DBO.[CreateCrims_FromStaging] @apno
				,@FolderId
				,@DateEntered
		END


			--  /*Auto-Clear Lead Step Start - schapyala on 05/19/2020 */

		Declare @SkipAutoClear Bit = 0 

		--Skip AutoClear if Admitted Record
		--Select @SkipAutoClear = Case When IsNull(AdmittedRecord,0) = 1 or IsHistoryRecord = 1 then cast(1 as bit) else cast(0 as bit) end
		--From #tmpCrim D 

		 -- DDegenar - 9/20/2021 No longer using #tmpCrim but are using Apno now, so modified
		 Select @SkipAutoClear = Case When IsNull(AdmittedRecord,0) = 1 or IsHistoryRecord = 1 then cast(1 as bit) else cast(0 as bit) end  
		 From dbo.Crim D 
         where D.Apno = @apno 
		
		--Skip AutoClear if ZipCrim clients
		Select @SkipAutoClear = Case When AffiliateID IN (249) --249 (everifile/zipcrim)
											  Then cast(1 as bit) else cast(0 as bit) End
		From DBO.APPL A inner Join dbo.CLient C on A.CLNO = C.CLNO
		Where APNO = @Apno
	
		--Qualify for AutoClears only when there is [no Self-Disclosure or Past COnvictions] and for NON-ZipCrim Clients
		-- DDegenar - 9/20/2021 No longer using #tmpCrim but are using Crim now, so modified
		IF @SkipAutoClear = 0
			--Logic for setting Clear status to Y - "Auto Clear - Intellicorp" for qualified counties by partner (5 - Intellicorp) table configuration
			UPDATE C Set [Clear] = Case When PJ.County IS NULL then [Clear] else 'Y' end,
			Priv_Notes = Case When PJ.County IS NULL then Priv_Notes else (CAST( CURRENT_TIMESTAMP as varchar) + ' - Jurisdiction Qualified after AI Review Process for Intellicorp AutoClear service;  ' + isnull(Priv_Notes,'')) End
			--FROM #tmpCrim C LEFT JOIN dbo.County_PartnerJurisdiction PJ on C.CNTY_NO = PJ.CNTY_NO
			FROM dbo.Crim C  LEFT JOIN dbo.County_PartnerJurisdiction PJ on C.CNTY_NO = PJ.CNTY_NO 
			WHERE PartnerID in (4) -- Intellicorp 
			AND isnull([Clear],'') in ('','R','H')
			and c.Apno = @apno
	

	  /*Auto-Clear Lead Step END - schapyala on 05/19/2020 */
	  



		--Temp solution to update sex offender
		--added USFederal, FedBankruptcy, and USCivil to this logic - schapyala 02/05/14
		IF (@IsReview = 1)
		BEGIN
			UPDATE [dbo].[Crim]
			SET Clear = 'H'
			WHERE cnty_no IN (
					2480
					,2738
					,229
					,2737
					)
				AND Apno = @apno
				AND Isnull(Clear, '') = ''
				AND ishidden = 0 --added by schapyala to only set it to R when Ishidden=0 (not in unsed) - 07/06/2017
		END
		ELSE
		BEGIN
			UPDATE [dbo].[Crim]
			SET Clear = 'R'
			WHERE cnty_no IN (
					2480
					,2738
					,229
					,2737
					)
				AND Apno = @apno
				AND Isnull(Clear, '') = ''
				AND ishidden = 0 --added by schapyala to only set it to R when Ishidden=0 (not in unsed) - 07/06/2017
		END

		IF (@IsReview = 0) -- or @UnLockAppl = 1) --dhe changed on 03/21/2018
		BEGIN
			UPDATE [dbo].[Crim]
			SET Clear = 'R'
			WHERE apno = @apno
				AND Clear = 'H'
		END
		ELSE IF (@IsReview = 1) --dhe changed on 03/21/2018
		BEGIN
			UPDATE [dbo].[Crim]
			SET Clear = 'H'
			WHERE apno = @apno
				AND Clear = 'R'
		END
	END

	--reviewed button
	IF (charindex('Education', @sectionList) > 0)
	BEGIN
		IF (
				SELECT count(folderId)
				FROM [dbo].[PrecheckFramework_EducatStaging]
				WHERE @folderId = folderId
					AND apno = @apno
					AND CreatedDate >= @DateEntered
				) > 0
		BEGIN
			UPDATE edu
			SET [School] = edstg.[School]
				,[State] = edstg.[State]
				,[Phone] = edstg.[Phone]
				,[Degree_A] = edstg.[Degree_A]
				,[Studies_A] = edstg.[Studies_A]
				,[From_A] = edstg.[From_A]
				,[To_A] = edstg.[To_A]
				,[Name] = edstg.[Name]
				,[Degree_V] = edstg.[Degree_V]
				,[Studies_V] = edstg.[Studies_V]
				,[From_V] = edstg.[From_V]
				,[To_V] = edstg.[To_V]
				,[Contact_Name] = edstg.[Contact_Name]
				,[Contact_Title] = edstg.[Contact_Title]
				,[Contact_Date] = edstg.[Contact_Date]
				,[Investigator] = ISNULL(edstg.[Investigator], edu.investigator)
				,Priv_Notes = cast(edstg.Priv_Notes AS VARCHAR(max)) -- + CHAR(13) + IsNull(cast(edu.Priv_Notes as varchar(max)),'')  
				,Pub_Notes = cast(edstg.Pub_Notes AS VARCHAR(max)) -- + CHAR(13) + IsNull(cast(edu.Pub_Notes as varchar(max)),'')  
				,[web_status] = Isnull(edstg.[web_status], edu.web_status)
				-- ,[SectStat] = IsNull(edstg.[SectStat],'0')  
				,[SectStat] = CASE 
					WHEN @IsReview = 1
						AND edstg.[SectStat] = '9'
						THEN 'H'
					ELSE IsNull(edstg.[SectStat], '0')
					END
				,[Worksheet] = IsNull(edstg.[Worksheet], 1)
				,[Includealias] = IsNull(edstg.[Includealias], 'y')
				,[Includealias2] = IsNull(edstg.[Includealias2], 'y')
				,[Includealias3] = IsNull(edstg.[Includealias3], 'y')
				,[Includealias4] = IsNull(edstg.[Includealias4], 'y')
				-- ,[pendingupdated] = <pendingupdated, datetime,>  
				,[web_updated] = IsNull(edstg.[web_updated], Current_Timestamp)
				--,[Time_In] = IsNull(edstg.[Time_In],Current_Timestamp)           
				,[InUse] = NULL --@userName  
				,InUse_TimeStamp = NULL
				--,[Last_Updated] = <Last_Updated, datetime,>  
				,[city] = edstg.[city]
				,[zipcode] = edstg.[zipcode]
				,[CampusName] = edstg.[CampusName]
				--,[CreatedDate] = IsNull(edstg.[CreatedDate],Current_Timestamp)  
				--,[ToPending] = <ToPending, datetime,>  
				--,[FromPending] = <FromPending, datetime,>  
				--,[Completed] = <Completed, bit,>  
				--,[Last_Worked] = <Last_Worked, datetime,>  
				--,[SchoolID] = <SchoolID, int,>  
				,[IsCamReview] = IsNull(edstg.[IsCamReview], 0)
				,[IsOnReport] = IsNull(edstg.[IsOnReport], 0)
				,[IsHidden] = IsNull(edstg.[IsHidden], 0)
				,[IsHistoryRecord] = IsNull(edstg.[IsHistoryRecord], 0)
				,[HasGraduated] = IsNull(edstg.[HasGraduated], 0)
				,[HighestCompleted] = edstg.[HighestCompleted]
				--,[EducatVerifyID] = <EducatVerifyID, int,>  
				--,[GetNextDate] = <GetNextDate, datetime,>  
				--,[SubStatusID] = <SubStatusID, int,>  
				,[ClientAdjudicationStatus] = IsNull(edstg.[ClientAdjudicationStatus], edu.[ClientAdjudicationStatus])
				--,[ClientRefID] = <ClientRefID, varchar(25),>  
				,[IsIntl] = Isnull(edstg.[IsIntl], 0)
			--,[DateOrdered] = <DateOrdered, datetime,>  
			--,[OrderId] = <OrderId, varchar(20),>  
			    ,City_V = edstg.City_V
				,State_V = edstg.State_V
				,Country_V = edstg.Country_V
				,GraduationDate_V = edstg.GraduationDate_V
				,Recipientname_V = edstg.Recipientname_V
			FROM [dbo].[Educat] edu
			JOIN [dbo].[PrecheckFramework_EducatStaging] edstg ON edstg.Apno = edu.Apno
				AND edstg.SectionId = edu.EducatId
			WHERE IsNull(edstg.SectionID, '') <> ''
				AND edstg.FolderId = @folderId
				AND edstg.CreatedDate >= @DateEntered

			INSERT INTO dbo.Educat (
				[APNO]
				,[School]
				,[SectStat]
				,[Worksheet]
				,[State]
				,[Phone]
				,[Degree_A]
				,[Studies_A]
				,[From_A]
				,[To_A]
				,[Name]
				,[Degree_V]
				,[Studies_V]
				,[From_V]
				,[To_V]
				,[Contact_Name]
				,[Contact_Title]
				,[Contact_Date]
				,[Investigator]
				,[Priv_Notes]
				,[Pub_Notes]
				,[web_status]
				,[includealias]
				,[includealias2]
				,[includealias3]
				,[includealias4]
				,[pendingupdated]
				,[web_updated]
				,[Time_In]
				,[Last_Updated]
				,[city]
				,[zipcode]
				,[CampusName]
				,[InUse]
				,[CreatedDate]
				,[ToPending]
				,[FromPending]
				,[Completed]
				,[Last_Worked]
				,[SchoolID]
				,[IsCAMReview]
				,[IsOnReport]
				,[IsHidden]
				,[IsHistoryRecord]
				,[HasGraduated]
				,[HighestCompleted]
				,[EducatVerifyID]
				,[GetNextDate]
				,[SubStatusID]
				,[ClientAdjudicationStatus]
				,[ClientRefID]
				,[IsIntl]
				,[DateOrdered]
				,[OrderId]
				,City_V 
				,State_V
				,Country_V
				,GraduationDate_V
				,RecipientName_V
				)
			SELECT [APNO]
				,[School]
				-- ,IsNull([SectStat],0)  
				,CASE 
					WHEN @IsReview = 1
						AND SectStat = '9'
						THEN 'H'
					ELSE IsNull(SectStat, '0')
					END AS SectStat
				,IsNull([Worksheet], 1)
				,[State]
				,[Phone]
				,[Degree_A]
				,[Studies_A]
				,[From_A]
				,[To_A]
				,[Name]
				,[Degree_V]
				,[Studies_V]
				,[From_V]
				,[To_V]
				,[Contact_Name]
				,[Contact_Title]
				,[Contact_Date]
				,[Investigator]
				,[Priv_Notes]
				,[Pub_Notes]
				,IsNull([web_status], 0)
				,IsNull([includealias], 'y')
				,IsNull([includealias2], 'y')
				,IsNull([includealias3], 'y')
				,IsNull([includealias4], 'y')
				,[pendingupdated]
				,[web_updated]
				,IsNull([Time_In], Current_Timestamp)
				,[Last_Updated]
				,[city]
				,[zipcode]
				,[CampusName]
				,NULL --@userName as InUse  
				,IsNull([CreatedDate], Current_Timestamp)
				,[ToPending]
				,[FromPending]
				,[Completed]
				,[Last_Worked]
				,[SchoolID]
				,IsNull([IsCAMReview], 0)
				,IsNull([IsOnReport], 0)
				,IsNull([IsHidden], 0)
				,IsNull([IsHistoryRecord], 0)
				,IsNull([HasGraduated], 0)
				,[HighestCompleted]
				,[EducatVerifyID]
				,[GetNextDate]
				,[SubStatusID]
				,[ClientAdjudicationStatus]
				,[ClientRefID]
				,IsNull([IsIntl], 0)
				,[DateOrdered]
				,[OrderId]
				,City_V 
				,State_V
				,Country_V
				,GraduationDate_V
				,RecipientName_V
			FROM dbo.PrecheckFramework_EducatStaging e
			WHERE IsNull(SectionID, '') = ''
				AND apno = @apno
				AND e.FolderId = @folderId
				AND e.CreatedDate >= @DateEntered

			--Update [dbo].Educat
			--Set Inuse = NULL, InUse_TimeStamp=NULL
			--WHERE Inuse = @UserName			 
			DELETE
			FROM [dbo].[PrecheckFramework_EducatStaging]
			WHERE FolderId = @FolderId
				AND apno = @apno
				--and IsNull(SectionId,'') <> ''  
		END

		IF (charindex('LockAppl', @sectionList) = 0)
		BEGIN
			UPDATE [dbo].Educat
			SET Inuse = NULL
				,InUse_TimeStamp = NULL
			WHERE apno = @apno
				AND Inuse = @UserName
		END

		IF (@IsReview = 0) -- or @UnLockAppl = 1) --dhe changed on 03/21/2018
		BEGIN
			UPDATE [dbo].[Educat]
			SET SectStat = '9'
			WHERE apno = @apno
				AND SectStat = 'H'
		END
		ELSE IF (@IsReview = 1) --dhe changed on 03/21/2018
		BEGIN
			UPDATE [dbo].[Educat]
			SET SectStat = 'H'
			WHERE apno = @apno
				AND SectStat = '9'
		END
	END

	-- MVR  
	IF (charindex('MVR', @sectionList) > 0)
	BEGIN
		--IF (SELECT count(folderId) FROM dbo.PrecheckFramework_MVRPIDSCStaging mvrstg WHERE @folderId = folderId and apno = @apno and Type='MVR') > 0  
		--BEGIN  
		UPDATE mvr
		SET [SectStat] = mvrstg.SectStat
			--,Report = IsNull(mvrstg.Report,IsNull(cast(mvr.Report as varchar(max)),''))  
			,Report = IsNull(mvrstg.Report, mvr.Report)
			--,[Web_status] = mvrstg.Web_Status     
			,[InUse] = NULL --@UserName 
			,IsHidden = mvrstg.IsHidden
		FROM [dbo].[DL] mvr
		JOIN dbo.PrecheckFramework_MVRPIDSCStaging mvrstg ON mvrstg.Apno = mvr.Apno
		WHERE mvrstg.Apno = @apno
			AND mvrstg.[Type] = 'MVR'
			AND mvrstg.FolderId = @FolderId
			AND mvrstg.CreatedDate >= @DateEntered

		DELETE
		FROM dbo.PrecheckFramework_MVRPIDSCStaging
		WHERE FolderId = @FolderId
			AND IsNull(Apno, '') <> ''
			AND Type = 'MVR'
	END

	IF (charindex('SanctionCheck', @sectionList) > 0)
	BEGIN
		--IF (SELECT count(folderId) FROM dbo.PrecheckFramework_MVRPIDSCStaging mvrstg WHERE folderId = @folderId  and apno = @apno and Type='SC') > 0  
		--BEGIN  
		UPDATE sc
		SET [SectStat] = mvrstg.SectStat
			--,Report = IsNull(IsNull(mvrstg.Report,''),IsNull(cast(sc.Report as varchar(max)),''))            
			,Report = IsNull(mvrstg.Report, sc.Report)
			,[InUse] = NULL --@UserName 
			,IsHidden = mvrstg.IsHidden
		FROM [dbo].[MedInteg] sc
		INNER JOIN dbo.PrecheckFramework_MVRPIDSCStaging mvrstg ON mvrstg.Apno = sc.Apno
		--and   
		-- mvrstg.FolderId = @FolderId       
		WHERE mvrstg.Apno = @apno
			AND mvrstg.[Type] = 'SC'
			AND mvrstg.FolderId = @FolderId
			AND mvrstg.CreatedDate >= @DateEntered

		DELETE
		FROM dbo.PrecheckFramework_MVRPIDSCStaging
		WHERE FolderId = @FolderId
			AND IsNull(Apno, '') <> ''
			AND Type = 'SC'
	END

	IF (charindex('Credit', @sectionList) > 0)
	BEGIN
		IF (
				SELECT count(folderId)
				FROM dbo.PrecheckFramework_MVRPIDSCStaging mvrstg
				WHERE folderId = @folderId
					AND apno = @apno
					AND Type = 'CR'
					AND CreatedDate >= @DateEntered
				) > 0
		BEGIN
			UPDATE cr
			SET [SectStat] = mvrstg.SectStat
				--,Report = IsNull(mvrstg.Report,IsNull(cast(cr.Report as varchar(max)),''))  
				,Report = IsNull(mvrstg.Report, cr.Report)
				,[InUse] = NULL --@UserName 
				,IsHidden = mvrstg.IsHidden
			FROM [dbo].[Credit] cr
			JOIN dbo.PrecheckFramework_MVRPIDSCStaging mvrstg ON mvrstg.Apno = cr.Apno
			--and   
			-- mvrstg.FolderId = @FolderId       
			WHERE mvrstg.Apno = @apno
				AND mvrstg.[Type] = 'CR'
				AND mvrstg.FolderId = @FolderId
				AND CR.RepType = 'C'
				AND mvrstg.CreatedDate >= @DateEntered

			DELETE
			FROM dbo.PrecheckFramework_MVRPIDSCStaging
			WHERE FolderId = @FolderId
				AND IsNull(Apno, '') <> ''
				AND Type = 'CR'
		END
	END

	IF (charindex('PositiveID', @sectionList) > 0)
	BEGIN
		IF (
				SELECT count(folderId)
				FROM dbo.PrecheckFramework_MVRPIDSCStaging mvrstg
				WHERE folderId = @folderId
					AND apno = @apno
					AND Type = 'PID'
					AND CreatedDate >= @DateEntered
				) > 0
		BEGIN
			UPDATE cr
			SET [SectStat] = mvrstg.SectStat
				--,Report = IsNull(mvrstg.Report,IsNull(cast(cr.Report as varchar(max)),''))  
				,Report = IsNull(mvrstg.Report, cr.Report)
				,[InUse] = NULL --@UserName
				,IsHidden = mvrstg.IsHidden
			FROM [dbo].[Credit] cr
			JOIN dbo.PrecheckFramework_MVRPIDSCStaging mvrstg ON mvrstg.Apno = cr.Apno
			--and   
			-- mvrstg.FolderId = @FolderId       
			WHERE mvrstg.Apno = @apno
				AND mvrstg.[Type] = 'PID'
				AND mvrstg.FolderId = @FolderId
				AND CR.RepType = 'S'
				AND mvrstg.CreatedDate >= @DateEntered

			DELETE
			FROM dbo.PrecheckFramework_MVRPIDSCStaging
			WHERE FolderId = @FolderId
				AND IsNull(Apno, '') <> ''
				AND Type = 'PID'
		END
	END

	IF (
			charindex('Employment', @sectionList) > 0
			AND charindex('Education', @sectionList) > 0
			AND charindex('Licensing', @sectionList) > 0
			AND charindex('PersRef', @sectionList) > 0
			)
	BEGIN
		UPDATE [dbo].[Empl]
		SET SectStat = '9'
		WHERE apno = @apno
			AND SectStat = 'H'

		UPDATE [dbo].[Educat]
		SET SectStat = '9'
		WHERE apno = @apno
			AND SectStat = 'H'

		UPDATE [dbo].[ProfLic]
		SET SectStat = '9'
		WHERE apno = @apno
			AND SectStat = 'H'

		UPDATE [dbo].[Persref]
		SET SectStat = '9'
		WHERE apno = @apno
			AND SectStat = 'H'

		UPDATE [dbo].[Crim]
		SET Clear = 'R'
		WHERE apno = @apno
			AND Clear = 'H'
	END

	--UNLOCK app (Master Lock)    
	IF (
			@UnLockAppl = 1
			OR @RerunPID = 1
			)
		UPDATE dbo.Appl
		--schapyala added PID Rerun Logic to set Inuse on 7/16/2019 to support Oasis to ZipCrim Project
		SET InUse = CASE 
				WHEN @RerunPID = 1
					THEN 'PID_S'
				ELSE NULL
				END
		WHERE apno = @apno
END
