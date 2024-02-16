
-- =============================================
-- Author:		Gaurav
-- Create date: 10/29/2019
-- Description:	Report on CDCChangeLogDetail
-- =============================================
-- select * from [Report].[GetCDCChangeLogDetail]('10/1/2018','10/25/2019',4)
create  function [Report].[GetCDCChangeLogDetail](@StartTime SMALLDATETIME,@EndTime SMALLDATETIME, @ChangeLogId INT null)
RETURNS @ScanInfo TABLE(ReportCode Varchar(20),ReportValue int,UniqueId VARCHAR(20) NULL, UniqueIdDescription VARCHAR(50) null) 
AS	
BEGIN
	
	INSERT INTO @ScanInfo(ReportCode, ReportValue, UniqueId, UniqueIdDescription)
	SELECT 
	'ACT_CDC', COUNT(D.ChangeLogDetailId), CAST(L.ChangeLogId AS VARCHAR(20)), 
	CONCAT(L.TableName,'.',L.ColumnName)
	FROM dbo.CDCChangeLog L 
		left outer JOIN dbo.CDCChangeLogDetail D  ON l.ChangeLogId=D.ChangeLogId 
		AND D.ChangeDate BETWEEN @StartTime AND @EndTime
	WHERE L.ChangeLogId=ISNULL(@ChangeLogId,L.ChangeLogId)
	GROUP BY L.ChangeLogId,L.TableName,L.ColumnName
	

	RETURN
END
