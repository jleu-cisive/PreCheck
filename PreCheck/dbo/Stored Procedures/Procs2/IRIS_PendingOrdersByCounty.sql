
---			[IRIS_PendingOrdersByCounty] 597
-- 2287



CREATE procedure [dbo].[IRIS_PendingOrdersByCounty]  
@County int  
as  
--schapyala - 01/05/2013 - modified to return trimmed names 
--schapyala - 01/18/2013 - modified to substitiue the main last or first names when an alias has a missing last or first. - the assumption is that the part of the name was ommitted because it is the same as provided name  
Select Section,SectionID,Apno,County,Ordered,ltrim(rtrim(Last)) Last,ltrim(rtrim(First)) First,ltrim(rtrim(Middle)) Middle,
DOB,
right('00' + convert(varchar(2),month(DOB)),2)  DOB_MM,  right('00' + convert(varchar(2),Day(DOB)),2) DOB_DD,Year(DOB) DOB_YYYY,SSN,left(SSN,3) SSN1, Case When charindex('-',SSN)>0 then substring(SSN,5,2) else substring(SSN,4,2) end SSN2,right(SSN,4) SSN3,KnownHits --,'Doug' TestField,null Testfield2  
into #tempTable
From  
(  
SELECT 'Crim' Section,C.CrimID SectionID,C.APNO ,C.County, C.Ordered,isnull(A.Last,'') Last, isnull(A.First, '') First,ISNULL(A.Middle, '') middle,  
A.DOB as DOB,  
A.SSN as SSN,  
ISNULL(C.CRIM_SpecialInstr,'') AS KnownHits  
From Crim C WITH (NOLOCK) INNER JOIN Appl A WITH (NOLOCK) ON A.APNO = C.APNO   
WHERE  C.txtlast = 1 and   (C.Cnty_no = @County) and (C.Clear in( 'O','W')) and (A.InUse is null) and c.ishidden = 0  
and A.CLNO not in (3468,2135) -- Added this by Santosh on 06/24/13 to exclude BAD APPS 
UNION ALL  
SELECT 'Crim' Section,C.CrimID SectionID,C.APNO ,C.County, C.Ordered,isnull(A.Alias1_Last,A.Last) Last, isnull(A.Alias1_First, A.First) First,ISNULL(A.Alias1_Middle, '') middle,  
A.DOB as DOB,  
A.SSN as SSN,  
ISNULL(C.CRIM_SpecialInstr,'') AS KnownHits  
From Crim C WITH (NOLOCK) INNER JOIN Appl A WITH (NOLOCK) ON A.APNO = C.APNO   
WHERE  C.txtalias = 1  and (LTRIM(RTRIM((isnull(A.Alias1_Last,'') + ', ' + isnull(A.Alias1_First, '') + ' ' + ISNULL(A.Alias1_Middle, ''))))) <> ','  
and   (C.Cnty_no = @County) and (C.Clear in( 'O','W')) and (A.InUse is null) and c.ishidden = 0   
and A.CLNO not in (3468,2135) -- Added this by Santosh on 06/24/13 to exclude BAD APPS 
UNION ALL  
SELECT 'Crim' Section,C.CrimID SectionID,C.APNO ,C.County, C.Ordered,isnull(A.Alias2_Last,A.Last) Last, isnull(A.Alias2_First, A.First) First,ISNULL(A.Alias2_Middle, '') middle,  
A.DOB as DOB,  
A.SSN as SSN,  
ISNULL(C.CRIM_SpecialInstr,'') AS KnownHits  
From Crim C WITH (NOLOCK) INNER JOIN Appl A WITH (NOLOCK) ON A.APNO = C.APNO   
WHERE  C.txtalias2 = 1  and (LTRIM(RTRIM((isnull(A.Alias2_Last,'') + ', ' + isnull(A.Alias2_First, '') + ' ' + ISNULL(A.Alias2_Middle, ''))))) <> ','  
and   (C.Cnty_no = @County) and (C.Clear in( 'O','W')) and (A.InUse is null) and c.ishidden = 0  
and A.CLNO not in (3468,2135) -- Added this by Santosh on 06/24/13 to exclude BAD APPS  
UNION ALL  
SELECT 'Crim' Section,C.CrimID SectionID,C.APNO ,C.County, C.Ordered,isnull(A.Alias3_Last,A.Last) Last, isnull(A.Alias3_First, A.First) First,ISNULL(A.Alias3_Middle, '') middle,  
A.DOB as DOB,  
A.SSN as SSN,  
ISNULL(C.CRIM_SpecialInstr,'') AS KnownHits  
From Crim C WITH (NOLOCK) INNER JOIN Appl A WITH (NOLOCK) ON A.APNO = C.APNO   
WHERE  C.txtalias3 = 1  and (LTRIM(RTRIM((isnull(A.Alias3_Last,'') + ', ' + isnull(A.Alias3_First, '') + ' ' + ISNULL(A.Alias3_Middle, ''))))) <> ','  
and   (C.Cnty_no = @County) and (C.Clear in( 'O','W')) and (A.InUse is null) and c.ishidden = 0   
and A.CLNO not in (3468,2135)-- Added this by Santosh on 06/24/13 to exclude BAD APPS 
UNION ALL  
SELECT 'Crim' Section,C.CrimID SectionID,C.APNO ,C.County, C.Ordered,isnull(A.Alias4_Last,A.Last) Last, isnull(A.Alias4_First, A.First) First,ISNULL(A.Alias4_Middle, '') middle,  
A.DOB as DOB,  
A.SSN as SSN,  
ISNULL(C.CRIM_SpecialInstr,'') AS KnownHits  
From Crim C WITH (NOLOCK) INNER JOIN Appl A WITH (NOLOCK) ON A.APNO = C.APNO   
WHERE  C.txtalias4 = 1 and (LTRIM(RTRIM((isnull(A.Alias4_Last,'') + ', ' + isnull(A.Alias4_First, '') + ' ' + ISNULL(A.Alias4_Middle, ''))))) <> ','  
and   (C.Cnty_no = @County) and (C.Clear in( 'O','W')) and (A.InUse is null) and c.ishidden = 0 
and A.CLNO not in (3468,2135) -- Added this by Santosh on 06/24/13 to exclude BAD APPS 
) Qry Order By SSN


--If @County = 597
--begin
--select  * from #tempTable (nolock) where IsNull(First,'') <> ''  --and cast(Ordered as datetime) > '8/15/2016' --order by  apno
--End
--else
--begin
--select * from #tempTable (nolock) where IsNull(First,'') <> '' 
--end
select * from #tempTable (nolock) where IsNull(First,'') <> '' 
drop table #tempTable
