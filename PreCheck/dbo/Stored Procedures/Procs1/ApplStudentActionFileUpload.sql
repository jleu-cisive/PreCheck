

CREATE PROCEDURE [dbo].[ApplStudentActionFileUpload] 
AS
SET NOCOUNT ON

INSERT	dbo.ApplStudentAction (ssn, lastname, firstname, clno_hospital, StudentActionID, isactive)
SELECT	ssn, lastname, firstname, clno_hospital, 0, isactive
FROM	dbo.tmpApplStudentAction 
WHERE	CONVERT(varchar, clno_hospital) + ISNULL(ssn, '') NOT IN (SELECT CONVERT(varchar, clno_hospital) + ISNULL(ssn, '') FROM dbo.ApplStudentAction)

UPDATE	dbo.ApplStudentAction
SET		ssn = (SELECT TOP 1 ssn FROM tmpApplStudentAction WHERE dbo.ApplStudentAction.ssn = tmpApplStudentAction.ssn AND ApplStudentAction.clno_hospital = tmpApplStudentAction.clno_hospital)
		, clno_hospital = (SELECT TOP 1 clno_hospital FROM dbo.tmpApplStudentAction WHERE ApplStudentAction.ssn = tmpApplStudentAction.ssn AND ApplStudentAction.clno_hospital = tmpApplStudentAction.clno_hospital)
		, isactive = (SELECT TOP 1 isactive FROM dbo.tmpApplStudentAction WHERE ApplStudentAction.ssn = tmpApplStudentAction.ssn AND ApplStudentAction.clno_hospital = tmpApplStudentAction.clno_hospital)
WHERE	EXISTS (SELECT ssn, clno_hospital, isactive FROM dbo.tmpApplStudentAction WHERE ApplStudentAction.ssn = tmpApplStudentAction.ssn AND ApplStudentAction.clno_hospital = tmpApplStudentAction.clno_hospital)

SET NOCOUNT OFF


set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON

