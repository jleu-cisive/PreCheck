
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
-- Modified by Radhika Dereddy on 09/09/2020 - Added this because while exporting the columns to excel the length of Priv_notes field is 214766 for APNO =5179533) 
-- and many of more so adding the max length of the excel to accommodate the export.

*/---------------------------------------------------------------------------------

CREATE PROCEDURE [dbo].[Client_BackgroundCheck_ReportDetails_For_Client_Or_ClientGroup_10152021]
@Clno VARCHAR(MAX) = NULL,
@StartDate DateTime,
@EndDate DateTime,
@Affiliate int,
@IsOneHr bit
AS

BEGIN

	if(@CLNO = '0' OR @CLNO = '' OR LOWER(@CLNO) = 'null') Begin  SET @CLNO = NULL  END

	SELECT DISTINCT [Recruiter],[Report Number],[Client ID],ClientName, Affiliate, CAM, ISNULL(CP.ClientPackageDesc,P.PackageDesc) [Package Ordered],
					[Applicant FirstName],  [Applicant LastName], [Applicant MiddleName], [Component Type],[Component Data],[Record Status],
					[Date Created],[Report CompletedDate],IsHidden,IsOnReport,[Private Notes], [Public Notes],[TAT], IsOneHR
	  FROM 
	(
		(SELECT isnull(A.Attn,'') as [Recruiter], A.APNO  as [Report Number],C.CLNO as [Client ID], C.Name AS ClientName, RA.Affiliate,A.UserID as [CAM],
				A.First as [Applicant FirstName], A.Last as [Applicant LastName], A.Middle as [Applicant MiddleName], 'Employment' as [Component Type],
				emp.Employer as [Component Data], S.Description as [Record Status], A.ApDate as [Date Created], A.CompDate as [Report CompletedDate], 
				CASE emp.IsHidden WHEN 1 THEN 'UnUsed' ELSE 'On Report' End AS IsHidden, CASE emp.IsOnReport WHEN 1 THEN 'Yes' ELSE 'UnUsed' End AS IsOnReport,
				emp.Priv_Notes as [Private Notes] ,emp.Pub_Notes as [Public Notes],A.PackageID,
				[dbo].[ElapsedBusinessDays_2](A.Apdate, A.OrigCompDate) as [TAT], (CASE WHEN F.IsOneHR = 0 THEN 'False' ELSE 'True' END) AS IsOneHR
		FROM dbo.Appl AS A(NOLOCK)
		INNER JOIN dbo.Empl AS emp WITH(NOLOCK) ON emp.Apno = A.APNO
		INNER JOIN dbo.Client AS C WITH(NOLOCK) ON C.CLNO = A.CLNO
		INNER JOIN dbo.SectStat AS S WITH(NOLOCK) ON S.Code = emp.SectStat
		INNER JOIN dbo.refAffiliate RA WITH(NOLOCK) ON C.AffiliateID = RA.AffiliateID
		LEFT OUTER JOIN HEVN.dbo.Facility F (NOLOCK) ON isnull(A.DeptCode,0) = F.FacilityNum
		WHERE (@clno IS NULL OR a.CLNO IN (SELECT * from [dbo].[Split](':',@clno))) 
		AND (convert(date,A.Apdate) >= @StartDate) and (convert(date,A.Apdate) <= @EndDate)
		and RA.AffiliateID = IIF(@Affiliate=0, RA.AffiliateID, @Affiliate) 
		AND (ISNULL(F.IsOneHR,0) = @IsOneHR)
		AND LEN(Replace(REPLACE(emp.Priv_Notes , char(10),';'),char(13),';')) < 32767
		)

		UNION

		(SELECT isnull(A.Attn,'') as [Recruiter],A.APNO  as [Report Number],C.CLNO as [Client ID], C.Name AS ClientName, RA.Affiliate,A.UserID as [CAM],
				A.First as [Applicant FirstName], A.Last as [Applicant LastName], A.Middle as [Applicant MiddleName],'Education' as [Component Type],
				edu.School as [Component Data],	S.Description as [Record Status], A.ApDate as [Date Created], A.CompDate as [Report CompletedDate],
				CASE edu.IsHidden WHEN 1 THEN 'UnUsed' ELSE 'On Report' End AS IsHidden, CASE edu.IsOnReport WHEN 1 THEN 'Yes' ELSE 'UnUsed' End AS IsOnReport,
				edu.Priv_Notes as [Private Notes],edu.Pub_Notes as [Public Notes],A.PackageID,
				[dbo].[ElapsedBusinessDays_2](A.OrigCompDate, A.Apdate) as [TAT],  (CASE WHEN F.IsOneHR = 0 THEN 'False' ELSE 'True' END) AS IsOneHR
		FROM dbo.Appl AS A(NOLOCK)
		INNER JOIN dbo.Educat AS edu WITH(NOLOCK) ON edu.Apno = A.APNO
		INNER JOIN dbo.Client AS C WITH(NOLOCK) ON C.CLNO = A.CLNO
		INNER JOIN dbo.SectStat AS S WITH(NOLOCK) ON S.Code = edu.SectStat
		INNER JOIN dbo.refAffiliate RA WITH(NOLOCK) ON C.AffiliateID = RA.AffiliateID
		LEFT OUTER JOIN HEVN.dbo.Facility F (NOLOCK) ON isnull(A.DeptCode,0) = F.FacilityNum
		WHERE  (@clno IS NULL OR a.CLNO IN (SELECT * from [dbo].[Split](':',@clno))) 
		AND (convert(date,A.Apdate) >= @StartDate) and (convert(date,A.Apdate) <= @EndDate)
		and RA.AffiliateID = IIF(@Affiliate=0, RA.AffiliateID, @Affiliate) 
		AND (ISNULL(F.IsOneHR,0) = @IsOneHR)
		AND LEN(Replace(REPLACE(edu.Priv_Notes , char(10),';'),char(13),';')) < 32767
		)

		UNION

		(SELECT isnull(A.Attn,'') as [Recruiter],A.APNO  as [Report Number],C.CLNO as [Client ID], C.Name AS ClientName,RA.Affiliate,A.UserID as [CAM],
				A.First as [Applicant FirstName], A.Last as [Applicant LastName], A.Middle as [Applicant MiddleName], 'License' as [Component Type],
				lic.Lic_type as [Component Data],S.Description as [Record Status], A.ApDate as [Date Created], A.CompDate as [Report CompletedDate],
				CASE lic.IsHidden WHEN 1 THEN 'UnUsed' ELSE 'On Report' End AS IsHidden, CASE lic.IsOnReport WHEN 1 THEN 'Yes' ELSE 'UnUsed' End AS IsOnReport,
				lic.Priv_Notes as [Private Notes],lic.Pub_Notes as [Public Notes],A.PackageID,
				[dbo].[ElapsedBusinessDays_2](A.Apdate, A.OrigCompDate) as [TAT],  (CASE WHEN F.IsOneHR = 0 THEN 'False' ELSE 'True' END) AS IsOneHR
		FROM dbo.Appl AS A(NOLOCK)
		INNER JOIN dbo.ProfLic AS lic WITH(NOLOCK) ON lic.Apno = A.APNO
		INNER JOIN dbo.Client AS C WITH(NOLOCK) ON C.CLNO = A.CLNO
		INNER JOIN dbo.SectStat AS S WITH(NOLOCK) ON S.Code = lic.SectStat
		INNER JOIN dbo.refAffiliate RA WITH(NOLOCK) ON C.AffiliateID = RA.AffiliateID
		LEFT OUTER JOIN HEVN.dbo.Facility F (NOLOCK) ON isnull(A.DeptCode,0) = F.FacilityNum
		WHERE  (@clno IS NULL OR a.CLNO IN (SELECT * from [dbo].[Split](':',@clno))) 
		AND (convert(date,A.Apdate) >= @StartDate) and (convert(date,A.Apdate) <= @EndDate)
		and RA.AffiliateID = IIF(@Affiliate=0, RA.AffiliateID, @Affiliate) 
		AND (ISNULL(F.IsOneHR,0) = @IsOneHR)
		AND LEN(Replace(REPLACE(lic.Priv_Notes , char(10),';'),char(13),';')) < 32767
		)

		UNION

		(SELECT isnull(A.Attn,'') as [Recruiter],A.APNO  as [Report Number],C.CLNO as [Client ID], C.Name AS ClientName, RA.Affiliate,A.UserID as [CAM],
				A.First as [Applicant FirstName], A.Last as [Applicant LastName], A.Middle as [Applicant MiddleName],'Public Records' as [Component Type], 
				crim.County as [Component Data],  css.CrimDescription as [Record Status], A.ApDate as [Date Created], A.CompDate as [Report CompletedDate],
				CASE crim.IsHidden WHEN 1 THEN 'UnUsed' ELSE 'On Report' End AS IsHidden, '' AS IsOnReport,crim.Priv_Notes as [Private Notes], 
				crim.Pub_Notes as [Public Notes],A.PackageID,
				[dbo].[ElapsedBusinessDays_2](A.Apdate, A.OrigCompDate) as [TAT],  (CASE WHEN F.IsOneHR = 0 THEN 'False' ELSE 'True' END) AS IsOneHR
		FROM dbo.Appl AS A(NOLOCK)
		INNER JOIN dbo.Crim AS crim WITH(NOLOCK) ON crim.Apno = A.APNO
		INNER JOIN dbo.Client AS C WITH(NOLOCK) ON C.CLNO = A.CLNO
		INNER JOIN dbo.Crimsectstat AS css WITH(NOLOCK) ON css.crimsect = crim.Clear
		INNER JOIN dbo.refAffiliate RA WITH(NOLOCK) ON C.AffiliateID = RA.AffiliateID
		LEFT OUTER JOIN HEVN.dbo.Facility F (NOLOCK) ON isnull(A.DeptCode,0) = F.FacilityNum
		WHERE   (@clno IS NULL OR a.CLNO IN (SELECT * from [dbo].[Split](':',@clno))) 
		AND (convert(date,A.Apdate) >= @StartDate) and (convert(date,A.Apdate) <= @EndDate)
		and RA.AffiliateID = IIF(@Affiliate=0, RA.AffiliateID, @Affiliate) 
		AND (ISNULL(F.IsOneHR,0) = @IsOneHR)
		AND LEN(Replace(REPLACE(crim.Priv_Notes , char(10),';'),char(13),';')) < 32767
		)

		UNION

	
		(SELECT isnull(A.Attn,'') as [Recruiter],A.APNO  as [Report Number],C.CLNO as [Client ID], C.Name AS ClientName, RA.Affiliate,A.UserID as [CAM],
				A.First as [Applicant FirstName], A.Last as [Applicant LastName], A.Middle as [Applicant MiddleName],'Reference' as [Component Type],
			    pr.Name AS [Component Data], S.Description as [Record Status], A.ApDate as [Date Created], a.CompDate as [Report CompletedDate],
				CASE pr.IsHidden WHEN 1 THEN 'UnUsed' ELSE 'On Report' End AS IsHidden,  CASE pr.IsOnReport WHEN 1 THEN 'Yes' ELSE 'UnUsed' End AS IsOnReport,
				Pr.Priv_Notes as [Private Notes], PR.Pub_Notes as [Public Notes],A.PackageID,
				[dbo].[ElapsedBusinessDays_2](A.Apdate, A.OrigCompDate) as [TAT], (CASE WHEN F.IsOneHR = 0 THEN 'False' ELSE 'True' END) AS IsOneHR
		FROM dbo.Appl AS A(NOLOCK)
		INNER JOIN dbo.PersRef AS pr WITH(NOLOCK) ON pr.Apno = A.APNO
		INNER JOIN dbo.Client AS C WITH(NOLOCK) ON C.CLNO = A.CLNO
		INNER JOIN dbo.SectStat AS S WITH(NOLOCK) ON S.Code = pr.SectStat
		INNER JOIN dbo.refAffiliate RA WITH(NOLOCK) ON C.AffiliateID = RA.AffiliateID
		LEFT OUTER JOIN HEVN.dbo.Facility F (NOLOCK) ON isnull(A.DeptCode,0) = F.FacilityNum
		WHERE  (@clno IS NULL OR a.CLNO IN (SELECT * from [dbo].[Split](':',@clno))) 
		AND (convert(date,A.Apdate) >= @StartDate) and (convert(date,A.Apdate) <= @EndDate)
		and RA.AffiliateID = IIF(@Affiliate=0, RA.AffiliateID, @Affiliate) 
		AND (ISNULL(F.IsOneHR,0) = @IsOneHR)
		AND LEN(Replace(REPLACE(Pr.Priv_Notes , char(10),';'),char(13),';')) < 32767
		)


		UNION

		(SELECT isnull(A.Attn,'') as [Recruiter],A.APNO  as [Report Number],C.CLNO as [Client ID], C.Name AS ClientName, RA.Affiliate,A.UserID as [CAM],
				A.First as [Applicant FirstName], A.Last as [Applicant LastName], A.Middle as [Applicant MiddleName],'PID' as [Component Type], 
				'PID' AS [Component Data], S.Description as [Record Status], A.ApDate as [Date Created], a.CompDate as [Report CompletedDate],
				CASE pid.IsHidden WHEN 1 THEN 'UnUsed' ELSE 'On Report' End AS IsHidden, '' AS IsOnReport,A.Priv_Notes as [Private Notes], 
				A.Pub_Notes as [Public Notes],A.PackageID,
				[dbo].[ElapsedBusinessDays_2](A.Apdate, A.OrigCompDate) as [TAT],  (CASE WHEN F.IsOneHR = 0 THEN 'False' ELSE 'True' END) AS IsOneHR
		FROM dbo.Appl AS A(NOLOCK)
		INNER JOIN dbo.Credit AS PID WITH(NOLOCK) ON PID.Apno = A.APNO
		INNER JOIN dbo.Client AS C WITH(NOLOCK) ON C.CLNO = A.CLNO
		INNER JOIN dbo.SectStat AS S WITH(NOLOCK) ON S.Code = pid.SectStat
		INNER JOIN dbo.refAffiliate RA WITH(NOLOCK) ON C.AffiliateID = RA.AffiliateID
		LEFT OUTER JOIN HEVN.dbo.Facility F (NOLOCK) ON isnull(A.DeptCode,0) = F.FacilityNum
		WHERE (@clno IS NULL OR a.CLNO IN (SELECT * from [dbo].[Split](':',@clno))) 
		AND (convert(date,A.Apdate) >= @StartDate) and (convert(date,A.Apdate) <= @EndDate)
		and RA.AffiliateID = IIF(@Affiliate=0, RA.AffiliateID, @Affiliate) 
		AND (ISNULL(F.IsOneHR,0) = @IsOneHR)
		AND LEN(Replace(REPLACE(A.Priv_Notes , char(10),';'),char(13),';')) < 32767
		)


		UNION

		(SELECT isnull(A.Attn,'') as [Recruiter],A.APNO  as [Report Number],C.CLNO as [Client ID], C.Name AS ClientName, RA.Affiliate,A.UserID as [CAM],
				A.First as [Applicant FirstName], A.Last as [Applicant LastName], A.Middle as [Applicant MiddleName],'SanctionCheck' as [Component Type],
				MR.[Status] AS [Component Data], S.Description as [Record Status], A.ApDate as [Date Created], a.CompDate as [Report CompletedDate],
				CASE m.IsHidden WHEN 1 THEN 'UnUsed' ELSE 'On Report' End AS IsHidden, '' AS IsOnReport,A.Priv_Notes as [Private Notes],
				A.Pub_Notes as [Public Notes],A.PackageID,
				[dbo].[ElapsedBusinessDays_2](A.Apdate, A.OrigCompDate) as [TAT], (CASE WHEN F.IsOneHR = 0 THEN 'False' ELSE 'True' END) AS IsOneHR
		FROM dbo.Appl AS A(NOLOCK)
		INNER JOIN dbo.MedInteg AS m WITH(NOLOCK) ON m.Apno = A.APNO
		LEFT OUTER JOIN dbo.MedIntegLog MR ON m.APNO = MR.APNO
		INNER JOIN dbo.Client AS C WITH(NOLOCK) ON C.CLNO = A.CLNO
		INNER JOIN dbo.SectStat AS S WITH(NOLOCK) ON S.Code = m.SectStat
		INNER JOIN dbo.refAffiliate RA WITH(NOLOCK) ON C.AffiliateID = RA.AffiliateID
		LEFT OUTER JOIN HEVN.dbo.Facility F (NOLOCK) ON isnull(A.DeptCode,0) = F.FacilityNum
		WHERE (@clno IS NULL OR a.CLNO IN (SELECT * from [dbo].[Split](':',@clno))) 
		AND (convert(date,A.Apdate) >= @StartDate) and (convert(date,A.Apdate) <= @EndDate)
		and RA.AffiliateID = IIF(@Affiliate=0, RA.AffiliateID, @Affiliate) 
		AND (ISNULL(F.IsOneHR,0) = @IsOneHR)
		AND LEN(Replace(REPLACE(A.Priv_Notes , char(10),';'),char(13),';')) < 32767
		)
	) QRY 
		LEFT OUTER JOIN dbo.PackageMain P WITH (NOLOCK) ON Qry.PackageID = P.PackageID
		LEFT OUTER JOIN dbo.ClientPackages CP WITH (NOLOCK) ON P.PackageID = CP.PackageID
END


