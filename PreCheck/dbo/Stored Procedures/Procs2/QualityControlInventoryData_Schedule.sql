-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 10/20/2021
-- Description:	HCA Initiative - Automated Inventory Report for C-Suite
-- =============================================
CREATE PROCEDURE dbo.[QualityControlInventoryData_Schedule]
	-- Add the parameters for the stored procedure here
AS
BEGIN
	
	SET NOCOUNT ON;

	IF OBJECT_ID('tempdb..#CAMActivityDetails1') IS NOT NULL
		DROP TABLE #CAMActivityDetails1
	IF OBJECT_ID('tempdb..#TempAPNOLastUpdatedList1') IS NOT NULL
		DROP TABLE #TempAPNOLastUpdatedList1
	IF OBJECT_ID('tempdb..#APNOList1') IS NOT NULL
		DROP TABLE #APNOList1
	IF OBJECT_ID('tempdb..#tmpFinalCAMActivity1') IS NOT NULL
		DROP TABLE #tmpFinalCAMActivity1



	SELECT A.* INTO #APNOList1 
	FROM APPL A with(nolock)
	INNER JOIN dbo.Client c with(nolock) ON a.CLNO = c.CLNO
	WHERE A.ApStatus IN ('P','W') 
	 AND ISNULL(A.Investigator, '') <> ''
	 AND A.userid IS NOT null
	 AND A.UserID NOT IN ('Agonzale','Complian','RTREVINO','cbingham','Cisive','CVendor','AEnsming', '', 'Hollie')
	 AND ISNULL(A.CAM, '') = ''
	 AND ISNULL(c.clienttypeid,-1) <> 15 


	--  SELECT * FROM #APNOList1


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

				--SELECT * FROM #TempAPNOLastUpdatedList1

	-- Get CAM Details
	SELECT	DISTINCT a.CLNO, A.ApStatus, A.APNO, A.ApDate, A.ReopenDate, A.[State] ApplicantState,
			DATEDIFF(DAY, A.ApDate, GETDATE()) AS ElapseDays, A.Last, A.First, C.Name AS ClientName, A.UserID AS ClientCAM,C.AffiliateID, ra.Affiliate,
			CASE WHEN A.InprogressReviewed= 1 THEN 'Yes' ELSE 'No' END as InProgressReviewed, A.EnteredVia, 
			(SELECT MAX(activitydate) FROM applactivity WHERE apno = a.apno and activitycode  = 2)  SentPending, --> Smart Status records
			ISNULL(AAD2.Crim_SelfDisclosed, ISNULL(AAD.Crim_SelfDisclosed,0)) Crim_SelfDisclosed, ISNULL(cc.value,'False') SmartStatusClient,
			ISNULL(empl.cnt,0) emplPendingCount,ISNULL(Educat.cnt,0)  EducatPendingCount,ISNULL(PersRef.cnt,0)  PersRefPendingCount,ISNULL(ProfLic.cnt,0)  ProfLicPendingCount,
			ISNULL(PID.cnt,0)  PIDPendingCount,ISNULL(MedInteg.cnt,0)  MedIntegPendingCount,ISNULL(Crim.cnt,0)  CrimPendingCount,
			ISNULL(CCredit.cnt,0)  CCreditPendingCount,ISNULL(DL.cnt,0)  DLPendingCount, tl.Last_Updated 
			INTO #CAMActivityDetails1
	From #APNOList1 A with(nolock)
	INNER JOIN dbo.Client C WITH(NOLOCK)ON A.CLNO = C.CLNO
	LEFT JOIN (SELECT COUNT(1) cnt, APNO FROM dbo.Empl WITH(NOLOCK) WHERE SectStat IN ('0','9') AND IsOnReport = 1  and apno in (select apno FROM #APNOList1 ) GROUP BY Apno) Empl on A.APNO = Empl.APNO
	LEFT JOIN (SELECT COUNT(1) cnt, APNO FROM dbo.Educat WITH(NOLOCK) WHERE SectStat IN ('0','9') AND IsOnReport = 1 and apno in (select apno FROM #APNOList1 )  GROUP BY Apno) Educat on A.APNO = Educat.APNO
	LEFT JOIN (SELECT COUNT(1) cnt, APNO FROM dbo.PersRef WITH(NOLOCK) WHERE SectStat IN ('0','9') AND IsOnReport = 1 and apno in (select apno FROM #APNOList1 ) GROUP BY Apno) PersRef on A.APNO = PersRef.APNO
	LEFT JOIN (SELECT COUNT(1) cnt, APNO FROM dbo.ProfLic WITH(NOLOCK) WHERE SectStat IN ('0','9') AND IsOnReport = 1 and apno in (select apno FROM #APNOList1 ) GROUP BY Apno) ProfLic on A.APNO = ProfLic.APNO
	LEFT JOIN (SELECT COUNT(1) cnt, APNO FROM dbo.Credit WITH(NOLOCK) WHERE SectStat IN ('0','9') and reptype ='S' and apno in (select apno FROM #APNOList1 ) GROUP BY Apno) PID on A.APNO = PID.APNO
	LEFT JOIN (SELECT COUNT(1) cnt, APNO FROM dbo.Credit WITH(NOLOCK) WHERE SectStat IN ('0','9') and reptype ='C' and apno in (select apno FROM #APNOList1 ) GROUP BY Apno) CCredit on A.APNO = CCredit.APNO
	LEFT JOIN (SELECT COUNT(1) cnt, APNO FROM dbo.MedInteg WITH(NOLOCK) WHERE SectStat IN ('0','9') and apno in (select apno FROM #APNOList1 )  GROUP BY Apno) MedInteg on A.APNO = MedInteg.APNO
	LEFT JOIN (SELECT COUNT(1) cnt, APNO FROM dbo.DL WITH(NOLOCK) WHERE SectStat IN ('0','9') and apno in (select apno FROM #APNOList1 )  GROUP BY Apno) DL on A.APNO = DL.APNO
	LEFT JOIN (SELECT COUNT(1) cnt, APNO FROM dbo.Crim  WITH(NOLOCK) WHERE ISNULL(Clear, '') IN ('','R','M','O', 'V','W','X','E','N','I','Q','Z') and ishidden = 0 and apno in (select apno FROM #APNOList1 ) Group by Apno) Crim on A.APNO = Crim.APNO
	LEFT OUTER JOIN dbo.ApplAdditionalData AAD WITH(NOLOCK) ON (A.CLNO = AAD.CLNO AND  A.SSN = AAD.SSN AND AAD.SSN IS NOT NULL )
	LEFT OUTER JOIN dbo.ApplAdditionalData AAD2 WITH(NOLOCK) ON (A.APNO = AAD2.APNO AND AAD2.APNO IS NOT NULL) 
	LEFT JOIN dbo.clientconfiguration cc WITH(NOLOCK) on c.clno = cc.clno and cc.configurationkey = 'OASIS_InProgressStatus' 
	LEFT JOIN #TempAPNOLastUpdatedList1 tl with(NOLOCK) ON a.APNO	= tl.APNO
	INNER JOIN dbo.refAffiliate ra	ON c.AffiliateID = ra.AffiliateID


	-- Get Report Fields
	Select APNO,ApplicationDate, AvailableDate, ReopenDate, ApplicantState, Last_Updated, ElapsedTimeOnTBF, [ElapsedHoursOnTBF],
			 [Last], [First], ClientName, ClientCAM , CLNO, AffiliateID, Affiliate,InProgressReviewed, EnteredVia
		INTO #tmpFinalCAMActivity1
	FROM (
	Select A.APNO, A.ApDate ApplicationDate, A.SentPending AvailableDate, A.ReopenDate, A.ApplicantState,A.Last_Updated,
		  [dbo].[ElapsedBusinessDays_2](Last_Updated,GETDATE()) AS ElapsedTimeOnTBF, 
		  [dbo].[ElapsedBusinessHours_2](Last_Updated,GETDATE()) [ElapsedHoursOnTBF],
		   A.Last, A.First, A.ClientName, A.ClientCAM, A.CLNO,A.AffiliateID, A.Affiliate, 
		   A.InProgressReviewed, A.EnteredVia
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
	Select A.APNO, A.ApDate ApplicationDate, A.SentPending AvailableDate, A.ReopenDate,A.ApplicantState,
			A.Last_Updated, [dbo].[ElapsedBusinessDays_2](Last_Updated,GETDATE()) AS ElapsedTimeOnTBF,
			[dbo].[ElapsedBusinessHours_2](Last_Updated,GETDATE()) [ElapsedHoursOnTBF],
			A.Last, A.First, A.ClientName, A.ClientCAM,A.CLNO,A.AffiliateID, A.Affiliate, 
			A.InProgressReviewed, A.EnteredVia
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


	SELECT	T.APNO AS [Report Number],	
			T.ElapsedTimeOnTBF ,	
			T.ElapsedHoursOnTBF	
	FROM #tmpFinalCAMActivity1 AS T



END
