
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Inova_Nursing_Education]
	-- Add the parameters for the stored procedure here
	@CLNO int,
	@StartDate DateTime,
	@EndDate Datetime

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here


Select a.Apno as [Report Number], a.CLNO as [Client Number], e.school as Education, e.Studies_V as Studies, a.First as [First Name], a.Last as [Last Name], a.SSN as SSN, a.DOB as DOB,  e.degree_A as [Applicant Provided Degree], 
e.Degree_V as [Degree Verified],  a.apdate as [Report Date]
from Appl a
Inner join Educat E on E.Apno = A.APno
where (a.Apdate between @StartDate and @EndDate)
and (a.clno = @CLNO)
and e.IsonReport = 1
order by a.apno, a.CLNO

END