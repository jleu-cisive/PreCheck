



CREATE PROCEDURE [dbo].[M_InvestigatorReport] 
(
	@name varchar(30)
	--, @startdate varchar(10)
	--, @enddate varchar(10)
    ,@startdate datetime
	, @enddate datetime
)
AS
SET NOCOUNT ON

if( DateDiff(m,@startDate,@enddate) <= 4)
BEGIN
If (select @name) = 'ALL'
begin
	SELECT distinct e.Investigator
		,a.apno
		,a.apdate
		,(SELECT COUNT(*) FROM Empl with (nolock) WHERE (Empl.Apno = A.Apno) AND (Empl.SectStat = '5') and (empl.investigator = e.investigator) AND Empl.IsOnReport = 1) AS Verified
		,(SELECT COUNT(*) FROM Empl with (nolock) WHERE (Empl.Apno = A.Apno) AND (Empl.SectStat = '6') and (empl.investigator = e.investigator) AND Empl.IsOnReport = 1)  AS Unverified_Attached
		,(SELECT COUNT(*) FROM Empl with (nolock) WHERE (Empl.Apno = A.Apno) AND (Empl.SectStat = '7') and (empl.investigator = e.investigator) AND Empl.IsOnReport = 1)  AS Alert_attached
		,(SELECT COUNT(*) FROM Empl with (nolock) WHERE (Empl.Apno = A.Apno) AND (Empl.SectStat = '8') and (empl.investigator = e.investigator) AND Empl.IsOnReport = 1)  AS See_attached
		,(SELECT COUNT(*) FROM Empl with (nolock) WHERE (Empl.Apno = A.Apno) AND (Empl.SectStat = '9') and (empl.investigator = e.investigator) AND Empl.IsOnReport = 1) AS Empl_Count
		,(SELECT COUNT(*) FROM PersRef with (nolock) WHERE (PersRef.Apno = A.Apno) AND (PersRef.SectStat = '9') and (persref.investigator = e.investigator) AND PersRef.IsOnReport = 1) AS PersRef_Count
	FROM dbo.Appl A with (nolock) 
		INNER JOIN dbo.Empl e  with (nolock) ON A.apno = e.apno
	WHERE E.Investigator IN (SELECT UserID FROM dbo.Users with (nolock) WHERE Empl = 1 OR PersRef = 1) AND e.IsOnReport = 1
/*
	--WHERE (A.ApStatus IN ('P','W')) 
	--	AND (A.Investigator = @name)  and   A.apdate BETWEEN CONVERT(DATETIME, @startdate, 102) AND CONVERT(DATETIME, @enddate, 102)
	where e.Investigator in ('A-TEAM','AGARCIA','AHICKS','AJACKSON','ALEX','AMY','ANDREA','ANGIE','ANHLEE','ANNA','APICKENS','AREZA','B-TEAM','BECKY','BILL','BMANN'
		,'BRENDA','C-TEAM','CAROLINE','CBUNN','CCALDARE','CEBIL','CJESSUP','CNELSON','CRIEDING','CRIMINAL','CRYSTAL','CYNTHIA','DANNY','DELMORE','DFORD','DIANA'
		,'DOUGLASS','DSANGERH','DSMITH','DWHITE','ECOPELAN','FCARRILL','FHUBBARD','GCONTRER','GLENN','HELEN','HOLLIE','IMCKINNE','JALEX','JANET','JANICE','JBEEBE'
		,'JCROSSDR','JEAN','JESSICA','JHYLAND','JMURPHY','JOHN','JSOTO','JWHITE','KAY','KESA','KGREEN','KSNOWDEN','KYM','LBAY','LINDA','LINDA T.','LISA','LOU'
		,'LSPILLER','MARIE','MBERG','MBERRYMA','MELLIS','MELNOR','MIKE','MIKEC','MONICA','MONICAJ','MRICO','NAWANEA','NGONZALE','PAT','PENNY','RACHEL','RAFAEL'
		,'RANDALL','RAVEN','RBRANTLE','RHAWKINS','ROBERT','ROVERSTR','RROGERS','RSTEELE','RSTOWE','RUBY','RUSH','SADOLPH','SANDY','SBAZAN','SCOTT','SDRAPELA'
		,'SERENA','SGREEN','SHAHANNA','SHARON','SJORDAN','SMURDOCK','SNORMAN','SONJA','STEPH','SUSAN','SUZANNA','T-TEAM','TAMMY','TANICKA','TEMP 1','TEMP 2'
		,'TEMP 3','TEMP 4','TFORD','TRAINEE','TRAINEE1','TRAINEE2','TRAINING','TTUITT','TWHITE','WATSON','YGARZA','ZDAIGLE','NThanars')
*/
		and (a.apdate  BETWEEN @startdate  AND @enddate+1) and --(e.sectstat <> '0' and e.sectstat <> '9') AND 
		(A.APStatus <> 'M')
end
else
begin
	SELECT DISTINCT e.Investigator
		,e.emplid
		,A.APNO
		,(SELECT COUNT(*) FROM Empl with (nolock) WHERE (Empl.emplid = e.emplid) AND (Empl.SectStat = '5') AND (empl.investigator = @name) AND Empl.IsOnReport = 1) AS Verified
		,(SELECT COUNT(*) FROM Empl with (nolock) WHERE (Empl.emplid = e.emplid) AND (Empl.SectStat = '6') AND (empl.investigator = @name) AND Empl.IsOnReport = 1) AS Unverified_Attached
		,(SELECT COUNT(*) FROM Empl with (nolock) WHERE (Empl.emplid = e.emplid) AND (Empl.SectStat = '7') AND (empl.investigator = @name) AND Empl.IsOnReport = 1) AS Alert_attached
		,(SELECT COUNT(*) FROM Empl with (nolock) WHERE (Empl.emplid = e.emplid) AND (Empl.SectStat = '8') AND (empl.investigator = @name) AND Empl.IsOnReport = 1) AS See_attached
		--,(SELECT COUNT(*) FROM Empl WHERE (empl.emplid = e.emplid) AND (Empl.SectStat = '9') AND (empl.investigator = @name) and (empl.PendingUpdated between @startdate and @enddate) AND Empl.IsOnReport = 1) AS Empl_Count
        ,(SELECT COUNT(*) FROM Empl with (nolock) WHERE (empl.emplid = e.emplid) AND (Empl.SectStat = '9') AND (empl.investigator = @name) and (empl.Last_Worked > @startdate and empl.Last_Worked < @enddate + 1) AND Empl.IsOnReport = 1) AS Empl_Count
		,(SELECT COUNT(*) FROM PersRef with (nolock) WHERE (PersRef.Apno = A.Apno) AND (PersRef.SectStat = '9') AND (PersRef.investigator = @name) AND PersRef.IsOnReport = 1) AS PersRef_Count
	FROM dbo.Appl A with (nolock) 
		INNER JOIN dbo.Empl e with (nolock) ON A.APNO = e.Apno
	WHERE (e.Investigator = @name) AND (e.Last_Worked > @startdate AND e.Last_Worked < @enddate+1) AND e.IsOnReport = 1 AND
		--(e.SectStat <> '9' AND e.SectStat <> '0') AND 
		(A.APStatus <> 'M')
end
END
ELSE
raiserror('Error, the date range provided is too large. Please limit date range to 4 months.',16,1)



SET NOCOUNT OFF

set ANSI_NULLS OFF
set QUOTED_IDENTIFIER OFF




