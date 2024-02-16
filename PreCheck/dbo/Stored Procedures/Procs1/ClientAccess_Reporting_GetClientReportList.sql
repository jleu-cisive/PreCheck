
--EXEC [ClientAccess_Reporting_GetClientReportList] 12444
-- =============================================
CREATE PROCEDURE [dbo].[ClientAccess_Reporting_GetClientReportList]
@clno int
AS

SET NOCOUNT ON

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

select * from (
SELECT [t1].[ProcedureName], [t1].[DisplayName], [t1].[Description], [t1].[ParameterNames], [t1].[ParameterTypes], [t1].[ParameterDisplay], null as 'LastParameters', -1 as 'MapID', 1 as 'AllClients', [t1].ClientAccessReportID
FROM [ClientAccess_Report] AS [t1]
WHERE ([t1].[AllClients] = 1)

union 

SELECT [t1].[ProcedureName], [t1].[DisplayName], [t1].[Description], [t1].[ParameterNames], [t1].[ParameterTypes], [t1].[ParameterDisplay], [t0].[LastParameters], [t0].[ClientAccessReportMapID] as 'MapID', 0 as 'AllClients', [t1].ClientAccessReportID
FROM [ClientAccess_ReportMap] AS [t0], [ClientAccess_Report] AS [t1]
WHERE ([t0].[CLNO] = @clno) AND ([t1].[ClientAccessReportID] = [t0].[ClientAccessReportID])
) [TA]
order by [TA].ClientAccessReportID

SET ANSI_NULLS ON

SET TRANSACTION ISOLATION LEVEL READ COMMITTED

SET NOCOUNT OFF
