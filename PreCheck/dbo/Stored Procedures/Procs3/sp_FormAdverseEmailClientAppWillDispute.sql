
CREATE Proc [dbo].[sp_FormAdverseEmailClientAppWillDispute]
@APNO int
As
Declare @ErrorCode int

Begin Transaction
Set @ErrorCode=@@Error

select '192.168.1.28' as MailServer,aet.[From],aa.ClientEmail as [To],
       aet.subject1+appl.[last]+', '+appl.[first]+'; (APNO: '+Convert(char(7),aa.apno)+') '+aet.subject2 as Subject,
       aet.body1+appl.[last]+', '+appl.[first]+'; (APNO: '+Convert(char(7),aa.apno)+')'+aet.body2 as Body
from   AdverseAction aa,AdverseEmailTemplate aet,Appl appl
where  aa.apno=@APNO
  and  aa.apno=appl.apno
  and  aet.refAdverseStatusID=7 


If (@ErrorCode<>0)
  Begin
  RollBack Transaction
  Return (-@ErrorCode)
  End
Else
  Commit Transaction
  --Return (@ErrorCode)


