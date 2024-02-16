

--EXEC Precheck.[dbo].[Reports_Education_Unverified] 1935,'08/10/2011','09/15/2014'

-- =============================================
-- Author:		<Prasanna>
-- Create date: <09/25/2014>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Reports_Education_Unverified]
    @CLNO int,
	@StartDate DateTime,
	@EndDate DateTime

AS
BEGIN

 		 SELECT c.CLNO, a.APNO as [Report Number]
		, CONCAT(ISNULL(a.[First],''),' ',ISNULL(a.Middle,''),' ',ISNULL(a.[Last],'')) as [Applicant Name]
		, e.School as [Name of Unverified Education]
        , CONVERT(varchar(10),ApDate,101) as ApDate
		, a.CompDate
		FROM Appl a (NOLOCK) 
		INNER JOIN Educat e (NOLOCK) ON e.APNO=a.APNO
		INNER JOIN SectStat s (NOLOCK) ON s.Code=e.SectStat
		INNER JOIN Client c (NOLOCK) ON c.CLNO = a.CLNO
		WHERE ApDate >= @StartDate AND ApDate <= @EndDate and c.CLNO=@Clno AND Description in ('UNVERIFIED/SEE ATTACHED')
		ORDER BY ApDate

END