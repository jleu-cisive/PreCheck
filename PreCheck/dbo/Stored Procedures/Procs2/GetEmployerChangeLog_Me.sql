-- =============================================
-- Author:		<Liel Alimole>
-- Create date: <05/20/2013>
-- Description:	<Gets change log of employer>
-- =============================================
--[dbo].[GetEmployerChangeLog_Me] '07/08/2019','07/10/2019'
CREATE PROCEDURE [dbo].[GetEmployerChangeLog_Me]
	-- Add the parameters for the stored procedure here
	@StartDate DateTime = getdate,
	@EndDate DateTime = getdate
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	-- Region Parameters
DECLARE @p0 VarChar(1000) = 'Empl.SectStat'
DECLARE @p1 VarChar(1000) = '9'
DECLARE @p2 VarChar(1000) = '0'

-- EndRegion
SELECT [t2].[APNO], [t2].[ApDate], [t3].[Name] AS [ClientName], [t2].[CLNO] AS [ClientID], [t1].[Employer], [t1].web_status, (
    SELECT [t5].[Description]
    FROM (
        SELECT TOP (1) [t4].[Description]
        FROM [SectStat] AS [t4]
        WHERE (CONVERT(NVarChar(1),[t4].[Code])) = [t0].[NewValue]
        ) AS [t5]
    ) AS [FinalStatus], [t1].[Investigator] AS [UserModuleIn], [t0].[UserID] AS [ClosedBy], [t0].[ChangeDate] AS [ChangedDate]
FROM [ChangeLog] AS [t0], [Empl] AS [t1], [Appl] AS [t2], [Client] AS [t3]
WHERE (([t0].[TableName] = @p0) AND (([t0].[OldValue] = @p1) OR ([t0].[OldValue] = @p2))) AND ([t0].[NewValue] <> @p2) 
AND ([t0].[NewValue] <> @p1) AND
(CAST([t0].[ChangeDate] as DATE) >= CAST(@StartDate as DATE)) AND (CAST([t0].[ChangeDate] as DATE) <= CAST(@EndDate as DATE)) 
AND (([t1].[EmplID]) = [t0].[ID]) AND ([t2].[APNO] = [t1].[Apno]) AND ([t3].[CLNO] = [t2].[CLNO])
END

