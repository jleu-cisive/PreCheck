-- =============================================
-- Author:		Humera Ahmed
-- Create date: 1/2/2020
-- Description:	HDT #63949 - Daily scheduled report for client #15660 - To display component information for any report in a pending status.
-- EXEC DailyEmailReport_BCStatusReport 15660
-- =============================================
CREATE PROCEDURE [dbo].[DailyEmailReport_BCStatusReport]
	-- Add the parameters for the stored procedure here
	
	@CLNO int 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	if OBJECT_ID('tempdb..#AllPendingLicenses') IS NOT NULL DROP TABLE #AllPendingLicenses
	if OBJECT_ID('tempdb..#EmploymentPending') IS NOT NULL DROP TABLE #EmploymentPending
	if OBJECT_ID('tempdb..#EducationPending') IS NOT NULL DROP TABLE #EducationPending
	if OBJECT_ID('tempdb..#CrimPending') IS NOT NULL DROP TABLE #CrimPending
	if OBJECT_ID('tempdb..#SanctionCheckPending') IS NOT NULL DROP TABLE #SanctionCheckPending
	if OBJECT_ID('tempdb..#PIDPending') IS NOT NULL DROP TABLE #PIDPending

	SELECT 
	a.First +' '+ a.Last [Applicant Name],
	ase.APNO [Report Number],
	FORMAT(a.ApDate, 'MM/dd/yyyy hh:mm:ss tt') [Report Start Date],
	a.Pos_Sought [Position],
	dbo.elapsedbusinessdays_2(cc.ClientCertUpdated, CURRENT_TIMESTAMP) AS [Elapsed Biz Days],
	FORMAT(max(ase.ETADate), 'MM/dd/yyyy') [ETA]
	INTO #AllPendingLicenses
	From dbo.Appl a 
	INNER JOIN dbo.ApplSectionsETA ase ON a.APNO = ase.Apno
	LEFT JOIN dbo.ClientCertification cc ON a.APNO = cc.APNO
	GROUP BY ase.Apno, a.CLNO, a.ApStatus, a.First, a.Last, a.ApDate, a.Pos_Sought, a.origcompdate, cc.ClientCertUpdated
	Having 
	a.CLNO = @CLNO 
	AND a.ApStatus = 'P'

	SELECT 
	Count(e.EmplID) as [Employment Count],
	apl.[Report Number]
	INTO #EmploymentPending 
	FROM #AllPendingLicenses apl
	Left JOIN dbo.Empl e ON apl.[Report Number] = E.APNO
	WHERE 
		--E.IsOnReport = 1 
		E.IsHidden = 0
		AND (E.EmplID IS NULL 
		OR E.sectstat IN ('0','9','8'))
	GROUP BY apl.[Report Number]

	SELECT 
		Count(Ed.EducatID) as [Education Count],
		apl.[Report Number]
	INTO #EducationPending 
	FROM #AllPendingLicenses apl
	LEFT JOIN Educat Ed ON apl.[Report Number] =Ed.APNO 
	WHERE 
		--Ed.IsOnReport = 1 
		 Ed.IsHidden = 0
		And (Ed.EducatID IS NULL 
		OR Ed.sectstat IN ('0','9','8'))
	GROUP BY apl.[Report Number]

	SELECT 
		Count(Cr.CrimID) as [Criminal Count],
		apl.[Report Number]
		INTO #CrimPending 
		FROM #AllPendingLicenses apl 
		LEFT JOIN Crim Cr ON apl.[Report Number] =Cr.APNO
		WHERE 
			Cr.ishidden = 0 
			AND (Cr.CrimID IS NULL 
			OR ISNULL(Cr.Clear,'') not in ('T','F')) 
		GROUP BY apl.[Report Number]

	SELECT 
		Count(mi.APNO) as [SanctionCheck Count],
		apl.[Report Number]
		INTO #SanctionCheckPending 
		FROM #AllPendingLicenses apl 
		LEFT JOIN dbo.MedInteg mi ON apl.[Report Number] =mi.APNO
		WHERE 
			mi.ishidden = 0  
			And (mi.APNO IS NULL 
			OR mi.sectstat IN ('0','9','8'))
		GROUP BY apl.[Report Number]

	SELECT 
		Count(c.APNO) as [PID Count],
		apl.[Report Number]
		INTO #PIDPending 
		FROM #AllPendingLicenses apl 
		LEFT JOIN dbo.Credit c ON apl.[Report Number] =c.APNO
		WHERE 
			c.ishidden = 0 
			AND c.RepType = 'S' 
			And (c.APNO IS NULL 
			OR c.sectstat IN ('0','9','8'))
		GROUP BY apl.[Report Number]

	--SELECT * FROM #AllPendingLicenses apl
	--SELECT * FROM #EmploymentPending ep
	--SELECT * FROM #EducationPending ep
	--SELECT * FROM #CrimPending cp
	--SELECT  *FROM #SanctionCheckPending scp

	SELECT 
		apl.[Applicant Name],
		apl.[Report Number],
		apl.[Report Start Date],
		apl.Position,
		CASE WHEN cp.[Criminal Count]>0 THEN 'Pending' ELSE 'Closed' END [Public Records], 
		CASE WHEN ep.[Employment Count] >0 THEN 'Pending' ELSE 'Closed' END [Employment], 
		CASE WHEN ep2.[Education Count] >0 THEN 'Pending' ELSE 'Closed' END [Education],
		CASE WHEN scp.[SanctionCheck Count] >0 THEN 'Pending' ELSE 'Closed' END [Sanction Check],
		CASE WHEN p.[PID Count] >0 THEN 'Pending' ELSE 'Closed' END [Identification Verification],
		apl.ETA,
		apl.[Elapsed Biz Days] [TAT] 
	FROM #AllPendingLicenses apl 
	LEFT JOIN #CrimPending cp ON apl.[Report Number] = cp.[Report Number]
	LEFT JOIN #EmploymentPending ep ON apl.[Report Number] = ep.[Report Number]
	LEFT JOIN #EducationPending ep2 ON apl.[Report Number] = ep2.[Report Number]
	LEFT JOIN #SanctionCheckPending scp ON apl.[Report Number] = scp.[Report Number]
	LEFT JOIN #PIDPending p ON apl.[Report Number] = p.[Report Number]
END
