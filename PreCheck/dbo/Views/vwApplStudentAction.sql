

CREATE VIEW [dbo].[vwApplStudentAction]
AS
SELECT        asa.APNO, A.First AS FirstName, A.Last AS LastName, 
                         CASE WHEN asa.StudentActionId = 0 THEN '' WHEN asa.StudentActionId = 1 THEN 'Accepted' WHEN asa.StudentActionId = 2 THEN 'Adverse Action' WHEN asa.StudentActionId = 3 THEN 'Ineligible' WHEN asa.StudentActionId = 4
                          THEN 'Not Accepted' END AS Status, ActionId = sa.StudentActionId, S.CLNO AS ClientId, S.Name AS ClientName, C.CLNO AS ClinicId, C.Name AS ClinicName, asa.DateHospitalAssigned AS DateAssigned, asa.DateStatusSet AS LastUpdateDate, 
                         asa.ModifyDate
FROM            dbo.ApplStudentAction AS asa INNER JOIN
                         dbo.Appl AS A ON asa.APNO = A.APNO INNER JOIN
                         dbo.Client AS S ON A.CLNO = S.CLNO INNER JOIN
                         dbo.Client AS C ON asa.CLNO_Hospital = C.CLNO INNER JOIN
                         dbo.refStudentAction AS sa ON asa.StudentActionID = sa.StudentActionID
WHERE        (ISNULL(asa.IsActive, 1) = 1) AND (asa.StudentActionID > 0)
