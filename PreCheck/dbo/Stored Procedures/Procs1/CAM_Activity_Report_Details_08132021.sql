
-- =========================================================================================
-- Author:		Radhika Derddy
-- Create date: 08/17/2017
-- Description:	Requested By: Jennifer Prather
-- Creataed a new one since a lot of CAMs are using the same instance of the qrpeort and it is more taxing on the database
-- EXEC [dbo].[CAM_Activity_Report_Details]  NULL 
-- Modified by radhika dereddy on 08/18/2020 to add PackageOrdered,Apstatus, InProgressReviewed, EnteredVia, AffiliateName 
-- =========================================================================================

CREATE PROCEDURE [dbo].[CAM_Activity_Report_Details_08132021]
@CAM varchar(8) = NULL
AS


	IF OBJECT_ID('tempdb..#CAMActivityDetails') IS NOT NULL	
		DROP TABLE #CAMActivityDetails	
	IF OBJECT_ID('tempdb..#TempAPNOLastUpdatedList') IS NOT NULL
		DROP TABLE #TempAPNOLastUpdatedList
	IF OBJECT_ID('tempdb..#APNOList') IS NOT NULL
		DROP TABLE #APNOList
 	IF OBJECT_ID('tempdb..#tempCrim') IS NOT NULL
		DROP TABLE #tempCrim
	IF OBJECT_ID('tempdb..#tempCrimDetailFinal') IS NOT NULL
		DROP TABLE #tempCrimDetailFinal
	IF OBJECT_ID('tempdb..#tempCAMDetailFinal') IS NOT NULL
		DROP TABLE #tempCAMDetailFinal
		

	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	--	DECLARE @CAM varchar(8) = NULL
	SELECT A.* INTO #APNOList 
	FROM APPL A with(nolock)
	INNER JOIN dbo.Client c with(nolock) ON a.CLNO = c.CLNO
	INNER JOIN dbo.refAffiliate ra(NOLOCK) ON C.AffiliateID = ra.AffiliateID
	WHERE (@CAM IS NULL OR A.UserID = @CAM)
	 --AND C.AffiliateID  = IIF(@AffiliateID=0, c.AffiliateID, @AffiliateID) 
	 AND A.ApStatus IN ('P','W') -- Only "Pending/InProgress OR "SmartStatus"
	 AND ISNULL(A.Investigator, '') <> ''
	 AND A.userid IS NOT null
	 AND ISNULL(A.CAM, '') = ''
	 AND ISNULL(c.clienttypeid,-1) <> 15 -- NOT "Reseller" ClientType
	 ORDER BY a.apno DESC

	--  SELECT * FROM #APNOList 


	 SELECT MAX(Last_Updated) AS Last_Updated, APNO INTO #TempAPNOLastUpdatedList
				FROM (
				(SELECT Last_Updated, APNO FROM dbo.Appl WITH(NOLOCK) WHERE apno IN (SELECT apno FROM #APNOList) )
						 UNION ALL
					  (SELECT Last_Updated, APNO FROM dbo.Empl WITH(NOLOCK) WHERE apno IN (SELECT apno FROM #APNOList) and SectStat NOT IN ('0','9') AND IsOnReport = 1 AND Last_Updated IS NOT null )
						 UNION ALL
					  (SELECT Last_Updated, APNO FROM dbo.Educat WITH(NOLOCK) WHERE  apno IN (SELECT apno FROM #APNOList) and SectStat NOT IN ('0','9') AND IsOnReport = 1 AND Last_Updated IS NOT null)
						 UNION ALL
					  (SELECT  Last_Updated, APNO FROM dbo.PersRef WITH(NOLOCK) WHERE  apno IN (SELECT apno FROM #APNOList) and SectStat NOT IN ('0','9') AND IsOnReport = 1 AND Last_Updated IS NOT null) 
						 UNION ALL
					  (SELECT  Last_Updated, APNO FROM dbo.ProfLic WITH(NOLOCK) WHERE  apno IN (SELECT apno FROM #APNOList) and SectStat NOT IN ('0','9') AND IsOnReport = 1 AND Last_Updated IS NOT null)
						 UNION ALL
					  (SELECT Last_Updated, APNO FROM dbo.Credit WITH(NOLOCK) WHERE  apno IN (SELECT apno FROM #APNOList) and SectStat NOT IN ('0','9') and reptype ='S' AND Last_Updated IS NOT null) 
						 UNION ALL
					  (SELECT Last_Updated, APNO FROM dbo.Credit WITH(NOLOCK) WHERE  apno IN (SELECT apno FROM #APNOList) and SectStat NOT IN ('0','9') and reptype ='C' AND Last_Updated IS NOT null)
						 UNION ALL
					  (SELECT Last_Updated, APNO FROM dbo.MedInteg WITH(NOLOCK) WHERE  apno IN (SELECT apno FROM #APNOList) and SectStat NOT IN ('0','9') AND Last_Updated IS NOT null)
						 UNION ALL
					  (SELECT Last_Updated, APNO FROM dbo.DL WITH(NOLOCK) WHERE  apno IN (SELECT apno FROM #APNOList) and SectStat NOT IN ('0','9') AND Last_Updated IS NOT null)
						 UNION ALL
					  (SELECT Last_Updated, APNO FROM dbo.Crim  WITH(NOLOCK) WHERE  apno IN (SELECT apno FROM #APNOList) and ISNULL(Clear, '') NOT IN ('','R','M','O', 'V','W','X','E','N','I','Q','Z') AND ishidden = 0 AND Last_Updated IS NOT null)
					) AS X GROUP BY X.APNO 

				--SELECT * FROM #TempAPNOLastUpdatedList

	-- Get CAM Details
	SELECT	DISTINCT a.CLNO, A.ApStatus, A.APNO, A.ApDate, A.ReopenDate, A.[State] ApplicantState,
			DATEDIFF(DAY, A.ApDate, GETDATE()) AS ElapseDays, A.Last, A.First, C.Name AS ClientName,
			 A.UserID AS ClientCAM, C.AffiliateID, ra.Affiliate,
			 ISNULL(CP.ClientPackageDesc,P.PackageDesc) as PackageOrdered,
			CASE WHEN A.InprogressReviewed= 1 THEN 'Yes' ELSE 'No' END as InProgressReviewed, A.EnteredVia, 
			(SELECT MAX(activitydate) FROM applactivity WHERE apno = a.apno and activitycode  = 2)  SentPending, --> Smart Status records
			ISNULL(AAD2.Crim_SelfDisclosed, ISNULL(AAD.Crim_SelfDisclosed,0)) Crim_SelfDisclosed, ISNULL(cc.value,'False') SmartStatusClient,
			ISNULL(empl.cnt,0) emplPendingCount,ISNULL(Educat.cnt,0)  EducatPendingCount,ISNULL(PersRef.cnt,0) PersRefPendingCount,
			ISNULL(ProfLic.cnt,0)  ProfLicPendingCount,
			ISNULL(PID.cnt,0)  PIDPendingCount,ISNULL(MedInteg.cnt,0)  MedIntegPendingCount,ISNULL(Crim.cnt,0)  CrimPendingCount,
			ISNULL(CCredit.cnt,0)  CCreditPendingCount,ISNULL(DL.cnt,0)  DLPendingCount, tl.Last_Updated 
				INTO #CAMActivityDetails
	From #APNOList A with(nolock)
	INNER JOIN dbo.Client C WITH(NOLOCK)ON A.CLNO = C.CLNO
	LEFT JOIN  dbo.ClientPackages CP ON A.PACKAGEID = CP.PACKAGEID 
	--and A.clno = CP.CLNO
	LEFT JOIN dbo.PackageMain P ON CP.PackageID = P.PackageID 
	LEFT JOIN (SELECT COUNT(1) cnt, APNO FROM dbo.Empl WITH(NOLOCK) WHERE SectStat IN ('0','9') AND IsOnReport = 1  and apno in (select apno FROM #APNOList ) GROUP BY Apno) Empl on A.APNO = Empl.APNO
	LEFT JOIN (SELECT COUNT(1) cnt, APNO FROM dbo.Educat WITH(NOLOCK) WHERE SectStat IN ('0','9') AND IsOnReport = 1 and apno in (select apno FROM #APNOList )  GROUP BY Apno) Educat on A.APNO = Educat.APNO
	LEFT JOIN (SELECT COUNT(1) cnt, APNO FROM dbo.PersRef WITH(NOLOCK) WHERE SectStat IN ('0','9') AND IsOnReport = 1 and apno in (select apno FROM #APNOList ) GROUP BY Apno) PersRef on A.APNO = PersRef.APNO
	LEFT JOIN (SELECT COUNT(1) cnt, APNO FROM dbo.ProfLic WITH(NOLOCK) WHERE SectStat IN ('0','9') AND IsOnReport = 1 and apno in (select apno FROM #APNOList ) GROUP BY Apno) ProfLic on A.APNO = ProfLic.APNO
	LEFT JOIN (SELECT COUNT(1) cnt, APNO FROM dbo.Credit WITH(NOLOCK) WHERE SectStat IN ('0','9') and reptype ='S' and apno in (select apno FROM #APNOList ) GROUP BY Apno) PID on A.APNO = PID.APNO
	LEFT JOIN (SELECT COUNT(1) cnt, APNO FROM dbo.Credit WITH(NOLOCK) WHERE SectStat IN ('0','9') and reptype ='C' and apno in (select apno FROM #APNOList ) GROUP BY Apno) CCredit on A.APNO = CCredit.APNO
	LEFT JOIN (SELECT COUNT(1) cnt, APNO FROM dbo.MedInteg WITH(NOLOCK) WHERE SectStat IN ('0','9') and apno in (select apno FROM #APNOList )  GROUP BY Apno) MedInteg on A.APNO = MedInteg.APNO
	LEFT JOIN (SELECT COUNT(1) cnt, APNO FROM dbo.DL WITH(NOLOCK) WHERE SectStat IN ('0','9') and apno in (select apno FROM #APNOList )  GROUP BY Apno) DL on A.APNO = DL.APNO
	LEFT JOIN (SELECT COUNT(1) cnt, APNO FROM dbo.Crim  WITH(NOLOCK) WHERE ISNULL(Clear, '') IN ('','R','M','O', 'V','W','X','E','N','I','Q','Z') and ishidden = 0 and apno in (select apno FROM #APNOList ) Group by Apno) Crim on A.APNO = Crim.APNO
	LEFT OUTER JOIN dbo.ApplAdditionalData AAD WITH(NOLOCK) ON (A.CLNO = AAD.CLNO AND  A.SSN = AAD.SSN AND AAD.SSN IS NOT NULL )
	LEFT OUTER JOIN dbo.ApplAdditionalData AAD2 WITH(NOLOCK) ON (A.APNO = AAD2.APNO AND AAD2.APNO IS NOT NULL) 
	LEFT JOIN dbo.clientconfiguration cc WITH(NOLOCK) on c.clno = cc.clno and cc.configurationkey = 'OASIS_InProgressStatus' 
	LEFT JOIN #TempAPNOLastUpdatedList tl with(NOLOCK) ON a.APNO = tl.APNO
	INNER JOIN dbo.refAffiliate ra	ON c.AffiliateID = ra.AffiliateID
	--SELECT * FROM #CAMActivityDetails where Apno =  2648676

	--select * from #CAMActivityDetails

		SELECT distinct CLNO, ApStatus, T.APNO, ApDate, ReopenDate, ApplicantState,ElapseDays,Last, First,  ClientName,
			  ClientCAM, AffiliateID, Affiliate,PackageOrdered, InProgressReviewed, EnteredVia, 
			   SentPending,Crim_SelfDisclosed,  SmartStatusClient,
			   emplPendingCount, EducatPendingCount, PersRefPendingCount,
			   ProfLicPendingCount,PIDPendingCount,  MedIntegPendingCount, 
			   CrimPendingCount,CCreditPendingCount, DLPendingCount, T.Last_Updated,
				C.County,
				c2.crimsect + ' - ' + c2.crimdescription as CrimStatus,
				C.CrimEnteredTime,
				C.Ordered as CrimOrderedDateTime,
				C.Last_Updated as CrimLastUpdated
		INTO #tempCrim FROM
		#CAMActivityDetails T
		INNER JOIN dbo.crim c WITH(NOLOCK) on T.apno = c.apno and C.IsHidden =0
		INNER JOIN dbo.Crimsectstat c2 WITH(NOLOCK) ON C.Clear = c2.crimsect
		WHERE C2.Crimsect ='G'

		--SELECT * FROM #tempCrim
		
		SELECT distinct CLNO, ApStatus, T.APNO, ApDate, ReopenDate, ApplicantState,ElapseDays,Last, First,  ClientName,
			 ClientCAM, AffiliateID, Affiliate,PackageOrdered, InProgressReviewed, EnteredVia, 
			 SentPending,Crim_SelfDisclosed,  SmartStatusClient,
			 emplPendingCount, EducatPendingCount, PersRefPendingCount,
			 ProfLicPendingCount,PIDPendingCount,  MedIntegPendingCount, 
			 CrimPendingCount,CCreditPendingCount, DLPendingCount, T.Last_Updated, '' County,
				'' as CrimStatus,
				'' CrimEnteredTime,
				'' as CrimOrderedDateTime,
				'' as CrimLastUpdated
		 INTO #tempCrimDetailFinal 
		 FROM #CAMActivityDetails T WHERE T.APNO NOT IN (SELECT APNO FROM #tempCrim)

		 --SELECT * FROM #tempCrimDetailFinal

		 SELECT CLNO, ApStatus, APNO, ApDate, ReopenDate, ApplicantState,ElapseDays,Last, First,  ClientName,
				ClientCAM, AffiliateID, Affiliate,PackageOrdered, InProgressReviewed, EnteredVia, 
				SentPending,Crim_SelfDisclosed,  SmartStatusClient,
				emplPendingCount, EducatPendingCount, PersRefPendingCount,
				ProfLicPendingCount,PIDPendingCount,  MedIntegPendingCount, 
				CrimPendingCount,CCreditPendingCount, DLPendingCount, Last_Updated,
				County,CrimStatus,CrimEnteredTime,CrimOrderedDateTime,CrimLastUpdated 
		INTO #tempCAMDetailFinal 
		FROM
		 ( 
			 SELECT * FROM #tempCrim
			 UNION ALL
			 SELECT * FROM #tempCrimDetailFinal
		 )A

	-- Get Report Fields
	
	SELECT APNO,ApplicationDate, AvailableDate, ReopenDate, ApplicantState, Last_Updated, ElapsedTimeOnTBF,
			 [ElapsedHoursOnTBF], [Last], [First], CLNO, ClientName, ClientCAM , AffiliateID, Affiliate,
			 PackageOrdered, InProgressReviewed, EnteredVia,
			 County,CrimStatus,CrimEnteredTime,CrimOrderedDateTime,CrimLastUpdated
		INTO #tmpFinalCAMActivity
	FROM 
	(
			SELECT A.APNO, A.ApDate as ApplicationDate, A.SentPending as AvailableDate, A.ReopenDate, A.ApplicantState, A.Last_Updated,
					[dbo].[ElapsedBusinessDays_2](Last_Updated,GETDATE()) AS ElapsedTimeOnTBF, [dbo].[ElapsedBusinessHours_2](Last_Updated,GETDATE()) [ElapsedHoursOnTBF],
					A.Last, A.First, A.CLNO, A.ClientName, A.ClientCAM, A.AffiliateID, A.Affiliate, A.PackageOrdered, 
					A.InProgressReviewed, A.EnteredVia,
					A.County,
					A.CrimStatus ,
					A.CrimEnteredTime,
					A.CrimOrderedDateTime,
					A.CrimLastUpdated
			FROM #tempCAMDetailFinal A
			--#CAMActivityDetails A
			WHERE A.ApStatus in ('P','W')
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

			SELECT A.APNO, A.ApDate as ApplicationDate,A.SentPending as AvailableDate, A.ReopenDate, A.ApplicantState, 
				   A.Last_Updated, [dbo].[ElapsedBusinessDays_2](Last_Updated,GETDATE()) AS ElapsedTimeOnTBF,
					[dbo].[ElapsedBusinessHours_2](Last_Updated,GETDATE()) [ElapsedHoursOnTBF],
					A.Last, A.First, A.CLNO, A.ClientName, A.ClientCAM, A.AffiliateID, A.Affiliate, 
					A.PackageOrdered, A.InProgressReviewed, A.EnteredVia,
					A.County,
					A.CrimStatus ,
					A.CrimEnteredTime,
					A.CrimOrderedDateTime,
					A.CrimLastUpdated
			FROM #tempCAMDetailFinal A
			--#CAMActivityDetails A
			WHERE A.ApStatus = 'P'
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


	SELECT	T.APNO AS [Report Number], 
			FORMAT(T.ApplicationDate,'MM/dd/yyyy hh:mm tt') AS ApplicationDate, 
			FORMAT(T.AvailableDate,'MM/dd/yyyy hh:mm tt') AS AvailableDate, 
			FORMAT(T.ReopenDate,'MM/dd/yyyy hh:mm tt') AS ReopenDate, 
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
			T.PackageOrdered,
			T.InProgressReviewed,
			T.EnteredVia, 
			T.County,
			T.CrimStatus,
			T.CrimEnteredTime,
			T.CrimOrderedDateTime,
			T.CrimLastUpdated
		--INTO #tempCrim
		FROM #tmpFinalCAMActivity AS T
		
		

	

	--SELECT * FROM #tmpFinalCAMActivity AS T


--SET NOCOUNT OFF
--SET TRANSACTION ISOLATION LEVEL READ COMMITTED
