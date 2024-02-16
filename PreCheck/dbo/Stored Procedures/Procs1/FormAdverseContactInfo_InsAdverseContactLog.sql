
Create Proc dbo.FormAdverseContactInfo_InsAdverseContactLog
@apno int,
@adversecontactid int

As
Declare @ErrorCode int
declare @adverseactionid int

Begin Transaction
-- insert AdverseContactLog
set @adverseactionid=(select adverseactionid from adverseaction where apno=@apno)
insert AdverseContactLog (AdverseActionID,AdverseContactID)
values (@adverseactionid,@adversecontactid)
            
Set @ErrorCode=@@Error
If (@ErrorCode<>0)
  Begin
  RollBack Transaction
  Return (-@ErrorCode)
  End
Else
  Commit Transaction
  


