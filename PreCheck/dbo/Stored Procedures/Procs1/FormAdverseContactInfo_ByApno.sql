
Create Proc dbo.FormAdverseContactInfo_ByApno
@apno int
as
declare @ErrorCode int
declare @cnt int

Begin Transaction
Set @ErrorCode=@@Error

set @cnt=(select count (apno) from adverseaction where apno=@apno)

if (@cnt!=0)
 begin
   select aa.apno,appl.ssn, --aa.adverseactionid as aaid,
	  aa.[name] as applicant,
          appl.clno,c.[name] as client             
   from   adverseaction aa,appl appl,client c   
   where  aa.apno=@apno
     and  aa.apno=appl.apno
     and  appl.clno=c.clno
  end

else if (@cnt=0)
 begin
   select appl.apno,appl.ssn,
	  case 
    	 	when middle is null
    	 		then [first]+' '+[last]
    	 	when middle is not null
    			then [first]+' '+middle+' '+[last] 
    	 	end as applicant,
          appl.clno,c.[name] as client             
   from   appl appl,client c   
   where  appl.apno=@apno
     and  appl.clno=c.clno
 end
 
If (@ErrorCode<>0)
  Begin
  RollBack Transaction
  Return (-@ErrorCode)
  End
Else
  Commit Transaction
  

