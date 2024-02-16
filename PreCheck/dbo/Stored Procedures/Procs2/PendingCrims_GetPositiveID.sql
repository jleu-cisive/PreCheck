

CREATE PROCEDURE [dbo].[PendingCrims_GetPositiveID]
@apno int
AS
BEGIN
SELECT TOP (1) [t0].[Report]
FROM [Credit] AS [t0]
WHERE ([t0].[APNO] = @apno) AND ([t0].[RepType] = 'S')
ORDER BY [t0].[Last_Updated] DESC

END

