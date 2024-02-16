



CREATE PROCEDURE [dbo].[Bis3_MedIntegReportSection] @apno int AS

 DECLARE @CLNO INT, @Faciss_Lookup BIT 

 SELECT @CLNO = CLNO FROM Precheck.dbo.Appl WHERE APNO = @apno

 IF (SELECT COUNT(1) FROM PreCheck.dbo.ClientConfiguration WHERE  CLNO = @CLNO AND ConfigurationKey = 'Faciss-III_Lookup' AND Value='True') > 0
	Set @Faciss_Lookup = 1
 ELSE 
	Set @Faciss_Lookup = 0    


 SELECT  MedInteg.APNO,MedInteg.SectStat,SectStat.Description,  SectStat.LevelOfImportance, MedInteg.IsHidden, MedInteg.Report, @Faciss_Lookup Faciss_Lookup
 FROM   PreCheck.dbo.MedInteg MedInteg INNER JOIN PreCheck.dbo.SectStat SectStat ON MedInteg.SectStat=SectStat.Code
 WHERE  MedInteg.IsHidden=0 AND MedInteg.APNO=@Apno
 ORDER BY SectStat.LevelOfImportance DESC




