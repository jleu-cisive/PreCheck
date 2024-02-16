

CREATE PROCEDURE [dbo].[M_InvestigatorAllReport] 
(@name varchar(30)
 , @startdate varchar(10)
 , @enddate varchar(10))
AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

-- Report For Bruce Smith 2/5/2004
If @name = 'ALL'
BEGIN
	SELECT DISTINCT 
		A.Investigator
		, A.APNO
		, A.ApDate

		,  (SELECT COUNT(*) 
			FROM dbo.Empl
			WHERE dbo.Empl.Apno = A.Apno
				AND dbo.Empl.SectStat = '5') AS Verified

		,  (SELECT COUNT(*) 
			FROM dbo.Empl
			WHERE dbo.Empl.Apno = A.Apno
				AND dbo.Empl.SectStat = '6') AS Unverified_Attached

		,  (SELECT COUNT(*) 
			FROM dbo.Empl
            WHERE dbo.Empl.Apno = A.Apno
				AND dbo.Empl.SectStat = '7')  AS Alert_Attached

		,  (SELECT COUNT(*) 
			FROM dbo.Empl
            WHERE dbo.Empl.Apno = A.Apno
				AND dbo.Empl.SectStat = '8')  AS See_Attached

		,  (SELECT COUNT(*) 
			FROM dbo.Empl
			WHERE dbo.Empl.Apno = A.Apno
				AND dbo.Empl.SectStat = '9') AS Empl_Count

		,  (SELECT COUNT(*) 
			FROM dbo.PersRef
			WHERE dbo.PersRef.Apno = A.Apno
				AND dbo.PersRef.SectStat = '9') AS PersRef_Count

	FROM dbo.Appl A
		INNER JOIN dbo.Empl E
		ON A.APNO = E.APNO
	-- WHERE (A.ApStatus IN ('P','W')) 
	--  AND (A.Investigator = @name)  and   A.apdate BETWEEN CONVERT(DATETIME, @startdate, 102) AND CONVERT(DATETIME, 
	--                      @enddate, 102)
	WHERE A.Investigator IN (SELECT UserID FROM dbo.Users WHERE Disabled = 0)
		/*
		('A-TEAM','AGARCIA','AHICKS','AJACKSON','ALEX','AMY','ANDREA','ANGIE','ANHLEE'
		,'ANNA','APICKENS','AREZA','B-TEAM','BECKY','BILL','BMANN','BRENDA','C-TEAM','CAROLINE','CBUNN'
		,'CCALDARE','CEBIL','CJESSUP','CNELSON','CRIEDING','CRIMINAL','CRYSTAL','CYNTHIA','DANNY','DELMORE'
		,'DFORD','DIANA','DOUGLASS','DSANGERH','DSMITH','DWHITE','ECOPELAN','FCARRILL','FHUBBARD','GCONTRER'
		,'GLENN','HELEN','HOLLIE','IMCKINNE','JALEX','JANET','JANICE','JBEEBE','JCROSSDR','JEAN','JESSICA'
		,'JHYLAND','JMURPHY','JOHN','JSOTO','JWHITE','KAY','KESA','KGREEN','KSNOWDEN','KYM','LBAY','LINDA'
		,'LINDA T.','LISA','LOU','LSPILLER','MARIE','MBERG','MBERRYMA','MELLIS','MELNOR','MIKE','MIKEC'
		,'MONICA','MONICAJ','MRICO','NAWANEA','NGONZALE','PAT','PENNY','RACHEL','RAFAEL','RANDALL','RAVEN'
		,'RBRANTLE','RHAWKINS','ROBERT','ROVERSTR','RROGERS','RSTEELE','RSTOWE','RUBY','RUSH','SADOLPH'
		,'SANDY','SBAZAN','SCOTT','SDRAPELA','SERENA','SGREEN','SHAHANNA','SHARON','SJORDAN','SMURDOCK'
		,'SNORMAN','SONJA','STEPH','SUSAN','SUZANNA','T-TEAM','TAMMY','TANICKA','TEMP 1','TEMP 2','TEMP 3'
		,'TEMP 4','TFORD','TRAINEE','TRAINEE1','TRAINEE2','TRAINING','TTUITT','TWHITE','WATSON','YGARZA'
		,'ZDAIGLE','NThanars')
		*/
	--'BRENDA','CBUNN','DFORD','CJESSUP','MELLIS','KGREEN','SGREEN','BCAIN','AJACKSON','LBAY','LWILLIAM','ROVERSTR','TWHITE','RAVEN','FHUBBARD','TFORD','TRAINING','APICKENS','DWHITE','NGONZALE','LSPILLER','MRICO','AGARCIA','CRIEDING')  
	--and e.PendingUpdated  BETWEEN CONVERT(DATETIME, @startdate, 101) AND CONVERT(DATETIME,  @enddate , 101) and e.sectstat <> 0
	--and dbo.datepart(a.apdate)  BETWEEN  dbo.datepart(@startdate)  AND  dbo.datepart(@enddate) and (e.sectstat <> 0 and e.sectstat <> 9)
	AND A.ApDate BETWEEN @startdate AND @enddate
	AND A.APStatus <> 'M'
	AND E.SectStat <> '0' 
	AND E.SectStat <> '9'
END
ELSE
BEGIN
	SELECT  distinct  A.Investigator,a.apno,
      
       (SELECT COUNT(*) FROM Empl
	WHERE (Empl.Apno = A.Apno)
	  AND (Empl.SectStat = '5')) AS Verified,
       (SELECT COUNT(*) FROM Empl
	WHERE (Empl.Apno = A.Apno)
	  AND (Empl.SectStat = '6'))  AS Unverified_Attached,
        (SELECT COUNT(*) FROM Empl
            WHERE (Empl.Apno = A.Apno)
	  AND (Empl.SectStat = '7'))  AS Alert_attached,
   (SELECT COUNT(*) FROM Empl
            WHERE (Empl.Apno = A.Apno)
	  AND (Empl.SectStat = '8'))  AS See_attached,
 (SELECT COUNT(*) FROM Empl
	WHERE (Empl.Apno = A.Apno)
	  AND (Empl.SectStat = '9')) AS Empl_Count,
        (SELECT COUNT(*) FROM PersRef
	WHERE (PersRef.Apno = A.Apno)
	  AND (PersRef.SectStat = '9')) AS PersRef_Count
FROM Appl A
JOIN empl e  ON A.apno = e.apno
where (A.Investigator = @name)  and (e.PendingUpdated  BETWEEN  @startdate  AND  @enddate) and (e.sectstat <> '9' and e.sectstat <> '0') AND (A.APStatus <> 'M')
--and dbo.datepart(e.PendingUpdated)  BETWEEN  dbo.datepart(@startdate)  AND  dbo.datepart(@enddate) and (e.sectstat <> 9 or e.sectstat <> 0)
end

SET NOCOUNT OFF
SET TRANSACTION ISOLATION LEVEL READ COMMITTED

