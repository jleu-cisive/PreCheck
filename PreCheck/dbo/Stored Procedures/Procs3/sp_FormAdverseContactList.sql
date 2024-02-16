CREATE Proc dbo.sp_FormAdverseContactList
As
Declare @ErrorCode int

Begin Transaction
select acl.AdverseContactLogID As ACLID,acl.AdverseActionID As AAID,acl.UserID,acl.APNO,
       acl.ApplicantName,acl.SSN,acl.EmployerName As Client,
       acl.AdverseContactMethodID As ACMID,refacm.Method As ContactMethod,
       Convert(char(10),acl.[Date],101) As ContactDate,
       acl.Comments,acl.AdverseSummaryID As ASID,refacs.Summary As AdverseSummary     
FROM AdverseContactLog acl LEFT OUTER JOIN refAdverseContactMethod refacm ON acl.AdverseContactMethodID = refacm.AdverseContactMethodID LEFT OUTER JOIN refAdverseContactSummary refacs ON acl.AdverseSummaryID = refacs.AdverseContactSummaryID

Set @ErrorCode=@@Error
If (@ErrorCode<>0)
  Begin
  RollBack Transaction
  Return (-@ErrorCode)
  End
Else
  Commit Transaction
  Return (0)