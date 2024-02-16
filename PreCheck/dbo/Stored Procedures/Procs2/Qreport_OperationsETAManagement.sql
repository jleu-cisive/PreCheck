
-- =============================================
-- Author:		Humera Ahmed
-- Create date: 4/20/2018
-- Description:	Used for a new Q-Report Operations ETA Management
-- Modifed By: Deepak Vodethela
-- Modified Date: 06/22/2018
/*
 EXEC [dbo].[Qreport_OperationsETAManagement] '1031:1629:1937:11365',0,'All','06/01/2018','06/21/2018'
 EXEC [dbo].[Qreport_OperationsETAManagement] '0',215,'All','06/01/2021','07/21/2021'
 EXEC [dbo].[Qreport_OperationsETAManagement] '0',114,'All','06/01/2018','06/21/2018'
 EXEC [dbo].[Qreport_OperationsETAManagement] '','','All','06/01/2018','06/21/2018'
 EXEC [dbo].[Qreport_OperationsETAManagement] '','','Employment','06/01/2018','06/21/2018'
 EXEC [dbo].[Qreport_OperationsETAManagement] '','','Education','06/01/2018','06/21/2018'
 EXEC [dbo].[Qreport_OperationsETAManagement] '','','Criminal','06/01/2018','06/21/2018'
 EXEC [dbo].[Qreport_OperationsETAManagement] '','','MVR','06/01/2018','06/21/2018'
 EXEC [dbo].[Qreport_OperationsETAManagement] '','','Sanction','06/01/2018','06/21/2018'
 */
-- =============================================

/* Modified By: Sunil Mandal A
-- Modified Date: 07/01/2022
-- Description: Ticketno-53763 
Modify existing q-reports that have affiliate ids in their search parameters
Details: 
Change search parameters for the Affiliate Id field
     * search by multiple affiliate ids (ex 4:297)
     * want to also be able to search all affiliates by putting zero - meaning 0 to search all affiliates
     * multiple affiliates to be separated by a colon  
Under Parameter Names - after Affiliate ID include this wording (separate by colon, default 0)
*/
---Testing
/*

 EXEC [dbo].[Qreport_OperationsETAManagement] '0',215,'All','06/01/2021','07/21/2021'
 EXEC [dbo].[Qreport_OperationsETAManagement] '0',0,'All','06/01/2021','08/21/2021'
  EXEC [dbo].[Qreport_OperationsETAManagement] '0','215:158','All','06/01/2021','07/21/2021'

*/
CREATE PROCEDURE [dbo].[Qreport_OperationsETAManagement]
	-- Add the parameters for the stored procedure here
		@ClientList varchar(MAX) = NULL, 
		-- @AffiliateID INT, --code added by Sunil Mandal for ticket id -53763
		@AffiliateIDs varchar(MAX) = '0',  --code added by Sunil Mandal for ticket id -53763
		@Section VARCHAR(100),
		@StartDate DATE = NULL,
		@EndDate DATE = NULL	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	-- Insert statements for procedure here
	SET NOCOUNT ON;

		--code added by Sunil Mandal for ticket id -53763 starts
	IF @AffiliateIDs = '0' 
	BEGIN  
		SET @AffiliateIDs = NULL  
	END
     --code added by Sunil Mandal for ticket id -53763 Ends	

	IF(@ClientList = '' OR LOWER(@ClientList) = 'null' OR @ClientList = '0'  ) 
	Begin  
		SET @ClientList = NULL  
	END

	--DECLARE temp tables (helps to maintain the same plan regardless of stats change)
	CREATE TABLE #tmpReportConclusionETA (
		[APNO] [int] NOT NULL,
        [MaxETADate] [Date] NULL)

	CREATE TABLE #tmpAllPendingReportsForDateRange (
		[APNO] [int] NOT NULL,
		[ApDate] [DateTime] NOT NULL,
		[CLNO] [smallint] NOT NULL,
		[ApplSectionID] [int] NOT NULL,
		[SectionKeyID] [int] NOT NULL,
		[ETADate] [date] NULL,
		[SSN] Varchar(11) NULL)

	CREATE TABLE #tmpAllPendingComponentReports (
		[CLNO] [smallint] NOT NULL,
		[APNO] [int] NOT NULL,
		[Section] Varchar(100) NOT NULL,
		[SectionDescription] Varchar(100) NULL,
		[SectionStatus] Varchar(100) NOT NULL,
		[ETADate] [Date] NULL,
		[ApDate] [DateTime] NOT NULL,
		[SSN] Varchar(20) NULL)

	--Index on temp tables
	CREATE CLUSTERED INDEX IX_ReportConclusionETA_01 ON #tmpReportConclusionETA(APNO)
	CREATE CLUSTERED INDEX IX_tmpAllPendingReportsForDateRange_01 ON #tmpAllPendingReportsForDateRange(APNO,[SectionKeyID])
	CREATE CLUSTERED INDEX IX_tmpAllPendingComponentReports_01 ON #tmpAllPendingComponentReports(APNO)
	
	-- Get all Pending Data for Date Range
	INSERT INTO #tmpAllPendingReportsForDateRange([APNO],[ApDate],[CLNO],[ApplSectionID],[SectionKeyID],[ETADate], [SSN])
	SELECT A.APNO,a.ApDate, a.CLNO, ase.[ApplSectionID], ase.[SectionKeyID], ase.ETADate, a.SSN
	FROM dbo.ApplSectionsETA AS ase(NOLOCK)
	INNER JOIN dbo.Appl a(NOLOCK) ON ase.Apno  = a.APNO
	WHERE A.ApStatus = 'P'
	  AND (A.CreatedDate BETWEEN @StartDate AND DATEADD(d,1,@EndDate))

	-- Get Pending Components data for the given date range
	INSERT INTO	#tmpAllPendingComponentReports(CLNO, APNO, Section, SectionStatus, SectionDescription, ETADate, [ApDate], [SSN])
	SELECT T.CLNO, T.APNO,'Employment' AS [Section], ss.[Description] AS [SectionStatus], E.Employer, T.ETADate, T.ApDate, T.SSN
	FROM #tmpAllPendingReportsForDateRange AS T(NOLOCK)
	INNER JOIN EMPL AS E(NOLOCK) ON T.APNO = E.APNO AND T.SectionKeyID	= E.EmplID	AND T.ApplSectionID	 = 1
	INNER JOIN dbo.SectStat AS ss(NOLOCK)  ON e.SectStat = ss.Code
	WHERE E.IsOnReport = 1
	  AND E.SectStat NOT IN ('2','3','4','5')
	  AND @Section IN ('All','Employment')
	UNION ALL
	SELECT T.CLNO, T.APNO,'Education' AS [Section], ss.[Description] AS [SectionStatus], E.School, T.ETADate, T.ApDate, T.SSN
	FROM #tmpAllPendingReportsForDateRange AS T(NOLOCK)
	INNER JOIN Educat AS E(NOLOCK) ON T.APNO = E.APNO AND T.SectionKeyID = E.EducatID	AND T.ApplSectionID	 = 2
	INNER JOIN dbo.SectStat AS ss(NOLOCK)  ON e.SectStat = ss.Code
	WHERE E.IsOnReport = 1
	  AND E.SectStat NOT IN ('2','3','4','5')
	  AND @Section IN ('All','Education')
	UNION ALL
	SELECT T.CLNO, T.APNO,'License' AS [Section], ss.[Description] AS [SectionStatus], pl.Lic_Type, T.ETADate, T.ApDate, T.SSN
	FROM #tmpAllPendingReportsForDateRange AS T(NOLOCK)
	INNER JOIN dbo.ProfLic AS pl(NOLOCK) ON T.APNO = pl.APNO AND T.SectionKeyID	= pl.ProfLicID	AND T.ApplSectionID	 = 4
	INNER JOIN dbo.SectStat AS ss(NOLOCK)  ON pl.SectStat = ss.Code
	WHERE PL.IsOnReport = 1
	  AND PL.SectStat NOT IN ('2','3','4','5')
	  AND @Section IN ('All','License')
	UNION ALL
	SELECT T.CLNO, T.APNO,'Criminal' AS [Section], cs.[CrimDescription] AS [SectionStatus], c.County, T.ETADate, T.ApDate, T.SSN
	FROM #tmpAllPendingReportsForDateRange AS T(NOLOCK)
	INNER JOIN dbo.Crim AS c(NOLOCK) ON T.APNO = c.APNO AND T.SectionKeyID = c.CrimID AND T.ApplSectionID = 5
	INNER JOIN dbo.Crimsectstat AS cs(NOLOCK)  ON c.[Clear] = cs.crimsect
	WHERE C.IsHidden = 0
	  AND C.[Clear] NOT IN ('T','F')
	  AND @Section IN ('All','Criminal')
	UNION ALL
	SELECT T.CLNO, T.APNO,'MVR' AS [Section], ss.[Description] AS [SectionStatus], '', T.ETADate, T.ApDate, T.SSN
	FROM #tmpAllPendingReportsForDateRange AS T(NOLOCK)
	INNER JOIN dbo.DL AS d(NOLOCK) ON T.APNO = d.APNO AND T.ApplSectionID = 6
	INNER JOIN dbo.SectStat AS ss(NOLOCK)  ON d.SectStat = ss.Code
	WHERE D.SectStat NOT IN ('2','3','4','5')
	  AND @Section IN ('All','MVR')
	UNION ALL
	SELECT T.CLNO, T.APNO,'Sanction' AS [Section], ss.[Description] AS [SectionStatus], '', T.ETADate, T.ApDate, T.SSN
	FROM #tmpAllPendingReportsForDateRange AS T(NOLOCK)
	INNER JOIN dbo.MedInteg AS mi(NOLOCK) ON T.APNO = mi.APNO AND T.ApplSectionID = 7
	INNER JOIN dbo.SectStat AS ss(NOLOCK)  ON mi.SectStat = ss.Code
	WHERE MI.SectStat NOT IN ('2','3','4','5')
	  AND @Section IN ('All','Sanction')

	--SELECT * FROM #tmpAllPendingComponentReports AS T(NOLOCK) ORDER BY T.APNO	

	-- Get MAX(ETADate)
	INSERT INTO #tmpReportConclusionETA
	SELECT DISTINCT T.APNO,
			MAX(ETADate) OVER (PARTITION BY T.APNO) AS MaxETADate
	FROM #tmpAllPendingComponentReports AS T
	ORDER BY T.APNO	
	
	----SELECT * FROM #tmpAllPendingComponentReports AS T(NOLOCK) ORDER BY T.APNO	
	----SELECT * FROM #tmpReportConclusionETA

	-- Get Details
	SELECT  C.CLNO,F.APNO AS [Report Number],R.[Date] AS [Release Signed Date], C.Apdate AS [Certification Received Date],  CONVERT(VARCHAR, F.MaxETADate, 101) AS [Report Conclusion ETA],
			C.Section, C.SectionDescription, C.SectionStatus, CONVERT(VARCHAR, C.ETADate, 101) AS [Section ETA], CAST(rf.AffiliateID AS VARCHAR) + ' - ' + rf.Affiliate AS [Affiliate ID & Name]
	FROM #tmpReportConclusionETA AS F(NOLOCK)
	INNER JOIN #tmpAllPendingComponentReports AS C(NOLOCK) ON F.APNO = C.APNO
	INNER JOIN dbo.ReleaseForm AS R(NOLOCK) ON C.SSN = R.SSN
	INNER JOIN dbo.Client AS T(NOLOCK) ON C.CLNO = T.CLNO
	INNER JOIN refAffiliate AS rf (NOLOCK) ON T.affiliateID = rf.AffiliateID
	WHERE (@ClientList IS NULL OR C.CLNO IN (SELECT VALUE FROM fn_Split(@ClientList,':')))
	 -- AND rf.AffiliateID = IIF(@AffiliateID = 0, rf.AffiliateID, @AffiliateID) --code added by Sunil Mandal for ticket id -53763
	 AND (@AffiliateIDs IS NULL OR rf.AffiliateID IN (SELECT value FROM fn_Split(@AffiliateIDs,':'))) --code added by Sunil Mandal for ticket id -53763
	ORDER BY F.APNO

	DROP TABLE #tmpAllPendingReportsForDateRange
	DROP TABLE #tmpAllPendingComponentReports
	DROP TABLE #tmpReportConclusionETA

END

	/* --Commented By Deepak on 06/25/2018
	DECLARE @ReportConclusionETA TABLE (ReportNumber int,
                           MaxETADate Date)


	--Select @StartDate = CAST([MainDB].[dbo].[fnGetEstimatedBusinessDate_2](CURRENT_TIMESTAMP,-10) AS DATE),
	--	   @EndDate = CAST(CURRENT_TIMESTAMP AS DATE)

		INSERT  INTO @ReportConclusionETA (ReportNumber, MaxETADate)
		select  distinct [Report Number], 'Report Conclusion ETA' = MAX(ETADate) OVER (PARTITION BY [Report Number])
		 from
		(
			SELECT ETADate,[Report Number] FROM
			(
				select  eta.ETADate, a.apno as [Report Number]
				from appl a (NOLOCK)
				inner join  dbo.empl e(NOLOCK)  on a.apno = e.apno
				 inner join dbo.ReleaseForm r (NOLOCK) on a.clno = r.clno and a.ssn=r.ssn
				 inner join dbo.Client c (NOLOCK) ON c.clno=a.CLNO
				 left join dbo.ApplSectionsETA eta (NOLOCK) on e.EmplID = eta.SectionKeyID
				where e.isonreport = 1 and e.ishidden = 0 and 
				(@ClientList !='' or @AffliateId !='') and
				((a.clno in (select value from fn_Split(@ClientList,':')) or @ClientList = ''))  and 
				((c.AffiliateID in (select value from fn_Split(@AffliateId,':')) or @AffliateId = '')) and 
				a.ApStatus = 'P'
			) Y 
			
		 UNION ALL 

		   SELECT ETADate, [Report Number] FROM
			(
				 select eta.ETADate, a.apno as [Report Number]
				 from appl a (NOLOCK)
				 inner join  dbo.educat e (NOLOCK) on a.apno = e.apno 
				 inner join dbo.ReleaseForm r (NOLOCK) on a.clno = r.clno and a.ssn=r.ssn
				 inner join dbo.Client c (NOLOCK) ON c.clno=a.CLNO
				 left join dbo.ApplSectionsETA eta (NOLOCK) on e.EducatID= eta.SectionKeyID
				 where e.isonreport = 1 and e.ishidden = 0 and 
				 (@ClientList!='' or @AffliateId!='') and
				 ((a.clno in (select value from fn_Split(@ClientList,':')) or @ClientList = ''))  and
				 ((c.AffiliateID in (select value from fn_Split(@AffliateId,':')) or @AffliateId = '')) and 
				 a.ApStatus = 'P'
		   ) Y 
		  
		 UNION ALL 

			SELECT ETADate, [Report Number] FROM
			(
				 select eta.ETADate, a.apno as [Report Number]
				 from appl a (NOLOCK)
				 inner join  dbo.proflic e (NOLOCK) on a.apno = e.apno
				  inner join dbo.ReleaseForm r (NOLOCK) on a.clno = r.clno and a.ssn=r.ssn
				  inner join dbo.Client c (NOLOCK) ON c.clno=a.CLNO
				  left join dbo.ApplSectionsETA eta (NOLOCK) on e.ProfLicID = eta.SectionKeyID
				 where e.isonreport = 1 and e.ishidden = 0 and 
				 (@ClientList!='' or @AffliateId!='') and
				 ((a.clno in (select value from fn_Split(@ClientList,':')) or @ClientList = ''))  and 
				 ((c.AffiliateID in (select value from fn_Split(@AffliateId,':')) or @AffliateId = '')) and 
				 a.ApStatus = 'p'
			) y
		 UNION ALL 

			SELECT ETADate, [Report Number] FROM
			(
				 select eta.ETADate, a.apno as [Report Number]
				 from appl a (NOLOCK)
				 inner join  dbo.crim e(NOLOCK) on a.apno = e.apno 
				 inner join crimsectstat css(NOLOCK) on css.crimsect = e.[Clear]
				  inner join dbo.ReleaseForm r(NOLOCK) on a.clno = r.clno and a.ssn=r.ssn
				  inner join dbo.Client c (NOLOCK) ON c.clno=a.CLNO
				  left join dbo.ApplSectionsETA eta(NOLOCK) on e.CrimID = eta.SectionKeyID
				 where e.ishidden = 0 and 
				 (@ClientList!='' or @AffliateId!='') and
				 ((a.clno in (select value from fn_Split(@ClientList,':')) or @ClientList = ''))  and
				 ((c.AffiliateID in (select value from fn_Split(@AffliateId,':')) or @AffliateId = '')) and
				 a.ApStatus = 'P'
			) y 

		 UNION ALL 

			SELECT ETADate, [Report Number] FROM
			(
				 select eta.ETADate, a.apno as [Report Number]
				 from appl a (NOLOCK)
				 inner join  dbo.persref e (NOLOCK) on a.apno = e.apno 
				 inner join dbo.ReleaseForm r (NOLOCK) on a.clno = r.clno and a.ssn=r.ssn
				 inner join dbo.Client c (NOLOCK) ON c.clno=a.CLNO
				 left join dbo.ApplSectionsETA eta (NOLOCK) on e.PersRefID = eta.SectionKeyID
				 where e.isonreport = 1 and e.ishidden = 0 and  
				 (@ClientList!='' or @AffliateId!='') and
				 ((a.clno in (select value from fn_Split(@ClientList,':')) or @ClientList = ''))  and
				 ((c.AffiliateID in (select value from fn_Split(@AffliateId,':')) or @AffliateId = '')) and
				 a.ApStatus = 'P'
			)y 
	 ) E
	--select * from @ReportConclusionETA 

	IF @Section = 'Reference Report' -- Used by Personal Reference Report (QReport)
	  SELECT AffiliateID, CLNO,[Report Number],[Release Signed Date], [Certification Received Date], MaxETADate as 'Report Conclusion Date', 
	  Section, 'Section Description', sectstat,ETADate   FROM
	  (
		 select c.AffiliateID,a.clno, a.apno as [Report Number],  r.Date as [Release Signed Date], a.Apdate as [Certification Received Date], rd.MaxETADate, ApStatus as ReportStatus,'Personal Reference' as Section,e.Name, sectstat, eta.ETADate
		 from appl a (NOLOCK)
		 inner join dbo.persref e (NOLOCK) on a.apno = e.apno 
		 inner join dbo.ReleaseForm r (NOLOCK) on a.clno = r.clno and a.ssn=r.ssn
		 inner join dbo.Client c (NOLOCK) ON c.clno=a.CLNO
		 left join dbo.ApplSectionsETA eta (NOLOCK) on e.EmplID = eta.SectionKeyID
		 inner join @ReportConclusionETA rd on e.Apno = rd.ReportNumber
		 where e.isonreport = 1 and e.ishidden = 0 and 
		 (@ClientList!='' or @AffliateId!='') and
		 ((a.clno in (select value from fn_Split(@ClientList,':')) or @ClientList = ''))  and 
		 ((c.AffiliateID in (select value from fn_Split(@AffliateId,':')) or @AffliateId = '')) and 
		 a.ApStatus = 'P'
	  )y  
	ELSE
  	 select AffiliateID, CLNO,[Report Number], [Release Signed Date], [Certification Received Date], 
	 MaxETADate as 'Report Conclusion Date', Section, [Section Description], ISNULL(S.Description,sectstat) SectionStatus, ETADate
	 from
	 (
			SELECT AffiliateID, CLNO, [Report Number], [Release Signed Date], [Certification Received Date], MaxETADate, ReportStatus, Section, Employer as 'Section Description', sectstat, ETADate FROM
			(
				select c.AffiliateID, a.clno as CLNO, a.apno as [Report Number],r.Date as [Release Signed Date], a.Apdate as [Certification Received Date], rd.MaxETADate, apStatus as ReportStatus,
				'Employment' as Section, e.Employer, sectstat, eta.ETADate
				from appl a (NOLOCK)
				inner join  dbo.empl e (NOLOCK) on a.apno = e.apno
				 inner join dbo.ReleaseForm r (NOLOCK) on a.clno = r.clno and a.ssn=r.ssn
				 inner join dbo.Client c (NOLOCK) ON c.clno=a.CLNO
				 left join dbo.ApplSectionsETA eta (NOLOCK) on e.EmplID = eta.SectionKeyID
				 inner join @ReportConclusionETA rd on e.Apno = rd.ReportNumber
				where e.isonreport = 1 and e.ishidden = 0 and  
				(@ClientList!='' or @AffliateId!='') and
				((a.clno in (select value from fn_Split(@ClientList,':')) or @ClientList = ''))  and 
				((c.AffiliateID in (select value from fn_Split(@AffliateId,':')) or @AffliateId = '')) and 
				a.ApStatus = 'P'
			) Y 
			WHERE @Section IN ('All','Employment')
	
		 UNION ALL 

		   SELECT AffiliateID, CLNO, [Report Number],[Release Signed Date], [Certification Received Date], MaxETADate, ReportStatus,Section, CampusName as 'Section Description', sectstat, ETADate FROM
			(
				 select c.AffiliateID, a.clno, a.apno as [Report Number], r.Date as [Release Signed Date], a.Apdate as [Certification Received Date], rd.MaxETADate, ApStatus as ReportStatus,
				 'Education' as Section, e.CampusName, sectstat, eta.ETADate
				 from appl a (NOLOCK)
				 inner join  dbo.educat e (NOLOCK) on a.apno = e.apno 
				 inner join dbo.ReleaseForm r (NOLOCK) on a.clno = r.clno and a.ssn=r.ssn
				 inner join dbo.Client c (NOLOCK) ON c.clno=a.CLNO
				 left join dbo.ApplSectionsETA eta (NOLOCK) on e.EducatID= eta.SectionKeyID
				 inner join @ReportConclusionETA rd on e.Apno = rd.ReportNumber
				 where e.isonreport = 1 and e.ishidden = 0 and 
				 (@ClientList!='' or @AffliateId!='') and
				 ((a.clno in (select value from fn_Split(@ClientList,':')) or @ClientList = ''))  and 
				 ((c.AffiliateID in (select value from fn_Split(@AffliateId,':')) or @AffliateId = '')) and 
				 a.ApStatus = 'P'
		   ) Y 
		   WHERE @Section IN ('All','Education')

		 UNION ALL 

			SELECT AffiliateID,CLNO,[Report Number], [Release Signed Date], [Certification Received Date], MaxETADate, ReportStatus,Section,Lic_Type as 'Section Description', sectstat, ETADate FROM
			(
				 select c.AffiliateID, a.clno, a.apno as [Report Number], r.Date as [Release Signed Date], a.Apdate as [Certification Received Date], rd.MaxETADate,  ApStatus as ReportStatus,
				 'License' as Section, e.Lic_Type, sectstat, eta.ETADate
				 from appl a (NOLOCK) 
				 inner join  dbo.proflic e (NOLOCK) on a.apno = e.apno
				  inner join dbo.ReleaseForm r (NOLOCK) on a.clno = r.clno and a.ssn=r.ssn
				  inner join dbo.Client c (NOLOCK) ON c.clno=a.CLNO
				  left join dbo.ApplSectionsETA eta (NOLOCK) on e.ProfLicID = eta.SectionKeyID
				  inner join @ReportConclusionETA rd on e.Apno = rd.ReportNumber
				 where e.isonreport = 1 and e.ishidden = 0 and 
				 (@ClientList!='' or @AffliateId!='') and 
				 ((a.clno in (select value from fn_Split(@ClientList,':')) or @ClientList = ''))  and 
				 ((c.AffiliateID in (select value from fn_Split(@AffliateId,':')) or @AffliateId = '')) and 
				 a.ApStatus = 'p'
			) y
			WHERE @Section IN ('All','License')

		 UNION ALL 

			SELECT AffiliateID, CLNO,[Report Number],[Release Signed Date], [Certification Received Date],MaxETADate, ReportStatus, Section, County as 'Section Description', sectstat, ETADate FROM
			(
				 select c.AffiliateID, a.clno, a.apno as [Report Number],r.Date as [Release Signed Date], a.Apdate as [Certification Received Date], rd.MaxETADate, ApStatus as ReportStatus,'Criminal' as Section,
				 e.County, css.crimdescription sectstat,eta.ETADate
				 from appl a (NOLOCK) 
				 inner join  dbo.crim e (NOLOCK) on a.apno = e.apno 
				 inner join crimsectstat css (NOLOCK) on css.crimsect = e.[Clear]
				  inner join dbo.ReleaseForm r (NOLOCK) on a.clno = r.clno and a.ssn=r.ssn
				  inner join dbo.Client c (NOLOCK) ON c.clno=a.CLNO
				  left join dbo.ApplSectionsETA eta (NOLOCK) on e.CrimID = eta.SectionKeyID
				  inner join @ReportConclusionETA rd on e.Apno = rd.ReportNumber
				 where e.ishidden = 0 and 
				 (@ClientList!='' or @AffliateId!='') and
				 ((a.clno in (select value from fn_Split(@ClientList,':')) or @ClientList = ''))  and 
				 ((c.AffiliateID in (select value from fn_Split(@AffliateId,':')) or @AffliateId = '')) and
				 a.ApStatus = 'P'
			) y 
			WHERE @Section IN ('All','Criminal')

		 UNION ALL 

			SELECT AffiliateID, CLNO, [Report Number],[Release Signed Date], [Certification Received Date], MaxETADate, ReportStatus,Section, Name as 'Section Description',sectstat, ETADate FROM
			(
				 select c.AffiliateID, a.clno, a.apno as [Report Number],r.Date as [Release Signed Date], a.Apdate as [Certification Received Date], rd.MaxETADate, ApStatus as ReportStatus,
				 'Personal Reference' as Section, e.Name, sectstat, eta.ETADate
				 from appl a (NOLOCK) 
				 inner join  dbo.persref e (NOLOCK) on a.apno = e.apno 
				 inner join dbo.ReleaseForm r (NOLOCK) on a.clno = r.clno and a.ssn=r.ssn
				 inner join dbo.Client c (NOLOCK) ON c.clno=a.CLNO
				 left join dbo.ApplSectionsETA eta (NOLOCK) on e.PersRefID = eta.SectionKeyID
			     inner join @ReportConclusionETA rd on e.Apno = rd.ReportNumber
				 where e.isonreport = 1 and e.ishidden = 0 and 
				 (@ClientList!='' or @AffliateId!='') and
				 ((a.clno in (select value from fn_Split(@ClientList,':')) or @ClientList = ''))  and 
				 ((c.AffiliateID in (select value from fn_Split(@AffliateId,':')) or @AffliateId = '')) and
				 a.ApStatus = 'P'
			)y 
			WHERE @Section IN ('All','Reference')
	 ) Z 
	 LEFT JOIN dbo.SectStat S ON Z.SectStat = S.Code
	 ORDER by AffiliateID, CLNO,[Report Number],Section
END
*/
