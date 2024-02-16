
Create Proc dbo.FormAdverseFileOpenFinalize_ClientEmail
@adverseActionId int

As
declare @ErrorCode int
declare @statusid int

Begin Transaction
Set @ErrorCode=@@Error

if @adverseActionId<0
  begin 
    set @statusid=10
  end
if @adverseActionId>0
  begin
    set @statusid=13
  end

select aet.[From],aa.ClientEmail as [To],
       aet.subject1+aa.name+'; (APNO: '+Convert(char(6),aa.apno)+') '+aet.subject2 as Subject,
       aet.body1+aa.name+'; (APNO: '+Convert(char(6),aa.apno)+')'+aet.body2 as Body
from   AdverseAction aa,AdverseEmailTemplate aet
where  aa.AdverseActionID=abs(@adverseActionId)
  and  aet.refAdverseStatusID=@statusid 


If (@ErrorCode<>0)
  Begin
  RollBack Transaction
  Return (-@ErrorCode)
  End
Else
  Commit Transaction
 

