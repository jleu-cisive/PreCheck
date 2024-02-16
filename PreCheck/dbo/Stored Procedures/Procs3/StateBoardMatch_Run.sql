



CREATE PROCEDURE [dbo].[StateBoardMatch_Run] 
(
@StateBoardSourceID int
)
AS
SET NOCOUNT ON


-- ===================Rabbit.HEVN DATABASE MATCH======================
INSERT INTO StateBoardMatch
   (EmployeeFirstName,EmployeeMiddleName,EmployeeLastName,EmployeeSSN,CLNO,StateBoardLicenseType,StateBoardLicenseNumber,StateBoardLicenseState,CredentCheckBis,StateBoardDisciplinaryRunID)

SELECT DISTINCT 
                      HE.[First], HE.Middle, HE.[Last], HE.SSN, HE.EmployerID, dbo.StateBoardFinalData.LicenseType, dbo.StateBoardFinalData.LicenseNumber, dbo.StateBoardFinalData.State, 
                      'C' AS Expr1, dbo.StateBoardFinalData.StateBoardDisciplinaryRunID
FROM			      dbo.StateBoardFinalData  INNER JOIN
                      Rabbit.HEVN.dbo.License HL ON  
					  dbo.StateBoardFinalData.LicenseNumber = HL.Number AND 
					 (dbo.StateBoardFinalData.State = HL.IssuingState) AND 
				     (dbo.StateBoardFinalData.LicenseType = HL.Type) INNER JOIN
					  Rabbit.HEVN.dbo.EmployeeRecord HE ON
					  HL.EmployeeRecordID = HE.EmployeeRecordID 
					
WHERE     dbo.StateBoardFinalData.StateBoardSourceID = @StateBoardSourceID
		  
		 


-- ===================BIS LICENSE DATABASE MATCH======================
INSERT INTO StateBoardMatch
   (EmployeeFirstName,EmployeeMiddleName,EmployeeLastName,EmployeeSSN,CLNO,StateBoardLicenseType,StateBoardLicenseNumber,StateBoardLicenseState,CredentCheckBis,Apno,Apdate,StateBoardDisciplinaryRunID)
SELECT DISTINCT 
                      A.[First], A.Middle, A.[Last], A.SSN, A.CLNO, P.Lic_Type, dbo.StateBoardFinalData.LicenseNumber, dbo.StateBoardFinalData.State, 'B' AS Expr1, 
                      A.APNO, A.ApDate, dbo.StateBoardFinalData.StateBoardDisciplinaryRunID
FROM				  dbo.ProfLic P INNER JOIN
					  dbo.StateBoardFinalData ON  dbo.StateBoardFinalData.LicenseNumber = P.Lic_No AND 
					 (dbo.StateBoardFinalData.State = P.State) AND 
					 (dbo.StateBoardFinalData.LicenseType = P.Lic_Type) INNER JOIN 
					  dbo.Appl A ON 
					  P.Apno = A.APNO 
					 
WHERE     dbo.StateBoardFinalData.StateBoardSourceID = @StateBoardSourceID
		  
		

SET NOCOUNT OFF




