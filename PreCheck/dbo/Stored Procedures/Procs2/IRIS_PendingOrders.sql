
--[IRIS_PendingOrders] 3519

--[dbo].[IRIS_PendingOrders] 1002

--[IRIS_PendingOrders] null,1

CREATE procedure [dbo].[IRIS_PendingOrders] (@County int = null,@CountyList BIT = 0)   
as  
SET NOCOUNT ON

DECLARE @tmpPendingSearches TABLE
(
	Section varchar(100),
	SectionID int,
	Apno int,
	County varchar(30),
	Cnty_No int,
	Ordered DateTime,
	Last varchar(100),		
	First varchar(100),		
	Middle varchar(100),
	DOB datetime,
	DOB_MM varchar(2),
	DOB_DD varchar(2),
	DOB_YYYY int,
	SSN varchar(11),
	SSN1 varchar(3),
	SSN2 varchar(2),
	SSN3 varchar(4),
	KnownHits varchar(max)
)

IF @CountyList = 1 -- Return a distinct list of counties
	BEGIN
		DECLARE @time time(3) = Current_TimeStamp;

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
		  AND (CASE WHEN (OffPeakHoursOnly =1 AND  @time > '4 AM' AND @time <'6 PM') THEN 0 ELSE 1 END) = 1 
	END
ELSE -- Return the pending list per county
	BEGIN
		insert into @tmpPendingSearches
		Select Distinct 'Crim' Section,SectionID,Apno,County,Cnty_No,cast(isnull(Ordered,'1/1/1900') as DateTime) Ordered,
		--REPLACE(Last,char(39),char(39)+char(39)) as 
		Last,
		--REPLACE(First,char(39),char(39)+char(39)) as 
		First,
		--REPLACE([Middle],'','''') as 
		Middle,		
		DOB,
		right('00' + convert(varchar(2),month(DOB)),2)  DOB_MM,  right('00' + convert(varchar(2),Day(DOB)),2) DOB_DD,Year(DOB) DOB_YYYY,SSN,left(SSN,3) SSN1, Case When charindex('-',SSN)>0 then substring(SSN,5,2) else substring(SSN,4,2) end SSN2,right(SSN,4) SSN3,cast(KnownHits as varchar(max)) KnownHits--,'Doug' TestField,null Testfield2  
		--into #tmpPendingSearches
		From  
		(  
		SELECT	DISTINCT C.CrimID SectionID,C.APNO ,C.County,C.Cnty_no, C.Ordered,
				ISNULL(AA.Last,'') Last, ISNULL(AA.First,'') First
				,Null Middle, --ISNULL(AA.Middle, '') middle,  
				A.DOB AS DOB,  
				CASE WHEN c.Cnty_no = 3906 then  REPLACE(A.SSN,'-','') else A.SSN end AS SSN,  
				ISNULL(C.CRIM_SpecialInstr,'') AS KnownHits,c.InUse,InUseByIntegration ,IsPrimaryName ,AA.ApplAliasID
		FROM Crim C WITH (NOLOCK) 
		INNER JOIN Appl A WITH (NOLOCK) ON A.APNO = C.APNO 		
		LEFT OUTER JOIN dbo.ApplAlias_Sections AS S (NOLOCK) ON S.SectionKeyID = C.CrimID AND S.ApplSectionID = 5 AND S.IsActive=1-- crim
		LEFT OUTER JOIN ApplAlias AS AA(NOLOCK) ON AA.ApplAliasID = S.ApplAliasID
		WHERE (C.Cnty_no = @County )--OR @County IS NULL) 
		  AND (C.Clear IN( 'O','W')) 
		  AND (A.InUse IS NULL) 
		  AND c.ishidden = 0   
		  AND A.CLNO NOT IN (3468,2135)	
		) Qry 
		Order By cast(isnull(Ordered,'1/1/1900') as DateTime)
		

		--IF @County = 2480
			Select T.* from @tmpPendingSearches t
			inner join (Select distinct top 100  APNO, Ordered From @tmpPendingSearches Order by 2) Q on t.APNO = Q.APNO
			where IsNull(T.First,'') <> ''
			order by t.Ordered
		--ELSE
		--Select * from #tmpPendingSearches 

		--DROP TABLE #tmpPendingSearches


	END
SET NOCOUNT OFF	
