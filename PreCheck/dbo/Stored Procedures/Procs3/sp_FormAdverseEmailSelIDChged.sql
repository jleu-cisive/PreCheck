CREATE Proc dbo.sp_FormAdverseEmailSelIDChged
  @AETID int
As
Declare @ErrorCode int

Begin Transaction
select aet.AdverseEmailtemplateID As AATID,refas.refAdverseStatusID as refASID,
       refas.Status as Status,
       aet.[From],aet.Subject1,aet.Subject2,aet.Body1,aet.Body2
FROM AdverseemailTemplate aet LEFT OUTER JOIN refAdverseStatus refas ON aet.refAdverseStatusID = refas.refAdverseStatusID
WHERE aet.AdverseEmailTemplateID = @AETID
          
Set @ErrorCode=@@Error
If (@ErrorCode<>0)
  Begin
  RollBack Transaction
  Return (-@ErrorCode)
  End
Else
  Commit Transaction
  Return (0)