
CREATE VIEW [Enterprise].[vwReleaseForm_Order]
AS

SELECT ApplicantNumber APNO, A.LastName, A.FirstName, D.ReleaseFormId FROM Enterprise.dbo.[Applicant] A 
INNER JOIN Enterprise.dbo.[ApplicantDocument] D ON D.ApplicantId = A.ApplicantId 

