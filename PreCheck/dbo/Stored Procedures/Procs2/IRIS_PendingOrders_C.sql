
--[IRIS_PendingOrders]

--[dbo].[IRIS_PendingOrders_C] null,1,1
--[IRIS_PendingOrders] null,1

--[IRIS_PendingOrders] null,1,1

CREATE procedure [dbo].[IRIS_PendingOrders_C] (@County int = null,@CountyList BIT = 0,@ForIntegration BIT = 0)   
as  
SET NOCOUNT ON
IF @CountyList = 1 -- Return a distinct list of counties
	BEGIN
		DECLARE @time time(3) = Current_TimeStamp;
		Declare  @tmpCountyList TABLE
		(
			Section VARCHAR(10),
			Cnty_No int,
			VendorAccountId int
		)

		INSERT INTO @tmpCountyList
		SELECT DISTINCT 'Crim' Section,Cnty_No,IsNull(VendorMapping.VendorId,5)
		FROM  
		( 
		SELECT Cnty_No  
		FROM Crim C WITH (NOLOCK) 
		INNER JOIN Appl A WITH (NOLOCK) ON A.APNO = C.APNO  
		WHERE (C.Clear IN( 'O','W')) 
		  AND (A.InUse IS NULL) 
		  AND c.ishidden = 0   
		  AND A.CLNO NOT IN (3468,2135) -- Added this by Santosh on 06/24/13 to exclude BAD APPS 
		) Qry INNER JOIN DataXtract_RequestMapping M ON cast(Qry.Cnty_No AS VARCHAR)= SectionKeyID
		LEFT JOIN dbo.Dataxtract_VendorRequestMapping VendorMapping ON M.DataXtract_RequestMappingXMLID = VendorMapping.DataXtract_RequestMappingId
		WHERE M.Section = 'Crim' 
		  AND IsAutomationEnabled = 1
		  AND (CASE WHEN (OffPeakHoursOnly =1 AND  @time > '4 AM' AND @time <'6 PM') THEN 0 ELSE 1 END) = 1 -- only schedule these between 7 PM AND 5 AM CST
		
		insert into @tmpCountyList
		SELECT distinct 'Crim' as Section,Cnty_No,7 
		From Crim C WITH (NOLOCK) INNER JOIN Appl A WITH (NOLOCK) ON A.APNO = C.APNO   
		WHERE  
		 (C.Clear in( 'O','W')) 
		and (A.InUse is null and IsNull(c.InUseByIntegration,'') = '') 
		and c.ishidden = 0   
		and A.CLNO not in (3468,2135) -- Added this by Santosh on 06/24/13 to exclude BAD APPS
		and vendorid = 20

		insert into @tmpCountyList
		SELECT distinct 'Crim' as Section,Cnty_No,10 
		From Crim C WITH (NOLOCK) INNER JOIN Appl A WITH (NOLOCK) ON A.APNO = C.APNO   
		WHERE  
		 (C.Clear in( 'O','W')) 
		and (A.InUse is null and IsNull(c.InUseByIntegration,'') = '') 
		and c.ishidden = 0   
		and A.CLNO not in (3468,2135) -- Added this by Santosh on 06/24/13 to exclude BAD APPS
		and vendorid = 5679614

		insert into @tmpCountyList
		SELECT distinct 'Crim' as Section,Cnty_No,11 
		From Crim C WITH (NOLOCK) INNER JOIN Appl A WITH (NOLOCK) ON A.APNO = C.APNO   
		WHERE  
		 (C.Clear in( 'O','W')) 
		and (A.InUse is null and IsNull(c.InUseByIntegration,'') = '') 
		and c.ishidden = 0   
		and A.CLNO not in (3468,2135) -- Added this by Santosh on 06/24/13 to exclude BAD APPS
		and vendorid = 5679569




		select distinct Section,Cnty_No,IsNull(VendorAccountId,9) as VendorAccountId from @tmpCountyList order by Cnty_No


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
			IsPrimaryName bit
		)

		INSERT INTO @CrimPendingSearches
		SELECT  Distinct 'Crim' Section,SectionID,Apno,	County,	Cnty_No,CAST(ISNULL(Ordered,'1/1/1900') AS DateTime) Ordered, Last,	First, Middle, DOB,
				RIGHT('00' + CONVERT(VARCHAR(2),MONTH(DOB)),2)  DOB_MM,  right('00' + CONVERT(VARCHAR(2),Day(DOB)),2) DOB_DD,YEAR(DOB) DOB_YYYY,SSN,left(SSN,3) SSN1, 
				CASE WHEN CHARINDEX('-',SSN)>0 THEN SUBSTRING(SSN,5,2) ELSE SUBSTRING(SSN,4,2) END SSN2,right(SSN,4) SSN3,CAST(KnownHits AS VARCHAR(max)) KnownHits,		
				InUse,InUseByIntegration,IsPrimaryName
		FROM  
		(  
		SELECT	DISTINCT C.CrimID SectionID,C.APNO ,C.County,C.Cnty_no, C.Ordered,
				ISNULL(AA.Last,'') Last, ISNULL(AA.First,'') First
				,Null Middle, --ISNULL(AA.Middle, '') middle,  
				A.DOB AS DOB,  
				CASE WHEN c.Cnty_no = 3906 then  REPLACE(A.SSN,'-','') else A.SSN end AS SSN,  
				ISNULL(C.CRIM_SpecialInstr,'') AS KnownHits,c.InUse,InUseByIntegration ,IsPrimaryName 
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
				SELECT	Distinct 'Crim' Section,
						SectionID, Apno,County,	Cnty_No,CAST(ISNULL(Ordered,'1/1/1900') AS DATETIME) Ordered,
						[Last] =  CASE WHEN IsPrimaryName = 1 then Last ELSE '' END,[First] = CASE WHEN IsPrimaryName = 1 then First ELSE '' END  ,Middle, DOB,
						RIGHT('00' + convert(VARCHAR(2),MONTH(DOB)),2)  DOB_MM,
						RIGHT('00' + convert(VARCHAR(2),DAY(DOB)),2) DOB_DD,
						YEAR(DOB) DOB_YYYY,SSN,LEFT(SSN,3) SSN1,
						CASE WHEN CHARINDEX('-',SSN)>0 THEN SUBSTRING(SSN,5,2) ELSE SUBSTRING(SSN,4,2) END SSN2,
						RIGHT(SSN,4) SSN3,
						CAST(KnownHits AS VARCHAR(max)) KnownHits,InUse, InUseByIntegration 
				from @CrimPendingSearches
				where ISNULL(inuse,0)=0
				  AND IsNull(InUseByIntegration,'') = ''

				SELECT SectionID,Last,First,Middle
				FROM @CrimPendingSearches
				WHERE IsPrimaryName = 0
				AND ISNULL(inuse,0)=0
				AND IsNull(InUseByIntegration,'') = ''
			END
		
		ELSE
		--IF @County = 2480
			BEGIN
				SELECT DISTINCT T.* 
				FROM @CrimPendingSearches t
				INNER JOIN (SELECT distinct top 100  APNO, Ordered FROM @CrimPendingSearches ORDER BY 2) Q on t.APNO = Q.APNO
				ORDER BY t.Ordered
			END


	END
SET NOCOUNT OFF	
