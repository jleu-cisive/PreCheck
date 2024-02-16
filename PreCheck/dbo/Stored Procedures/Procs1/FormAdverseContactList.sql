
Create Proc dbo.FormAdverseContactList
@ssn char(11)
As
Declare @ErrorCode int

Begin Transaction

begin
 select a.apno,a.clno,c.[name] as client,
 case
   when aa.apno=a.apno
     then aa.[name]
   else 
     case
       when a.middle is null
    		then a.[first]+' '+a.[last]
    	when a.middle is not null
    		then a.[first]+' '+a.middle+' '+a.[last] 
    	end
 end as applicant,   
 case 
   when aa.apno=a.apno
     then address1
   else
     case 
        when a.addr_num is null and a.addr_dir is null
     	     then a.addr_street
	when a.addr_num is null and a.addr_dir is not null
		then a.addr_dir+' '+a.addr_street
	when a.addr_num is not null and a.addr_dir is null
		then a.addr_num+' '+a.addr_street
	else a.addr_num+' '+a.addr_dir+' '+a.addr_street
        end
   end as address1,
  case 
    when aa.apno=a.apno
      then aa.city
    else a.city
    end as city,
  case
    when aa.apno=a.apno
      then aa.state
    else a.state
    end as state,
  case
    when aa.apno=a.apno
      then aa.zip
    else a.zip
    end as zip      
from appl a inner join client c on a.clno=c.clno
            left join adverseaction aa ON a.apno = aa.apno
where  ssn=@ssn 
   and  ssn!=''
 order  by a.apno desc
end
             
Set @ErrorCode=@@Error
If (@ErrorCode<>0)
  Begin
  RollBack Transaction
  Return (-@ErrorCode)
  End
Else
  Commit Transaction

