CREATE VIEW dbo.v_WorkCalendar
AS
SELECT CAST(Dateid AS Datetime) AS [DATE], YEAR(CAST(Dateid AS Datetime)) AS [Year], DATENAME(QUARTER,CAST(Dateid AS Datetime)) AS [QTR], DATENAME(MONTH,CAST(Dateid AS Datetime)) AS [MONTH], DATENAME(WK,CAST(Dateid AS Datetime)) AS Week_of_Year, IsWeekDay
, IsWorkDay  
FROM HEVN.dbo.WorkCalendar 