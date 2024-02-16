


CREATE Proc [dbo].[sp_FormAdverseEmailClient]
@APNO int,
@StatusId int
As
Declare @ErrorCode int

Begin Transaction
Set @ErrorCode=@@Error

select aet.[From],aa.ClientEmail as [To],
       aet.subject1+appl.[last]+', '+appl.[first]+'; (APNO: '+Convert(char(7),aa.apno)+') '+aet.subject2 as Subject,
       aet.body1+appl.[last]+', '+appl.[first]+'; (APNO: '+Convert(char(7),aa.apno)+')'+aet.body2 as Body
from   AdverseAction aa,AdverseEmailTemplate aet,Appl appl, 
	client c	--hz added this line on 7/3/06
where  aa.apno=@APNO
  and  aa.apno=appl.apno
  and  aet.refAdverseStatusID=@StatusId 
  and appl.clno=c.clno and isnull(c.adverse,-1)<>3  --hz added this line on 7/3/06
  


If (@ErrorCode<>0)
  Begin
  RollBack Transaction
  Return (-@ErrorCode)
  End
Else
  Commit Transaction
  --Return (@ErrorCode)

