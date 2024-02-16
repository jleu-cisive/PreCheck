CREATE Proc dbo.FormNewApplicationLicTypesSelect
as 
declare @ErrorCode int

begin transaction
set @ErrorCode=@@Error

select Lic_Type from (SELECT  '     ' Lic_Type 
UNION ALL SELECT Lic_Type FROM dbo.LicTypes) Qry

                            

If (@ErrorCode<>0)
  Begin
  RollBack Transaction
  Return (-@ErrorCode)
  End
Else
  Commit Transaction