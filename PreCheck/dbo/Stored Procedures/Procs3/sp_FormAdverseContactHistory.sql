
Create Proc dbo.sp_FormAdverseContactHistory
  @APNO int
As
Declare @ErrorCode int

Begin Transaction
select AdverseContactLogID As ACID,AdverseActionID As AAID,UserID,APNO,
       ApplicantName,SSN,EmployerName As Client,Comments,Convert(char(10),[Date],101)As ContactDate--CLNO, 
from   AdverseContactLog 
where  APNO=@APNO 
             
Set @ErrorCode=@@Error
If (@ErrorCode<>0)
  Begin
  RollBack Transaction
  Return (-@ErrorCode)
  End
Else
  Commit Transaction
  Return (0)


