-- =============================================
-- Author:		Deepak Vodethela
-- Create date: 12/19/2018
-- Description:	New q-report for the Thoughtonomy IPR Project.  The Virtual Worker needs to be able to pull from this q-report, so the virtual worker can work thru the report numbers to do the In-Progress Review (IPR). 
-- Execution: EXEC RPA_IPR_Data_Pull
-- =============================================
CREATE PROCEDURE [dbo].[RPA_IPR_Data_Pull] 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
		SELECT *
			INTO #tmpRPAClients
		FROM [HOU-SQL-01].PreCheck.dbo.client c(nolock)
		WHERE c.CLNO IN
		(
		1023,
		1057,
		1064,
		1087,
		1352,
		1508,
		1523,
		1547,
		1616,
		1617,
		1618,
		1619,
		1620,
		1621,
		1622,
		1623,
		1656,
		1982,
		1986,
		2000,
		2001,
		2003,
		2004,
		2005,
		2007,
		2009,
		2010,
		2129,
		2160,
		2822,
		2947,
		3115,
		3256,
		3494,
		3597,
		3690,
		5543,
		6050,
		6222,
		6600,
		6604,
		6681,
		7077,
		8281,
		8287,
		8394,
		8908,
		9121,
		9388,
		9486,
		9528,
		10047,
		10055,
		10073,
		10295,
		10296,
		10746,
		10747,
		10750,
		10751,
		10752,
		10753,
		10754,
		10756,
		10757,
		10758,
		10759,
		10760,
		10761,
		10762,
		10966,
		11045,
		11340,
		11567,
		11625,
		11771,
		12094,
		12408,
		12802,
		13021,
		13122,
		13127,
		13128,
		13129,
		13187,
		13188,
		13189,
		13190,
		13191,
		13192,
		13193,
		13194,
		13196,
		13198,
		13199,
		13200,
		13201,
		13202,
		13204,
		13205,
		13206,
		13208,
		13209,
		13211,
		13212,
		13213,
		13214,
		13215,
		13216,
		13217,
		13218,
		13220,
		13221,
		13222,
		13223,
		13224,
		13225,
		13226,
		13227,
		13228,
		13229,
		13230,
		13231,
		13232,
		13233,
		13234,
		13235,
		13236,
		13237,
		13238,
		13239,
		13240,
		13241,
		13242,
		13243,
		13244,
		13245,
		13246,
		13248,
		13249,
		13252,
		13253,
		13254,
		13255,
		13256,
		13257,
		13258,
		13259,
		13260,
		13261,
		13262,
		13263,
		13264,
		13266,
		13267,
		13268,
		13269,
		13270,
		13271,
		13272,
		13274,
		13276,
		13277,
		13278,
		13279,
		13280,
		13281,
		13284,
		13286,
		13287,
		13288,
		13289,
		13291,
		13292,
		13294,
		13295,
		13296,
		13297,
		13298,
		13299,
		13300,
		13302,
		13303,
		13304,
		13305,
		13306,
		13307,
		13308,
		13309,
		13310,
		13313,
		13316,
		13318,
		13320,
		13321,
		13322,
		13324,
		13326,
		13327,
		13328,
		13329,
		13330,
		13331,
		13332,
		13333,
		13334,
		13335,
		13337,
		13338,
		13340,
		13343,
		13344,
		13345,
		13346,
		13347,
		13348,
		13350,
		13351,
		13352,
		13353,
		13354,
		13355,
		13357,
		13358,
		13359,
		13361,
		13362,
		13364,
		13365,
		13366,
		13368,
		13369,
		13370,
		13371,
		13372,
		13373,
		13374,
		13375,
		13376,
		13377,
		13378,
		13379,
		13380,
		13381,
		13382,
		13383,
		13384,
		13385,
		13386,
		13387,
		13389,
		13390,
		13392,
		13393,
		13394,
		13395,
		13396,
		13397,
		13398,
		13399,
		13400,
		13401,
		13402,
		13403,
		13404,
		13405,
		13406,
		13408,
		13409,
		13410,
		13412,
		13413,
		13414,
		13415,
		13416,
		13417,
		13418,
		13419,
		13420,
		13421,
		13422,
		13424,
		13425,
		13426,
		13427,
		13428,
		13429,
		13430,
		13431,
		13432,
		13433,
		13435,
		13436,
		13437,
		13438,
		13439,
		13440,
		13441,
		13442,
		13443,
		13444,
		13446,
		13447,
		13448,
		13449,
		13450,
		13451,
		13452,
		13453,
		13454,
		13589,
		13590,
		14026,
		14092,
		14131,
		14247,
		14293,
		14320,
		14321,
		14322,
		14323,
		14324,
		14325,
		14326,
		14327,
		14328,
		14344,
		14360,
		14399,
		14409,
		14607,
		14654,
		14705,
		15354
		)

		SELECT * 
			INTO #tmpRPAPackages
		FROM [HOU-SQL-01].PreCheck.dbo.PackageMain m(nolock) 
		WHERE m.PackageDesc	IN 
		(
		'MHHS Annual ReCheck',
		'MHHS NRC Package',
		'PSL PACK',
		'PractitionerCheck',
		'MHHS Volunteer Pack',
		'MH-HNP Pack',
		'Volunteer w/5 Crim',
		'BROADLANE 1012',
		'Refresh',
		'Basic+',
		'HCA College Package',
		'Practitioner Check',
		'Basic',
		'TMH Volunteer',
		'HCA Surgery Center',
		'HCA Surgery Center K',
		'Practitioner ck',
		'Precheck Basic Package + (3 Crims)',
		'HT - Volunteer/High School',
		'HT - Special',
		'Level 1-5Crim',
		'HPG 12 Volunteers and HS Package',
		'HT - Practitioner Advanced',
		'ReCheck of Providers',
		'PreCheck Volunteer Package',
		'Volunteer Basic',
		'PreCheck Basic +',
		'PreCheck Basic',
		'PreCheck Core',
		'PreCheck Select',
		'HT Practitioner',
		'OH - HomeCare/Hospice: Basic',
		'OH - Volunteer',
		'OH - Director and Above'
		)

SELECT cn.CLNO, cn.NoteText
			INTO #tmpRPAClientNotes
		FROM [HOU-SQL-01].PreCheck.dbo.ClientNotes cn(NOLOCK)
		WHERE cn.CLNO IN (SELECT R.CLNO FROM #tmpRPAClients R )

		--SELECT * FROM dbo.#tmpRPAClients
		--SELECT * FROM dbo.#tmpRPAPackages
		--SELECT * FROM dbo.#tmpRPAClientNotes ORDER BY clno 

		SELECT t1.CLNO,
				STUFF((SELECT DISTINCT ', ' + CAST(NoteText AS VARCHAR(MAX))
						FROM #tmpRPAClientNotes t2
						WHERE t2.CLNO = t1.CLNO
						FOR XML PATH('')),1,1,'') AS NoteText
			INTO #tmpRPAClientNotesInSingleLine
		FROM #tmpRPAClientNotes t1
		GROUP BY t1.CLNO
		ORDER BY clno 

		--SELECT * FROM #tmpRPAClientNotesInSingleLine

		SELECT  a.APNO, a.CLNO AS [ClientNumber] , C.Name AS ClientName,  C.CAM AS ClientCAM, A.Investigator, 
				CASE A.InProgressReviewed 
						WHEN 1 THEN 'Yes'
						WHEN 0 THEN 'No' 
				END AS InProgressReviewed,
				a.EnteredVia,
				c.CAM,
				pm.PackageDesc AS Package,
				n.NoteText AS [ClientNotes],
				a.Priv_Notes as [OasisPrivateNotes],
				al.[first] AS [Applicant First],
				al.middle AS [Appliant Middle],
				al.[last] AS [Applicant Last]
		INTO #RPA
		FROM [HOU-SQL-01].PreCheck.dbo.Appl AS a(NOLOCK) 
		--INNER JOIN [HOU-SQL-01].EnterpriseRST.dbo.dbo.Applicant e(NOLOCK) ON a.APNO = e.ApplicantNumber -- Adding this will only get CIC reports
		INNER JOIN dbo.#tmpRPAClients C(NOLOCK) ON A.CLNO = C.CLNO
		INNER JOIN dbo.#tmpRPAPackages pm(NOLOCK) ON A.PackageID = pm.PackageID	
		LEFT OUTER JOIN [HOU-SQL-01].PreCheck.dbo.ApplAlias al (nolock) ON A.APNO = al.APNO
		INNER JOIN #tmpRPAClientNotesInSingleLine AS N (NOLOCK) ON A.CLNO = N.CLNO
		WHERE IsPrimaryName =  1
		 AND a.EnteredVia IN ('CIC')
		 --Removed 'XML' as it was not tested during UAT
		 AND a.ApStatus = 'P'

		--SELECT * FROM #RPA

		DECLARE @maxalias int;

		select @maxalias =  max(ct)
		from 
		(
		select count(apno) ct
		from [HOU-SQL-01].PreCheck.dbo.applalias
		where IsPrimaryName =  0 
		and apno in (select distinct APNO from #RPA)
		group by apno) A

		--SELECT @maxalias
		--select First,Middle,Last,IsPrimaryName from applalias where apno in (select distinct APNO from #tmpAppl) order by apno

		DECLARE @count INT;
		DECLARE @sqlCommand varchar(125)
		SET @count = 1;

		WHILE @count <= @maxalias
		BEGIN
  
			SET @sqlCommand =  'ALTER TABLE #RPA ADD Alias' + cast(@count as varchar)  +  'First  varchar(50) NULL;'
			EXEC (@sqlCommand)
			SET @sqlCommand = 'ALTER TABLE #RPA ADD Alias'  + cast(@count as varchar) +   'Middle  varchar(50) NULL;'
			EXEC (@sqlCommand)
			SET @sqlCommand = 'ALTER TABLE #RPA ADD Alias'  + cast(@count as varchar) +  'Last  varchar(50) NULL;'
			EXEC (@sqlCommand)

			set @count = @count + 1
		END;

		DECLARE @firstName as NVARCHAR(50);
		DECLARE @middleName as NVARCHAR(50);
		DECLARE @lastName as NVARCHAR(50);
		DECLARE @Row# as INT;
		DECLARE @apno as INT;
		declare @sqlcommand1 as varchar(500);

		DECLARE @PeopleCursor as CURSOR;
 
		SET @PeopleCursor = CURSOR FORWARD_ONLY FOR
		--a.apno -> ReportNumber
		select ROW_NUMBER() OVER(PARTITION BY a.apno ORDER BY b.Last ASC) AS Row#, a.apno, b.First ,b.Middle ,b.Last 
		from #RPA a
		INNER JOIN [HOU-SQL-01].PreCheck.dbo.applalias b(NOLOCK) on a.apno = b.apno
		AND a.apno in ( select apno from #rpa)
		AND b.IsPrimaryName =  0 
 
		OPEN @PeopleCursor;
		FETCH NEXT FROM @PeopleCursor INTO @Row#, @apno, @firstName, @middleName, @lastName;
		 WHILE @@FETCH_STATUS = 0
		BEGIN

			SET @sqlCommand1 = 'UPDate #RPA SET Alias' + cast(@Row# as varchar)  + 'First  = ''' + REPLACE(@firstName, '''', '') + ''' , Alias' + cast(@Row# as varchar)  +  'Middle = ''' + REPLACE(@middleName, '''', '') + ''', Alias' + cast(@Row# as varchar)  +  'Last =  ''' + REPLACE(@lastName, '''', '') + ''''
			SET @sqlCommand1 = @sqlCommand1 + ' where apno = ' + cast(@apno as varchar)
			--print @sqlCommand1

			EXEC (@sqlCommand1)
	 
			FETCH NEXT FROM @PeopleCursor INTO @Row#, @apno, @firstName, @middleName, @lastName;

		END
		CLOSE @PeopleCursor;
		DEALLOCATE @PeopleCursor;
 
		SELECT * FROM #RPA

		DROP TABLE #tmpRPAClients
		DROP TABLE #tmpRPAPackages
		DROP TABLE #RPA
		DROP TABLE #tmpRPAClientNotes
		DROP TABLE #tmpRPAClientNotesInSingleLine
		/*
		--SELECT cn.CLNO, cn.NoteText
		--	INTO #tmpRPAClientNotes
		--FROM [HOU-SQL-01].PreCheck.dbo.ClientNotes cn(NOLOCK)
		--WHERE cn.CLNO IN (SELECT R.CLNO FROM #tmpRPAClients R )

		----SELECT * FROM dbo.#tmpRPAClients
		----SELECT * FROM dbo.#tmpRPAPackages
		--SELECT * FROM dbo.#tmpRPAClientNotes


		--SELECT  a.APNO ,a.CLNO , C.Name AS ClientName,  C.CAM AS ClientCAM, A.Investigator, 
		--		CASE A.InProgressReviewed 
		--				WHEN 1 THEN 'Yes'
		--				WHEN 0 THEN 'No' 
		--		END AS InProgressReviewed,
		--		a.EnteredVia,
		--		c.CAM,
		--		pm.PackageDesc AS Package,
		--		--,n.NoteText AS [Client Notes],
		--		al.[first] AS [Applicant First],
		--		al.middle AS [Appliant Middle],
		--		al.[last] AS [Applicant Last]
		--INTO #RPA
		--FROM [HOU-SQL-01].PreCheck.dbo.Appl AS a(NOLOCK) 
		----INNER JOIN [HOU-SQL-01].EnterpriseRST.dbo.dbo.Applicant e(NOLOCK) ON a.APNO = e.ApplicantNumber -- Adding this will only get CIC reports
		--INNER JOIN dbo.#tmpRPAClients C(NOLOCK) ON A.CLNO = C.CLNO
		--INNER JOIN dbo.#tmpRPAPackages pm(NOLOCK) ON A.PackageID = pm.PackageID	
		--LEFT OUTER JOIN [HOU-SQL-01].PreCheck.dbo.ApplAlias al (nolock) ON A.APNO = al.APNO
		----INNER JOIN #tmpRPAClientNotes AS N (NOLOCK) ON A.CLNO = N.CLNO
		--WHERE IsPrimaryName =  1
		-- AND a.EnteredVia IN ('CIC','XML') 
		-- AND a.ApStatus = 'P'

		----SELECT * FROM #RPA

		--DECLARE @maxalias int;

		--select @maxalias =  max(ct)
		--from 
		--(
		--select count(apno) ct
		--from [HOU-SQL-01].PreCheck.dbo.applalias
		--where IsPrimaryName =  0 
		--and apno in (select distinct APNO from #RPA)
		--group by apno) A

		----SELECT @maxalias
		----select First,Middle,Last,IsPrimaryName from applalias where apno in (select distinct APNO from #tmpAppl) order by apno

		--DECLARE @count INT;
		--DECLARE @sqlCommand varchar(125)
		--SET @count = 1;

		--WHILE @count <= @maxalias
		--BEGIN
  
		--	SET @sqlCommand =  'ALTER TABLE #RPA ADD Alias' + cast(@count as varchar)  +  'First  varchar(50) NULL;'
		--	EXEC (@sqlCommand)
		--	SET @sqlCommand = 'ALTER TABLE #RPA ADD Alias'  + cast(@count as varchar) +   'Middle  varchar(50) NULL;'
		--	EXEC (@sqlCommand)
		--	SET @sqlCommand = 'ALTER TABLE #RPA ADD Alias'  + cast(@count as varchar) +  'Last  varchar(50) NULL;'
		--	EXEC (@sqlCommand)

		--	set @count = @count + 1
		--END;

		--DECLARE @firstName as NVARCHAR(50);
		--DECLARE @middleName as NVARCHAR(50);
		--DECLARE @lastName as NVARCHAR(50);
		--DECLARE @Row# as INT;
		--DECLARE @apno as INT;
		--declare @sqlcommand1 as varchar(500);

		--DECLARE @PeopleCursor as CURSOR;
 
		--SET @PeopleCursor = CURSOR FORWARD_ONLY FOR
		--select ROW_NUMBER() OVER(PARTITION BY a.apno ORDER BY b.Last ASC) AS Row#, a.apno, b.First ,b.Middle ,b.Last 
		--from #RPA a
		--INNER JOIN [HOU-SQL-01].PreCheck.dbo.applalias b(NOLOCK) on a.apno = b.apno
		--AND a.apno in ( select apno from #rpa)
		--AND b.IsPrimaryName =  0 
 
		--OPEN @PeopleCursor;
		--FETCH NEXT FROM @PeopleCursor INTO @Row#, @apno, @firstName, @middleName, @lastName;
		-- WHILE @@FETCH_STATUS = 0
		--BEGIN

		--	SET @sqlCommand1 = 'UPDate #RPA SET Alias' + cast(@Row# as varchar)  + 'First  = ''' + REPLACE(@firstName, '''', '') + ''' , Alias' + cast(@Row# as varchar)  +  'Middle = ''' + REPLACE(@middleName, '''', '') + ''', Alias' + cast(@Row# as varchar)  +  'Last =  ''' + REPLACE(@lastName, '''', '') + ''''
		--	SET @sqlCommand1 = @sqlCommand1 + ' where apno = ' + cast(@apno as varchar)
		--	--print @sqlCommand1

		--	EXEC (@sqlCommand1)
	 
		--	FETCH NEXT FROM @PeopleCursor INTO @Row#, @apno, @firstName, @middleName, @lastName;

		--END
		--CLOSE @PeopleCursor;
		--DEALLOCATE @PeopleCursor;
 
		--SELECT * FROM #RPA

		--DROP TABLE #tmpRPAClients
		--DROP TABLE #tmpRPAPackages
		--DROP TABLE #RPA

		*/


	/*
	SELECT distinct A.Investigator,a.CLNO,A.ApStatus,A.APNO, A.ApDate, A.ReopenDate, DATEDIFF(day, A.ApDate, getdate()) AS ElapseDays, A.SSN, A.Last, A.First, C.Name AS ClientName, A.UserID AS ClientCAM, 
	(select max(activitydate) from applactivity where apno = a.apno and activitycode  = 2)  SentPending,isnull(AAD2.Crim_SelfDisclosed,isnull(AAD.Crim_SelfDisclosed,0)) Crim_SelfDisclosed,isnull(cc.value,'False') SmartStatusClient,
	isnull(empl.cnt,0) emplPendingCount,isnull(Educat.cnt,0)  EducatPendingCount,isnull(PersRef.cnt,0)  PersRefPendingCount,isnull(ProfLic.cnt,0)  ProfLicPendingCount,
	isnull(PID.cnt,0)  PIDPendingCount,isnull(MedInteg.cnt,0)  MedIntegPendingCount,isnull(Crim.cnt,0)  CrimPendingCount,
	isnull(CCredit.cnt,0)  CCreditPendingCount,isnull(DL.cnt,0)  DLPendingCount, isnull(A.InProgressReviewed,0) InProgressReviewed
	into #tmpAppl
	FROM dbo.Appl A with (nolock)  
		INNER JOIN dbo.Client C with (nolock)  ON A.CLNO = C.CLNO
		LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.Empl    with (nolock)   WHERE SectStat IN ('0','9') AND IsOnReport = 1 AND Ishidden = 0 Group by Apno) Empl on A.APNO = Empl.APNO
		LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.Educat  with (nolock)   WHERE SectStat IN ('0','9') AND IsOnReport = 1 AND Ishidden = 0 Group by Apno) Educat on A.APNO = Educat.APNO
		LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.PersRef with (nolock)   WHERE SectStat IN ('0','9') AND IsOnReport = 1 AND Ishidden = 0 Group by Apno) PersRef on A.APNO = PersRef.APNO
		LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.ProfLic  with (nolock)  WHERE SectStat IN ('0','9') AND IsOnReport = 1 AND Ishidden = 0 Group by Apno) ProfLic on A.APNO = ProfLic.APNO
		LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.Credit  with (nolock)   WHERE SectStat IN ('0','9') AND reptype ='S' AND Ishidden = 0 Group by Apno) PID on A.APNO = PID.APNO
		LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.Credit  with (nolock)   WHERE SectStat IN ('0','9') AND reptype ='C' AND Ishidden = 0 Group by Apno) CCredit on A.APNO = CCredit.APNO
		LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.MedInteg with (nolock)  WHERE SectStat IN ('0','9') AND Ishidden = 0 Group by Apno) MedInteg on A.APNO = MedInteg.APNO
		LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.DL      with (nolock)   WHERE SectStat IN ('0','9') AND Ishidden = 0 Group by Apno) DL on A.APNO = DL.APNO
		LEFT JOIN (SELECT COUNT(1) cnt,APNO FROM dbo.Crim	 with (nolock)   WHERE ISNULL(Clear, '') IN ('','R','M','O', 'V','W','X','E','N','I','Q','Z') AND ishidden = 0 Group by Apno) Crim on A.APNO = Crim.APNO
		LEFT OUTER JOIN dbo.ApplAdditionalData AAD with (Nolock) ON ( (A.CLNO = AAD.CLNO AND  A.SSN = AAD.SSN AND AAD.SSN IS NOT NULL ))
		LEFT OUTER JOIN dbo.ApplAdditionalData AAD2 with (Nolock) ON (A.APNO = AAD2.APNO AND  AAD2.APNO IS NOT NULL)	
		left join clientconfiguration cc with (Nolock) on c.clno = cc.clno and cc.configurationkey = 'OASIS_InProgressStatus'	
	WHERE A.ApStatus in ('P','W')
	  AND Isnull(A.Investigator, '') <> ''
	  AND A.userid IS NOT null
	  AND Isnull(A.CAM, '') = ''
	  AND IsNull(c.clienttypeid,-1) <> 15

	CREATE NONCLUSTERED INDEX IX_tmpAppl_ApStatus_SmartStatusClient
	ON [dbo].[#tmpAppl] ([ApStatus],[SmartStatusClient],[ProfLicPendingCount],[PIDPendingCount],[MedIntegPendingCount],[CrimPendingCount])
	INCLUDE ([Investigator],[APNO],[ApDate],[ReopenDate],[ElapseDays],[SSN],[Last],[First],[ClientName],[ClientCAM],[SentPending],[Crim_SelfDisclosed],[emplPendingCount],[EducatPendingCount],[PersRefPendingCount],[CCreditPendingCount],[DLPendingCount],[InProgressReviewed])

	--SELECT * FROM #tmpAppl

	SELECT  t.APNO,t.CLNO, t.ClientName, t.ClientCAM, t.Investigator, 
			CASE t.InProgressReviewed 
					WHEN 1 THEN 'Yes'
					WHEN 0 THEN 'No' 
			END AS InProgressReviewed,
			a.EnteredVia,
			c.CAM,
			pm.PackageDesc AS Package,
			cn.NoteText AS [Client Notes]
	FROM #tmpAppl AS t
	INNER JOIN dbo.Appl AS a(NOLOCK) ON t.APNO = a.APNO
	INNER JOIN dbo.client c(NOLOCK) ON t.CLNO = c.CLNO
	LEFT OUTER JOIN dbo.PackageMain pm(NOLOCK) ON a.PackageID = pm.PackageID
	LEFT OUTER JOIN dbo.ClientNotes cn(NOLOCK) ON A.CLNO = cn.CLNO
	WHERE (cn.NoteText LIKE '%Package Components%' OR cn.NoteText LIKE '%Volunteer Basic includes%')

	DROP TABLE #tmpAppl
	*/
END
