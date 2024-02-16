
Create Proc dbo.FormAdverseContactInfo_InsAdverseContact
@apno int,
@clno int,
@contactname varchar(50),
@workphone varchar(20),
@workext varchar(10),
@homephone varchar(20),
@cellphone varchar(20),
@email varchar(50),
@adversecontacttypeid int

As
Declare @ErrorCode int
declare @adverseactionid int
declare @adversecontactid int

Begin Transaction
-- insert AdverseContact
insert AdverseContact (clno,contactname,workphone,workext,homephone,cellphone,email,adversecontacttypeid)
values (@clno,@contactname,@workphone,@workext,@homephone,@cellphone,@email,@adversecontacttypeid)

--for insert AdverseContactLog
set @adversecontactid=ident_current('AdverseContact') 
set @adverseactionid=(select adverseactionid from adverseaction where apno=@apno)

-- insert AdverseContactLog
insert AdverseContactLog(adverseactionid,adversecontactid)
values (@adverseactionid,@adversecontactid)
            
Set @ErrorCode=@@Error
If (@ErrorCode<>0)
  Begin
  RollBack Transaction
  Return (-@ErrorCode)
  End
Else
  Commit Transaction
  


