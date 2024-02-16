




CREATE PROCEDURE [dbo].[M_InvestigatorRefActReport]  @name varchar(30), @startdate varchar(10), @enddate varchar(10)  AS


if( DateDiff(m,@startDate,@enddate) <= 4)
BEGIN
If (select @name) = 'ALL'
begin
SELECT  distinct p.Investigator,a.apno,a.apdate,
      
       (SELECT COUNT(*) FROM persref with (nolock) 
	WHERE (persref.Apno = A.Apno)
	  AND (persref.SectStat = '5') and (persref.investigator = p.investigator)) AS Verified,
       (SELECT COUNT(*) FROM persref with (nolock) 
	WHERE (persref.Apno = A.Apno)
	  AND (persref.SectStat = '6') and (persref.investigator = p.investigator))  AS Unverified_Attached,
        (SELECT COUNT(*) FROM persref with (nolock) 
            WHERE (persref.Apno = A.Apno)
	  AND (persref.SectStat = '7') and (persref.investigator = p.investigator))  AS Alert_attached,
   (SELECT COUNT(*) FROM persref with (nolock) 
            WHERE (Persref.Apno = A.Apno)
	  AND (Persref.SectStat = '8') and (persref.investigator = p.investigator))  AS See_attached,
 (SELECT COUNT(*) FROM persref with (nolock) 
	WHERE (persref.Apno = A.Apno)
	  AND (persref.SectStat = '9') and (persref.investigator = p.investigator)) AS Empl_Count,
        (SELECT COUNT(*) FROM PersRef with (nolock) 
	WHERE (PersRef.Apno = A.Apno)
	  AND (PersRef.SectStat = '9') and (persref.investigator = p.investigator)) AS PersRef_Count
FROM Appl A with (nolock) 
JOIN persref p  with (nolock) ON A.apno = p.apno
-- WHERE (A.ApStatus IN ('P','W')) 
--  AND (A.Investigator = @name)  and   A.apdate BETWEEN CONVERT(DATETIME, @startdate, 102) AND CONVERT(DATETIME, 
--                      @enddate, 102)
where (p.PendingUpdated   BETWEEN @startdate  AND @enddate) and (p.sectstat <> 0 and p.sectstat <> '9')

end
else
begin
SELECT DISTINCT p.Investigator,p.persrefid, A.APNO,
                          (SELECT     COUNT(*)
                            FROM          persref with (nolock) 
                            WHERE    (persref.persrefid = p.persrefid) AND (persref.SectStat = '5') AND (persref.investigator = @name)) AS Verified,
                          (SELECT     COUNT(*)
                            FROM          persref with (nolock) 
                            WHERE      (persref.persrefid = p.persrefid) AND (persref.SectStat = '6') AND (persref.investigator = @name)) AS Unverified_Attached,
                          (SELECT     COUNT(*)
                            FROM          persref with (nolock) 
                            WHERE    (persref.persrefid = p.persrefid) AND (persref.SectStat = '7') AND (persref.investigator = @name)) AS Alert_attached,
                          (SELECT     COUNT(*)
                            FROM         persref with (nolock) 
                            WHERE     (persref.persrefid = p.persrefid) AND (persref.SectStat = '8') AND (persref.investigator = @name)) AS See_attached,
                          (SELECT     COUNT(*)
                            FROM          persref with (nolock) 
                            WHERE     (persref.apno = a.apno) AND (persref.SectStat = '9') AND (persref.investigator = @name) and (persref.PendingUpdated between @startdate and @enddate)) AS Empl_Count,
                          (SELECT     COUNT(*)
                            FROM          PersRef with (nolock) 
                            WHERE      (PersRef.Apno = A.Apno) AND (PersRef.SectStat = '9') AND (PersRef.investigator = @name)) AS PersRef_Count
FROM         dbo.Appl A with (nolock) INNER JOIN
                      dbo.persref p with (nolock) ON A.APNO = p.Apno
WHERE     (p.Investigator = @name) AND (p.PendingUpdated BETWEEN @startdate AND @enddate) AND (p.SectStat <> '9' AND p.SectStat <> '0')
end

END
ELSE
raiserror('Error, the date range provided is too large. Please limit date range to 4 months.',16,1)




