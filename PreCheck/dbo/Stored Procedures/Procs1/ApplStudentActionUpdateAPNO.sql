CREATE PROCEDURE [dbo].[ApplStudentActionUpdateAPNO] 
AS
SET NOCOUNT ON

update	dbo.ApplStudentAction 
set		ApplStudentAction.Apno=T1.apno
	, ApplStudentAction.DateHospitalAssigned=getdate() 
from	(select appl.apno 
			, clientschoolhospital.clno_school
			, applstudentaction.ssn 
			, applstudentaction.clno_hospital
		from dbo.ApplStudentAction (nolock)
			join dbo.clientschoolhospital  (nolock) on clientschoolhospital.clno_hospital = ApplStudentAction.clno_hospital 
			join dbo.appl  (nolock) on appl.clno=clientschoolhospital.clno_school
		where appl.ssn=applstudentaction.ssn 
			--and clientschoolhospital.clno_hospital=applstudentaction.clno_hospital
		)T1 
where	T1.clno_hospital=ApplStudentAction.clno_hospital 
	and applstudentaction.ssn=T1.ssn

SET NOCOUNT OFF