

CREATE PROCEDURE dbo.StateBoardMatchInsert @StateBoardDisciplinaryRunID int AS

SET NOCOUNT ON


-- ===================Rabbit.HEVN DATABASE MATCH======================
INSERT INTO StateBoardMatch
   (EmployeeFirstName,EmployeeMiddleName,EmployeeLastName,EmployeeSSN,CLNO,StateBoardLicenseType,StateBoardLicenseNumber,StateBoardLicenseState,CredentCheckBis,StateBoardDisciplinaryRunID)

SELECT DISTINCT 
                      HE.[First], HE.Middle, HE.[Last], HE.SSN, HE.EmployerID, dbo.VWLicenseAuthority.LicenseTypes,dbo.StateBoardLicenseNumber.LicenseNumber, dbo.VWLicenseAuthority.SourceState, 
                      'C' AS Expr1, dbo.StateBoardDisciplinaryRun.StateBoardDisciplinaryRunID
FROM         dbo.VWLicenseAuthority INNER JOIN
                      dbo.StateBoardDisciplinaryRun INNER JOIN
                      dbo.StateBoardLicenseNumber ON 
                      dbo.StateBoardDisciplinaryRun.StateBoardDisciplinaryRunID = dbo.StateBoardLicenseNumber.StateBoardDisciplinaryRunID INNER JOIN
                      Rabbit.HEVN.dbo.License HL INNER JOIN
                      Rabbit.HEVN.dbo.EmployeeRecord HE ON HL.EmployeeRecordID = HE.EmployeeRecordID ON 
                      dbo.StateBoardLicenseNumber.LicenseNumber = HL.Number ON 
                      dbo.VWLicenseAuthority.StateBoardSourceID = dbo.StateBoardDisciplinaryRun.StateBoardSourceInfoID
WHERE     (dbo.StateBoardDisciplinaryRun.StateBoardDisciplinaryRunID = @StateBoardDisciplinaryRunID)


-- ===================BIS LICENSE DATABASE MATCH======================
INSERT INTO StateBoardMatch
   (EmployeeFirstName,EmployeeMiddleName,EmployeeLastName,EmployeeSSN,CLNO,StateBoardLicenseType,StateBoardLicenseNumber,StateBoardLicenseState,CredentCheckBis,Apno,Apdate,StateBoardDisciplinaryRunID)
SELECT DISTINCT 
                      A.[First], A.Middle, A.[Last], A.SSN, A.CLNO,dbo.VWLicenseAuthority.LicenseTypes, dbo.StateBoardLicenseNumber.LicenseNumber, dbo.VWLicenseAuthority.SourceState, 'B' AS Expr1, 
                      A.APNO, A.ApDate, dbo.StateBoardDisciplinaryRun.StateBoardDisciplinaryRunID
FROM         dbo.VWLicenseAuthority INNER JOIN
                      dbo.StateBoardDisciplinaryRun INNER JOIN
                      dbo.StateBoardLicenseNumber ON 
                      dbo.StateBoardDisciplinaryRun.StateBoardDisciplinaryRunID = dbo.StateBoardLicenseNumber.StateBoardDisciplinaryRunID INNER JOIN
                      dbo.ProfLic P INNER JOIN
                      dbo.Appl A ON P.Apno = A.APNO AND P.Apno = A.APNO ON dbo.StateBoardLicenseNumber.LicenseNumber = P.Lic_No ON 
                      dbo.VWLicenseAuthority.StateBoardSourceID = dbo.StateBoardDisciplinaryRun.StateBoardSourceInfoID
WHERE     (dbo.StateBoardDisciplinaryRun.StateBoardDisciplinaryRunID = @StateBoardDisciplinaryRunID)
