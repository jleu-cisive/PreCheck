-- =============================================
-- Author:		Radhika Dereddy
-- Create date: 02/11/2019
-- Description: INOVA Pending Report [date], to include all pending reports currently open and display the following fields:
-- =============================================
CREATE PROCEDURE [dbo].[INOVA_Pending_Report]
	-- Add the parameters for the stored procedure here

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


WITH MainQuery ([ReportNumber], [ClientID], [ClientName], [PendingDays], [DateSubmitted],[LastName],[FirstName],[SSN]) AS
(
	SELECT a.Apno as [ReportNumber], a.CLNO as [ClientID], C.Name as [ClientName],
		[dbo].[ElapsedBusinessDays_2](A.ApDate,CURRENT_TIMESTAMP) [PendingDays],
		A.ApDate as [DateSubmitted], a.Last as [LastName], a.First as [FirstName],
		'XXX-XX-'+Right((a.ssn),4) as SSN
	FROM Appl A
	INNER JOIN CLIENT C ON A.CLNO = C.CLNO
	WHERE A.apstatus = 'P'
	AND C.CLNO in (1932,1934,1935,1936,1937,3696,8789)
)
, Education ([EducationCount], [APNO]) AS 
(
	SELECT Count(E.APNO) as [EducationCount], E.APNO	
	FROM Educat E 
	INNER JOIN MainQuery A ON E.APNO = A.[ReportNumber] 
	WHERE E.IsOnReport = 1 
	AND E.IsHidden = 0
	AND E.sectstat IN ('0','9','8')
	GROUP BY E.APNO
)
, Employment ([EmploymentCount],[APNO]) AS
(
	SELECT Count(Em.APNO) as [EmploymentCount], Em.APNO
	FROM Empl Em 
	INNER JOIN MainQuery A ON Em.APNO = A.[ReportNumber] 
	WHERE Em.IsOnReport = 1 
	AND Em.IsHidden = 0
	AND Em.sectstat IN ('0','9','8')
	GROUP BY Em.APNO
)
, Criminal ([CriminalCount], [APNO]) AS
(
	SELECT Count(Cr.APNO) as [CriminalCount],cr.APNO
	FROM Crim Cr 
	INNER JOIN MainQuery A ON Cr.APNO = A.[ReportNumber]
	WHERE Cr.ishidden = 0  
	AND ISNULL(Cr.Clear,'') not in ('T','F') 
	GROUP BY Cr.APNO
)
, License ([LicenseCount], APNO) AS
(
	SELECT Count(P.APNO) as [LicenseCount], P.APNO
	FROM ProfLic P 
	INNER JOIN MainQuery A ON P.APNO = A.[ReportNumber]
	WHERE P.isonreport = 1 
	AND P.ishidden = 0 
	AND P.sectstat IN ('0','9','8')
	GROUP BY P.APNO
)
, PersonalReference ([PersonalReferenceCount], APNO) AS
(
	SELECT Count(Pr.APNO) as [PersonalReferenceCount], Pr.APNO
	FROM PersRef Pr 
	INNER JOIN MainQuery A ON Pr.APNO = A.[ReportNumber] 
	WHERE Pr.isonreport = 1 
	AND Pr.ishidden = 0 
	AND Pr.sectstat IN ('0','9','8')
	GROUP BY Pr.APNO
)

SELECT ReportNumber, ClientID, ClientName, PendingDays, FORMAT(DateSubmitted, 'MM/dd/yyyy hh:mm:ss tt') as DateSubmitted, LastName, FirstName, SSN, 
	ISNULL([EmploymentCount],0) [EmploymentCount],ISNULL([EducationCount], 0) [EducationCount],ISNULL([LicenseCount],0) [LicenseCount],
	 ISNULL([PersonalReferenceCount],0) [PersonalReferenceCount],ISNULL([CriminalCount],0) [CriminalCount]
FROM MainQuery A
LEFT JOIN Education E ON A.[ReportNumber] = E.APNO 
LEFT JOIN Employment Em ON A.[ReportNumber] = Em.APNO 
LEFT JOIN Criminal Cr ON A.[ReportNumber] = Cr.APNO 
LEFT JOIN License P ON A.[ReportNumber] = P.APNO 
LEFT JOIN PersonalReference Pr ON A.[ReportNumber] = Pr.APNO 
WHERE ( [EducationCount] > 0 
OR [EmploymentCount] > 0
OR [LicenseCount] > 0
OR [CriminalCount] > 0
OR [PersonalReferenceCount] > 0
)
ORDER BY [ReportNumber]

END
