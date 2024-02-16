/*
[dbo].[IRIS_PendingOrders_Integrations] 2271 ,0,1
[dbo].[IRIS_PendingOrders_Integrations] null,1,1

*/

CREATE procedure [dbo].[IRIS_PendingOrders_Integrations_bkp08152017] (@County int = null,@CountyList BIT = 0,@ForIntegration BIT = 0)   
AS  
SET NOCOUNT ON
IF @CountyList = 1 -- Return a distinct list of counties
	BEGIN

	DECLARE @time time(3) = Current_TimeStamp;
	DECLARE @DayOfWeek INT = DATEPART(dw, Current_TimeStamp) -- 1 = Sunday; 7 = Saturday
	DECLARE @OffPeak BIT = 0

	--Set OffPeak flag to True on Weekends and all other times with the exception of between 4 AM to 5 PM Alamogordo times on weekdays
	SET @OffPeak = CASE WHEN @DayOfWeek IN (1,7) THEN 1
						WHEN (@time > '4 AM' and @time <'5 PM') THEN 0
						ELSE 1
						END

		Declare  @tmpCountyList TABLE
		(
			Section VARCHAR(10),
			Cnty_No int,
			VendorAccountId int
		)

		INSERT INTO @tmpCountyList
		SELECT DISTINCT 'Crim' Section,Cnty_No,IsNull(VendorMapping.VendorId,9)
		FROM  
		( 
		SELECT Cnty_No  
		FROM Crim C WITH (NOLOCK) 
		INNER JOIN Appl A WITH (NOLOCK) ON A.APNO = C.APNO  
		INNER JOIN dbo.ApplAlias_Sections AS S (NOLOCK) ON S.SectionKeyID = C.CrimID AND S.ApplSectionID = 5 AND S.IsActive=1-- crim
		INNER JOIN ApplAlias AS AA(NOLOCK) ON AA.ApplAliasID = S.ApplAliasID
		WHERE (C.Clear IN( 'O','W')) 
		  AND (A.InUse IS NULL) 
		  AND c.ishidden = 0   
		  AND A.CLNO NOT IN (3468,2135) -- Added this by Santosh on 06/24/13 to exclude BAD APPS 
		) Qry INNER JOIN DataXtract_RequestMapping M ON cast(Qry.Cnty_No AS VARCHAR)= SectionKeyID
		LEFT JOIN dbo.Dataxtract_VendorRequestMapping VendorMapping ON M.DataXtract_RequestMappingXMLID = VendorMapping.DataXtract_RequestMappingId
		WHERE M.Section = 'Crim' 
		  AND IsAutomationEnabled = 1
		  AND (CASE WHEN (OffPeakHoursOnly =1 AND  @OffPeak = 0) THEN 0 ELSE 1 END) = 1 -- only schedule these between 6 PM AND 6 AM CST
		
		-- This makes sure that the baxter counties come up, IN the county list if new vendors are added please add them below
		INSERT INTO @tmpCountyList
		SELECT DISTINCT 'Crim' AS Section,Cnty_No,7
		FROM Crim C WITH (NOLOCK) 
		INNER JOIN Appl A WITH (NOLOCK) ON A.APNO = C.APNO 
		INNER JOIN dbo.ApplAlias_Sections AS S (NOLOCK) ON S.SectionKeyID = C.CrimID AND S.ApplSectionID = 5 AND S.IsActive=1-- crim
		INNER JOIN ApplAlias AS AA(NOLOCK) ON AA.ApplAliasID = S.ApplAliasID
		WHERE (C.Clear IN( 'O','W')) 
		 -- AND (A.InUse IS NULL AND IsNull(c.InUseByIntegration,'') = '') AND Isnull(Ordered,'')=''
		  AND (A.InUse IS NULL AND ((IsNull(c.InUseByIntegration,'') = '') OR Isnull(Ordered,'')=''))
		  AND c.ishidden = 0   
		  AND A.CLNO NOT IN (3468,2135) -- Added this by Santosh on 06/24/13 to exclude BAD APPS
		  AND c.vendorid IN (20)
		UNION
		SELECT DISTINCT 'Crim' AS Section,Cnty_No,10
		FROM Crim C WITH (NOLOCK) 
		INNER JOIN Appl A WITH (NOLOCK) ON A.APNO = C.APNO 
		INNER JOIN dbo.ApplAlias_Sections AS S (NOLOCK) ON S.SectionKeyID = C.CrimID AND S.ApplSectionID = 5 AND S.IsActive=1-- crim
		INNER JOIN ApplAlias AS AA(NOLOCK) ON AA.ApplAliasID = S.ApplAliasID
		WHERE (C.Clear IN( 'O','W')) 
		  --AND (A.InUse IS NULL AND IsNull(c.InUseByIntegration,'') = '') AND Isnull(Ordered,'')=''
		  AND (A.InUse IS NULL AND ((IsNull(c.InUseByIntegration,'') = '') OR Isnull(Ordered,'')=''))
		  AND c.ishidden = 0   
		  AND A.CLNO NOT IN (3468,2135) -- Added this by Santosh on 06/24/13 to exclude BAD APPS
		  AND c.vendorid IN (5679614)
		  UNION
		  SELECT DISTINCT 'Crim' AS Section,Cnty_No,11
		FROM Crim C WITH (NOLOCK) 
		INNER JOIN Appl A WITH (NOLOCK) ON A.APNO = C.APNO 
		INNER JOIN dbo.ApplAlias_Sections AS S (NOLOCK) ON S.SectionKeyID = C.CrimID AND S.ApplSectionID = 5 AND S.IsActive=1-- crim
		INNER JOIN ApplAlias AS AA(NOLOCK) ON AA.ApplAliasID = S.ApplAliasID
		WHERE (C.Clear IN( 'O','W')) 
		  AND (A.InUse IS NULL AND IsNull(c.InUseByIntegration,'') = '') AND Isnull(Ordered,'')=''
		 -- AND (A.InUse IS NULL AND ((IsNull(c.InUseByIntegration,'') = '') OR Isnull(Ordered,'')=''))
		  AND c.ishidden = 0   
		  AND A.CLNO NOT IN (3468,2135) -- Added this by Santosh on 06/24/13 to exclude BAD APPS
		  AND c.vendorid IN (5679569)

		SELECT DISTINCT Section,Cnty_No,IsNull(VendorAccountId,5) AS VendorAccountId FROM @tmpCountyList ORDER BY Cnty_No

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
			Ordered DATETIME,
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



		INSERT INTO @CrimPendingSearches
		SELECT  Distinct 'Crim' Section,SectionID,Apno,	County,	Cnty_No,CAST(ISNULL(Ordered,'1/1/1900') AS DateTime) Ordered, Last,	First, Middle, DOB,
				RIGHT('00' + CONVERT(VARCHAR(2),MONTH(DOB)),2)  DOB_MM,  right('00' + CONVERT(VARCHAR(2),Day(DOB)),2) DOB_DD,YEAR(DOB) DOB_YYYY,SSN,left(SSN,3) SSN1, 
				CASE WHEN CHARINDEX('-',SSN)>0 THEN SUBSTRING(SSN,5,2) ELSE SUBSTRING(SSN,4,2) END SSN2,right(SSN,4) SSN3,CAST(KnownHits AS VARCHAR(max)) KnownHits,		
				InUse,InUseByIntegration,IsPrimaryName,ApplAliasID
		FROM  
		(  
		SELECT	DISTINCT C.CrimID SectionID,C.APNO ,C.County,C.Cnty_no, C.Ordered,
				ISNULL(AA.Last,'') Last, 
				ISNULL(AA.First,'') First,
				Null Middle, --ISNULL(AA.Middle, '') AS Middle,
				A.DOB AS DOB,  
				CASE WHEN c.Cnty_no = 3906 then  REPLACE(A.SSN,'-','') else A.SSN end AS SSN,  
				ISNULL(C.CRIM_SpecialInstr,'') AS KnownHits,c.InUse,InUseByIntegration ,IsPrimaryName ,AA.ApplAliasID
		FROM Crim C WITH (NOLOCK) 
		INNER JOIN Appl A WITH (NOLOCK) ON A.APNO = C.APNO 		
		INNER JOIN dbo.ApplAlias_Sections AS S (NOLOCK) ON S.SectionKeyID = C.CrimID AND S.ApplSectionID = 5 AND S.IsActive=1-- crim
		INNER JOIN ApplAlias AS AA(NOLOCK) ON AA.ApplAliasID = S.ApplAliasID
		WHERE (C.Cnty_no = @County )--OR @County IS NULL) 
		  AND (C.Clear IN( 'O','W')) 
		  AND (A.InUse IS NULL) 
		  AND c.ishidden = 0   
		  AND A.CLNO NOT IN (3468,2135) -- Added this by Santosh on 06/24/13 to exclude BAD APPS 				 		
		) Qry 
		ORDER BY CAST(ISNULL(Ordered,'1/1/1900') AS DateTime)
		
		IF (@ForIntegration = 1)
			BEGIN

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


				SELECT	Distinct 'Crim' Section,
						SectionID, Apno,County,	Cnty_No,CAST(ISNULL(Ordered,'1/1/1900') AS DATETIME) Ordered,
						[Last] ,[First]   ,Middle, DOB,
						RIGHT('00' + convert(VARCHAR(2),MONTH(DOB)),2)  DOB_MM,
						RIGHT('00' + convert(VARCHAR(2),DAY(DOB)),2) DOB_DD,
						YEAR(DOB) DOB_YYYY,SSN,LEFT(SSN,3) SSN1,
						CASE WHEN CHARINDEX('-',SSN)>0 THEN SUBSTRING(SSN,5,2) ELSE SUBSTRING(SSN,4,2) END SSN2,
						RIGHT(SSN,4) SSN3,
						CAST(KnownHits AS VARCHAR(max)) KnownHits,InUse, InUseByIntegration 
				from @CrimPendingSearches
				where (ISNULL(inuse,'')='' 
				  AND   (IsNull(InUseByIntegration,'') = '' OR Isnull(Ordered,'')=''))
			  AND Isnull(Ordered,'')=''
				AND   ApplAliasID IN (SELECT ApplAliasID FROM @CrimAlias) --Inlcude all names in the temp table (Primary names + first alias name)

				SELECT 'CrimAliases' Section,SectionID,APNO,ApplAliasID,Last,First,Middle
				FROM @CrimPendingSearches
				WHERE ApplAliasID NOT IN (SELECT ApplAliasID FROM @CrimAlias) --Exclude the aliases that are already included in the main set (for those searches where primary is not included)
				AND (ISNULL(inuse,'')=''
				AND (IsNull(InUseByIntegration,'') = '' OR Isnull(Ordered,'')=''))
			  AND Isnull(Ordered,'')=''
			END
		
		ELSE
		--IF @County = 2480
			BEGIN
				/*SELECT DISTINCT T.* 
				FROM @CrimPendingSearches t
				INNER JOIN (SELECT distinct top 100  APNO, Ordered FROM @CrimPendingSearches ORDER BY 2) Q on t.APNO = Q.APNO
				ORDER BY t.Ordered*/

				DECLARE @NumRecords INT = 100

				IF @County = 597
					SET @NumRecords = 50
					
				 select Distinct 'Crim' Section,SectionID,t.Apno,County,	Cnty_No,CAST(ISNULL(t.Ordered,'1/1/1900') AS DateTime) as Ordered, Last,	First, Middle, DOB,
				RIGHT('00' + CONVERT(VARCHAR(2),MONTH(DOB)),2)  DOB_MM,  right('00' + CONVERT(VARCHAR(2),Day(DOB)),2) DOB_DD,YEAR(DOB) DOB_YYYY,SSN,left(SSN,3) SSN1, 
				CASE WHEN CHARINDEX('-',SSN)>0 THEN SUBSTRING(SSN,5,2) ELSE SUBSTRING(SSN,4,2) END SSN2,right(SSN,4) SSN3,CAST(KnownHits AS VARCHAR(max)) KnownHits				
				--SELECT DISTINCT T.* 
				FROM @CrimPendingSearches t
				INNER JOIN (SELECT distinct top (@NumRecords)  APNO, Ordered FROM @CrimPendingSearches ORDER BY 2) Q on t.APNO = Q.APNO
				ORDER BY Ordered
			END
		--ELSE
		--SELECT * from #tmpPendingSearches 



	END
SET NOCOUNT OFF	
