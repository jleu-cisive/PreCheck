
CREATE PROCEDURE [dbo].[SchoolAutolinkHospital] AS
INSERT INTO dbo.ApplStudentAction([APNO], [CLNO_Hospital], [StudentActionID],DateHospitalAssigned)
SELECT      dbo.Appl.APNO,dbo.ClientSchoolHospital.CLNO_Hospital AS HOSP,0,getDate()
FROM         dbo.Client INNER JOIN
                      dbo.Appl ON dbo.Client.CLNO = dbo.Appl.CLNO
	     INNER JOIN
                      dbo.ClientSchoolHospital ON dbo.Client.CLNO = dbo.ClientSchoolHospital.CLNO_School
WHERE     (AutoLinkHospitals = 1) and (dbo.ClientSchoolHospital.CLNO_Hospital is not null)
AND       (dbo.Appl.APNO + dbo.ClientSchoolHospital.CLNO_Hospital) not in (Select ([APNO]+[CLNO_Hospital]) from dbo.ApplStudentAction)

