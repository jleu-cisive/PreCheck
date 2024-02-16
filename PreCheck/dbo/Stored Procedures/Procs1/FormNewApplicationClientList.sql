CREATE Proc dbo.FormNewApplicationClientList
as 
declare @ErrorCode int

begin transaction
set @ErrorCode=@@Error

select Name, CLNO,clnoname from (SELECT '' Name, 0 CLNO, '' clnoname 
UNION ALL SELECT Name, CLNO, CONVERT(varchar(10), CLNO) + '  ' + '|' + '  ' + 
Name  AS clnoname FROM dbo.Client where IsInactive = 0 and IsOnCreditHold = 0 and NonClient = 0)Qry order by Name;
 
                            

If (@ErrorCode<>0)
  Begin
  RollBack Transaction
  Return (-@ErrorCode)
  End
Else
  Commit Transaction