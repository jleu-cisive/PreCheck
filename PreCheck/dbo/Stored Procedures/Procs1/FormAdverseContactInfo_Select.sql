
Create Proc dbo.FormAdverseContactInfo_Select
@adversecontactid int,
@adversecontactid2 int,
@apno int

as
declare @ErrorCode int
declare @clno int

Begin Transaction
Set @ErrorCode=@@Error

if @adversecontactid!=0
 begin
  select @apno as apno,'' as userid,ac.clno,0 as adversecontactmethodid,
	 ac.adversecontactid,ac.contactname,ac.workphone,ac.workext,ac.homephone,
         ac.cellphone,ac.email,ac.adversecontacttypeid,'' as comment,'' as adversecontactid2
    from adverseaction aa,adversecontactlog acl,adversecontact ac
   where aa.adverseactionid=acl.adverseactionid
     and acl.adversecontactid=ac.adversecontactid
     and ac.adversecontactid=@adversecontactid
     and aa.apno=@apno
 end

else --@adversecontactid=0
 begin
 if @adversecontactid2!=0
  begin
   select @apno as apno,'' as userid,ac.clno as clno,0 as adversecontactmethodid,
	  @adversecontactid2 as adversecontactid,ac.contactname,ac.workphone,ac.workext,ac.homephone,
          ac.cellphone,ac.email,ac.adversecontacttypeid,'' as comment,@adversecontactid2 as adversecontactid2
     from adversecontactlog acl,adversecontact ac
    where acl.adversecontactid=ac.adversecontactid
      and ac.adversecontactid=@adversecontactid2
  end
 end

If (@ErrorCode<>0)
  Begin
  RollBack Transaction
  Return (-@ErrorCode)
  End
Else
  Commit Transaction
  
 


