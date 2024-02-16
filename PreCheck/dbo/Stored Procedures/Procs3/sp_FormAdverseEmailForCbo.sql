
Create Proc dbo.sp_FormAdverseEmailForCbo
@purpose varchar(200),
@tableName varchar(100)
As
Declare @ErrorCode int

Begin Transaction

if @tableName != ''
   select aet.AdverseEmailtemplateID As AATID,
          aet.refAdverseStatusID as refID,refas.Status as EmailType,
          aet.[From],aet.Subject1,aet.Subject2,aet.Body1,aet.Body2,
          aet.purpose
   from   AdverseemailTemplate aet, refAdverseStatus refas
   where  aet.refAdverseStatusID=refas.refAdverseStatusID
     and  aet.Purpose=@purpose
else if @tableName = ''
  select aet.AdverseEmailtemplateID As AATID,
          aet.refAdverseStatusID as refID,aet.[text] as EmailType,
          aet.[From],aet.Subject1,aet.Subject2,aet.Body1,aet.Body2,aet.purpose         
   from   AdverseemailTemplate aet
   where  aet.Purpose=@purpose
          
Set @ErrorCode=@@Error
If (@ErrorCode<>0)
  Begin
  RollBack Transaction
  Return (-@ErrorCode)
  End
Else
  Commit Transaction
  --Return (0)

