

/*---------------------------------------------------------------------------------
Requested By: Dana Sangerhausen
Author: Prasanna
Date : 10/27/2014
Updates: SY: Added column Recruiter, modified CLNO input paramt o accept colon separated list, per HDT from Valerie
         SY: 4/5/2017: Added columns Client ID, Private Notes per HDT 12928 from Valerie K. Salazar
Modified by	Radhika: 06/13/2017 - to add components PID and PersRef to the report.
Modified by	Radhika: 08/29/2018 - Fix AffiliateID and Add TAT column
Modified by	dEEPAK: 08/30/2018 - Add IsOneHr column and Parameter
Modified by	Radhika: 08/30/2018 - Fixed IsOneHr and Add CAM column
Modified by	Radhika: 05/29/2019 - Fixed ApDate column in the filter by just using the date part.
Modified by	Deepak: 06/04/2019 - Req#52957-Please this q-report.  When I put in a client number, it is running all client information instead of the one client I put in the search parameters.

EXEC [Client_BackgroundCheck_ReportDetails_For_Client_Or_ClientGroup] 0,'05/01/2019','05/03/2019',230,0
EXEC [Client_BackgroundCheck_ReportDetails_For_Client_Or_ClientGroup] '8424','05/01/2019','05/05/2019',0,0
EXEC [dbo].[Client_BackgroundCheck_ReportDetails_For_Client_Or_ClientGroup] '7519 : 11340','08/01/2018','08/11/2018', '4',0
EXEC [dbo].[Client_BackgroundCheck_ReportDetails_For_Client_Or_ClientGroup] '10660 : 10675 : 10674: 1524: 1034','08/01/2014','09/11/2014',0,0
EXEC [dbo].[Client_BackgroundCheck_ReportDetails_For_Client_Or_ClientGroup] '8424:7519:11340','05/01/2019','05/05/2019',0,0
-- Modified by Radhika Dereddy on 09/09/2020 - Added this because while exporting the columns to excel the length of Priv_notes field is 214766 for APNO =5179533) 
-- and many of more so adding the max length of the excel to accommodate the export.
Modified by	Joshua Ates: 10/14/2021 - Rewrote query to increase speed dramatically. 


*/---------------------------------------------------------------------------------

CREATE PROCEDURE [dbo].[Client_BackgroundCheck_ReportDetails_For_Client_Or_ClientGroup_CA] 
	@Clno VARCHAR(MAX)		--=	'8424:7519:11340'
	,@StartDate DATETIME	--=	'05/01/2019'
	,@EndDate DATETIME		--=	'05/05/2019'
	,@Affiliate INT			--=	0
	,@IsOneHr BIT			--=	0
	,@Section VARCHAR(20)='All'  
AS
BEGIN
	IF		(
			@CLNO = '0'
			OR @CLNO = ''
			OR LOWER(@CLNO) = 'null'
			)
	BEGIN
		SET @CLNO = NULL
	END

	DECLARE @CLNOs TABLE 
	(
		Items VARCHAR(10)
	)

	INSERT INTO @CLNOs
	SELECT * FROM [dbo].[Split](':', @clno)

	
	DROP TABLE IF EXISTS #AppData
	DROP TABLE IF EXISTS #DataSet1
	DROP TABLE IF EXISTS #DataSet2
	DROP TABLE IF EXISTS #DataSet3
	DROP TABLE IF EXISTS #DataSet4
	DROP TABLE IF EXISTS #DataSet5
	DROP TABLE IF EXISTS #DataSet6
	DROP TABLE IF EXISTS #DataSet7
	DROP TABLE IF EXISTS #DataSet8

	SELECT 
		 isnull(A.Attn, '') AS [Recruiter]
		,A.APNO AS [Report Number]
		,C.CLNO AS [Client ID]
		,C.Name AS ClientName
		,RA.Affiliate
		,A.UserID AS [CAM]
		,A.First AS [Applicant First Name]
		,A.Last AS [Applicant Last Name]
		,A.Middle AS [Applicant Middle Name]
		--,A.ApDate AS [Date Created]
		--,A.CompDate AS [Report CompletedDate]
		,FORMAT(a.ApDate, 'MM/dd/yyyy hh:mm tt') AS 'Report Create Date'
		,FORMAT(a.OrigCompDate, 'MM/dd/yyyy hh:mm tt') AS 'Original Closed Date'
		,FORMAT(a.ReopenDate, 'MM/dd/yyyy hh:mm tt') AS 'Reopen Date'
		,FORMAT(a.CompDate, 'MM/dd/yyyy hh:mm tt') AS 'Complete Date'
		,A.PackageID
		,[dbo].[ElapsedBusinessDays_2](A.Apdate, A.OrigCompDate) AS [TAT]
		,(
			CASE 
				WHEN F.IsOneHR = 0
					THEN 'False'
				ELSE 'True'
				END
			) AS IsOneHR
		,A.Priv_Notes AS [Private Notes]
		,A.Pub_Notes AS [Public Notes]
	INTO #AppData
	FROM 
		dbo.Appl AS A
	LEFT JOIN 
		@CLNOs AS CLNOS 
		ON a.CLNO = CLNOS.Items 
	INNER JOIN 
		dbo.Client AS C WITH (NOLOCK) 
		ON C.CLNO = A.CLNO
	INNER JOIN dbo.refAffiliate RA WITH (NOLOCK) 
		ON C.AffiliateID = RA.AffiliateID
	LEFT OUTER JOIN 
		HEVN.dbo.Facility F(NOLOCK) ON isnull(A.DeptCode, 0) = F.FacilityNum
	WHERE 
			(CLNOS.Items IS NOT NULL OR @Clno IS NULL)
		AND (convert(DATE, A.Apdate) >= @StartDate)
		AND (convert(DATE, A.Apdate) <= @EndDate)
		AND RA.AffiliateID = IIF(@Affiliate = 0, RA.AffiliateID, @Affiliate)
		AND (@IsOneHR is null or (ISNULL(F.IsOneHR, 0) = @IsOneHR))



BEGIN --DATASET 1
	SELECT 
		 [Report Number]
		,'Employment' AS [Component Type]
		,emp.Employer AS [Component Data]
		,S.Description AS [Record Status]
		,CASE emp.IsHidden
			WHEN 1
				THEN 'UnUsed'
			ELSE 'On Report'
			END AS IsHidden
		,CASE emp.IsOnReport
			WHEN 1
				THEN 'Yes'
			ELSE 'UnUsed'
			END AS IsOnReport
		,emp.Priv_Notes AS [Private Notes]
		,emp.Pub_Notes AS [Public Notes]
	INTO #DataSet1
	FROM #AppData AS A
	INNER JOIN dbo.Empl AS emp WITH (NOLOCK) ON emp.Apno = A.[Report Number]
	INNER JOIN dbo.SectStat AS S WITH (NOLOCK) ON S.Code = emp.SectStat
	WHERE
		LEN(Replace(REPLACE(emp.Priv_Notes, CHAR(10), ';'), CHAR(13), ';')) < 32767
		and @Section IN ('All','Employment')


END

--SELECT * FROM #DataSet1
--SELECT * FROM refAffiliate WHERE Affiliate = 'UTMB Galveston'

BEGIN --DataSet 2
	
	SELECT
		 [Report Number]
		,'Education' AS [Component Type]
		,edu.School AS [Component Data]
		,S.Description AS [Record Status]
		,CASE edu.IsHidden
			WHEN 1
				THEN 'UnUsed'
			ELSE 'On Report'
			END AS IsHidden
		,CASE edu.IsOnReport
			WHEN 1
				THEN 'Yes'
			ELSE 'UnUsed'
			END AS IsOnReport
		,edu.Priv_Notes AS [Private Notes]
		,edu.Pub_Notes AS [Public Notes]
	INTO #DataSet2
	FROM #AppData AS A
	INNER JOIN dbo.Educat AS edu WITH (NOLOCK) ON edu.Apno = A.[Report Number]
	INNER JOIN dbo.SectStat AS S WITH (NOLOCK) ON S.Code = edu.SectStat
    WHERE @Section IN ('All','Education')
		
END
	
BEGIN --DataSet 3

	SELECT
		 [Report Number]
		,'License' AS [Component Type]
		,lic.Lic_type AS [Component Data]
		,S.Description AS [Record Status]
		,CASE lic.IsHidden
			WHEN 1
				THEN 'UnUsed'
			ELSE 'On Report'
			END AS IsHidden
		,CASE lic.IsOnReport
			WHEN 1
				THEN 'Yes'
			ELSE 'UnUsed'
			END AS IsOnReport
		,lic.Priv_Notes AS [Private Notes]
		,lic.Pub_Notes AS [Public Notes]
	INTO #DataSet3
	FROM #AppData AS A
	INNER JOIN dbo.ProfLic AS lic WITH (NOLOCK) ON lic.Apno = A.[Report Number]
	INNER JOIN dbo.SectStat AS S WITH (NOLOCK) ON S.Code = lic.SectStat
	WHERE
		LEN(Replace(REPLACE(Priv_Notes, CHAR(10), ';'), CHAR(13), ';')) < 32767	
	and @Section IN ('All','License')

END


BEGIN --DataSet 4

	SELECT
		 [Report Number]
		,'Public Records' AS [Component Type]
		,crim.County AS [Component Data]
		,css.CrimDescription AS [Record Status]
		,CASE crim.IsHidden
			WHEN 1
				THEN 'UnUsed'
			ELSE 'On Report'
			END AS IsHidden
		,'' AS IsOnReport
		,crim.Priv_Notes AS [Private Notes]
		,crim.Pub_Notes AS [Public Notes]
	INTO #DataSet4
	FROM #AppData AS A
	INNER JOIN dbo.Crim AS crim WITH (NOLOCK) ON crim.Apno = [Report Number]
	INNER JOIN dbo.Crimsectstat AS css WITH (NOLOCK) ON css.crimsect = crim.Clear
	WHERE
		LEN(Replace(REPLACE(Priv_Notes, CHAR(10), ';'), CHAR(13), ';')) < 32767	
		and @Section IN ('All','Criminal')			
END

BEGIN --Dataset 5

	SELECT 
		 [Report Number]
		,'Reference' AS [Component Type]
		,pr.Name AS [Component Data]
		,S.Description AS [Record Status]
		,CASE pr.IsHidden
			WHEN 1
				THEN 'UnUsed'
			ELSE 'On Report'
			END AS IsHidden
		,CASE pr.IsOnReport
			WHEN 1
				THEN 'Yes'
			ELSE 'UnUsed'
			END AS IsOnReport
		,Pr.Priv_Notes AS [Private Notes]
		,PR.Pub_Notes AS [Public Notes]
	INTO #DataSet5
	FROM #AppData AS A
	INNER JOIN dbo.PersRef AS pr WITH (NOLOCK) ON pr.Apno = [Report Number]
	INNER JOIN dbo.SectStat AS S WITH (NOLOCK) ON S.Code = pr.SectStat
	WHERE
		LEN(Replace(REPLACE(Priv_Notes, CHAR(10), ';'), CHAR(13), ';')) < 32767	
		and  @Section IN ('All','Reference')
END


BEGIN --DataSet 6
	
	SELECT
		 [Report Number]
		,'PID' AS [Component Type]
		,'PID' AS [Component Data]
		,S.Description AS [Record Status]
		,CASE pid.IsHidden
			WHEN 1
				THEN 'UnUsed'
			ELSE 'On Report'
			END AS IsHidden
		,'' AS IsOnReport
		,[Private Notes]
		,[Public Notes]
	INTO #DataSet6
	FROM #AppData AS A
	INNER JOIN dbo.Credit AS PID WITH (NOLOCK) ON PID.Apno = A.[Report Number]
	INNER JOIN dbo.SectStat AS S WITH (NOLOCK) ON S.Code = pid.SectStat
	WHERE @Section IN ('All','PID')


END

BEGIN --DataSet 7
			
	SELECT 
		 [Report Number]
		,'SanctionCheck' AS [Component Type]
		,MR.[Status] AS [Component Data]
		,S.Description AS [Record Status]
		,CASE m.IsHidden
			WHEN 1
				THEN 'UnUsed'
			ELSE 'On Report'
			END AS IsHidden
		,'' AS IsOnReport
		,[Private Notes]
		,[Public Notes]
	INTO #DataSet7
	FROM #AppData AS A
	INNER JOIN dbo.MedInteg AS m WITH (NOLOCK) ON m.Apno = [Report Number]
	LEFT OUTER JOIN dbo.MedIntegLog MR ON m.APNO = MR.APNO
	INNER JOIN dbo.SectStat AS S WITH (NOLOCK) ON S.Code = m.SectStat
	WHERE @Section IN ('All','Sanction')

			
END


	SELECT DISTINCT [Recruiter]
		,#AppData.[Report Number]
		,[Client ID]
		,ClientName
		,Affiliate
		,CAM
		,ISNULL(CP.ClientPackageDesc, P.PackageDesc) [Package Ordered]
		,[Applicant First Name]
		,[Applicant Last Name]
		,[Applicant Middle Name]
		,[Component Type]
		,[Component Data]
		,[Record Status]
		,[Report Create Date]
		,[Original Closed Date]
		,[Reopen Date]
		,[Complete Date]
		--,[Date Created]
		--,[Report CompletedDate]
		,IsHidden
		,IsOnReport
		,ISNULL(QRY.[Private Notes],#AppData.[Private Notes]) [Private Notes]
		,ISNULL(QRY.[Public Notes],#AppData.[Public Notes]) [Public Notes] 
		,[TAT]
		,IsOneHR
	FROM (
		
		SELECT * FROM #DataSet1
		UNION
		SELECT * FROM #DataSet2
		UNION
		SELECT * FROM #DataSet3
		UNION
		SELECT * FROM #DataSet4
		UNION
		SELECT * FROM #DataSet5
		UNION
		SELECT * FROM #DataSet6
		UNION
		SELECT * FROM #DataSet7

		) QRY
	INNER JOIN #AppData ON #AppData.[Report Number] = QRY.[Report Number]
	LEFT OUTER JOIN dbo.PackageMain P WITH (NOLOCK) ON #AppData.PackageID = P.PackageID
	LEFT OUTER JOIN dbo.ClientPackages CP WITH (NOLOCK) ON P.PackageID = CP.PackageID


END




