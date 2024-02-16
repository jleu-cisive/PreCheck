
Create Proc dbo.FormAdverseContactInfo_PreFill
@apno int

as
declare @ErrorCode int
declare @cnt int


Begin Transaction
Set @ErrorCode=@@Error

set @cnt=(select count(apno) from adverseaction where apno=@apno)

-- for an existing apno
if @cnt!=0 
 begin
   select aa.apno,appl.ssn,
	  aa.[name] as applicant,appl.clno,c.[name] as client
   from   adverseaction aa,appl appl,client c
   where  aa.apno=@apno
     and  aa.apno=appl.apno
     and  appl.clno=c.clno
 end

-- for a new apno
else if @cnt=0 
 begin 
   select appl.apno,appl.ssn,
	  	case 
    	 	   when appl.middle is null
    	 		then appl.[first]+' '+appl.[last]
    	 	   when appl.middle is not null
    			then appl.[first]+' '+appl.middle+' '+appl.[last] 
    	 	end as applicant,
                appl.clno,c.[name] as client
     from  appl,client c
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
  

