--EXEC [PBI_MultiCare_Executive_Access_Dashboard] @TableName='AdverseAction'
CREATE PROCEDURE [dbo].[PBI_MultiCare_Executive_Access_Dashboard] 
@TableName varchar(100)  
AS  
SET NOCOUNT ON  
SET XACT_ABORT ON  
  
BEGIN  
  
	IF @TableName='AdverseAction'		--Execution time 1 sec & 3 rows 
	BEGIN  
		;WITH cteAdverseHistory AS
		(
			SELECT va.*   
			FROM [dbo].[vwAdverseHistory] va
			INNER JOIN APPl a on va.APNO = a.APNO
			INNER JOIN Client c on a.CLNO = c.CLNO
			WHERE c.CLNO = 16729 and Year(a.OrigCompDate) > 2020
		), 
		cteReportList AS
		(
			SELECT	distinct a.apno, c.CLNO AS [ClientID], c.Name AS [ClientName],ra.Affiliate AS [AffiliateName], f.IsOneHR AS [IsOneHR], a.Last AS [Applicant LastName],
					a.First AS [Applicant FirstName],aa.ClientEmail AS [RequestedBy], aah.StatusID AS AdverseActionStatusID, 
					ras.Status AS [AdverseActionStatus], aah.[Date] AS AdverseActionHistoryDate,
					ras.Status, A.APDATE, A.CompDate, a.OrigCompDate 
			FROM appl a (nolock)		
			LEFT OUTER JOIN HEVN.dbo.Facility F (NOLOCK) ON a.clno =FacilityCLNO and ISNULL(A.DeptCode,0) = F.FacilityNum
			LEFT OUTER JOIN client c(nolock) ON a.CLNO = c.CLNO
			LEFT OUTER JOIN AdverseAction aa(nolock) ON a.APNO = aa.APNO
			LEFT OUTER JOIN AdverseActionHistory aah(nolock) ON aa.AdverseActionID = aah.AdverseActionID
			LEFT OUTER JOIN refAffiliate ra(nolock) ON c.AffiliateID = ra.AffiliateID
			LEFT OUTER JOIN refAdverseStatus ras ON aah.StatusID = ras.refAdverseStatusID 
			WHERE c.CLNO =16729
			AND aah.StatusID in(1,8,30,16,31)
		), 
		ctePreAdverse AS
		(
			SELECT X.APNO, X.Reason AS [PreAdverse Reason], X.[Description] AS [Component]		
			FROM Enterprise.[dbo].[vwAdverseActionReason]  AS X 
			INNER JOIN cteReportList D(NOLOCK) ON X.APNO = D.APNO
			WHERE X.RuleGroup = 'PreAdverse' 
		),
		cteAdverse AS
		(
			SELECT X.APNO, X.Reason AS [Adverse Reason], X.[Description] AS [Component]
			FROM Enterprise.[dbo].[vwAdverseActionReason] AS X 
			INNER JOIN cteReportList D(NOLOCK) ON X.APNO = D.APNO
			WHERE X.RuleGroup = 'Adverse' 
		),
		cteAdverseActivity AS	
		(
			SELECT distinct tva.APNO, trl.[ClientID],trl.[ClientName], trl.[AffiliateName], trl.[IsOneHR], 
					trl.Apdate,
					trl.OrigCompDate,
					trl.CompDate,
					trl.[Applicant LastName], 
					trl.[Applicant FirstName],
					tva.City AS [CityofResidence],
					tva.[State] AS [ApplicantResidentState], 
					Q.StateEmploymentOccur AS [JobState],
					trl.[RequestedBy],
					trl1.AdverseActionHistoryDate  AS [PreAdverse Requested],
					trl3.AdverseActionHistoryDate AS [PreAdverse Emailed],
					(CASE
						WHEN trl1.AdverseActionStatusID = 1 AND trl3.AdverseActionStatusID = 30 THEN 'PreAdverse Requested and Emailed'
						WHEN trl3.AdverseActionStatusID = 30 THEN trl3.AdverseActionStatus  
						WHEN trl1.AdverseActionStatusID = 1 THEN  trl1.AdverseActionStatus
						ELSE NULL
					END) AS [PreAdverseActionStatus],
					X.[Component] AS [PreAdverse Component], 
					X.[PreAdverse Reason],
					trl5.AdverseActionHistoryDate AS [Adverse Requested],
					trl4.AdverseActionHistoryDate AS [Adverse Emailed],
					(CASE
						WHEN trl5.AdverseActionStatusID = 16 AND trl4.AdverseActionStatusID = 31 THEN 'Adverse Requested and Emailed'   
						WHEN trl4.AdverseActionStatusID = 31 THEN trl4.AdverseActionStatus   
						WHEN trl5.AdverseActionStatusID = 16 THEN trl5.AdverseActionStatus 
						ELSE NULL
					END) AS [AdverseActionStatus],
					Y.[Component] AS [Adverse Component],
					Y.[Adverse Reason],
					trl2.AdverseActionHistoryDate AS  [Applicant Dispute Date]
			FROM cteAdverseHistory tva
			LEFT OUTER JOIN ctePreAdverse AS X ON tva.APNO = X.APNO
			LEFT OUTER JOIN cteAdverse AS Y ON tva.APNO = Y.APNO
			LEFT OUTER JOIN PRECHECK.dbo.ApplAdditionalData Q(NOLOCK) ON tva.APNO = Q.APNO AND Q.StateEmploymentOccur IS NOT NULL
			INNER JOIN  cteReportList trl ON tva.APNO =trl.APNO 
			LEFT JOIN (select * from cteReportList where AdverseActionStatusID = 1) trl1 ON tva.APNO =trl1.APNO 
			LEFT JOIN (select * from cteReportList where AdverseActionStatusID = 8) trl2 ON tva.APNO =trl2.APNO 
			LEFT JOIN (select * from cteReportList where AdverseActionStatusID = 30) trl3 ON tva.APNO =trl3.APNO 
			LEFT JOIN (select * from cteReportList where AdverseActionStatusID = 31) trl4 ON tva.APNO =trl4.APNO 
			LEFT JOIN (select * from cteReportList where AdverseActionStatusID = 16) trl5 ON tva.APNO =trl5.APNO
		)
		SELECT * FROM cteAdverseActivity    
	END  
  
	IF @TableName='ApplicantContacts'  --Execition time is 00 & 0 rows 
	BEGIN  
		;WITH cteAppl AS
		(
			SELECT a.APNO
			FROM dbo.Appl a WITH (nolock)
			INNER JOIN client c WITH (nolock)
				ON c.clno = a.clno
			INNER JOIN dbo.ClientCertification cer (nolock)
				ON cer.APNO = a.APNO AND cer.ClientCertReceived='Yes'
			WHERE year(a.OrigCompDate) > 2020
			--AND month(a.apDate) = 1
			AND c.CLNO = 16729
			AND a.OrigCompDate IS NOT NULL
		)
		SELECT
			a.APNO,
			applS.Description ComponentType,
			CASE ac.ApplSectionID
				WHEN 1 THEN (SELECT e.Employer FROM Empl AS e WHERE e.EmplID = ac.SectionUniqueID)
				WHEN 2 THEN (SELECT e.School FROM Educat AS e WHERE e.EducatID = ac.SectionUniqueID)
				WHEN 3 THEN (SELECT p.Name FROM PersRef AS p WHERE p.PersRefID = ac.SectionUniqueID)
				WHEN 4 THEN (SELECT p.Lic_Type FROM ProfLic AS p WHERE p.ProfLicID = ac.SectionUniqueID)
			END ComponentDescription,
			CASE ac.ApplSectionID
				WHEN 1 THEN (SELECT ss.Description FROM Empl AS e INNER JOIN dbo.SectStat ss ON e.SectStat=ss.Code WHERE e.EmplID = ac.SectionUniqueID)
				WHEN 2 THEN (SELECT ss.Description FROM Educat AS e INNER JOIN dbo.SectStat ss ON e.SectStat=ss.Code WHERE e.EducatID = ac.SectionUniqueID)
				WHEN 3 THEN (SELECT ss.Description FROM PersRef AS p INNER JOIN dbo.SectStat ss ON p.SectStat=ss.Code WHERE p.PersRefID = ac.SectionUniqueID)
				WHEN 4 THEN (SELECT ss.Description FROM ProfLic AS p INNER JOIN dbo.SectStat ss ON p.SectStat=ss.Code WHERE p.ProfLicID = ac.SectionUniqueID)
			END AS Status,
			rmc.ItemName AS MethodOfContact,
			rrc.ItemName AS ReasonforContact,
			ac.Investigator,
			FORMAT(ac.CreateDate, 'MM/dd/yyyy hh:mm tt') AS DateofContact
		FROM ApplicantContact AS ac WITH (NOLOCK)
			INNER JOIN cteAppl AS a WITH (NOLOCK) ON a.APNO = ac.APNO
			INNER JOIN refMethodOfContact AS rmc WITH (NOLOCK) ON rmc.refMethodOfContactID = ac.refMethodOfContactID
			INNER JOIN refReasonForContact AS rrc WITH (NOLOCK) ON rrc.refReasonForContactID = ac.refReasonForContactID
			INNER JOIN ApplSections AS applS WITH (NOLOCK) ON applS.ApplSectionID = ac.ApplSectionID
	END  
  
	IF @TableName='Applications'	--Execution time 0 sec a& 10301 Rows 
	BEGIN  
		SELECT DISTINCT GETDATE() DateDataRefreshed, c.AffiliateID, a.APNO, a.Last + ', ' + a.First FullName, a.Sex, a.ApStatus AppStatus, a.EnteredVia
			, a.ApDate DateCreated, cer.ClientCertUpdated DateCertified, a.OrigCompDate, a.ReopenDate, a.CompDate
			, a.CLNO ClientId, c.Name ClientName, c.State ClientState, aff.Affiliate AffiliateName
			,ISNULL(COALESCE(cpm.PackageDesc, dpm.PackageDesc), 'NO PACKAGE') PackageName, COALESCE(cpm.DefaultPrice, dpm.DefaultPrice) PackagePrice
		FROM dbo.Appl a(nolock) --5894
		INNER JOIN dbo.ClientPackages cp --This will help get the actual package for this client
			ON a.CLNO = cp.CLNO AND cp.PackageID = a.PackageID
		LEFT JOIN PackageMain cpm(nolock) --
			ON cp.PackageID = cpm.PackageID
		LEFT JOIN PackageMain dpm(nolock) 
			ON a.PackageID = dpm.PackageID
		INNER JOIN dbo.ClientCertification cer (nolock)
			ON cer.APNO = a.APNO AND cer.ClientCertReceived='Yes'
		INNER JOIN client c (nolock) --this should be inner
			ON c.clno = a.clno
		INNER JOIN refAffiliate aff (nolock)  --Each client has an affiliate
			ON aff.AffiliateID = c.AffiliateID
		LEFT JOIN (SELECT FacilityID, FacilityNum, FacilityName, Division, IsOneHR, ROW_NUMBER() OVER (PARTITION by FacilityNum ORDER BY FacilityID DESC) RowNumber 
			from HEVN.dbo.Facility WHERE ParentEmployerID = 7519) f ON isnull(a.deptcode,0) = f.FacilityNum AND f.RowNumber=1
		WHERE year(a.OrigCompDate) > 2020
		AND c.CLNO = 16729
		AND a.OrigCompDate IS NOT NULL
    
	END  
  
	IF @TableName='Billing'		--Execution time 2 sec & 130438 Rows 
	BEGIN  
		;WITH cteApplIds AS
		(
			SELECT a.APNO
			FROM dbo.Appl a WITH (nolock)
			INNER JOIN client c WITH (nolock)
				ON c.clno = a.clno
			INNER JOIN dbo.ClientCertification cer WITH (nolock)
				ON cer.APNO = a.APNO AND cer.ClientCertReceived='Yes'
			WHERE year(a.OrigCompDate) > 2020
			AND c.CLNO = 16729
			AND a.OrigCompDate IS NOT NULL
		)
		SELECT inv.InvDetID, inv.InvoiceNumber, inv.CreateDate, inv.APNO, inv.Type, inv.Description, Inv.Amount 
		FROM dbo.InvDetail inv WITH (nolock)
		INNER JOIN cteApplIds a ON inv.APNO = a.APNO
		WHERE inv.Billed=1
  
	END  
  
	IF @TableName='Criminal'	--Execution time 1:13 sec & 51490 Rows 
	BEGIN  
		;WITH cteApplIds AS
		(
			SELECT a.APNO
			FROM dbo.Appl a WITH (nolock)
			INNER JOIN client c WITH (nolock)
				ON c.clno = a.clno
			INNER JOIN dbo.ClientCertification cer (nolock)
				ON cer.APNO = a.APNO AND cer.ClientCertReceived='Yes'
			WHERE year(a.OrigCompDate) > 2020
			AND c.CLNO = 16729
			AND a.OrigCompDate IS NOT NULL
		), cteCrimIds AS
		(
			SELECT app.APNO, cr.CrimID, cr.County
			, IsInternational =	CASE WHEN ISNULL(d.refCountyTypeID, 0) = 5 THEN 1 ELSE 0 END
			, RecordFound = CASE WHEN css.CrimDescription <> 'Clear' THEN 1 ELSE 0 END
			, Degree = CASE 
				WHEN cr.Degree = '1' THEN 'Petty Misdemeanor'
				WHEN cr.Degree = '2' THEN 'Traffic Misdemeanor'
				WHEN cr.Degree = '3' THEN 'Criminal Traffic'
				WHEN cr.Degree = '4' THEN 'Traffic'
				WHEN cr.Degree = '5' THEN 'Ordinance Violation'
				WHEN cr.Degree = '6' THEN 'Infraction'
				WHEN cr.Degree = '7' THEN 'Disorderly Persons'
				WHEN cr.Degree = '8' THEN 'Summary Offense'
				WHEN cr.Degree = '9' THEN 'Indictable Crime'
				WHEN cr.Degree = 'F' THEN 'Felony'
				WHEN cr.Degree = 'M' THEN 'Misdemeanor'
				WHEN cr.Degree = 'O' THEN 'Other'
				WHEN cr.Degree = 'U' THEN 'Unknown'
			END
			, cr.Offense, cr.Crimenteredtime DateCreated, cr.Last_Updated LastUpdated
			FROM [dbo].Crim cr WITH (nolock)
			INNER JOIN cteApplIds app
				ON cr.APNO = app.APNO
			INNER JOIN dbo.counties d (NOLOCK) 
				ON cr.CNTY_NO = d.CNTY_NO 
			INNER JOIN Crimsectstat css  
				ON cr.Clear = css.crimsect
			WHERE cr.IsHidden = 0 AND cr.Clear IN ('F','T','P')
		)
		, cteChangeLogs AS
		(
			SELECT cl.ID, MAX(cl.ChangeDate) ChangeDate
			FROM dbo.ChangeLog cl WITH (nolock)
			INNER JOIN cteCrimIds cr
				ON cl.ID = cr.CrimID
			WHERE cl.NewValue IN ('F','T','P') AND YEAR(ChangeDate) >= 2019
			GROUP BY cl.ID
		), cteCrims AS
		(
			SELECT cr.APNO, cr.CrimID, cr.County, cr.IsInternational, cr.RecordFound, cr.Degree, cr.Offense
			, cr.DateCreated
			, ComponentClosingDate = CASE WHEN cl.ChangeDate IS NOT NULL THEN cl.ChangeDate
					ELSE cr.LastUpdated END
			FROM cteCrimIds cr
			LEFT JOIN cteChangeLogs cl 
				ON cl.ID = cr.CrimID
		)
		SELECT *
		FROM cteCrims
		where ComponentClosingDate is not null
  
	END  
	  -----------------------------  
	IF @TableName='Education'	--Execution time 00:36 sec & 4669 Rows
	BEGIN  
		;WITH cteApplIds AS
		(
			SELECT a.APNO
			FROM dbo.Appl a WITH (nolock)
			INNER JOIN client c WITH (nolock)
				ON c.clno = a.clno
			INNER JOIN dbo.ClientCertification cer (nolock)
				ON cer.APNO = a.APNO AND cer.ClientCertReceived='Yes'
			WHERE year(a.OrigCompDate) > 2020
			--AND month(a.apDate) = 1
			AND c.CLNO = 16729
			AND a.OrigCompDate IS NOT NULL
		), cteEduIds AS
		(
			SELECT app.APNO, edu.EducatID, edu.School, ISNULL(edu.IsIntl, 0) IsInternational, edu.SectStat, edu.Last_Updated
			FROM [dbo].Educat edu WITH (nolock)
			INNER JOIN cteApplIds app
				ON edu.APNO = app.APNO
			WHERE edu.IsOnReport = 1 AND edu.IsHidden = 0
		)
		, cteChangeLogs AS
		(
			SELECT cl.ID, MAX(cl.ChangeDate) ChangeDate
			FROM dbo.ChangeLog cl WITH (nolock)
			INNER JOIN cteEduIds edu
				ON cl.ID = edu.EducatID
			WHERE cl.NewValue IN ('1','2','3','4','5','6','7','8','A','E','B') AND cl.TableName = 'Educat.SectStat' AND YEAR(ChangeDate) >= 2019
			GROUP BY cl.ID
		), cteEdu AS
		(
			SELECT edu.APNO, edu.EducatID EducatId, edu.School, edu.IsInternational, edu.SectStat
			, eduStatus.Description EducatStatus, edu.Last_Updated EducationLastUpdated
			, CASE WHEN cl.ChangeDate IS NOT NULL THEN cl.ChangeDate
					WHEN edu.SectStat IN ('1','2','3','4','5','6','7','8','A','E','B') THEN edu.Last_Updated
					ELSE NULL
					END ComponentClosingDate
			FROM cteEduIds edu
			INNER JOIN dbo.SectStat eduStatus 
				ON edu.SectStat = eduStatus.Code
			LEFT JOIN cteChangeLogs cl 
				ON cl.ID = edu.EducatID --AND cl.NewValue IN ('2','3','4','5') AND cl.TableName = 'Empl.SectStat'
		)
		SELECT *
		FROM cteEdu
		where EducatStatus NOT IN ('NEEDS REVIEW','PENDING','OnHold-AIReview')
		AND ComponentClosingDate is not null

	END  
  
	  ----------------------------------------  
	IF @TableName='Employment'		--Execution time 01:27 sec & 7863 Rows
	BEGIN  
		;WITH cteApplIds AS
		(
			SELECT a.APNO
			FROM dbo.Appl a WITH (nolock)
			INNER JOIN client c WITH (nolock)
				ON c.clno = a.clno
			INNER JOIN dbo.ClientCertification cer (nolock)
				ON cer.APNO = a.APNO AND cer.ClientCertReceived='Yes'
			WHERE year(a.OrigCompDate) > 2020
			AND c.CLNO =16729
			AND a.OrigCompDate IS NOT NULL
		), cteEmplIds AS
		(
			SELECT app.APNO, empl.EmplID, empl.Employer, ISNULL(empl.IsIntl, 0) IsInternational, empl.SectStat, empl.Last_Updated
			FROM [dbo].[Empl] empl WITH (nolock)
			INNER JOIN cteApplIds app
				ON empl.APNO = app.APNO
			WHERE empl.IsOnReport = 1 AND empl.IsHidden = 0
		)
		, cteChangeLogs AS
		(
			SELECT cl.ID, MAX(cl.ChangeDate) ChangeDate
			FROM dbo.ChangeLog cl WITH (nolock)
			INNER JOIN cteEmplIds empl
				ON cl.ID = empl.EmplID
			WHERE cl.NewValue IN ('1','2','3','4','5','6','7','8','A','E','B') AND cl.TableName = 'Empl.SectStat' AND YEAR(ChangeDate) >= 2019
			GROUP BY cl.ID
		), cteEmpl AS
		(
			SELECT empl.APNO, empl.EmplID EmploymentId, empl.Employer, empl.IsInternational, empl.SectStat
			, emplStatus.Description EmplStatus, empl.Last_Updated EmplomentLastUpdated
			, CASE WHEN cl.ChangeDate IS NOT NULL THEN cl.ChangeDate
					WHEN empl.SectStat IN ('1','2','3','4','5','6','7','8','A','E','B') THEN empl.Last_Updated
					ELSE NULL
					END ComponentClosingDate
			FROM cteEmplIds empl
			INNER JOIN dbo.SectStat emplStatus 
				ON empl.SectStat = emplStatus.Code
			LEFT JOIN cteChangeLogs cl 
				ON cl.ID = empl.EmplID --AND cl.NewValue IN ('2','3','4','5') AND cl.TableName = 'Empl.SectStat'
		)
		SELECT *
		FROM cteEmpl
		WHERE EmplStatus NOT IN ('NEEDS REVIEW','PENDING','OnHold-AIReview')
		AND ComponentClosingDate IS NOT NULL
    
	END  
  
	  ---------------------------------------  
	IF @TableName='FeelsLikeTAT'	--Execution time 00:20 sec & 10386 Rows
	BEGIN  
		;SELECT
		-- DISTINCT a.apno,
		 vc.CLNO AS [Client Number], vc.Name AS [Client Name],RA.Affiliate AS [Affiliate Name],
		a.APNO			
					,(SELECT CONVERT(VARCHAR, it.InvitationDate, 101) + ' ' + CONVERT(CHAR(5),it.InvitationDate, 108)) AS [Invite Sent]--,it.InvitationDate AS [Invite Sent]
					,(SELECT CONVERT(VARCHAR, a.CreatedDate, 101) + ' ' + CONVERT(CHAR(5),a.CreatedDate, 108)) AS [Invite Completed]--, a.CreatedDate AS [Invite Completed]
			
		
					,(SELECT CONVERT(VARCHAR, cc.ClientCertUpdated, 101) + ' ' + CONVERT(CHAR(5),cc.ClientCertUpdated, 108)) AS [Certification Completed]--, cc.ClientCertUpdated AS [Certification Completed],
			
					,(SELECT CONVERT(VARCHAR, a.CreatedDate, 101) + ' ' + CONVERT(CHAR(5),a.CreatedDate, 108)) AS [Received Date]--,a.CreatedDate AS [Recived Date]
					,(SELECT CONVERT(VARCHAR, a.OrigCompDate, 101) + ' ' + CONVERT(CHAR(5),a.OrigCompDate, 108)) AS [Original Close Date]--,a.OrigCompDate AS [Original Close Date]
			
					,(SELECT CONVERT(VARCHAR, a.ReopenDate, 101) + ' ' + CONVERT(CHAR(5),a.ReopenDate, 108)) AS [ReOpen Date]--,a.ReopenDate AS [ReOpen Date]
					,(SELECT CONVERT(VARCHAR, a.CompDate, 101) + ' ' + CONVERT(CHAR(5),a.CompDate, 108)) AS [Completed Date]--, a.CompDate AS [Completed Date]

					,(DATEDIFF(dd, it.invitationdate, a.CreatedDate) + 1)  -(DATEDIFF(wk, it.invitationdate, a.CreatedDate) * 2)   AS [INVITE TAT]
					,(DATEDIFF(dd, a.CreatedDate, cc.ClientcertUpdated) + 1)  -(DATEDIFF(wk, a.CreatedDate, cc.ClientcertUpdated) * 2) AS [CERTIFICATION TAT]
					,(DATEDIFF(dd, cc.ClientCertUpdated, a.OrigCompDate) + 1)  -(DATEDIFF(wk, cc.ClientCertUpdated, a.OrigCompDate) * 2)  -(CASE WHEN DATENAME(dw, cc.ClientCertUpdated) = 'Sunday' THEN 1 ELSE 0 END)  -(CASE WHEN DATENAME(dw, a.OrigCompDate) = 'Saturday' THEN 1 ELSE 0 END) AS [PRECHECK TAT]
	
					,[dbo].[ElapsedBusinessDays_2](a.CreatedDate,a.OrigCompDate) AS [Report TAT]
			
					,[dbo].[ElapsedBusinessDays_2](it.InvitationDate,a.OrigCompDate) AS [Invite to Original Close TAT – Without Reopen],
					[dbo].[ElapsedBusinessDays_2](it.InvitationDate,a.CompDate) AS [Total Client TAT (Invite to Last Close Date)],
					CASE WHEN (X.RuleGroup IS NOT NULL OR LEN(X.RuleGroup) > 0) THEN 'True' ELSE 'False' END AS [Adverse/Dispute]
	
			   FROM Enterprise.Report.InvitationTurnaround AS it(NOLOCK)
			   INNER JOIN PreCheck..Client AS vc(NOLOCK) ON it.facilityID = vc.CLNO
			   INNER JOIN dbo.refAffiliate AS RA WITH (NOLOCK) ON vc.AffiliateId = RA.AffiliateID
			   INNER JOIN PreCheck.dbo.Appl AS a(NOLOCK) ON it.OrderNumber = a.APNO
			   LEFT OUTER JOIN PreCheck.dbo.ClientCertification AS cc(NOLOCK) ON a.APNO = cc.APNO AND CC.ClientCertReceived = 'Yes'
			   --LEFT JOIN HEVN.dbo.Facility F (NOLOCK) ON (ISNULL(A.DeptCode,0) = F.FacilityNum  OR A.CLNO = F.FacilityCLNO)
			   LEFT OUTER JOIN Enterprise.[dbo].[vwAdverseActionReason] AS X ON A.APNO = X.APNO
			   WHERE year(OrigCompDate) > 2020
			   AND vc.CLNO = 16729
			   AND OrigCompDate IS NOT NULL

	END  
  
	  ------------------------------------------------  
	IF @TableName='License'			--Execution time 00:00 sec & 5888 Rows
	BEGIN  
		;WITH cteAppl AS
		(
			SELECT a.APNO
			FROM dbo.Appl a WITH (nolock)
			INNER JOIN client c WITH (nolock)
				ON c.clno = a.clno
			INNER JOIN dbo.ClientCertification cer (nolock)
				ON cer.APNO = a.APNO AND cer.ClientCertReceived='Yes'
			WHERE year(a.OrigCompDate) > 2020
			--AND month(a.apDate) = 1
			AND c.CLNO = 16729
			AND a.OrigCompDate IS NOT NULL
		)
		SELECT a.APNO, lic.ProfLicID LicenseId, ISNULL(lic.Lic_NO,0) as [License Number],licStatus.Description LicStatus, lic.Lic_Type_V [License Type], lic.State_V as [License State]
		FROM cteAppl a
		INNER JOIN [dbo].[ProfLic] as lic
			ON a.[APNO] = lic.[Apno] AND lic.IsOnReport = 1 AND lic.IsHidden = 0
		LEFT JOIN dbo.SectStat licStatus 
			ON lic.SectStat = licStatus.Code
			WHERE licStatus.Description NOT IN ('NEEDS REVIEW','PENDING','OnHold-AIReview')

	END  
  
	  ------------------------------------  
	IF @TableName='PersonalReferences'		--Execution time 00:00 sec & 0 Rows
	BEGIN  
		;WITH cteAppl AS
		(
			SELECT a.APNO
			FROM dbo.Appl a WITH (nolock)
			INNER JOIN client c WITH (nolock)
				ON c.clno = a.clno
			INNER JOIN dbo.ClientCertification cer (nolock)
				ON cer.APNO = a.APNO AND cer.ClientCertReceived='Yes'
			WHERE year(a.OrigCompDate) > 2020
			--AND month(a.apDate) = 1
			AND c.CLNO = 16729
			AND a.OrigCompDate IS NOT NULL
		)
		SELECT a.APNO, personal.PersRefID, 
		personalStatus.Description PersonalRefStatus
		FROM cteAppl a
		INNER JOIN [dbo].PersRef as personal --Personal References
			ON a.[APNO] = personal.[Apno] --AND personal.IsOnReport = 1 AND personal.IsHidden = 0 --TODO: Uncomment conditions
		LEFT JOIN dbo.SectStat personalStatus 
			ON personal.SectStat = personalStatus.Code
		WHERE personalStatus.Description NOT IN ('NEEDS REVIEW','PENDING','OnHold-AIReview')
    
	END  
  
	  -------------------------------------  
	IF @TableName='SanctionCheck'		--Execution time 00:01 sec & 10300 Rows
	BEGIN  
		;WITH cteAppl AS
		(
			SELECT a.APNO
			FROM dbo.Appl a WITH (nolock)
			INNER JOIN client c WITH (nolock)
				ON c.clno = a.clno
			INNER JOIN dbo.ClientCertification cer (nolock)
				ON cer.APNO = a.APNO AND cer.ClientCertReceived='Yes'
			WHERE year(a.OrigCompDate) > 2020
			AND c.CLNO = 16729
			AND a.OrigCompDate IS NOT NULL
		),
		cteMedLog AS
		(
			SELECT medLog.Status as ComponentData, medLog.APNO
			FROM [MedIntegLog] medLog WITH (nolock)
			INNER JOIN Appl a
				ON medLog.APNO = a.APNO 
			WHERE medlog.ChangeDate = (SELECT max(changedate) FROM MedIntegLog WHERE apno = a.apno)	
		)
		SELECT a.APNO, medStatus.Description SanctionCheckStatus, medLog.ComponentData
		FROM cteAppl a
		INNER JOIN [dbo].[MedInteg] as med
			ON a.[APNO] = med.[Apno] AND med.IsHidden = 0
		INNER JOIN cteMedLog as medLog
			ON med.[APNO] = medLog.[APNO]
		LEFT JOIN dbo.SectStat medStatus 
			ON med.SectStat = medStatus.Code
  
	END      
  
	  ---------------------------  
	IF @TableName='DimHoliday'		--Execution time 00:00 sec & 121 Rows
	BEGIN  
	   SELECT Date FROM [dbo].[vwPrecheckHolidays]  
	END  
END  
