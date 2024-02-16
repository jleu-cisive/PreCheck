
CREATE VIEW [dbo].[vwBackgroundReport]
AS
SELECT 
	[BackgroundReportID],
	OrderId = APNO,
	ReportImage = [BackgroundReport],
	[CreateDate],
	OrderStatus = [ApStatus],
	IsReal = [RealReport]
FROM [BackgroundReports].[dbo].[BackgroundReport]

