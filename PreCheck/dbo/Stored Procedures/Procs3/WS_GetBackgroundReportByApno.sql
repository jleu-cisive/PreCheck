CREATE PROCEDURE dbo.WS_GetBackgroundReportByApno(@apno int)
as
--DECLARE @apno int = 4193829
SELECT  BackgroundReport FROM backgroundreports.dbo.backgroundreport WHERE (BackgroundReportID = (SELECT MAX(backgroundreportid) FROM backgroundreports.dbo.backgroundreport WHERE apno = @apno)) AND (Apno = @apno)
