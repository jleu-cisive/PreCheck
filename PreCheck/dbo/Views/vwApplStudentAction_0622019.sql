

CREATE VIEW [dbo].[vwApplStudentAction_0622019]
as
	SELECT
		ASA.APNO,
		FirstName = a.First,
		LastName = a.Last,
		[Status] = sa.StudentAction,
		ClientId = s.CLNO,
		ClientName = s.Name,
		ClinicId = c.CLNO,
		ClinicName = c.Name,
		DateAssigned = ASA.DateHospitalAssigned,
		LastUpdateDate = asa.DateStatusSet,
		asa.ModifyDate
	FROM
	dbo.ApplStudentAction asa
	INNER JOIN dbo.Appl A
		ON ASA.APNO=A.APNO
	INNER JOIN dbo.Client S
		ON A.CLNO=S.CLNO
	INNER JOIN dbo.Client C
		ON ASA.CLNO_Hospital = C.CLNO
	INNER JOIN dbo.refStudentAction sa
		ON asa.StudentActionID=sa.StudentActionID
	WHERE ISNULL(asa.IsActive,1)=1 AND asa.StudentActionID>0
