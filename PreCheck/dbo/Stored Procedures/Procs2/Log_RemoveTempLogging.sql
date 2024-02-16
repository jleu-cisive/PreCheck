CREATE PROCEDURE [dbo].[Log_RemoveTempLogging]
AS
BEGIN
	Print N'Dropping Logging Temp Tables'
	DROP TABLE #tmpLogHeader;
	DROP TABLE #tmpTasksStatus;
	Print N'Dropping Logging Temp Tables Succeeded'
END
