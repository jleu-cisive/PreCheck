

--EXEC Precheck.[dbo].[Reports_Crim_Found] 1935,'08/10/2011','09/15/2014'

-- =============================================
-- Author:		<Prasanna>
-- Create date: <09/25/2014>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Reports_Crim_Found]
    @CLNO int,
	@StartDate DateTime,
	@EndDate DateTime

AS
BEGIN
	--select appl.CLNO as [Client ID], crim.apno as [Report Number], crim.Name as [Applicant Name], CONVERT(varchar(10),ApDate,101) as ApDate, appl.CompDate as 
	--[Report Completion Date],crim.County as County
	--from Appl appl (NOLOCK) inner join Crim crim (NOLOCK) on appl.apno = crim.apno where appl.CLNO = @CLNO  and (crim.CLEAR ='F' or crim.CLEAR = 'P')
	--and (Apdate >= @Startdate and Apdate <= @Enddate)

	SELECT c.CLNO, a.APNO as [Report Number]
	, CONCAT(ISNULL(a.[First],''),' ',ISNULL(a.Middle,''),' ',ISNULL(a.[Last],'')) as [Applicant Name]
	, crim.County as County
    , CONVERT(varchar(10),ApDate,101) as ApDate
	, a.CompDate
	FROM Appl a (NOLOCK) 
	INNER JOIN Crim crim (NOLOCK) on crim.apno = a.apno
	INNER JOIN Client c (NOLOCK) ON c.CLNO = a.CLNO
	WHERE ApDate >= @StartDate AND ApDate < @EndDate and c.CLNO=@Clno AND (crim.CLEAR ='F' or crim.CLEAR = 'P')
	ORDER BY ApDate

END