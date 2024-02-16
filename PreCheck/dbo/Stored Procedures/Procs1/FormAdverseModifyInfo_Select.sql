

CREATE Proc [dbo].[FormAdverseModifyInfo_Select]
 @apno int,
 @statusgroup varchar(50) = 'AdverseAction'
as
declare @ErrorCode int

begin transaction
set @ErrorCode=@@Error


 if (@statusgroup = 'FreeReport')
Begin
select aa.FreeReportID,aa.apno,app.ssn,'' as clientemail,aa.name,aa.address1,aa.address2,aa.city,aa.state,aa.zip
from FreeReport aa,appl app
where aa.apno=@apno
  and aa.apno=app.apno

End
  else                        
Begin
select aa.adverseactionid,aa.apno,app.ssn,aa.clientemail,aa.name,aa.address1,aa.address2,aa.city,aa.state,aa.zip
from adverseaction aa,appl app
where aa.apno=@apno
  and aa.apno=app.apno
 End
If (@ErrorCode<>0)
  Begin
  RollBack Transaction
  Return (-@ErrorCode)
  End
Else
  Commit Transaction

