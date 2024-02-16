
Create Proc dbo.sp_FormAdverseContactInfo
  @apno int
As
Declare @ErrorCode int

Begin Transaction
select aa.AdverseActionID As AAID,aa.APNO,aa.[Name] as ApplicantName,
       appl.SSN,appl.CLNO,c.[Name] As Client
       --,acl.Comments,convert(char(10),acl.[Date],101) As ContactDate,
       --refacm.Method As ContactMethod,refacs.Summary As ContactSummary
from   AdverseAction aa,Appl appl,Client c--,AdverseContactLog acl
       --refAdverseContactMethod refacm,refAdverseContactSummary refacs
where  aa.apno=@apno     
       and aa.apno=appl.apno
       and appl.clno=c.clno 
       --and aa.adverseactionid*=acl.adverseactionid
       --and acl.AdverseContactMethodID *= refacm.AdverseContactMethodID
       --and acl.AdverseSummaryID *= refacs.AdverseContactSummaryID
/*
select ac.AdverseActionID As AAID,ac.APNO,appl.CLNO,c.[Name] As Client,
       acl.SSN,acl.ApplicantName,acl.Comments,convert(char(10),acl.[Date],101) As ContactDate,
       refacm.Method As ContactMethod,refacs.Summary As ContactSummary
from   AdverseAction ac,AdverseContactLog acl,Appl appl,Client c,
       refAdverseContactMethod refacm,refAdverseContactSummary refacs
where  ac.APNO=@APNO 
       and ac.adverseactionid=acl.adverseactionid
       and ac.apno=appl.apno
       and appl.clno=c.clno 
       and acl.AdverseContactMethodID *= refacm.AdverseContactMethodID
       and acl.AdverseSummaryID *= refacs.AdverseContactSummaryID
*/
             
Set @ErrorCode=@@Error
If (@ErrorCode<>0)
  Begin
  RollBack Transaction
  Return (-@ErrorCode)
  End
Else
  Commit Transaction
  Return (0)

