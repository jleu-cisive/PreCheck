



--ReportByStatusPerModule_Select 0,'2/1/2019','2/8/2019','ProfLic','PENDING',0





--Added  webstatus by veena on nov 14th 
CREATE PROCEDURE [dbo].[ReportByStatusPerModule_Select] (@Clno int, @bDate datetime, @eDate datetime,@tablename varchar(50),@SectStatDescription varchar(50),@webstatus int=0)
AS
IF @tablename = 'Empl'
BEGIN 
IF @Clno=0 
   SELECT a.APNO
	
     , CONVERT(varchar(10),ApDate,101) as ApDate
     , c.CLNO
	     , c.Name
     , Employer
     , a.UserID
     , s.Description
     , e.Pub_Notes 
     , e.Investigator
 ,a.priv_notes as PrivateNotes --Added By Veena on Nov 20th  
	,w.description
	
FROM dbo.Appl a with (nolock)
 inner  JOIN dbo.Empl e (nolock) ON e.APNO=a.APNO
 inner  JOIN dbo.SectStat s (nolock) ON s.Code=e.SectStat
 inner JOIN dbo.Client c (nolock)ON c.CLNO = a.CLNO
inner Join  dbo.Websectstat w(nolock) on e.web_status=w.code
WHERE ApDate >= @bDate AND ApDate < @eDate AND s.Description in (@SectStatDescription) and  e.IsOnReport = 1 
AND   e.Web_Status = Case When @webstatus = 0 then e.Web_Status else @webstatus end --Added by veena on nov 14th
ORDER BY ApDate





--Report on schools that may not be completed, because of holiday closures
ELSE IF @Clno >0 
SELECT a.APNO
	,a.priv_notes as PrivateNotes  --Added By Veena on Nov 20th
     , CONVERT(varchar(10),ApDate,101) AS ApDate
     , c.CLNO
     , c.Name
     , Employer
     , a.UserID
     , s.Description
     , e.Pub_Notes 
     , e.Investigator
	,w.description
FROM dbo.Appl a with (nolock)
	inner JOIN dbo.Empl e (nolock) ON e.APNO=a.APNO
	inner JOIN dbo.SectStat s(nolock) ON s.Code=e.SectStat
    inner JOIN dbo.Client c(nolock) ON c.CLNO = a.CLNO
	inner Join  dbo.Websectstat w(nolock) on e.web_status=w.code

WHERE ApDate >= @bDate AND ApDate < @eDate and c.CLNO=@Clno AND s.Description in (@SectStatDescription) and e.IsOnReport = 1 and 
  e.Web_Status = (case When @webstatus = 0 then e.Web_Status else @webstatus end)-- Added by Veena on Nov 14th
ORDER BY ApDate

END

 ELSE IF @tablename='ProfLic'

BEGIN 
IF @Clno=0 
   SELECT a.APNO
     ,a.priv_notes as PrivateNotes --Added By Veena on Nov 20th 
     , CONVERT(varchar(10),ApDate,101) AS ApDate
     , c.CLNO
     , c.Name
     , a.UserID
	 , p.Lic_Type
	 , p.State
     , s.Description
     , p.Pub_Notes 
     , p.Investigator
	,w.description 
FROM dbo.Appl a with (nolock)
     inner JOIN ProfLic p (nolock)ON p.APNO=a.APNO
      inner JOIN dbo.SectStat s (nolock)ON s.Code=p.SectStat
     inner JOIN dbo.Client c (nolock)ON c.CLNO = a.CLNO
	inner join  dbo.Websectstat w(nolock) on p.web_status=w.code

WHERE ApDate >= @bDate AND ApDate < @eDate AND s.Description IN (@SectStatDescription) AND p.IsOnReport = 1 
AND   p.Web_Status = Case When @webstatus = 0 then p.Web_Status else @webstatus end -- Added by Veena on Nov 14th
ORDER BY ApDate





--Report on schools that may not be completed, because of holiday closures
ELSE IF @Clno >0 
SELECT a.APNO
	 ,a.priv_notes as PrivateNotes  --Added By Veena on Nov 20th
     , CONVERT(varchar(10),ApDate,101) AS ApDate
     , c.CLNO
     , c.Name
     , a.UserID
     , s.Description
     , p.Pub_Notes 
     , p.Investigator
	,w.description
FROM dbo.Appl a with (nolock)
     inner JOIN ProfLic p (nolock)ON p.APNO=a.APNO
      inner JOIN dbo.SectStat s (nolock)ON s.Code=p.SectStat
     inner JOIN dbo.Client c (nolock)ON c.CLNO = a.CLNO
	inner join  dbo.Websectstat w(nolock) on p.web_status=w.code

WHERE ApDate >= @bDate AND ApDate < @eDate AND c.CLNO=@Clno AND s.Description IN (@SectStatDescription) AND p.IsOnReport = 1 
AND   p.Web_Status = Case When @webstatus = 0 then p.Web_Status else @webstatus end -- Added by Veena on Nov 14th
ORDER BY ApDate

END
ELSE IF @tablename = 'Educat'
BEGIN
IF @Clno=0 
   SELECT a.APNO
	 ,a.priv_notes as PrivateNotes --Added By Veena on Nov 20th 
     , CONVERT(varchar(10),ApDate,101) AS ApDate
	,  (isnull(First,'') +' '+ isnull(Middle,'') +' '+ isnull(Last,'') )As Applicant
,Attn as Recruiter

     , c.CLNO
     , c.Name
     , a.UserID
	 , edu.School
	 , edu.CampusName
     , s.Description
     , edu.Pub_Notes 
     , edu.Investigator
	,w.description
FROM dbo.Appl a with (nolock)
     inner JOIN dbo.Educat edu(nolock) ON edu.APNO=a.APNO
     inner JOIN dbo.SectStat s (nolock)ON s.Code= edu.SectStat
     inner JOIN dbo.Client c(nolock) ON c.CLNO = a.CLNO
	inner join  dbo.Websectstat w(nolock) on edu.web_status=w.code

WHERE ApDate >= @bDate AND ApDate < @eDate AND s.Description IN (@SectStatDescription) AND edu.IsOnReport = 1
AND   edu.Web_Status = Case When @webstatus = 0 then edu.Web_Status else @webstatus end -- Added by Veena on Nov 14th
ORDER BY ApDate





--Report on schools that may not be completed, because of holiday closures
ELSE IF @Clno >0 
SELECT a.APNO
		,a.priv_notes as PrivateNotes  --Added By Veena on Nov 20th
     , CONVERT(varchar(10),ApDate,101) AS ApDate
,  (isnull(First,'') +' '+ isnull(Middle,'') +' '+ isnull(Last,'') )As Applicant
,Attn as Recruiter
     , c.CLNO
     , c.Name
     , a.UserID
	 , edu.School
	 , edu.CampusName
     ,s.Description
     , edu.Pub_Notes 
     , edu.Investigator
	,w.description
FROM dbo.Appl a with (nolock)
     inner JOIN Educat edu (nolock)ON edu.APNO=a.APNO
     inner JOIN dbo.SectStat s(nolock) ON s.Code=edu.SectStat
     inner JOIN dbo.Client c(nolock) ON c.CLNO = a.CLNO
	inner join  dbo.Websectstat w(nolock) on edu.web_status=w.code


WHERE ApDate >= @bDate AND ApDate < @eDate AND c.CLNO=@Clno AND s.Description IN (@SectStatDescription) AND edu.IsOnReport = 1 
AND   edu.Web_Status = Case When @webstatus = 0 then edu.Web_Status else @webstatus end -- Added by Veena on Nov 14th
ORDER BY ApDate



END

ELSE IF @tablename = 'PersRef'
BEGIN
IF @Clno=0 
   SELECT a.APNO
	 ,a.priv_notes as PrivateNotes  --Added By Veena on Nov 20th
     , CONVERT(varchar(10),ApDate,101) AS ApDate
     , c.CLNO
     , c.Name
     , a.UserID
	 , prf.Name AS ContactPerson
     , s.Description
     , prf.Pub_Notes 
     , prf.Investigator
	,w.description
FROM dbo.Appl a with (nolock)
     inner JOIN PersRef prf (nolock)ON prf.APNO=a.APNO
     inner JOIN dbo.SectStat s (nolock)ON s.Code=prf.SectStat
     inner JOIN dbo.Client c (nolock)ON c.CLNO = a.CLNO
		inner join  dbo.Websectstat w(nolock) on prf.web_status=w.code

WHERE ApDate >= @bDate AND ApDate < @eDate AND s.Description IN (@SectStatDescription) AND prf.IsOnReport = 1
 AND   prf.Web_Status = Case When @webstatus = 0 then prf.Web_Status else @webstatus end -- Added by Veena on Nov 14th
ORDER BY ApDate





--Report on schools that may not be completed, because of holiday closures
ELSE IF @Clno >0 
SELECT a.APNO
	 ,a.priv_notes as PrivateNotes  --Added By Veena on Nov 20th
     , CONVERT(varchar(10),ApDate,101) AS ApDate
     , c.CLNO
     , c.Name
     , a.UserID
	 , prf.Name AS ContactPerson
     , s.Description
     , prf.Pub_Notes 
     , prf.Investigator
	,w.description
FROM dbo.Appl a with (nolock)
     inner JOIN PersRef prf(nolock) ON prf.APNO=a.APNO
     inner JOIN dbo.SectStat s (nolock)ON s.Code=prf.SectStat
     inner JOIN dbo.Client c (nolock)ON c.CLNO = a.CLNO
	 inner join  dbo.Websectstat w(nolock) on prf.web_status=w.code

WHERE ApDate >= @bDate AND ApDate < @eDate AND c.CLNO=@Clno AND s.Description IN (@SectStatDescription) AND prf.IsOnReport = 1 and
  prf.Web_Status = Case When @webstatus = 0 then prf.Web_Status else @webstatus end -- Added by Veena on Nov 14th
ORDER BY ApDate

END

ELSE IF @tablename = 'DL'
BEGIN
IF @Clno=0 
   SELECT a.APNO
	 ,a.priv_notes as PrivateNotes  --Added By Veena on Nov 20th
     , CONVERT(varchar(10),ApDate,101) AS ApDate
     , c.CLNO
     , c.Name
     , a.UserID
	 , dl.Ordered
     , s.Description
,w.description
FROM dbo.Appl a with (nolock)
     inner JOIN dbo.DL dl (nolock)ON dl.APNO=a.APNO
     inner JOIN dbo.SectStat s (nolock)ON s.Code= dl.SectStat
     inner JOIN dbo.Client c (nolock)ON c.CLNO = a.CLNO
	inner join  dbo.Websectstat w(nolock) on dl.web_status=w.code

WHERE ApDate >= @bDate AND ApDate < @eDate AND s.Description IN (@SectStatDescription) 
AND   dl.Web_Status = Case When @webstatus = 0 then dl.Web_Status else @webstatus end -- Added by Veena on Nov 14th
ORDER BY ApDate



--Report on schools that may not be completed, because of holiday closures
ELSE IF @Clno >0 
SELECT a.APNO
	 ,a.priv_notes as PrivateNotes  --Added By Veena on Nov 20th
     , CONVERT(varchar(10),ApDate,101) AS ApDate
     , c.CLNO
     , c.Name
     , a.UserID
     , dl.Ordered
     , s.Description
	,w.description

FROM dbo.Appl a with (nolock)
     inner JOIN dbo.DL dl (nolock)ON dl.APNO=a.APNO
     inner JOIN dbo.SectStat s (nolock)ON s.Code= dl.SectStat
     inner JOIN dbo.Client c (nolock)ON c.CLNO = a.CLNO
	inner join  dbo.Websectstat w(nolock) on dl.web_status=w.code

WHERE ApDate >= @bDate AND ApDate < @eDate AND c.CLNO=@Clno AND s.Description IN (@SectStatDescription) and
  dl.Web_Status = Case When @webstatus = 0 then dl.Web_Status else @webstatus end -- Added by Veena on Nov 14th
ORDER BY ApDate

END
ELSE IF @tablename = 'Credit'
BEGIN
IF @Clno=0 
   SELECT a.APNO
     ,a.priv_notes as PrivateNotes --Added By Veena on Nov 20th  
     , CONVERT(varchar(10),ApDate,101) AS ApDate
     , c.CLNO
     , c.Name
     , a.UserID
     , Description
     
FROM dbo.Appl a with (nolock)
     inner JOIN Credit cr (nolock)ON cr.APNO=a.APNO
     inner JOIN dbo.SectStat s (nolock)ON s.Code=cr.SectStat
     inner JOIN dbo.Client c (nolock)ON c.CLNO = a.CLNO
WHERE ApDate >= @bDate AND ApDate < @eDate AND Description IN (@SectStatDescription) --AND cr.RepType = 'C'
ORDER BY ApDate





--Report on schools that may not be completed, because of holiday closures
ELSE IF @Clno >0 
SELECT a.APNO
	 ,a.priv_notes as PrivateNotes  --Added By Veena on Nov 20th
     , CONVERT(varchar(10),ApDate,101) AS ApDate
     , c.CLNO
     , c.Name
     , a.UserID
     , Description
     
FROM dbo.Appl a with (nolock)
     inner JOIN Credit cr (nolock)ON cr.APNO=a.APNO
     inner JOIN dbo.SectStat s (nolock) ON s.Code=cr.SectStat
     inner JOIN dbo.Client c (nolock)ON c.CLNO = a.CLNO
WHERE ApDate >= @bDate AND ApDate < @eDate AND c.CLNO=@Clno AND Description IN (@SectStatDescription) AND cr.RepType = 'C'
ORDER BY ApDate
END

ELSE IF @tablename = 'PI'
BEGIN
IF @Clno=0 
   SELECT a.APNO
     ,a.priv_notes as PrivateNotes --Added By Veena on Nov 20th  
     , CONVERT(varchar(10),ApDate,101) AS ApDate
     , c.CLNO
     , c.Name
     , a.UserID
     , Description
     
FROM dbo.Appl a with (nolock)
     inner JOIN Credit cr (nolock)ON cr.APNO=a.APNO
     inner JOIN dbo.SectStat s (nolock)ON s.Code=cr.SectStat 
     inner JOIN dbo.Client c (nolock)ON c.CLNO = a.CLNO
WHERE ApDate >= @bDate AND ApDate < @eDate AND Description IN (@SectStatDescription) AND cr.RepType = 'S'
ORDER BY ApDate





--Report on schools that may not be completed, because of holiday closures
ELSE IF @Clno >0 
SELECT a.APNO
	 ,a.priv_notes as PrivateNotes  --Added By Veena on Nov 20th
     , CONVERT(varchar(10),ApDate,101) AS ApDate
     , c.CLNO
     , c.Name
     , a.UserID
     , Description
     
FROM dbo.Appl a with (nolock)
     inner JOIN Credit cr (nolock)ON cr.APNO=a.APNO
     inner JOIN dbo.SectStat s (nolock) ON s.Code=cr.SectStat
     inner JOIN dbo.Client c (nolock)ON c.CLNO = a.CLNO
WHERE ApDate >= @bDate AND ApDate < @eDate AND c.CLNO=@Clno AND Description IN (@SectStatDescription) AND cr.RepType = 'S'
ORDER BY ApDate
END













