
Create Proc dbo.FormAdverseContactInfo_InsAdverseAction
@apno int,
@userid char(10),
@adversecontactmethodid int,
@comment text

As
Declare @ErrorCode int
Declare @adverseactionid int

Begin Transaction
--insert into AdverseAction table
insert AdverseAction (apno,statusid,name,address1,city,state,zip)
select @apno,1
       ,first+' '+isnull(middle,'')+' '+last
       ,isnull(addr_num,'')+' '+isnull(addr_dir,'')+' '+addr_street+' '+isnull(addr_sttype,'')+' '+isnull(addr_apt,'')
       ,city
       ,state
       ,zip
from appl
where apno=@apno
set @adverseactionid=ident_current('AdverseAction')--for insert AdverseACtionHistory 

--insert into AdverseActionHistory table
insert into AdverseActionHistory (AdverseActionID,AdverseChangeTypeID,StatusID,UserID,AdverseContactMethodID,Comments,Date)
values(@adverseactionid,1,1,@userid,@adversecontactmethodid,@comment,getdate())
            
Set @ErrorCode=@@Error
If (@ErrorCode<>0)
  Begin
  RollBack Transaction
  Return (-@ErrorCode)
  End
Else
  Commit Transaction

  



