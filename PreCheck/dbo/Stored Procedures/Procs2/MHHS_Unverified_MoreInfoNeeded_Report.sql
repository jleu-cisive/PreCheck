
/*---------------------------------------------------------------------------------------------------------------------
Requested By: Brian Silver
Author: Prasanna
Date : 02/05/2020
Description: Created from the QReport "Client_BackgroundCheck_ReportDetails_For_Client_Or_ClientGroup"
--EXEC [dbo].[MHHS_Unverified_MoreInfoNeeded_Report] 8
*/--------------------------------------------------------------------------------------------------------------------------

CREATE PROCEDURE [dbo].[MHHS_Unverified_MoreInfoNeeded_Report]
@Affiliate int = 8
AS

BEGIN
Declare @StartDate datetime
Set @StartDate = dateadd(day,datediff(day,1,GETDATE()),0)
Declare @EndDate Datetime
Set @EndDate =  dateadd(day,datediff(day,0,GETDATE()),0)


	SELECT [Report Number],[Client Number],[Client Name], [Applicant FirstName],  [Applicant LastName], [Applicant MiddleName], [Component Type], [Component Data], [Record Status], [Onboarder]
	  FROM 
	(
		(SELECT  A.APNO  as [Report Number],C.CLNO as [Client Number], C.Name AS [Client Name], A.First as [Applicant FirstName], A.Last as [Applicant LastName], 
		A.Middle as [Applicant MiddleName], 'Employment' as [Component Type], emp.Employer as [Component Data], S.Description as [Record Status], Replace(A.Attn,',', '') AS [Onboarder]
		FROM dbo.Appl AS A(NOLOCK)
		INNER JOIN dbo.Empl AS emp WITH(NOLOCK) ON emp.Apno = A.APNO
		INNER JOIN dbo.Client AS C WITH(NOLOCK) ON C.CLNO = A.CLNO
		INNER JOIN dbo.SectStat AS S WITH(NOLOCK) ON S.Code = emp.SectStat
		INNER JOIN dbo.refAffiliate RA WITH(NOLOCK) ON C.AffiliateID = RA.AffiliateID
		LEFT OUTER JOIN ApplicantContact ac on emp.Apno = ac.APno and ac.ApplSectionID =1
		LEFT OUTER JOIN refReasonforContact rcr on ac.refReasonForContactID = rcr.refReasonForContactID
		WHERE 
		(A.CompDate between @StartDate and @EndDate)
	--	and A.ReopenDate IS NULL
		and RA.AffiliateID = IIF(@Affiliate=0, RA.AffiliateID, @Affiliate) 
		and Emp.SectStat IN ('6','U') AND Emp.IsOnReport = 1 and Emp.IsHidden =0
		)

		UNION

		(SELECT  A.APNO  as [Report Number],C.CLNO as [Client Number], C.Name AS [Client Name], A.First as [Applicant FirstName], A.Last as [Applicant LastName], 
		A.Middle as [Applicant MiddleName], 'Education' as [Component Type], edu.School as [Component Data], S.Description as [Record Status], Replace(A.Attn,',', '') AS [Onboarder]
		FROM dbo.Appl AS A(NOLOCK)		
		INNER JOIN dbo.Educat AS edu WITH(NOLOCK) ON edu.Apno = A.APNO
		INNER JOIN dbo.Client AS C WITH(NOLOCK) ON C.CLNO = A.CLNO
		INNER JOIN dbo.SectStat AS S WITH(NOLOCK) ON S.Code = edu.SectStat
		INNER JOIN dbo.refAffiliate RA WITH(NOLOCK) ON C.AffiliateID = RA.AffiliateID
		LEFT OUTER JOIN ApplicantContact ac on edu.Apno = ac.Apno and ac.ApplSectionID =2
		LEFT OUTER JOIN refReasonforContact rcr on ac.refReasonForContactID = rcr.refReasonForContactID
		WHERE (A.CompDate between @StartDate and @EndDate)
		and RA.AffiliateID = IIF(@Affiliate=0, RA.AffiliateID, @Affiliate) 
	--	AND A.ReopenDate IS NULL
		and Edu.SectStat IN ('6', 'U') AND Edu.IsOnReport = 1 and Edu.IsHidden =0
		)

		UNION

		(SELECT  A.APNO  as [Report Number],C.CLNO as [Client Number], C.Name AS [Client Name], A.First as [Applicant FirstName], A.Last as [Applicant LastName], 
		A.Middle as [Applicant MiddleName], 'Public Records' as [Component Type], crim.County as [Component Data], css.CrimDescription as [Record Status], Replace(A.Attn,',', '') AS [Onboarder]
		FROM dbo.Appl AS A(NOLOCK)
		INNER JOIN dbo.Crim AS crim WITH(NOLOCK) ON crim.Apno = A.APNO
		INNER JOIN dbo.Client AS C WITH(NOLOCK) ON C.CLNO = A.CLNO
		INNER JOIN dbo.Crimsectstat AS css WITH(NOLOCK) ON css.crimsect = crim.Clear
		INNER JOIN dbo.refAffiliate RA WITH(NOLOCK) ON C.AffiliateID = RA.AffiliateID
		WHERE (A.CompDate between @StartDate and @EndDate)
		and RA.AffiliateID = IIF(@Affiliate=0, RA.AffiliateID, @Affiliate) 
	   -- AND A.ReopenDate IS NULL
		AND crim.Clear IN ('P') and Crim.IsHidden =0
		)
		
	) QRY 
		
END


