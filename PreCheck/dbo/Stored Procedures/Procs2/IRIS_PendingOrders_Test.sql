
--[IRIS_PendingOrders_Test]

--[dbo].[IRIS_PendingOrders] 1150

--[IRIS_PendingOrders] null,1

CREATE procedure [dbo].[IRIS_PendingOrders_Test] (@County int = null,@CountyList BIT = 1)   
as  

DECLARE @tmpPendingSearches TABLE
(
	Section varchar(100),
	SectionID varchar(100),
	Apno int,
	County varchar(30),
	Cnty_No int,
	Ordered DateTime,
	Last varchar(100),		
	First varchar(100),		
	Middle varchar(100),
	DOB varchar(20),
	DOB_MM varchar(2),
	DOB_DD varchar(2),
	DOB_YYYY varchar(4),
	SSN varchar(11),
	SSN1 varchar(3),
	SSN2 varchar(2),
	SSN3 varchar(4),
	KnownHits varchar(max)
)

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
		From  
		(  
		SELECT C.CrimID SectionID,C.APNO ,C.County,C.Cnty_no, C.Ordered,isnull(A.Last,'') Last, isnull(A.First, '') First,Null Middle, --ISNULL(A.Middle, '') middle,  
		A.DOB as DOB,  
		case when c.Cnty_no = 3906 then  Replace(A.SSN,'-','') else A.SSN end as SSN,  
		ISNULL(C.CRIM_SpecialInstr,'') AS KnownHits  
		From Crim C WITH (NOLOCK) INNER JOIN Appl A WITH (NOLOCK) ON A.APNO = C.APNO   
		WHERE  C.txtlast = 1 
		and   (C.Cnty_no = @County OR @County IS NULL) 
		and (C.Clear in( 'O','W')) 
		and (A.InUse is null) 
		and (isnull(c.InUse,0) = 0)
		and c.ishidden = 0   
		and A.CLNO not in (3468,2135) -- Added this by Santosh on 06/24/13 to exclude BAD APPS 
		UNION ALL  
		SELECT C.CrimID SectionID,C.APNO ,C.County,C.Cnty_no, C.Ordered,isnull(A.Alias1_Last,'') Last, isnull(A.Alias1_First, '') First,Null Middle, --ISNULL(A.Alias1_Middle, '') middle,  
		A.DOB as DOB,  
		case when c.Cnty_no = 3906 then  Replace(A.SSN,'-','') else A.SSN end as SSN,    
		ISNULL(C.CRIM_SpecialInstr,'') AS KnownHits  
		From Crim C WITH (NOLOCK) INNER JOIN Appl A WITH (NOLOCK) ON A.APNO = C.APNO   
		WHERE  C.txtalias = 1  and (LTRIM(RTRIM((isnull(A.Alias1_Last,'') + ', ' + isnull(A.Alias1_First, '') )))) <> ',' 
		--WHERE  C.txtalias = 1  and (LTRIM(RTRIM((isnull(A.Alias1_Last,'') + ', ' + isnull(A.Alias1_First, '') + ' ' + ISNULL(A.Alias1_Middle, ''))))) <> ','  
		and   (C.Cnty_no = @County OR @County IS NULL) 
		and (C.Clear in( 'O','W')) 
		and (A.InUse is null) 
			and (isnull(c.InUse,0) = 0)
		and c.ishidden = 0   
		and A.CLNO not in (3468,2135) -- Added this by Santosh on 06/24/13 to exclude BAD APPS 
		UNION ALL  
		SELECT C.CrimID SectionID,C.APNO ,C.County,C.Cnty_no, C.Ordered,isnull(A.Alias2_Last,'') Last, isnull(A.Alias2_First, '') First,Null Middle, --ISNULL(A.Alias2_Middle, '') middle,  
		A.DOB as DOB,  
		case when c.Cnty_no = 3906 then  Replace(A.SSN,'-','') else A.SSN end as SSN,  
		ISNULL(C.CRIM_SpecialInstr,'') AS KnownHits  
		From Crim C WITH (NOLOCK) INNER JOIN Appl A WITH (NOLOCK) ON A.APNO = C.APNO   
		WHERE  C.txtalias2 = 1  and (LTRIM(RTRIM((isnull(A.Alias2_Last,'') + ', ' + isnull(A.Alias2_First, '') )))) <> ','  
		--WHERE  C.txtalias2 = 1  and (LTRIM(RTRIM((isnull(A.Alias2_Last,'') + ', ' + isnull(A.Alias2_First, '') + ' ' + ISNULL(A.Alias2_Middle, ''))))) <> ','  
		and   (C.Cnty_no = @County OR @County IS NULL) 
		and (C.Clear in( 'O','W')) 
		and (A.InUse is null) 
			and (isnull(c.InUse,0) = 0)
		and c.ishidden = 0  
		and A.CLNO not in (3468,2135) -- Added this by Santosh on 06/24/13 to exclude BAD APPS 		 
		UNION ALL  
		SELECT C.CrimID SectionID,C.APNO ,C.County,C.Cnty_no, C.Ordered,isnull(A.Alias3_Last,'') Last, isnull(A.Alias3_First, '') First,Null Middle, --ISNULL(A.Alias3_Middle, '') middle,  
		A.DOB as DOB,  
		case when c.Cnty_no = 3906 then  Replace(A.SSN,'-','') else A.SSN end as SSN,   
		ISNULL(C.CRIM_SpecialInstr,'') AS KnownHits  
		From Crim C WITH (NOLOCK) INNER JOIN Appl A WITH (NOLOCK) ON A.APNO = C.APNO   
		WHERE  C.txtalias3 = 1  and (LTRIM(RTRIM((isnull(A.Alias3_Last,'') + ', ' + isnull(A.Alias3_First, '') )))) <> ','  
		--WHERE  C.txtalias3 = 1  and (LTRIM(RTRIM((isnull(A.Alias3_Last,'') + ', ' + isnull(A.Alias3_First, '') + ' ' + ISNULL(A.Alias3_Middle, ''))))) <> ','  
		and   (C.Cnty_no = @County OR @County IS NULL) 
		and (C.Clear in( 'O','W')) 
		and (A.InUse is null) 
			and (isnull(c.InUse,0) = 0)
		and c.ishidden = 0   
		and A.CLNO not in (3468,2135) -- Added this by Santosh on 06/24/13 to exclude BAD APPS 
		UNION ALL  
		SELECT C.CrimID SectionID,C.APNO ,C.County,C.Cnty_no, C.Ordered,isnull(A.Alias4_Last,'') Last, isnull(A.Alias4_First, '') First,Null Middle, --ISNULL(A.Alias4_Middle, '') middle,  
		A.DOB as DOB,  
		case when c.Cnty_no = 3906 then  Replace(A.SSN,'-','') else A.SSN end as SSN,  
		ISNULL(C.CRIM_SpecialInstr,'') AS KnownHits  
		From Crim C WITH (NOLOCK) INNER JOIN Appl A WITH (NOLOCK) ON A.APNO = C.APNO   
		WHERE  C.txtalias4 = 1 and (LTRIM(RTRIM((isnull(A.Alias4_Last,'') + ', ' + isnull(A.Alias4_First, '') )))) <> ','  
		--WHERE  C.txtalias4 = 1 and (LTRIM(RTRIM((isnull(A.Alias4_Last,'') + ', ' + isnull(A.Alias4_First, '') + ' ' + ISNULL(A.Alias4_Middle, ''))))) <> ','  
		and   (C.Cnty_no = @County OR @County IS NULL) 
		and (C.Clear in( 'O','W')) 
		and (A.InUse is null) 
			and (isnull(c.InUse,0) = 0)
		and c.ishidden = 0 
		and A.CLNO not in (3468,2135) -- Added this by Santosh on 06/24/13 to exclude BAD APPS 		
		) Qry 
		Order By cast(isnull(Ordered,'1/1/1900') as DateTime)
		

		--IF @County = 2480
		--	Select T.* from #tmpPendingSearches t
	--		inner join (Select distinct top 100  APNO, Ordered From #tmpPendingSearches Order by 2) Q on t.APNO = Q.APNO
	--		where IsNull(T.First,'') <> ''
	--		order by t.Ordered
		--ELSE
		Select * from @tmpPendingSearches 

		--DROP TABLE #tmpPendingSearches


	

