

/******************************************************************
Procedure Name : [dbo].[CAM_Activity_Report_DetailXX] 
Requested By: Dana Sangerhausen
Developer: Deepak Vodethela
Execution : 	EXEC [dbo].[CAM_Activity_Report_DetailXX] NULL,0
Modified By: Amy Liu on 06/18/2018 HDT34696:This report is hanging up
Modified By: Deepak Vodethela on 05/23/2018 HDT52316
-- Modified By Radhika Dereddy on 12/09/2020 to correct the changes added from [CAM_Activity_Report_Details]
-- Modified by Sahithi 1/18/2022 : Added new column Original Close Date
-- Modified by Andy 2/2/2022 : added an index to Crim table and also to one of the temp tables
******************************************************************/

CREATE PROCEDURE [dbo].[CAM_Activity_Report_DetailXX]
(
@CAM varchar(8) = NULL,
@AffiliateID int = 0
)
AS


--DECLARE @CAM varchar(8) = NULL,
--@AffiliateID int = 4

	IF OBJECT_ID('tempdb..#CAMActivityDetails1') IS NOT NULL
	BEGIN
		DROP TABLE #CAMActivityDetails1
	END
	IF OBJECT_ID('tempdb..#TempAPNOLastUpdatedList1') IS NOT NULL
		DROP TABLE #TempAPNOLastUpdatedList1
	IF OBJECT_ID('tempdb..#APNOList1') IS NOT NULL
		DROP TABLE #APNOList1
	IF OBJECT_ID('tempdb..#tmpFinalCAMActivity1') IS NOT NULL
		DROP TABLE #tmpFinalCAMActivity1

			SET NOCOUNT ON;
			SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	--	DECLARE @CAM varchar(8) = NULL
	SELECT A.* INTO #APNOList1 
	FROM APPL A with(nolock)
	INNER JOIN dbo.Client c with(nolock) ON a.CLNO = c.CLNO
	INNER JOIN dbo.refAffiliate ra(NOLOCK) ON C.AffiliateID = ra.AffiliateID
	WHERE (@CAM IS NULL OR A.UserID = @CAM)
	 AND C.AffiliateID  = IIF(@AffiliateID=0, c.AffiliateID, @AffiliateID) 
	 AND A.ApStatus IN ('P','W') -- Only "Pending/InProgress OR "SmartStatus"
	 AND ISNULL(A.Investigator, '') <> ''
	 AND A.userid IS NOT null
	 AND ISNULL(A.CAM, '') = ''
	 AND ISNULL(c.clienttypeid,-1) <> 15 -- NOT "Reseller" ClientType
	 ORDER BY a.apno DESC

	--  SELECT * FROM #APNOList 


	 SELECT MAX(Last_Updated) AS Last_Updated, APNO INTO #TempAPNOLastUpdatedList1
				FROM (
				(SELECT Last_Updated, APNO FROM dbo.Appl WITH(NOLOCK) WHERE apno IN (SELECT apno FROM #APNOList1) )
						 UNION ALL
					  (SELECT Last_Updated, APNO FROM dbo.Empl WITH(NOLOCK) WHERE apno IN (SELECT apno FROM #APNOList1) and SectStat NOT IN ('0','9') AND IsOnReport = 1 AND Last_Updated IS NOT null )
						 UNION ALL
					  (SELECT Last_Updated, APNO FROM dbo.Educat WITH(NOLOCK) WHERE  apno IN (SELECT apno FROM #APNOList1) and SectStat NOT IN ('0','9') AND IsOnReport = 1 AND Last_Updated IS NOT null)
						 UNION ALL
					  (SELECT  Last_Updated, APNO FROM dbo.PersRef WITH(NOLOCK) WHERE  apno IN (SELECT apno FROM #APNOList1) and SectStat NOT IN ('0','9') AND IsOnReport = 1 AND Last_Updated IS NOT null) 
						 UNION ALL
					  (SELECT  Last_Updated, APNO FROM dbo.ProfLic WITH(NOLOCK) WHERE  apno IN (SELECT apno FROM #APNOList1) and SectStat NOT IN ('0','9') AND IsOnReport = 1 AND Last_Updated IS NOT null)
						 UNION ALL
					  (SELECT Last_Updated, APNO FROM dbo.Credit WITH(NOLOCK) WHERE  apno IN (SELECT apno FROM #APNOList1) and SectStat NOT IN ('0','9') and reptype ='S' AND Last_Updated IS NOT null) 
						 UNION ALL
					  (SELECT Last_Updated, APNO FROM dbo.Credit WITH(NOLOCK) WHERE  apno IN (SELECT apno FROM #APNOList1) and SectStat NOT IN ('0','9') and reptype ='C' AND Last_Updated IS NOT null)
						 UNION ALL
					  (SELECT Last_Updated, APNO FROM dbo.MedInteg WITH(NOLOCK) WHERE  apno IN (SELECT apno FROM #APNOList1) and SectStat NOT IN ('0','9') AND Last_Updated IS NOT null)
						 UNION ALL
					  (SELECT Last_Updated, APNO FROM dbo.DL WITH(NOLOCK) WHERE  apno IN (SELECT apno FROM #APNOList1) and SectStat NOT IN ('0','9') AND Last_Updated IS NOT null)
						 UNION ALL
					  (SELECT Last_Updated, APNO FROM dbo.Crim  WITH(NOLOCK) WHERE  apno IN (SELECT apno FROM #APNOList1) and ISNULL(Clear, '') NOT IN ('','R','M','O', 'V','W','X','E','N','I','Q','Z') AND ishidden = 0 AND Last_Updated IS NOT null)
					) AS X GROUP BY X.APNO 

				--SELECT * FROM #TempAPNOLastUpdatedList

	-- Get CAM Details
	SELECT	DISTINCT a.CLNO, A.ApStatus, A.APNO, A.ApDate, A.ReopenDate, A.[State] ApplicantState,
			DATEDIFF(DAY, A.ApDate, GETDATE()) AS ElapseDays, A.Last, A.First, C.Name AS ClientName, A.UserID AS ClientCAM,C.AffiliateID, ra.Affiliate,
			--PackageOrdered = ISNULL(CP.ClientPackageDesc,P.PackageDesc),
			CASE WHEN A.InprogressReviewed= 1 THEN 'Yes' ELSE 'No' END as InProgressReviewed, A.EnteredVia, 
			(SELECT MAX(activitydate) FROM applactivity WHERE apno = a.apno and activitycode  = 2)  SentPending, --> Smart Status records
			ISNULL(AAD2.Crim_SelfDisclosed, ISNULL(AAD.Crim_SelfDisclosed,0)) Crim_SelfDisclosed, ISNULL(cc.value,'False') SmartStatusClient,
			ISNULL(empl.cnt,0) emplPendingCount,ISNULL(Educat.cnt,0)  EducatPendingCount,ISNULL(PersRef.cnt,0)  PersRefPendingCount,ISNULL(ProfLic.cnt,0)  ProfLicPendingCount,
			ISNULL(PID.cnt,0)  PIDPendingCount,ISNULL(MedInteg.cnt,0)  MedIntegPendingCount,ISNULL(Crim.cnt,0)  CrimPendingCount,
			ISNULL(CCredit.cnt,0)  CCreditPendingCount,ISNULL(DL.cnt,0)  DLPendingCount, tl.Last_Updated -- DATEDIFF(DAY, Last_Updated, GETDATE()) AS ElapsedTimeOnTBF, Commented by VD to use the [dbo].[ElapsedBusinessDays_2]
			--(CASE WHEN crimsectstat='G' THEN County ELSE NULL END) as County, crimsectstat as CrimStatus,
			--(CASE WHEN crimsectstat='G' THEN CrimEnteredTime ELSE NULL END) as CrimEnteredTime,
			--(CASE WHEN crimsectstat='G' THEN crim.Last_Updated ELSE NULL END) as CrimLastUpdated
			,A.OrigCompDate
			INTO #CAMActivityDetails1
	From #APNOList1 A with(nolock)
	INNER JOIN dbo.Client C WITH(NOLOCK)ON A.CLNO = C.CLNO
	--LEFT JOIN  dbo.ClientPackages CP ON A.PACKAGEID = CP.PACKAGEID and A.clno = CP.CLNO
	--INNER JOIN dbo.PackageMain P ON CP.PackageID = P.PackageID 
	LEFT JOIN (SELECT COUNT(1) cnt, APNO FROM dbo.Empl WITH(NOLOCK) WHERE SectStat IN ('0','9') AND IsOnReport = 1  and apno in (select apno FROM #APNOList1 ) GROUP BY Apno) Empl on A.APNO = Empl.APNO
	LEFT JOIN (SELECT COUNT(1) cnt, APNO FROM dbo.Educat WITH(NOLOCK) WHERE SectStat IN ('0','9') AND IsOnReport = 1 and apno in (select apno FROM #APNOList1 )  GROUP BY Apno) Educat on A.APNO = Educat.APNO
	LEFT JOIN (SELECT COUNT(1) cnt, APNO FROM dbo.PersRef WITH(NOLOCK) WHERE SectStat IN ('0','9') AND IsOnReport = 1 and apno in (select apno FROM #APNOList1 ) GROUP BY Apno) PersRef on A.APNO = PersRef.APNO
	LEFT JOIN (SELECT COUNT(1) cnt, APNO FROM dbo.ProfLic WITH(NOLOCK) WHERE SectStat IN ('0','9') AND IsOnReport = 1 and apno in (select apno FROM #APNOList1 ) GROUP BY Apno) ProfLic on A.APNO = ProfLic.APNO
	LEFT JOIN (SELECT COUNT(1) cnt, APNO FROM dbo.Credit WITH(NOLOCK) WHERE SectStat IN ('0','9') and reptype ='S' and apno in (select apno FROM #APNOList1 ) GROUP BY Apno) PID on A.APNO = PID.APNO
	LEFT JOIN (SELECT COUNT(1) cnt, APNO FROM dbo.Credit WITH(NOLOCK) WHERE SectStat IN ('0','9') and reptype ='C' and apno in (select apno FROM #APNOList1 ) GROUP BY Apno) CCredit on A.APNO = CCredit.APNO
	LEFT JOIN (SELECT COUNT(1) cnt, APNO FROM dbo.MedInteg WITH(NOLOCK) WHERE SectStat IN ('0','9') and apno in (select apno FROM #APNOList1 )  GROUP BY Apno) MedInteg on A.APNO = MedInteg.APNO
	LEFT JOIN (SELECT COUNT(1) cnt, APNO FROM dbo.DL WITH(NOLOCK) WHERE SectStat IN ('0','9') and apno in (select apno FROM #APNOList1 )  GROUP BY Apno) DL on A.APNO = DL.APNO
	LEFT JOIN (SELECT COUNT(1) cnt, APNO FROM dbo.Crim  WITH(NOLOCK) WHERE ISNULL(Clear, '') IN ('','R','M','O', 'V','W','X','E','N','I','Q','Z') and ishidden = 0 and apno in (select apno FROM #APNOList1 ) Group by Apno) Crim on A.APNO = Crim.APNO
	--LEFT JOIN (SELECT COUNT(1) cnt, APNO, MAX(clear) as crimsectstat,MAX(County) as County, MAX(Crimenteredtime) as CrimEnteredTime,MAX(Last_Updated) as Last_Updated FROM dbo.Crim  WITH(NOLOCK) WHERE ISNULL(Clear, '') IN ('G') and ishidden = 0 and apno in (select apno FROM #APNOList1 ) Group by Apno) Crim on A.APNO = Crim.APNO
	LEFT OUTER JOIN dbo.ApplAdditionalData AAD WITH(NOLOCK) ON (A.CLNO = AAD.CLNO AND  A.SSN = AAD.SSN AND AAD.SSN IS NOT NULL )
	LEFT OUTER JOIN dbo.ApplAdditionalData AAD2 WITH(NOLOCK) ON (A.APNO = AAD2.APNO AND AAD2.APNO IS NOT NULL) 
	LEFT JOIN dbo.clientconfiguration cc WITH(NOLOCK) on c.clno = cc.clno and cc.configurationkey = 'OASIS_InProgressStatus' 
	LEFT JOIN #TempAPNOLastUpdatedList1 tl with(NOLOCK) ON a.APNO	= tl.APNO
	INNER JOIN dbo.refAffiliate ra	ON c.AffiliateID = ra.AffiliateID
	--SELECT * FROM #CAMActivityDetails where Apno =  2648676

	CREATE NONCLUSTERED INDEX [xyz]
ON [dbo].[#CAMActivityDetails1] ([emplPendingCount],[EducatPendingCount],[PersRefPendingCount],[ProfLicPendingCount],[PIDPendingCount],[MedIntegPendingCount],[CrimPendingCount],[CCreditPendingCount],[DLPendingCount],[ApStatus])
INCLUDE ([CLNO],[APNO],[ApDate],[ReopenDate],[ApplicantState],[Last],[First],[ClientName],[ClientCAM],[AffiliateID],[Affiliate],[InProgressReviewed],[EnteredVia],[SentPending],[Last_Updated],[OrigCompDate])

	-- Get Report Fields

	Select APNO,ApplicationDate, AvailableDate, ReopenDate, ApplicantState, Last_Updated, ElapsedTimeOnTBF, [ElapsedHoursOnTBF], [Last], [First], ClientName, ClientCAM , CLNO, AffiliateID, Affiliate,
	-- PackageOrdered, 
	InProgressReviewed,	 EnteredVia,OrigCompDate
	--, CrimStatus,CrimEnteredTime,CrimLastUpdated
		INTO #tmpFinalCAMActivity1
	FROM (
	Select A.APNO, A.ApDate ApplicationDate, A.SentPending AvailableDate, A.ReopenDate, A.ApplicantState,A.Last_Updated, [dbo].[ElapsedBusinessDays_2](Last_Updated,GETDATE()) AS ElapsedTimeOnTBF, [dbo].[ElapsedBusinessHours_2](Last_Updated,GETDATE()) [ElapsedHoursOnTBF],
			--A.ElapsedTimeOnTBF, ElapsedTimeOnTBF_NEW, [Hours], 
			A.Last, A.First, A.ClientName, A.ClientCAM, A.CLNO,A.AffiliateID, A.Affiliate, 
			--A.PackageOrdered,
			 A.InProgressReviewed, A.EnteredVia,A.OrigCompDate
			--, CrimStatus,CrimEnteredTime,CrimLastUpdated
	From #CAMActivityDetails1 A
	Where A.ApStatus in ('P','W')
	  AND emplPendingCount = 0
	  AND EducatPendingCount = 0
	  AND PersRefPendingCount = 0
	  AND CCreditPendingCount = 0
	  AND DLPendingCount = 0
	  AND ProfLicPendingCount = 0
	  AND PIDPendingCount = 0
	  AND MedIntegPendingCount = 0
	  AND CrimPendingCount = 0
	UNION ALL
	Select A.APNO, A.ApDate ApplicationDate, A.SentPending AvailableDate, A.ReopenDate,A.ApplicantState, A.Last_Updated, [dbo].[ElapsedBusinessDays_2](Last_Updated,GETDATE()) AS ElapsedTimeOnTBF, [dbo].[ElapsedBusinessHours_2](Last_Updated,GETDATE()) [ElapsedHoursOnTBF],
			--A.ElapsedTimeOnTBF, ElapsedTimeOnTBF_NEW, [Hours], 
			A.Last, A.First, A.ClientName, A.ClientCAM,A.CLNO,A.AffiliateID, A.Affiliate, 
			--A.PackageOrdered,
			 A.InProgressReviewed, A.EnteredVia,A.OrigCompDate
			--, CrimStatus,CrimEnteredTime,CrimLastUpdated
	From #CAMActivityDetails1 A
	Where A.ApStatus = 'P'
	  AND SmartStatusClient = 'True'
	  AND (emplPendingCount > 0
		OR EducatPendingCount > 0
		OR PersRefPendingCount>0
		OR CCreditPendingCount > 0
		OR DLPendingCount > 0)
	  AND ProfLicPendingCount = 0
	  AND PIDPendingCount = 0
	  AND MedIntegPendingCount = 0
	  AND CrimPendingCount = 0 
	  ) AS Q


	SELECT top 10	T.APNO AS [Report Number], 
			FORMAT(T.ApplicationDate,'MM/dd/yyyy hh:mm tt') AS ApplicationDate, 
			FORMAT(T.AvailableDate,'MM/dd/yyyy hh:mm tt') AS AvailableDate, 
			FORMAT(T.ReopenDate,'MM/dd/yyyy hh:mm tt') AS ReopenDate, 
			FORMAT(T.OrigCompDate,'MM/dd/yyyy hh:mm tt') AS [Original Close date],
			FORMAT(T.Last_Updated,'MM/dd/yyyy hh:mm tt') AS Last_Updated, 
			T.ElapsedTimeOnTBF AS [ElapsedDaysOnTBF], 
			(CASE WHEN T.ElapsedTimeOnTBF >= 0 THEN ISNULL(T.ElapsedTimeOnTBF,0) + 1 ELSE T.ElapsedTimeOnTBF END) AS [NextDayRollover],
			T.ElapsedHoursOnTBF,
			ltrim(rtrim(replace(replace(replace(T.Last,char(9),''),char(10),''),char(13),''))) as [Last], 
			ltrim(rtrim(replace(replace(replace(T.First,char(9),''),char(10),''),char(13),''))) as [First],
			T.ApplicantState,
			T.CLNO AS [Client ID],
			REPLACE(T.ClientName,',',' ') as [ClientName],
			T.AffiliateID AS [Affiliate ID],
			T.Affiliate, 
			T.ClientCAM,
			--T.PackageOrdered, 
			T.InProgressReviewed, T.EnteredVia
			-- ,T.CrimStatus, T.CrimEnteredTime, T.CrimLastUpdated
	FROM #tmpFinalCAMActivity1 AS T

	--SELECT * FROM #tmpFinalCAMActivity AS T

	IF OBJECT_ID('tempdb..#TempAPNOLastUpdatedList1') IS NOT NULL
		DROP TABLE #TempAPNOLastUpdatedList1
	IF OBJECT_ID('tempdb..#APNOList1') IS NOT NULL
		DROP TABLE #APNOList1

	DROP TABLE #CAMActivityDetails1
	DROP TABLE #tmpFinalCAMActivity1

	SET NOCOUNT OFF
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED
