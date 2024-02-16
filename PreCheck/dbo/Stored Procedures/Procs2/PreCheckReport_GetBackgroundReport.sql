-- =============================================
-- Created By: Dongmei He
-- Date: 01/31/2020
-- Description: Get background report
-- =============================================
-- EXEC [] null,0,null,null,null,null,268118,3789677,1

  Create PROCEDURE [dbo].[PreCheckReport_GetBackgroundReport]
   (@APNO INT,
	@BackgroundReportId INT
	)
  AS
  BEGIN
		SELECT BackgroundReportId AS ID, 
			   Backgroundreport AS BackgroundReportBinary, 
			   CreateDate 
		  FROM Backgroundreports..Backgroundreport  
		 WHERE Apno=@APNO 
		   AND Backgroundreportid = @BackgroundReportid 
		   AND Apstatus='F' 
	  ORDER BY Createdate DESC
 END
