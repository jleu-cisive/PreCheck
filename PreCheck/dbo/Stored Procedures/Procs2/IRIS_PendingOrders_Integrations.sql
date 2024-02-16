/******************************************************************
[dbo].[IRIS_PendingOrders_Integrations] 5501, 0, 1
[dbo].[IRIS_PendingOrders_Integrations] 1738,1,1
[dbo].[IRIS_PendingOrders_Integrations] 1376,0,1
exec [dbo].[IRIS_PendingOrders_Integrations] 599,0,1
exec [dbo].[IRIS_PendingOrders_Integrations] 237,0,1
[dbo].[IRIS_PendingOrders_Integrations] 2480, 0,0
[dbo].[IRIS_PendingOrders_Integrations] null,1,1
--For HDT 22307:Setting up STWD GA and GCIC through to current SJV Integration
----AmyLiu changed on 01/06/2022 modified the knownhit per Doug's instruction.
--Modified by Lalit to turn on middle names on 10-august-2022 for #58292
--Modified by Lalit to send cientid and affiliateid on 07-October-2022 for #59433
-- Modified By Lalit on 26 june 2023 for adding Infinity vendor account for #27740
-- Modified By Lalit on 15 Dec 2023 for #114356
-- Modified to exclude SOR going to Scrappy on 19 dec 2023
*********************************************************************/

CREATE procedure [dbo].[IRIS_PendingOrders_Integrations] (@County int = null,@CountyList BIT = 0,@ForIntegration BIT = 0)   
AS  
SET NOCOUNT ON
IF @CountyList = 1 -- Return a distinct list of counties
	BEGIN

	DECLARE @time time(3) = Current_TimeStamp;
	DECLARE @DayOfWeek INT = DATEPART(dw, Current_TimeStamp) -- 1 = Sunday; 7 = Saturday
	DECLARE @OffPeak BIT = 0

	--Set OffPeak flag to True on Weekends and all other times with the exception of between 4 AM to 5 PM Alamogordo times on weekdays
	--offpeak hours changed as per the website ,its 7pm to 6 am alamo time as on 02/19/2018
	SET @OffPeak = CASE WHEN @DayOfWeek IN (1,7) THEN 1
						WHEN (@time > '6 AM' and @time <'7 PM') THEN 0
						ELSE 1
						END

		Declare  @tmpCountyList TABLE
		(
			Section VARCHAR(10),
			Cnty_No int,
			VendorAccountId int
		)

		INSERT INTO @tmpCountyList
		SELECT DISTINCT  'Crim' Section,Cnty_No,IsNull(VendorMapping.VendorId,
		case when m.SectionKeyID='2480' then 13 else 16 end)
		FROM  
		( 
		SELECT Cnty_No ,vendorid 
		FROM Crim C WITH (NOLOCK) 
		INNER JOIN Appl A WITH (NOLOCK) ON A.APNO = C.APNO  
		INNER JOIN dbo.ApplAlias_Sections AS S (NOLOCK) ON S.SectionKeyID = C.CrimID AND S.ApplSectionID = 5 AND S.IsActive=1-- crim
		INNER JOIN ApplAlias AS AA(NOLOCK) ON AA.ApplAliasID = S.ApplAliasID
		WHERE (C.Clear IN( 'O','W')) 
		  AND (A.InUse IS NULL) 
		  AND A.ApStatus in ('p','w')
		  AND c.ishidden = 0   
		  AND A.CLNO NOT IN (3468,2135) -- Added this by Santosh on 06/24/13 to exclude BAD APPS 
		) Qry INNER JOIN DataXtract_RequestMapping M ON cast(Qry.Cnty_No AS VARCHAR)= SectionKeyID 
		inner join  DataXtract_AIMS_Schedule ds on ds.DataXtract_RequestMappingXMLID =M.DataXtract_RequestMappingXMLID  --added to run crims based on schedule on 5/07/2018 :sahithi
		LEFT JOIN dbo.Dataxtract_VendorRequestMapping VendorMapping ON M.DataXtract_RequestMappingXMLID = VendorMapping.DataXtract_RequestMappingId
		WHERE M.Section = 'Crim' 
		AND ds.NextRunTime <=current_timestamp -- added for getting crims based on schedule time -- sahithi 5/7/2018
		  AND IsAutomationEnabled = 1
		  AND (CASE WHEN (OffPeakHoursOnly =1 AND  @OffPeak = 0) THEN 0 ELSE 1 END) = 1 -- only schedule these between 6 PM AND 6 AM CST
		
		-- This makes sure that the Integration searches that are stuck for more than 45 minutes are released and resent
		--schapyala 08/18/2017
		declare @CurrentDate DateTime2 = current_timestamp
--		if (year(CURRENT_TIMESTAMP)%4 = 0)
--       set @CurrentDate = DATEADD(DAY,-1,CURRENT_TIMESTAMP)
--else
--       set @CurrentDate = CURRENT_TIMESTAMP     
      -- set @defaultOrderedDate = replace(@defaultOrderedDate,year(@defaultOrderedDate),'1900')

		
		update c
		set Ordered = null, InUseByIntegration = null
		FROM crim C
		WHERE (C.Clear IN( 'M')) 
			AND c.ishidden = 0   
			AND DATEDIFF( MINUTE,CAST(ordered AS DATETIME),replace(@CurrentDate,year(@CurrentDate),'1900'))>45
			AND c.DeliveryMethod = 'Integration'	
		----
				  		
		INSERT INTO @tmpCountyList
        SELECT DISTINCT 'Crim' AS Section,Cnty_No,
		Case VendorID when 20 then 7
					  When 5679614 then 10
					  When 5679569 then 11
					  WHEN 6351837 THEN 12
					  WHEN 9657688 THEN 18 --Reliance
					  WHEN 10875299 THEN 20 -- OMNI
					  WHEN 11064021 THEN 21 -- SecuritecQA
					  WHEN 11149926 THEN 22 -- SecuritecRawData
					  WHEN 14206014 THEN 24 -- Infinity  --added by Lalit for #27740
		End
		FROM Crim C WITH (NOLOCK) 
		INNER JOIN Appl A WITH (NOLOCK) ON A.APNO = C.APNO 
		INNER JOIN dbo.ApplAlias_Sections AS S (NOLOCK) ON S.SectionKeyID = C.CrimID AND S.ApplSectionID = 5 AND S.IsActive=1-- crim
		INNER JOIN ApplAlias AS AA(NOLOCK) ON AA.ApplAliasID = S.ApplAliasID
		WHERE (C.Clear IN( 'M')) 
		  AND A.InUse IS NULL
		  AND A.ApStatus in ('p','w')
		  AND Isnull(ltrim(rtrim(Ordered)),'')=''
		  AND c.ishidden = 0   
		  AND A.CLNO NOT IN (3468,2135) -- Added this by Santosh on 06/24/13 to exclude BAD APPS
		  AND c.DeliveryMethod = 'Integration'
		  AND IsNull(c.InUseByIntegration,'') = ''
		  AND c.CNTY_NO<>2480
		 

		SELECT DISTINCT Section,Cnty_No,IsNull(VendorAccountId,16) AS VendorAccountId FROM @tmpCountyList where CNTY_NO<>2480 ORDER BY Cnty_No

	END
ELSE -- Return the pending list per county
	BEGIN

		DECLARE @CrimPendingSearches TABLE
        (
			Section VARCHAR(20),
			SectionID INT,
			Apno INT,
			County VARCHAR(50),
			Cnty_No INT,
			Ordered VARCHAR(25),
			Last  VARCHAR(50),
			First VARCHAR(50), 
			Middle VARCHAR(50), 
			DOB DATETIME,
			DOB_MM VARCHAR(2),
			DOB_DD VARCHAR(2),
			DOB_YYYY INT,
			SSN VARCHAR(11),
			SSN1 VARCHAR(3),
			SSN2 VARCHAR(3),
			SSN3 VARCHAR(4),
			KnownHits VARCHAR(MAX),
			InUse Bit,
			InUseByIntegration VARCHAR(50),
			IsPrimaryName bit,
			ApplAliasID INT
		)



		IF (@ForIntegration = 1)
			BEGIN


				declare @defaultOrderedDate datetime
				declare @varcharOrderDate varchar(20)
				--set @defaultOrderedDate = CURRENT_TIMESTAMP -- added by Radhika on 07/06/2020 as instructed by DOUG
			--	set @defaultOrderedDate = dateadd(day,-1, getdate())	
			--	declare @defaultDate datetime
--Leap Year Fix
--if (year(CURRENT_TIMESTAMP)%4 = 0)
--       set @defaultOrderedDate = DATEADD(DAY,-1,CURRENT_TIMESTAMP)
--else
		set @defaultOrderedDate = CURRENT_TIMESTAMP     
--       set @defaultOrderedDate = replace(@defaultOrderedDate,year(@defaultOrderedDate),'1900')

				set @defaultOrderedDate = replace(@defaultOrderedDate,year(getdate()),'1900')
				set @varcharOrderDate = convert(varchar(10),@defaultOrderedDate,101) + ' ' + CONVERT(VARCHAR(10), @defaultOrderedDate, 108)		
--------------------------------------------------------------------------------------------------
				DECLARE @PickNumRecords INT = 500

				IF(@County in (5,3667))
					begin
						SET @PickNumRecords = 10
					end
--------------------------------------------------------------------------------------------------				
				
				INSERT INTO @CrimPendingSearches
				SELECT  Distinct TOP (@PickNumRecords) Section,SectionID,Apno,	County,	Cnty_No,@varcharOrderDate Ordered, Last,	First, Middle, DOB,
						RIGHT('00' + CONVERT(VARCHAR(2),MONTH(DOB)),2)  DOB_MM,  right('00' + CONVERT(VARCHAR(2),Day(DOB)),2) DOB_DD,YEAR(DOB) DOB_YYYY,SSN,left(SSN,3) SSN1, 
						CASE WHEN CHARINDEX('-',SSN)>0 THEN SUBSTRING(SSN,5,2) ELSE SUBSTRING(SSN,4,2) END SSN2,right(SSN,4) SSN3,CAST(KnownHits AS VARCHAR(max)) KnownHits,		
						InUse,InUseByIntegration,IsPrimaryName,ApplAliasID
				FROM  
				(  
				SELECT	DISTINCT 
							case 								
								when ct.refCountyTypeID = 8 then 'Civ'
							else 	
								'Crim' 
							end as Section,
				 C.CrimID SectionID,C.APNO ,C.County,C.Cnty_no, --C.Ordered,
						ISNULL(AA.Last,A.Last) Last, 
						ISNULL(AA.First,A.First) First,
						ISNULL(AA.Middle,'')  Middle,
						A.DOB AS DOB,  
						CASE WHEN c.Cnty_no = 3906 then  REPLACE(A.SSN,'-','') else A.SSN end AS SSN,  
						KnownHits =case when C.cnty_no in (5) then CONCAT('Client ID ',cl.clno,', Affiliate ID ',ISNULL(cl.affiliateid,'0'),'  **STAMP**',ISNULL(C.CRIM_SpecialInstr, ''))
						else CONCAT('Client ID ',cl.clno,', Affiliate ID ',ISNULL(cl.affiliateid,'0'),' ',ISNULL(C.CRIM_SpecialInstr, '')) END,
						c.InUse,InUseByIntegration ,IsPrimaryName ,AA.ApplAliasID
				FROM Crim C WITH (NOLOCK) 
				INNER JOIN Appl A WITH (NOLOCK) ON A.APNO = C.APNO 		
				INNER JOIN dbo.ApplAlias_Sections AS S (NOLOCK) ON S.SectionKeyID = C.CrimID AND S.ApplSectionID = 5 AND S.IsActive=1-- crim
				INNER JOIN ApplAlias AS AA(NOLOCK) ON AA.ApplAliasID = S.ApplAliasID
				INNER JOIN dbo.TblCounties ct on ct.CNTY_NO = c.CNTY_NO
				INNER JOIN Client cl WITH (NOLOCK) ON a.clno=cl.clno
				--Humera Ahmed 3/29/2013 including civil county search
				LEFT OUTER JOIN refCountyType rct on rct.refCountyTypeID = ct.refCountyTypeID
				WHERE (C.Cnty_no = @County )--OR @County IS NULL) 
				  AND (C.Clear IN( 'M')) 
				  AND (A.InUse IS NULL) 
				  AND A.ApStatus in ('p','w')
				  AND c.ishidden = 0   
				  AND Isnull(Ordered,'')=''
				  AND A.CLNO NOT IN (3468,2135) -- Added this by Santosh on 06/24/13 to exclude BAD APPS 
				  AND c.DeliveryMethod = 'Integration'
				   AND IsNull(c.InUseByIntegration,'') = ''	
				   AND c.cnty_no<>2480
				) Qry 
				--ORDER BY CAST(ISNULL(Ordered,'1/1/1900') AS DateTime)

				-------------------------------------------- Stuck Ga Fix -----------------------------
					if(@County in (5,3667))
					begin
					drop TABLE IF EXISTS #tempGA
					SELECT  t.APNO into #tempGA FROM (
						SELECT  a.ApplicantNumber APNO    
						FROM Enterprise.dbo.Applicant a WITH(NOLOCK)      
						inner JOIN Enterprise.dbo.ApplicantExternalForm aef WITH(NOLOCK) ON a.ApplicantId=aef.ApplicantId AND aef.ModifyDate>a.CreateDate AND aef.IsLocked =1    
						inner JOIN Enterprise.[External].Form ef WITH(NOLOCK) ON aef.FormId=ef.FormId AND FormNumber IN ('SF_GA_01','SF_GA_02')
						INNER JOIN @CrimPendingSearches cps ON cps.Apno=a.ApplicantNumber AND cps.Cnty_No IN (5,3667)
						UNION ALL
						select af.apno APNO from applfile af 
						INNER JOIN @CrimPendingSearches cps ON cps.Apno=af.apno AND cps.Cnty_No IN (5,3667)
						where refapplfiletype = 1 and deleted = 0 AND AttachToReport IS NULL    
						AND ImageFilename LIKE '%GA_Consent%' AND   ImageFilename NOT LIKE '%_RA_%' 
				  )t
				  DELETE cps
				  --SELECT distinct cps.apno,cps.SectionID,tmp.apno 
				  FROM @CrimPendingSearches cps left join #tempGA tmp ON cps.apno=tmp.apno WHERE tmp.apno IS null AND cps.Cnty_No IN (5,3667)
				  drop TABLE IF EXISTS #tempGA
				  END
  -------------------------------------------------------------------------------------

				Update C Set Ordered = CP.Ordered
				From Crim C inner join @CrimPendingSearches CP on C.CrimID = CP.SectionID
				
				--The below logic is to handle any bad Date of Birth scenarios that need to be handled
				BEGIN TRY
					Declare @DOBCutoff Date = cast(Dateadd(YEAR,-12,current_timestamp) as Date)
					If (Select count(1) From @CrimPendingSearches where (DOB >= @DOBCutoff or DOB < '1/1/1920') or ISDATE(DOB) = 0) >0
					BEGIN
						
						Declare @msg varchar(5500)
						
						--compile a list of APNO's with bad DOB along with instructions
						SELECT distinct @msg =  COALESCE(@msg + ', ', '') + cast(Apno as varchar) + '[' + IsNull([First],'') + ' ' + IsNull([Last],'') + ']'  + char(9) + char(13)  
						FROM @CrimPendingSearches
						WHERE (DOB >= @DOBCutoff or DOB < '1/1/1920') or ISDATE(DOB) = 0
						
						Select @msg = 'Please find the list of Apps where the DOB is ' + cast(@DOBCutoff as varchar) +' or higher (less than 12 years of age) or the dob year is  less than 1920. These orders will be rejected by the integration vendors and hence need to be fixed or handled outside integration.' + char(9) + char(13) 
						+ 'Reports/Apps updated with a correct DOB will be re-tried to be sent in an hour or so. ' + char(9) + char(13) +  char(9) + char(13) 
						+ @msg +  char(9) + char(13) + ' You will continue to receive this notification for the above Reports about every hour (till fixed or handled). Thank you.' 
						
						--Delete the bad DOB records from the temp to prevent sending to the vendor
						Delete @CrimPendingSearches where DOB >= @DOBCutoff or ISDATE(DOB) = 0

						--send the compiled email to recepients
						EXEC msdb.dbo.sp_send_dbmail   @from_address = 'Integration Vendor Service <DoNotReply@PreCheck.com>',@subject=N'Date Of Birth Corrections Needed', @recipients=N'santoshchapyala@Precheck.com;DouglasDegenaro@precheck.com;JoeMonforti@precheck.com; MistySmallwood@precheck.com; AILeadershipTeam@precheck.com',    @body=@msg ;
						
					END
				END TRY
				BEGIN CATCH  
				--	--Error handling
				END CATCH
				

				DECLARE @CrimAlias TABLE
				(
					SectionID INT,
					APNO INT,
					ApplAliasID INT
				)

				--Include the records with Primary names qualified
				INSERT INTO @CrimAlias
				SELECT SectionID,APNO, ApplAliasID 
				FROM @CrimPendingSearches 
				WHERE IsPrimaryName = 1 

				--Include the first alias record for searches where primary name is NOT qualified
				INSERT INTO @CrimAlias
				SELECT SectionID,APNO, MIN(ApplAliasID)
				FROM @CrimPendingSearches C
				WHERE C.SectionID NOT IN(SELECT SectionID FROM @CrimAlias) 
				GROUP BY SectionID,APNO


				SELECT	DISTINCT Section,
						SectionID, Apno,County,	Cnty_No,CAST(ISNULL(Ordered,'1/1/1900') AS DATETIME) Ordered,
						[Last] ,[First]   ,Middle, DOB,
						RIGHT('00' + convert(VARCHAR(2),MONTH(DOB)),2)  DOB_MM,
						RIGHT('00' + convert(VARCHAR(2),DAY(DOB)),2) DOB_DD,
						YEAR(DOB) DOB_YYYY,SSN,LEFT(SSN,3) SSN1,
						CASE WHEN CHARINDEX('-',SSN)>0 THEN SUBSTRING(SSN,5,2) ELSE SUBSTRING(SSN,4,2) END SSN2,
						RIGHT(SSN,4) SSN3,
						CAST(KnownHits AS VARCHAR(max)) KnownHits,InUse, InUseByIntegration 
				from @CrimPendingSearches
				where ApplAliasID IN (SELECT ApplAliasID FROM @CrimAlias) --Inlcude all names in the temp table (Primary names + first alias name)

				SELECT 'CrimAliases' Section,SectionID,APNO,ApplAliasID,Last,First,Middle
				FROM @CrimPendingSearches
				WHERE ApplAliasID NOT IN (SELECT ApplAliasID FROM @CrimAlias) --Exclude the aliases that are already included in the main set (for those searches where primary is not included)
				
			END
		
		ELSE
		--IF @County = 2480
			BEGIN
				/*SELECT DISTINCT T.* 
				FROM @CrimPendingSearches t
				INNER JOIN (SELECT distinct top 100  APNO, Ordered FROM @CrimPendingSearches ORDER BY 2) Q on t.APNO = Q.APNO
				ORDER BY t.Ordered*/

				INSERT INTO @CrimPendingSearches
				SELECT  Distinct 'Crim' Section,SectionID,Apno,	County,	Cnty_No,CAST(ISNULL(Ordered,'1/1/1900') AS DateTime2) Ordered, Last,	First, Middle, DOB,
						RIGHT('00' + CONVERT(VARCHAR(2),MONTH(DOB)),2)  DOB_MM,  right('00' + CONVERT(VARCHAR(2),Day(DOB)),2) DOB_DD,YEAR(DOB) DOB_YYYY,SSN,left(SSN,3) SSN1, 
						CASE WHEN CHARINDEX('-',SSN)>0 THEN SUBSTRING(SSN,5,2) ELSE SUBSTRING(SSN,4,2) END SSN2,right(SSN,4) SSN3,CAST(KnownHits AS VARCHAR(max)) KnownHits,		
						InUse,InUseByIntegration,IsPrimaryName,ApplAliasID
				FROM  
				(  
				SELECT	DISTINCT C.CrimID SectionID,C.APNO ,C.County,C.Cnty_no, C.Ordered,
						ISNULL(AA.Last,'') Last, 
						ISNULL(AA.First,'') First,
						ISNULL(AA.Middle, '') AS Middle,
						A.DOB AS DOB,  
						CASE WHEN c.Cnty_no = 3906 then  REPLACE(A.SSN,'-','') else A.SSN end AS SSN,  
						CONCAT('Client ID ',cl.clno,', Affiliate ID ',ISNULL(cl.affiliateid,'0'),' ',ISNULL(C.CRIM_SpecialInstr, '')) AS KnownHits,
						c.InUse,InUseByIntegration ,IsPrimaryName ,AA.ApplAliasID
				FROM Crim C WITH (NOLOCK) 
				INNER JOIN Appl A WITH (NOLOCK) ON A.APNO = C.APNO 		
				INNER JOIN dbo.ApplAlias_Sections AS S (NOLOCK) ON S.SectionKeyID = C.CrimID AND S.ApplSectionID = 5 AND S.IsActive=1-- crim
				INNER JOIN ApplAlias AS AA(NOLOCK) ON AA.ApplAliasID = S.ApplAliasID
				INNER JOIN Client cl WITH (NOLOCK) ON a.clno=cl.clno
				WHERE (C.Cnty_no = @County )--OR @County IS NULL) 
				  AND (C.Clear IN( 'O','W')) 
				  AND (A.InUse IS NULL) 
				  AND A.ApStatus in ('p','w')
				  AND c.ishidden = 0   
				  AND A.CLNO NOT IN (3468,2135) -- Added this by Santosh on 06/24/13 to exclude BAD APPS 				 		
				) Qry 
				ORDER BY CAST(ISNULL(Ordered,'1/1/1900') AS DateTime2)

				DECLARE @NumRecords INT = 100

				IF @County in (597)
					SET @NumRecords = 15 --set by Johnny 12/08/2020 for better automation progression through work load
				
				IF @County in (1434,34,335, 672, 1916, 2353, 2469, 3906)
					SET @NumRecords = 10 --set by Johnny 12/08/2020 for better automation progression through work load

				IF @County in (2032,2106, 2566, 13, 295, 824, 1916, 2523, 2052,623,2727,673,434,753,1666,2371,2079,1732, 1002, 3, 2738, 1598)
					SET @NumRecords = 5 --set by Johnny 5/10/2020 for better automation progression through work load

				--IF @County in (1598)
				--	SET @NumRecords = 3 --set by Johnny 5/10/2020 for better automation progression through work load

				IF @County in (3581,3772, 2, 2068, 312,2117,890,3396,1220,655)
					SET @NumRecords = 1 --set by Johnny 5/10/2020 for better automation progression through work load

				IF @County in (295)
					SET @NumRecords = 2 --set by Johnny 5/10/2020 for better automation progression through work load

				IF @County in (2080, 2737)
					SET @NumRecords = 20 --set by Johnny 5/10/2020 for better automation progression through work load

				--IF @County in (2737, 2738)
				--	SET @NumRecords = 30 --set by Johnny 5/10/2020 for better automation progression through work load

				--IF @County in (2480)
				--	SET @NumRecords = 25 --set by Johnny 5/10/2020 for better automation progression through work load
					
				 select Distinct 'Crim' Section,SectionID,t.Apno,County,	Cnty_No,CAST(ISNULL(t.Ordered,'1/1/1900') AS DateTime2) as Ordered, Last,	First, Middle, DOB,
				RIGHT('00' + CONVERT(VARCHAR(2),MONTH(DOB)),2)  DOB_MM,  right('00' + CONVERT(VARCHAR(2),Day(DOB)),2) DOB_DD,YEAR(DOB) DOB_YYYY,SSN,left(SSN,3) SSN1, 
				CASE WHEN CHARINDEX('-',SSN)>0 THEN SUBSTRING(SSN,5,2) ELSE SUBSTRING(SSN,4,2) END SSN2,right(SSN,4) SSN3,CAST(KnownHits AS VARCHAR(max)) KnownHits				
				--SELECT DISTINCT T.* 
				FROM @CrimPendingSearches t
				INNER JOIN (SELECT distinct top (@NumRecords)  APNO, Ordered FROM @CrimPendingSearches ORDER BY 2 asc) Q on t.APNO = Q.APNO
				ORDER BY Ordered
			END
		--ELSE
		--SELECT * from #tmpPendingSearches 



	END
SET NOCOUNT OFF
