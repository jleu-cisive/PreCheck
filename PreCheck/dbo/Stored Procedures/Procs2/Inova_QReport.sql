
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Inova_QReport]
	-- Add the parameters for the stored procedure here
	@StartDate DateTime,
	 @EndDate Datetime

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here


Select a.Apno as [Report Number], a.CLNO as [Client Number], e.school as Education, e.Studies_V as Studies, a.First as [First Name], a.Last as [Last Name], a.SSN as SSN, a.DOB as DOB,  e.degree_A as [Applicant Provided Degree], 
e.Degree_V as [Degree Verified], P.Lic_Type_V, P.Expire_V, a.apdate as [Report Date]
from Appl a
Inner join Educat E on E.Apno = A.APno
Inner join ProfLic P on P.aPno = a.apno
where (a.Apdate between @StartDate and @EndDate)
and (P.Lic_Type_V = 'RN' or P.lic_Type_V ='Registered Nurse')
and (a.clno in (1936, 1932, 1934, 1935, 1937, 3696))
and e.IsonReport = 1
order by a.apno, a.CLNO

END
