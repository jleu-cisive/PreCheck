
-- ===============================================================
-- Author:		Gaurav
-- Create date: 10/25/2019
-- Description:	Function to return summary of CDCChangeLogSummary
-- select * from [Report].[GetCDCChangeLogSummary]('10/5/2019','10/6/2019')
-- ===============================================================

CREATE  FUNCTION [Report].[GetCDCChangeLogSummary](@StartTime SMALLDATETIME,@EndTime SMALLDATETIME)
RETURNS @ChangeSummary TABLE(ReportCode Varchar(20),ReportValue VARCHAR(1000),UniqueId VARCHAR(20) NULL, UniqueIdDescription VARCHAR(50) null) 
AS	
BEGIN
	--DECLARE @ChangeSummary Table(ID INT Identity(1,1),ReportCode Varchar(20),ReportValue VARCHAR(1000),UniqueId VARCHAR(20) NULL, UniqueIdDescription VARCHAR(50) NULL)
	
	INSERT INTO @ChangeSummary(ReportCode,ReportValue,UniqueId,UniqueIdDescription)
	SELECT 'ACT', COUNT(*), NULL, 'CDCChangeLogDetailId'
	FROM dbo.CDCChangeLogDetail D WITH (NOLOCK)
		INNER JOIN dbo.CDCChangeLog L  ON L.ChangeLogId=D.ChangeLogId
	WHERE D.ChangeDate BETWEEN @StartTime AND @EndTime
	RETURN 
END