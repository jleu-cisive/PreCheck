






CREATE PROCEDURE [dbo].[DeleteApplication]
(
	@APNO int,@user varchar(8) = null
)
AS
SET NOCOUNT ON

IF (SELECT COUNT(*) FROM dbo.InvDetail WHERE APNO = @APNO AND Billed = 1) = 0
BEGIN

--added 7/10/07 for deletion archiving
INSERT INTO Precheck_Archive.dbo.Crim_Deleted SELECT *,@user,getdate() FROM Crim  where APNO = @APNO
INSERT INTO Precheck_Archive.dbo.Civil_Deleted SELECT *,@user,getdate() FROM Civil where APNO = @APNO
INSERT INTO Precheck_Archive.dbo.Credit_Deleted SELECT *,@user,getdate() FROM Credit where APNO = @APNO
INSERT INTO Precheck_Archive.dbo.Empl_Deleted SELECT *,@user,getdate() FROM Empl where APNO = @APNO
INSERT INTO Precheck_Archive.dbo.Educat_Deleted SELECT *,@user,getdate() FROM Educat where APNO = @APNO
INSERT INTO Precheck_Archive.dbo.ProfLic_Deleted SELECT *,@user,getdate() FROM ProfLic where APNO = @APNO
INSERT INTO Precheck_Archive.dbo.PersRef_Deleted SELECT *,@user,getdate() FROM PersRef where APNO = @APNO
INSERT INTO Precheck_Archive.dbo.DL_Deleted SELECT *,@user,getdate() FROM DL where APNO = @APNO
INSERT INTO Precheck_Archive.dbo.MedInteg_Deleted SELECT *,@user,getdate() FROM MedInteg where APNO = @APNO
INSERT INTO Precheck_Archive.dbo.Appl_Deleted SELECT *,@user,getdate() FROM Appl where APNO = @APNO
--INSERT INTO Precheck_Archive.dbo.ApplStudentAction_Deleted SELECT *,@user,getdate() FROM ApplStudentAction where APNO = @APNO

	DELETE FROM Iris_ws_criminal_Case where screening_id in (select id from iris_ws_screening where crim_Id in (SELECT crimid from crim where apno = @APNO))
	DELETE from Iris_ws_screening where crim_Id in (SELECT crimid from crim where apno = @APNO)
	DELETE from iris_ws_order where applicant_id = @APNO
	DELETE FROM dbo.InvDetail WHERE APNO = @APNO --EXEC dbo.DeleteInvDetail @APNO
	DELETE FROM dbo.Crim WHERE APNO = @APNO		--EXEC dbo.DeleteApplCrim @APNO
	DELETE FROM dbo.Civil WHERE APNO = @APNO	--EXEC dbo.DeleteApplCivil @APNO
	DELETE FROM dbo.Credit WHERE APNO = @APNO	--EXEC dbo.DeleteApplCredit @APNO
	DELETE FROM dbo.Empl WHERE APNO = @APNO		--EXEC dbo.DeleteApplEmpl @APNO
	DELETE FROM dbo.Educat WHERE APNO = @APNO	--EXEC dbo.DeleteApplEducat @APNO
	DELETE FROM dbo.ProfLic WHERE APNO = @APNO	--EXEC dbo.DeleteApplProfLic @APNO
	DELETE FROM dbo.PersRef WHERE APNO = @APNO	--EXEC dbo.DeleteApplPersRef @APNO
	DELETE FROM dbo.DL WHERE APNO = @APNO		--EXEC dbo.DeleteApplDL @APNO
	DELETE FROM dbo.MedInteg WHERE APNO = @APNO	--EXEC dbo.DeleteApplMedInteg @APNO
	--DELETE FROM dbo.ApplStudentAction WHERE APNO = @APNO	
	DELETE FROM dbo.ApplAddress WHERE APNO = @APNO
	DELETE FROM dbo.ApplAlias WHERE APNO = @APNO
	DELETE FROM dbo.ApplAdjudicationAuditTrail where APNO = @APNO
	DELETE FROM dbo.Appl WHERE APNO = @APNO		--EXEC dbo.DeleteAppl @APNO

	SELECT 1 AS IsDeleted
END
ELSE
	SELECT 0 AS IsDeleted

SET NOCOUNT OFF





