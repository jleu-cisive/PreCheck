-- =============================================
-- Author:		Deepak Vodethela
-- Create date: 12/19/2018
-- Description:	New q-report for the Thoughtonomy IPR Project.  The Virtual Worker needs to be able to pull from this q-report, so the virtual worker can work thru the report numbers to do the In-Progress Review (IPR). 
-- Execution: EXEC RPA_IPR_Data_Pull
-- =============================================
CREATE PROCEDURE [dbo].[RPA_IPR_Data_Pull_New] 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

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

	SELECT  t.APNO as [ReportNumber],t.CLNO as [ClientNumber], t.ClientName, t.ClientCAM, t.Investigator, 
			CASE t.InProgressReviewed 
					WHEN 1 THEN 'Yes'
					WHEN 0 THEN 'No' 
			END AS InProgressReviewed,
			a.EnteredVia,
			c.CAM,
			pm.PackageDesc AS Package,
			cn.NoteText AS [ClientNotes]
	FROM #tmpAppl AS t
	INNER JOIN dbo.Appl AS a(NOLOCK) ON t.APNO = a.APNO
	INNER JOIN dbo.client c(NOLOCK) ON t.CLNO = c.CLNO
	LEFT OUTER JOIN dbo.PackageMain pm(NOLOCK) ON a.PackageID = pm.PackageID
	LEFT OUTER JOIN dbo.ClientNotes cn(NOLOCK) ON A.CLNO = cn.CLNO
	WHERE (cn.NoteText LIKE '%Package Components%' OR cn.NoteText LIKE '%Volunteer Basic includes%')







	
	DROP TABLE #tmpAppl

END
