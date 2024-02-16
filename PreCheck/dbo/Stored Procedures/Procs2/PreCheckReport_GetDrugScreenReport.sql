-- =============================================
-- Created By: Dongmei He
-- Date: 01/31/2020
-- Description: Get drugtest report
-- =============================================

  CREATE PROCEDURE [dbo].[PreCheckReport_GetDrugScreenReport]
   (
   	@DrugtestReportId INT
   )
  AS
  BEGIN
		SELECT TID AS ID,
		       PDFReport AS DrugScreenReportBinary,
			   Reason AS DrugScreenStatus,
			   AddedOn AS CreateDate
		  FROM OCHS_PDFReports  
		 WHERE TID=@DrugtestReportId order by CreateDate desc 
		   
 END
