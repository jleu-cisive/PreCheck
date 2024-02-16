
Create Proc dbo.FormAdverseCreateNew_Select
@apno int
As
Declare @ErrorCode int

Begin Transaction
SELECT APNO, Last, First, Middle, SSN, Addr_Num, Addr_Dir, 
       Addr_Street, Addr_StType, Addr_Apt, City, State, Zip 
  FROM Appl 
 WHERE APNO=@Apno
            
Set @ErrorCode=@@Error
If (@ErrorCode<>0)
  Begin
  RollBack Transaction
  Return (-@ErrorCode)
  End
Else
  Commit Transaction
  

