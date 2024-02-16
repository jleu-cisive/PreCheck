CREATE Proc [dbo].[sp_FormAdverseAppNoResp]
As
Declare @ErrorCode int
Declare @cnt int
Declare @aaid int

Begin Transaction
Set @ErrorCode=@@Error

select distinct aet.[From],aa.ClientEmail as [To],
       aet.subject1+appl.[last]+', '+appl.[first]+'; (APNO: '+Convert(char(6),aa.apno)+') '+aet.subject2 as Subject,
       aet.body1+appl.[last]+', '+appl.[first]+'; (APNO: '+Convert(char(6),aa.apno)+') '+aet.body2 as Body
from   AdverseAction aa,AdverseEmailTemplate aet,Appl appl,adverseactionhistory aah
where  aa.statusid in (5,30)
  and  aa.adverseactionid=aah.adverseactionid
  and  aa.statusid=aah.statusid
  and  datediff (dd,aah.[date],getdate())>5
  and  aa.apno=appl.apno
  and  aet.refAdverseStatusID=6 

set @cnt=(select count(distinct aa.apno)
	  from adverseaction aa, adverseactionhistory aah
	  where aa.statusid in (5,30)
            and aa.adverseactionid=aah.adverseactionid
  	    and aa.statusid=aah.statusid
  	    and datediff (dd,aah.[date],getdate())>5
          )

if @cnt<>0 
Begin --work with cursor
Declare CursorQuery cursor for
	select distinct aa.adverseactionid 
	  from adverseaction aa, adverseactionhistory aah
	  where aa.statusid in (5,30)
	    and aa.adverseactionid=aah.adverseactionid
  	    and aa.statusid=aah.statusid
  	    and datediff (dd,aah.[date],getdate())>5
open CursorQuery
fetch next from CursorQuery
into @aaid 
while @@fetch_status=0
begin

insert into adverseactionhistory 
values (@aaid,1,6,'AutoEmail',null,null,getdate(),null,0)

update adverseaction
set statusid=6
where adverseactionid=@aaid

fetch next from cursorquery
into @aaid
end
close cursorquery
deallocate cursorquery
End --ending work with cursor
            
If (@ErrorCode<>0)
  Begin
  RollBack Transaction
  Return (-@ErrorCode)
  End
Else
  Commit Transaction
