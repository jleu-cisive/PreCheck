CREATE procedure [PRECHECK\DDegenaro].IRIS_PendingOrdersByCounty
@County int
as

Select Section,SectionID,Apno,County,Ordered,Last,First,Middle,DOB,month(DOB) DOB_MM, Day(DOB) DOB_DD,Year(DOB) DOB_YYYY,SSN,left(SSN,3) SSN1, Case When charindex('-',SSN)>0 then substring(SSN,5,2) else substring(SSN,4,2) end SSN2,right(SSN,4) SSN3,KnownHits --,'Doug' TestField,null Testfield2
From
(
SELECT 'Crim' Section,C.CrimID SectionID,C.APNO ,C.County, C.Ordered,isnull(A.Last,'') Last, isnull(A.First, '') First,ISNULL(A.Middle, '') middle,
A.DOB as DOB,
A.SSN as SSN,
ISNULL(C.CRIM_SpecialInstr,'') AS KnownHits
From Crim C WITH (NOLOCK) INNER JOIN Appl A WITH (NOLOCK) ON A.APNO = C.APNO 
WHERE  C.txtlast = 1 and   (C.Cnty_no = @County) and (C.Clear in( 'O','W')) and (A.InUse is null) and c.ishidden = 0 
UNION ALL
SELECT 'Crim' Section,C.CrimID SectionID,C.APNO ,C.County, C.Ordered,isnull(A.Alias1_Last,'') Last, isnull(A.Alias1_First, '') First,ISNULL(A.Alias1_Middle, '') middle,
A.DOB as DOB,
A.SSN as SSN,
ISNULL(C.CRIM_SpecialInstr,'') AS KnownHits
From Crim C WITH (NOLOCK) INNER JOIN Appl A WITH (NOLOCK) ON A.APNO = C.APNO 
WHERE  C.txtalias = 1  and (LTRIM(RTRIM((isnull(A.Alias1_Last,'') + ', ' + isnull(A.Alias1_First, '') + ' ' + ISNULL(A.Alias1_Middle, ''))))) <> ','
and   (C.Cnty_no = @County) and (C.Clear in( 'O','W')) and (A.InUse is null) and c.ishidden = 0 
UNION ALL
SELECT 'Crim' Section,C.CrimID SectionID,C.APNO ,C.County, C.Ordered,isnull(A.Alias2_Last,'') Last, isnull(A.Alias2_First, '') First,ISNULL(A.Alias2_Middle, '') middle,
A.DOB as DOB,
A.SSN as SSN,
ISNULL(C.CRIM_SpecialInstr,'') AS KnownHits
From Crim C WITH (NOLOCK) INNER JOIN Appl A WITH (NOLOCK) ON A.APNO = C.APNO 
WHERE  C.txtalias2 = 1  and (LTRIM(RTRIM((isnull(A.Alias2_Last,'') + ', ' + isnull(A.Alias2_First, '') + ' ' + ISNULL(A.Alias2_Middle, ''))))) <> ','
and   (C.Cnty_no = @County) and (C.Clear in( 'O','W')) and (A.InUse is null) and c.ishidden = 0 
UNION ALL
SELECT 'Crim' Section,C.CrimID SectionID,C.APNO ,C.County, C.Ordered,isnull(A.Alias3_Last,'') Last, isnull(A.Alias3_First, '') First,ISNULL(A.Alias3_Middle, '') middle,
A.DOB as DOB,
A.SSN as SSN,
ISNULL(C.CRIM_SpecialInstr,'') AS KnownHits
From Crim C WITH (NOLOCK) INNER JOIN Appl A WITH (NOLOCK) ON A.APNO = C.APNO 
WHERE  C.txtalias3 = 1  and (LTRIM(RTRIM((isnull(A.Alias3_Last,'') + ', ' + isnull(A.Alias3_First, '') + ' ' + ISNULL(A.Alias3_Middle, ''))))) <> ','
and   (C.Cnty_no = @County) and (C.Clear in( 'O','W')) and (A.InUse is null) and c.ishidden = 0 
UNION ALL
SELECT 'Crim' Section,C.CrimID SectionID,C.APNO ,C.County, C.Ordered,isnull(A.Alias4_Last,'') Last, isnull(A.Alias4_First, '') First,ISNULL(A.Alias4_Middle, '') middle,
A.DOB as DOB,
A.SSN as SSN,
ISNULL(C.CRIM_SpecialInstr,'') AS KnownHits
From Crim C WITH (NOLOCK) INNER JOIN Appl A WITH (NOLOCK) ON A.APNO = C.APNO 
WHERE  C.txtalias4 = 1 and (LTRIM(RTRIM((isnull(A.Alias4_Last,'') + ', ' + isnull(A.Alias4_First, '') + ' ' + ISNULL(A.Alias4_Middle, ''))))) <> ','
and   (C.Cnty_no = @County) and (C.Clear in( 'O','W')) and (A.InUse is null) and c.ishidden = 0 ) Qry Order By SSN