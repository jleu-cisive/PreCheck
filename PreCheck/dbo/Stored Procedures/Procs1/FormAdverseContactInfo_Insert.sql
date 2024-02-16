
Create Proc dbo.FormAdverseContactInfo_Insert
(@apno int,
 @userid char(10),
 @clno int,
 @adversecontactmethodid int,
 @adversecontactid int,
 @adversecontactid2 int,
 @contactname nvarchar(50),
 @workphone nvarchar(20),
 @workext char(4),
 @homephone nvarchar(20),
 @cellphone nvarchar(15),
 @email nvarchar(50),
 @adversecontacttypeid int, 
 @comment text
 )
as
declare @ErrorCode int
declare @adverseactionid int
declare @adversechangetypeid int
declare @cnt1 int
declare @cnt2 int

begin transaction
set @ErrorCode=@@Error

set @cnt1=(select count(apno) from adverseaction where apno=@apno)
if @adversecontacttypeid=3
 begin
  set @cnt2=(select count(adversecontactid) from adversecontact where clno=@clno and contactname=@contactname)
 end

else if @adversecontacttypeid=2
 begin
  set @cnt2=(select count(ac.adversecontactid) 
	     from adversecontact ac,adversecontactlog acl,adverseaction aa,appl a 
	    where ac.adversecontactid=acl.adversecontactid
	      and acl.adverseactionid=aa.adverseactionid
	      and aa.apno=a.apno
              and ac.clno=0 
	      and ac.contactname=@contactname 
              and a.ssn=(select ssn from appl where apno=@apno)
	     )
 end

if @cnt1=0 --for new apno
begin
  --insert into AdverseAction and AdverseActionHistory
  exec dbo.FormAdverseContactInfo_InsAdverseAction @apno,@userid,@adversecontactmethodid,@comment

  if @cnt2=0 --for a new Contact
   begin
     exec FormAdverseContactInfo_InsAdverseContact @apno,@clno,@contactname,@workphone,@workext,@homephone,@cellphone,@email,@adversecontacttypeid
   end 
  else if @cnt2!=0 --for an existing contact
   begin
     exec FormAdverseContactInfo_InsAdverseContactLog @apno,@adversecontactid2
   end
end

else if (@cnt1!=0) --for an existing apno in adverseaction
 begin
  set @adverseactionid=(select adverseactionid from adverseaction where apno=@apno)
  set @adversechangetypeid=3
  --insert AdverseActionHistory  
  exec dbo.FormAdverseContactInfo_InsAdverseActionHistory @apno,@userid,@adversechangetypeid,@adversecontactmethodid,@comment
      
  if @cnt2=0 -- for a new Contact
   begin
     exec FormAdverseContactInfo_InsAdverseContact @apno,@clno,@contactname,@workphone,@workext,@homephone,@cellphone,@email,@adversecontacttypeid
   end 
  else if @cnt2!=0 --for an existing apno in adverseaction
   begin
     exec FormAdverseContactInfo_InsAdverseContactLog @apno,@adversecontactid2
   end
 end

If (@ErrorCode<>0)
  Begin
  RollBack Transaction
  Return (-@ErrorCode)
  End
Else
  Commit Transaction
 


