
Create Proc dbo.FormAdverseContactInfo_FillCboClientContact
@acid int,
@apno int,
@actid int,
@contactname varchar(50)
as
declare @ErrorCode int
declare @cnt1 int
declare @cnt2 int
declare @cnt3 int
declare @app varchar(50)

Begin Transaction
Set @ErrorCode=@@Error

set @cnt1=(select count(apno) from adverseaction where apno=@apno)
set @cnt2=(select count(distinct clno) from adversecontact where clno=(select clno from appl where apno=@apno))
set @cnt3=(select count(ac.adversecontactid) 
	     from adversecontact ac,adversecontactlog acl,adverseaction aa,appl a 
	    where ac.adversecontactid=acl.adversecontactid
	      and acl.adverseactionid=aa.adverseactionid
	      and aa.apno=a.apno
              and ac.clno=0 
	      and ac.contactname=@contactname 
              and a.ssn=(select ssn from appl where apno=@apno)
	    ) 
set @app=(case @cnt1
		when 1 then (select [name] from adverseaction where apno=@apno)
		when 0 then (select first+' '+isnull(middle,'')+' '+last from appl where apno=@apno)
     	  end)

if (@acid!=0)
 begin
   select adversecontactid,contactname from adversecontact where adversecontactid=@acid
 end

else if (@acid=0)
 begin 
   if (@actid=2)
    begin
     if (@cnt3=0)
       begin
 	select -99 as adversecontactid,@app as contactname  
       end
     else if (@cnt3!=0)
       begin
        select ac.adversecontactid,ac.contactname 
	  from adversecontact ac,adversecontactlog acl,adverseaction aa,appl a 
	 where ac.adversecontactid=acl.adversecontactid
	   and acl.adverseactionid=aa.adverseactionid
	   and aa.apno=a.apno
           and ac.clno=0 
	   and ac.contactname=@contactname 
           and a.ssn=(select ssn from appl where apno=@apno)
       end
    end
   else if (@actid=3)
     begin
	if @cnt2=0
	  begin
		select -99 as advesecontactid, '' as contactname
	  end
	else if @cnt2=1
	  begin
		select adversecontactid,contactname 
		  from adversecontact
		 where clno in (select clno from appl where apno=@apno)
	  end
     end
 end


Set @ErrorCode=@@Error
If (@ErrorCode<>0)
  Begin
  RollBack Transaction
  Return (-@ErrorCode)
  End
Else
  Commit Transaction
 

