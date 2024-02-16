-- =============================================
-- Author:		Deepak Vodethela	
-- Create date: 02/27/2019
-- Description:	Create an ETA report for HCA to measure Precheck SLA time for all the sections for an APNO. And also to measure which of them take the longest and when will the verification be concluded.
-- Execution: EXEC [dbo].[ETA_Report_for_HCA] '05/01/2019','05/15/2019'
--			  EXEC [dbo].[ETA_Report_for_HCA] NULL, NULL
-- =============================================
--==============================================
-- Updated by : Doug DeGenaro
-- Updated date : 02/27/2019
-- Description: Removed comma from county,state as it was wreaking havoc and creating two columns when creating a CSV
--===============================================
--==============================================
-- Updated by : Doug DeGenaro
-- Ticket : 52979
-- Updated date : 02/27/2019
-- Description: We need to add in the functionality for columns J, O, R, U, & X of this report to display "ETA Unavailable" anytime there is an ETA that is in the past (as defined by a day prior to the current date).
-- EXEC dbo.[ETA_Report_for_HCA_REF52979] NULL, NULL
--===============================================
CREATE PROCEDURE [dbo].[ETA_Report_for_HCA_REF52979] 
	-- Add the parameters for the stored procedure here
 @StartDate	Date,
 @EndDate	Date
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @CLNO INT = 7519
	DECLARE @ETAPASTTRIGGER date = GETDATE()	
	IF (@StartDate IS NULL AND @EndDate IS NULL)
	BEGIN
		SET @StartDate = DATEADD(DAY, -30, CAST(CURRENT_TIMESTAMP AS DATE))
		SET @EndDate = CAST(CURRENT_TIMESTAMP AS DATE)

		--SELECT @StartDate AS StartDate, @EndDate AS EndDate
	END

	DECLARE @tmpCriminal TABLE (
		[ApplSectionID] [int] NOT NULL,
		[SectionName] VARCHAR(25) NOT NULL,
		[Apno] [int] NOT NULL,
		[SectionKeyID] [int] NOT NULL,
		[ETADate] [DATE] NULL,
		[ClientCertUpdated] [DATETIME] NULL,
		[SectStat] VARCHAR(25) NOT NULL,
		[CrimCountyName] VARCHAR(100) NOT NULL,
		[RowNumber] [int] NOT NULL
		)

	DECLARE @tmpEducation TABLE (
		[ApplSectionID] [int] NOT NULL,
		[SectionName] VARCHAR(25) NOT NULL,
		[Apno] [int] NOT NULL,
		[SectionKeyID] [int] NOT NULL,
		[ETADate] [DATE] NULL,
		[ClientCertUpdated] [DATETIME] NULL,
		[SectStat] VARCHAR(25) NOT NULL,
		[SchoolName] VARCHAR(100) NOT NULL,
		[RowNumber] [int] NOT NULL
		)

	DECLARE @tmpEmployment TABLE (
		[ApplSectionID] [int] NOT NULL,
		[SectionName] VARCHAR(25) NOT NULL,
		[Apno] [int] NOT NULL,
		[SectionKeyID] [int] NOT NULL,
		[ETADate] [DATE] NULL,
		[ClientCertUpdated] [DATETIME] NULL,
		[SectStat] VARCHAR(25) NOT NULL,
		[EmployerName] VARCHAR(100) NOT NULL,
		[RowNumber] [int] NOT NULL
		)

	DECLARE @tmpLicense TABLE (
		[ApplSectionID] [int] NOT NULL,
		[SectionName] VARCHAR(25) NOT NULL,
		[Apno] [int] NOT NULL,
		[SectionKeyID] [int] NOT NULL,
		[ETADate] [DATETIME] NULL,
		[ClientCertUpdated] [DATE] NULL,
		[SectStat] VARCHAR(25) NOT NULL,
		[LicenseType] VARCHAR(100) NOT NULL,
		[RowNumber] [int] NOT NULL
		)

	DECLARE @tmpMainSet TABLE (
		[ApplSectionID] [int] NOT NULL,
		[SectionName] VARCHAR(25) NOT NULL,
		[Apno] [int] NOT NULL,
		[SectionKeyID] [int] NOT NULL,
		[ETADate] [DATE] NULL,
		[ClientCertUpdated] [DATETIME] NULL,
		[SectStat] VARCHAR(25) NOT NULL,
		[ETAName] VARCHAR(100) NULL
		)

	DECLARE @tmpAll TABLE (
		[ApplSectionID] [int] NOT NULL,
		[SectionName] VARCHAR(25) NOT NULL,
		[Apno] [int] NOT NULL,
		[SectionKeyID] [int] NOT NULL,
		[ETADate] [DATE] NULL,
		[ClientCertUpdated] [DATETIME] NULL,
		[SectStat] VARCHAR(25) NOT NULL,
		[ETAName] VARCHAR(100) NOT NULL,
		[RowNumber] [int] NOT NULL
		)

	DECLARE @tmpAllMaxETA TABLE (
		[ApplSectionID] [int] NOT NULL,
		[SectionName] VARCHAR(25) NOT NULL,
		[Apno] [int] NOT NULL,
		[SectionKeyID] [int] NOT NULL,
		[ETADate] [DATE] NULL,
		[ClientCertUpdated] [DATETIME] NULL,
		[SectStat] VARCHAR(25) NOT NULL,
		[ETAName] VARCHAR(100) NOT NULL,
		[RowNumber] [int] NOT NULL
		)

	DECLARE @tmpETAForHCA TABLE(
		[Client Number] INT NOT NULL,
		[Client Name] VARCHAR(100) NOT NULL,
		[Report Number] INT NOT NULL,
		[Applicant Name] VARCHAR(100) NOT NULL,
		[Package Ordered] VARCHAR(100) NOT NULL,
		[Process Level] VARCHAR(50) NOT NULL,
		[Process Level Name] VARCHAR(100) NOT NULL,
		[Report Start Date] [DATE] NOT NULL,
		[Report Conclusion ETA] [DATE] NOT NULL,
		[ETADays] INT NOT NULL,
		[Turnaround Time] INT NOT NULL
	)
	
	;WITH Criminal AS
	(
		SELECT  ETA.ApplSectionID, ETA.Apno, ETA.SectionKeyID, ETA.ETADate, C.ClientCertUpdated,
				CASE WHEN CR.[Clear] NOT IN ('T','F','P') THEN ISNULL(CR.[Clear],'') END AS [ConclusiveStatus],
				ISNULL(CR.County ,'') AS County 
		FROM ApplSectionsETA AS ETA(NOLOCK)
		INNER JOIN APPL AS A(NOLOCK) ON ETA.APNO = A.Apno	
		LEFT OUTER JOIN ClientCertification C(NOLOCK) ON ETA.APNO = C.APNO
		LEFT OUTER JOIN dbo.Crim AS CR(NOLOCK) ON ETA.SectionKeyID = CR.CrimID AND ETA.ApplSectionID = 5
		WHERE CR.[Clear] NOT IN ('T','F','P') 
		  AND CR.IsHidden = 0
		  AND A.APSTATUS != 'F'
		  AND C.ClientCertUpdated >= @StartDate 
		  AND C.ClientCertUpdated < DateAdd(d,1,@EndDate) 
		  AND A.Clno IN (SELECT CLNO FROM Client (NOLOCK) WHERE CLNO = @clno OR WebOrderParentCLNO = @clno)
	)
	INSERT INTO @tmpCriminal
	SELECT  X.ApplSectionID, 'Criminal' AS SectionName,  
			X.Apno, X.SectionKeyID, X.ETADate, X.ClientCertUpdated,	ISNULL([ConclusiveStatus],'') AS [SectStat], ISNULL(X.County ,'') AS CrimCounty,
			ROW_NUMBER() OVER (PARTITION BY X.Apno ORDER BY X.ETADate DESC) AS RowNumber
	FROM Criminal AS X

	;WITH Employment AS
	(
		SELECT  ETA.ApplSectionID, ETA.Apno, ETA.SectionKeyID, ETA.ETADate, C.ClientCertUpdated,
				CASE WHEN E.SectStat = '9' THEN ISNULL(E.SectStat,'') END AS [ConclusiveStatus],
				ISNULL(E.Employer,'') as Employer
		FROM ApplSectionsETA AS ETA(NOLOCK)
		INNER JOIN APPL AS A(NOLOCK) ON ETA.APNO = A.Apno	
		LEFT OUTER JOIN ClientCertification C(NOLOCK) ON ETA.APNO = C.APNO
		LEFT OUTER JOIN dbo.EMPL AS E(NOLOCK) ON ETA.SectionKeyID = E.EmplID AND ETA.ApplSectionID = 1
		WHERE E.SectStat IN ('9')
		  AND A.APSTATUS != 'F'
		  AND C.ClientCertUpdated >= @StartDate
		  AND C.ClientCertUpdated < DateAdd(d,1,@EndDate) 
		  AND A.Clno IN (SELECT CLNO FROM Client (NOLOCK) WHERE CLNO = @clno OR WebOrderParentCLNO = @clno)
	)
	INSERT INTO @tmpEmployment
	SELECT  X.ApplSectionID, 'Employment' AS SectionName,  
			X.Apno, X.SectionKeyID, X.ETADate, X.ClientCertUpdated, ISNULL([ConclusiveStatus],'') AS [ConclusiveStatus], ISNULL(X.Employer,'') AS EmplEmployer,
			ROW_NUMBER() OVER (PARTITION BY X.Apno ORDER BY X.ETADate DESC) AS RowNumber
	FROM Employment AS X

	--SELECT * FROM @tmpMainSet t ORDER BY t.Apno

	;WITH Education AS
	(
		SELECT  ETA.ApplSectionID, ETA.Apno, ETA.SectionKeyID, ETA.ETADate, C.ClientCertUpdated,
				CASE WHEN ED.SectStat = '9' THEN ISNULL(ED.SectStat,'')	END AS [ConclusiveStatus],ISNULL(ED.School,'') AS School
		FROM ApplSectionsETA AS ETA(NOLOCK)
		INNER JOIN APPL AS A(NOLOCK) ON ETA.APNO = A.Apno	
		LEFT OUTER JOIN ClientCertification C(NOLOCK) ON ETA.APNO = C.APNO
		LEFT OUTER JOIN dbo.Educat AS ED(NOLOCK) ON ETA.SectionKeyID = ED.EducatID AND ETA.ApplSectionID = 2
		WHERE ED.SectStat IN ('9')
		  AND A.APSTATUS != 'F'
		  AND C.ClientCertUpdated >= @StartDate 
		  AND C.ClientCertUpdated < DateAdd(d,1,@EndDate) 
		 AND A.Clno IN (SELECT CLNO FROM Client (NOLOCK) WHERE CLNO = @clno OR WebOrderParentCLNO = @clno)
	)
	INSERT INTO @tmpEducation
	SELECT  X.ApplSectionID, 'Education' AS SectionName, 
			X.Apno, X.SectionKeyID, X.ETADate, X.ClientCertUpdated, ISNULL([ConclusiveStatus],'') AS [ConclusiveStatus], ISNULL(X.School,'') AS EducatSchool,
			ROW_NUMBER() OVER (PARTITION BY X.Apno ORDER BY X.ETADate DESC) AS RowNumber
	FROM Education AS X

	;WITH ProfessionalLicense AS
	(
		SELECT  ETA.ApplSectionID, ETA.Apno, ETA.SectionKeyID, ETA.ETADate, C.ClientCertUpdated,
				CASE WHEN P.SectStat = '9' THEN ISNULL(P.SectStat,'') END AS [ConclusiveStatus],
				ISNULL(P.Lic_Type,'') AS Lic_Type
		FROM ApplSectionsETA AS ETA(NOLOCK)
		INNER JOIN APPL AS A(NOLOCK) ON ETA.APNO = A.Apno	
		LEFT OUTER JOIN ClientCertification C(NOLOCK) ON ETA.APNO = C.APNO
		LEFT OUTER JOIN dbo.ProfLic AS P(NOLOCK) ON ETA.SectionKeyID = P.ProfLicID AND ETA.ApplSectionID = 4
		WHERE P.SectStat IN ('9')
		  AND A.APSTATUS != 'F'
		  AND C.ClientCertUpdated >= @StartDate 
		  AND C.ClientCertUpdated < DateAdd(d,1,@EndDate) 
		  AND A.Clno IN (SELECT CLNO FROM Client (NOLOCK) WHERE CLNO = @clno OR WebOrderParentCLNO = @clno)
	)
	INSERT INTO @tmpLicense
	SELECT  X.ApplSectionID, 'ProfessionalLicense' AS SectionName,  
			X.Apno, X.SectionKeyID, X.ETADate, X.ClientCertUpdated, ISNULL([ConclusiveStatus],'') AS [ConclusiveStatus], ISNULL(X.Lic_Type,'') AS ProfLicenseLic_Type,
			ROW_NUMBER() OVER (PARTITION BY X.Apno ORDER BY X.ETADate DESC) AS RowNumber
	FROM ProfessionalLicense AS X

	;WITH SanctionCheck AS
	(
		SELECT ETA.ApplSectionID, ETA.Apno, ETA.SectionKeyID, ETA.ETADate, C.ClientCertUpdated,
				CASE WHEN M.SectStat = '9' THEN ISNULL(M.SectStat,'') END AS [ConclusiveStatus]
		FROM ApplSectionsETA AS ETA(NOLOCK)
		INNER JOIN APPL AS A(NOLOCK) ON ETA.APNO = A.Apno	
		LEFT OUTER JOIN ClientCertification C(NOLOCK) ON ETA.APNO = C.APNO
		LEFT OUTER JOIN dbo.MedInteg AS M(NOLOCK) ON ETA.Apno = M.APNO AND ETA.ApplSectionID = 7
		WHERE M.SectStat IN ('9')
		  AND A.APSTATUS != 'F'
		  AND C.ClientCertUpdated >= @StartDate 
		  AND C.ClientCertUpdated < DateAdd(d,1,@EndDate) 
		  AND A.Clno IN (SELECT CLNO FROM Client (NOLOCK) WHERE CLNO = @clno OR WebOrderParentCLNO = @clno)
	)
	INSERT INTO @tmpMainSet
	SELECT X.ApplSectionID, 'SanctionCheck' AS SectionName,  
			Apno, SectionKeyID, ETADate, ClientCertUpdated, ISNULL([ConclusiveStatus],'') AS [ConclusiveStatus], NULL AS [SanctionCheck]
	FROM SanctionCheck AS X

	;WITH MVR AS
	(
		SELECT ETA.ApplSectionID, ETA.Apno, ETA.SectionKeyID, ETA.ETADate, C.ClientCertUpdated,
				CASE WHEN D.SectStat = '9' THEN ISNULL(D.SectStat,'') END AS [ConclusiveStatus]
		FROM ApplSectionsETA AS ETA(NOLOCK)
		INNER JOIN APPL AS A(NOLOCK) ON ETA.APNO = A.Apno	
		LEFT OUTER JOIN ClientCertification C(NOLOCK) ON ETA.APNO = C.APNO
		LEFT OUTER JOIN dbo.DL AS D(NOLOCK) ON ETA.Apno = D.APNO AND ETA.ApplSectionID = 6
		WHERE D.SectStat IN ('9')
		  AND A.APSTATUS != 'F'
		  AND C.ClientCertUpdated >= @StartDate 
		  AND C.ClientCertUpdated < DateAdd(d,1,@EndDate) 
		  AND A.Clno IN (SELECT CLNO FROM Client (NOLOCK) WHERE CLNO = @clno OR WebOrderParentCLNO = @clno)
	)
	INSERT INTO @tmpMainSet
	SELECT X.ApplSectionID, 'MVR' AS SectionName, 
			Apno, SectionKeyID, ETADate, ClientCertUpdated, ISNULL([ConclusiveStatus],'') AS [ConclusiveStatus], NULL AS [MVR]
	FROM MVR AS X


	--SELECT * FROM @tmpMainSet t ORDER BY T.Apno

	INSERT INTO @tmpMainSet
		SELECT tc.ApplSectionID, tc.SectionName, tc.Apno, tc.SectionKeyID, tc.ETADate, tc.ClientCertUpdated, tc.SectStat, tc.CrimCountyName FROM @tmpCriminal tc
		UNION ALL
		SELECT te.ApplSectionID, te.SectionName, te.Apno, te.SectionKeyID, te.ETADate, te.ClientCertUpdated, te.SectStat, te.SchoolName FROM @tmpEducation te
		UNION ALL
		SELECT te.ApplSectionID, te.SectionName, te.Apno, te.SectionKeyID, te.ETADate, te.ClientCertUpdated, te.SectStat, te.EmployerName FROM @tmpEmployment te
		UNION ALL
		SELECT tl.ApplSectionID, tl.SectionName, tl.Apno, tl.SectionKeyID, tl.ETADate, tl.ClientCertUpdated, tl.SectStat, tl.LicenseType FROM @tmpLicense tl

		--SELECT * FROM @tmpMainSet t ORDER BY T.Apno

	INSERT INTO @tmpAll
	SELECT	M.ApplSectionID, M.SectionName, M.Apno, M.SectionKeyID, M.ETADate, M.ClientCertUpdated, M.SectStat, ISNULL(M.ETAName,'') AS ETAName,
			ROW_NUMBER() OVER (PARTITION BY M.Apno ORDER BY M.ETADate DESC, M.SectionName ASC) AS RowNumber
	FROM @tmpMainSet M ORDER BY M.Apno 

	--SELECT * FROM @tmpAll a ORDER BY a.Apno	


	INSERT INTO @tmpAllMaxETA
	SELECT A.ApplSectionID, A.SectionName, A.Apno, A.SectionKeyID, A.ETADate, A.ClientCertUpdated, A.SectStat, A.ETAName, A.RowNumber
	FROM @tmpAll A 
	WHERE A.RowNumber = 1

	INSERT INTO @tmpETAForHCA
		SELECT DISTINCT
			   A.CLNO AS [Client Number], 
			   C.[Name] AS [Client Name], 
			   ETA.APNO as [Report Number], 
			   A.First + ' ' + A.Last AS [Applicant Name] , 
			   ISNULL(P.[PackageDesc],'') AS [Package Ordered], 
			   ISNULL(A.DeptCode,'') AS [Process Level],
			   ISNULL(f.FacilityName,'') AS [Process Level Name],
			   ETA.[ClientCertUpdated] AS [Report Start Date], 
			   CONVERT(varchar, ETADate, 101) AS [Report Conclusion ETA],
			   [dbo].[ElapsedBusinessDays_2](CONVERT(varchar,ETA.[ClientCertUpdated], 101),CONVERT(varchar, ETADate, 101)) AS [ETADays],
			   [dbo].[ElapsedBusinessDays_2](ETA.[ClientCertUpdated],CURRENT_TIMESTAMP) AS [Turnaround Time]
		FROM @tmpAllMaxETA AS ETA
		INNER JOIN Appl AS A(NOLOCK) ON ETA.APNO = A.APNO
		LEFT OUTER JOIN [HEVN].DBO.Facility f(NOLOCK) ON A.DeptCode = F.FacilityNum AND F.EmployerID IN (SELECT CLNO FROM Client (NOLOCK) WHERE CLNO = @clno OR WebOrderParentCLNO = @clno AND IsInactive = 0)
		LEFT OUTER JOIN Client AS C(NOLOCK) ON A.CLNO = C.CLNO
		LEFT OUTER JOIN PackageMain AS P(NOLOCK) ON P.PackageID = A.PackageID
		WHERE A.ApStatus NOT IN ('F','M')
		  AND A.OrigCompDate IS NULL
		  AND C.IsInactive = 0
		  AND A.Clno IN (SELECT CLNO FROM Client (NOLOCK) WHERE CLNO = @clno OR WebOrderParentCLNO = @clno AND C.IsInactive = 0)


		SELECT  t.[Client Number], t.[Client Name], t.[Report Number], t.[Applicant Name], t.[Package Ordered], t.[Process Level], 
				t.[Process Level Name], CONVERT(varchar,[MainDB].[dbo].[fnGetEstimatedBusinessDate_2](t.[Report Start Date],5),101) AS [Notification Date],
				t.[Report Start Date], t.[Report Conclusion ETA], 
				CASE when DATEDIFF(d,@ETAPASTTRIGGER,t.[Report Conclusion ETA]) < 0 then 'ETA Unavailable' else cast(t.[Report Conclusion ETA] as varchar(100)) end as [Report Conclusion ETA] ,--J
				 t.ETADays AS [Current ETA Days], t.[Turnaround Time] AS [Current Turnaround Time],
				P.[Pending Criminal Count], 
				REPLACE(P.[Longest ETA Criminal],',',' ') as [Longest ETA Criminal], 
				CASE when DATEDIFF(d,@ETAPASTTRIGGER,P.[Longest Criminal ETA]) < 0 then 'ETA Unavailable' else cast(P.[Longest Criminal ETA] as varchar(100)) end as [Longest Criminal ETA],--O
				--P.[Longest Criminal ETA],--O 
				Edu.[Pending Education Count], 
				Edu.[Longest ETA Education] AS [Longest ETA Education], 
				--CONVERT(varchar, Edu.[Longest Education ETA], 101) AS [Longest Education ETA],
				CASE when DATEDIFF(d,@ETAPASTTRIGGER,Edu.[Longest Education ETA]) < 0 then 'ETA Unavailable' else cast(Edu.[Longest Education ETA] as varchar(100)) end as [Longest Education ETA], --R
				--Edu.[Longest Education ETA], --R
				Emp.[Pending Employment Count],
				Emp.[Longest ETA Employment], 
				--CONVERT(varchar, Emp.[Longest Employment ETA], 101) AS [Longest Employment ETA],
				CASE when DATEDIFF(d,@ETAPASTTRIGGER,Emp.[Longest Employment ETA]) < 0 then 'ETA Unavailable' else cast(Emp.[Longest Employment ETA] as varchar(100)) end as [Longest Employment ETA], --U
				--Emp.[Longest Employment ETA], --U
				Lic.[Pending License Count], 
				Lic.[Longest ETA License], 
				--CONVERT(varchar,Lic.[Longest License ETA], 101) AS [Longest License ETA]
				CASE when DATEDIFF(d,@ETAPASTTRIGGER,Lic.[Longest License ETA]) < 0 then 'ETA Unavailable' else cast(Lic.[Longest License ETA] as varchar(100)) end as [Longest License ETA] --X
				--Lic.[Longest License ETA] --X
		FROM @tmpETAForHCA t 
		LEFT OUTER JOIN (SELECT tc.Apno, CAST(tc.ETADate AS DATE) AS [Longest Criminal ETA], tc.CrimCountyName AS [Longest ETA Criminal], C.[Pending Criminal Count]
						 FROM @tmpCriminal tc 
						 INNER JOIN (SELECT tc.Apno, COUNT(tc.Apno) AS [Pending Criminal Count]
									 FROM @tmpCriminal tc
									 GROUP BY tc.Apno
									 ) AS C ON  tc.Apno = c.Apno
  						 WHERE tc.RowNumber = 1) AS P ON T.[Report Number] = P.Apno
		LEFT OUTER JOIN (SELECT tc.Apno, CAST(tc.ETADate AS DATE) AS [Longest Education ETA], tc.SchoolName AS [Longest ETA Education], C.[Pending Education Count]
						 FROM @tmpEducation tc 
						 INNER JOIN (SELECT tc.Apno, COUNT(tc.Apno) AS [Pending Education Count]
									 FROM @tmpEducation tc
									 GROUP BY tc.Apno
									 ) AS C ON  tc.Apno = c.Apno
  						 WHERE tc.RowNumber = 1) AS Edu ON T.[Report Number] = Edu.Apno
		LEFT OUTER JOIN (SELECT tc.Apno, CAST(tc.ETADate AS DATE) AS [Longest Employment ETA], tc.EmployerName AS [Longest ETA Employment], C.[Pending Employment Count]
						 FROM @tmpEmployment tc 
						 INNER JOIN (SELECT tc.Apno, COUNT(tc.Apno) AS [Pending Employment Count]
									 FROM @tmpEmployment tc
									 GROUP BY tc.Apno
									 ) AS C ON  tc.Apno = c.Apno
  						 WHERE tc.RowNumber = 1) AS Emp ON T.[Report Number] = Emp.Apno
		LEFT OUTER JOIN (SELECT tc.Apno, CAST(tc.ETADate AS DATE) AS [Longest License ETA], tc.LicenseType AS [Longest ETA License], C.[Pending License Count]
						 FROM @tmpLicense tc 
						 INNER JOIN (SELECT tc.Apno, COUNT(tc.Apno) AS [Pending License Count]
									 FROM @tmpLicense tc
									 GROUP BY tc.Apno
									 ) AS C ON  tc.Apno = c.Apno
  						 WHERE tc.RowNumber = 1) AS Lic ON T.[Report Number] = Lic.Apno
		WHERE t.[Turnaround Time] >= 5
END
