-- =============================================
-- Author:		Prasanna
-- Create date: 08/22/2017
-- Description:	all clients where "OK to Contact Applicant" is not checked in Oasis Client Form
-- Exec OKToContactApplicant '04/01/2017','04/10/2017'
-- =============================================
CREATE PROCEDURE OKToContactApplicant 

    @StartDate DateTime = null,
	@EndDate DateTime = null
	
AS
BEGIN
	
	select distinct  c.CLNO, c.Name,(case when c.OKToContact=0 then 'False' else 'True' end) as OKToContactApplicant,refEmp.Employment as [Employment Requirements],COUNT(empl.EMPLID) OVER (PARTITION BY c.CLNO) as [Number of Employments] from Client c(nolock)
inner join Appl appl(nolock) on appl.CLNO=c.CLNO
inner join Empl empl(nolock) on empl.Apno = appl.APNO
inner join refEmployment refEmp(nolock) on refEmp.EmploymentID = c.EmploymentID where c.IsInactive=0 and (appl.ApDate BETWEEN @StartDate AND DATEADD(S,-1,DATEADD(D,1,@EndDate))) and c.OKtoContact=0
group by c.CLNO, c.Name,c.OKToContact,refEmp.Employment,empl.EMPLID;

END
