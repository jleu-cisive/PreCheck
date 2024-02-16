

--EXEC Precheck.[dbo].[Reports_Empl_Verified] 1935,'08/10/2011','09/15/2014'

-- =============================================
-- Author:		<Prasanna>
-- Create date: <10/07/2014>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Reports_Empl_Verified]
    @CLNO int,
	@StartDate DateTime,
	@EndDate DateTime

AS
BEGIN

	SELECT c.CLNO, a.APNO as [Report Number]
	,CONCAT(ISNULL(a.[First],''),' ',ISNULL(a.Middle,''),' ',ISNULL(a.[Last],'')) as [Applicant Name]
	,emp.Employer as [Name of Verified Employer]
	,a.CompDate as [Date of ReportCompletion]
	FROM Appl a (NOLOCK) 
	INNER JOIN Client c (NOLOCK) ON c.CLNO = a.CLNO
	INNER JOIN Empl emp (NOLOCK) ON emp.APNO = a.APNO 
	INNER JOIN SectStat s (NOLOCK) ON s.Code = emp.SectStat 
	WHERE ApDate >= @StartDate AND ApDate <= @EndDate and c.CLNO=@Clno AND s.Description in ('VERIFIED')
	ORDER BY ApDate


END




