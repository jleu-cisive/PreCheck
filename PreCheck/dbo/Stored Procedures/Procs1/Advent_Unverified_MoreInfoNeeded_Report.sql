
/*---------------------------------------------------------------------------------------------------------------------
Requested By: Brian Silver
Author: Prasanna
Date : 07/10/2019
Description: Created from the QReport "Client_BackgroundCheck_ReportDetails_For_Client_Or_ClientGroup"
--Modified by Humera Ahmed for HDT - 57607 and Change request 612 - Add new Recruiter column
--EXEC [dbo].[Advent_Unverified_MoreInfoNeeded_Report] 230
*/--------------------------------------------------------------------------------------------------------------------------

CREATE PROCEDURE [dbo].[Advent_Unverified_MoreInfoNeeded_Report]
--@Clno int = 0,
@Affiliate int = 0
AS

BEGIN

	--if(@CLNO = '0' OR @CLNO = '' OR LOWER(@CLNO) = 'null') Begin  SET @CLNO = NULL  END

	SELECT [Report Number],[Client Number],[Client Name], [Applicant FirstName],  [Applicant LastName], [Applicant MiddleName], [Candidate ID], [Component Type], [Component Data], [Record Status], [Applicant Contact Y/N], [Applicant Contact Reason], [Recruiter]
	  FROM 
	(
		(SELECT  A.APNO  as [Report Number],C.CLNO as [Client Number], C.Name AS [Client Name], RA.Affiliate,A.UserID as [CAM], A.First as [Applicant FirstName], 
		A.Last as [Applicant LastName], A.Middle as [Applicant MiddleName], A.ClientApplicantNO AS [Candidate ID], 'Employment' as [Component Type], emp.Employer as [Component Data], 
		S.Description as [Record Status], [Applicant Contact Y/N] = (CASE WHEN C.OKtoContact = 1 THEN 'Y' ELSE 'N' END), rcr.ItemName AS [Applicant Contact Reason], Replace(A.Attn,',', '') AS [Recruiter]
		FROM dbo.Appl AS A(NOLOCK)
		INNER JOIN dbo.Empl AS emp WITH(NOLOCK) ON emp.Apno = A.APNO
		INNER JOIN dbo.Client AS C WITH(NOLOCK) ON C.CLNO = A.CLNO
		INNER JOIN dbo.SectStat AS S WITH(NOLOCK) ON S.Code = emp.SectStat
		INNER JOIN dbo.refAffiliate RA WITH(NOLOCK) ON C.AffiliateID = RA.AffiliateID
		LEFT OUTER JOIN ApplicantContact ac on emp.Apno = ac.APno and ac.ApplSectionID =1
		LEFT OUTER JOIN refReasonforContact rcr on ac.refReasonForContactID = rcr.refReasonForContactID
		WHERE --C.CLNO = IIF(@CLNO =0, C.CLNO , @CLNO) AND
		(A.Apdate >= dateadd(day,datediff(day,1,GETDATE()),0) and A.Apdate < dateadd(day,datediff(day,0,GETDATE()),0))
		AND A.ReopenDate IS NULL
		and RA.AffiliateID = IIF(@Affiliate=0, RA.AffiliateID, @Affiliate) 
		and Emp.SectStat IN ('6') AND Emp.IsOnReport = 1 and Emp.IsHidden =0
		)

		UNION

		(SELECT A.APNO  as [Report Number],C.CLNO as [Client Number], C.Name AS [Client Name], RA.Affiliate,A.UserID as [CAM],A.First as [Applicant FirstName],
		 A.Last as [Applicant LastName], A.Middle as [Applicant MiddleName], A.ClientApplicantNO AS [Candidate ID], 'Education' as [Component Type], edu.School as [Component Data], 
		S.Description as [Record Status], [Applicant Contact Y/N] = (CASE WHEN C.OKtoContact = 1 THEN 'Y' ELSE 'N' END), rcr.ItemName AS [Applicant Contact Reason], Replace(A.Attn,',', '') AS [Recruiter]
		FROM dbo.Appl AS A(NOLOCK)
		INNER JOIN dbo.Educat AS edu WITH(NOLOCK) ON edu.Apno = A.APNO
		INNER JOIN dbo.Client AS C WITH(NOLOCK) ON C.CLNO = A.CLNO
		INNER JOIN dbo.SectStat AS S WITH(NOLOCK) ON S.Code = edu.SectStat
		INNER JOIN dbo.refAffiliate RA WITH(NOLOCK) ON C.AffiliateID = RA.AffiliateID
		LEFT OUTER JOIN ApplicantContact ac on edu.Apno = ac.Apno and ac.ApplSectionID =2
		LEFT OUTER JOIN refReasonforContact rcr on ac.refReasonForContactID = rcr.refReasonForContactID
		WHERE  --C.CLNO = IIF(@CLNO =0, C.CLNO , @CLNO) AND 
		(A.Apdate >= dateadd(day,datediff(day,1,GETDATE()),0) and A.Apdate < dateadd(day,datediff(day,0,GETDATE()),0))
		and RA.AffiliateID = IIF(@Affiliate=0, RA.AffiliateID, @Affiliate) 
		AND A.ReopenDate IS NULL
		and Edu.SectStat IN ('6') AND Edu.IsOnReport = 1 and Edu.IsHidden =0
		)

		UNION

		(SELECT A.APNO  as [Report Number],C.CLNO as [Client Number], C.Name AS [Client Name], RA.Affiliate,A.UserID as [CAM],A.First as [Applicant FirstName],
		 A.Last as [Applicant LastName], A.Middle as [Applicant MiddleName], A.ClientApplicantNO AS [Candidate ID], 'Public Records' as [Component Type], crim.County as [Component Data], 
		 css.CrimDescription as [Record Status], [Applicant Contact Y/N] = (CASE WHEN C.OKtoContact = 1 THEN 'Y' ELSE 'N' END), '' AS [Applicant Contact Reason], Replace(A.Attn,',', '') AS [Recruiter]
		FROM dbo.Appl AS A(NOLOCK)
		INNER JOIN dbo.Crim AS crim WITH(NOLOCK) ON crim.Apno = A.APNO
		INNER JOIN dbo.Client AS C WITH(NOLOCK) ON C.CLNO = A.CLNO
		INNER JOIN dbo.Crimsectstat AS css WITH(NOLOCK) ON css.crimsect = crim.Clear
		INNER JOIN dbo.refAffiliate RA WITH(NOLOCK) ON C.AffiliateID = RA.AffiliateID
		WHERE --C.CLNO = IIF(@CLNO =0, C.CLNO , @CLNO) AND  
		(A.Apdate >= dateadd(day,datediff(day,1,GETDATE()),0) and A.Apdate < dateadd(day,datediff(day,0,GETDATE()),0))
		and RA.AffiliateID = IIF(@Affiliate=0, RA.AffiliateID, @Affiliate) 
	    AND A.ReopenDate IS NULL
		AND crim.Clear IN ('P') and Crim.IsHidden =0
		)
		
	) QRY 
		
END


