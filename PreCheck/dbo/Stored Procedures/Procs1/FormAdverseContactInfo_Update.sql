
Create Proc dbo.FormAdverseContactInfo_Update
 @apno int, 
 @userid char(10),
 --@clno int,
 @adversecontactmethodid int,
 @adversecontactid int,
 --@contactname nvarchar(50),
 @workphone nvarchar(20),
 @workext char(4),
 @homephone nvarchar(20),
 @cellphone nvarchar(15),
 @email nvarchar(50),
 --@adversecontacttypeid int,
 @comment text
 
as
declare @ErrorCode int
declare @adverseactionid int
declare @adversechangetypeid int

set @adverseactionid=(select adverseactionid from adverseaction where apno=@apno)

begin transaction
set @ErrorCode=@@Error

--update adversecontact table
 begin
  update AdverseContact
	set --CLNO=@clno,
            --ContactName=@contactname,
	    WorkPhone=@workphone,
	    WorkExt=@workext,
	    HomePhone=@homephone,
	    CellPhone=@cellphone,
	    Email=@email--,
	    --AdverseContactTypeID=@adversecontacttypeid
      where AdverseContactID=@adversecontactid
 end

--insert adverseactionhistory table
set @adversechangetypeid=4 -- for contact information changed
exec FormAdverseContactInfo_InsAdverseActionHistory @apno,@userid,@adversechangetypeid,@adversecontactmethodid,@comment


If (@ErrorCode<>0)
  Begin
  RollBack Transaction
  Return (-@ErrorCode)
  End
Else
  Commit Transaction
  



