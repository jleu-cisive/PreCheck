
CREATE PROCEDURE [dbo].[CriminalSearchApproval] --'09/21/2015', '09/21/2015'

@StartDate DateTime = '09/21/2015', 
@EndDate DateTime = '09/21/2015'

AS

select a.first as [Applicant First Name], a.last as [Applicant Last Name], a.apdate as [App Created Date], a.APNO as [Report Number], c.name as [Client], a.investigator as [Investigator (AI)], a.userid as [CAM], count(*) as [# of Approval(s)]  
from Precheck.dbo.appl a join 
(select apno, countyname, [source], max(createdDate) as createdDate  from Metastorm9_2.dbo.CrimCountyApproval group by apno, countyname, [source]
having max(CreatedDate) between @StartDate and dateadd(s,-1,dateadd(d,1,@EndDate)))cm 
on a.APNO = cm.apno join client c on a.clno = c.clno group by
a.first, a.last, a.apdate, a.APNO, c.name, a.investigator, a.userid
having a.ApDate between @StartDate and dateadd(s,-1,dateadd(d,1,@EndDate))


